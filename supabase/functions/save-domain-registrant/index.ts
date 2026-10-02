import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const headers={"Content-Type":"application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});

const required=(v:unknown)=>String(v??"").trim();
const emailRegex=/^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const countryRegex=/^[A-Z]{2}$/;

Deno.serve(async req=>{
  if(req.method==="OPTIONS") return new Response("ok",{headers});
  if(req.method!=="POST") return json({error:"Method not allowed"},405);
  const auth=req.headers.get("Authorization");
  if(!auth) return json({error:"Authentication required"},401);

  try{
    const token=auth.replace(/^Bearer\s+/i,"");
    const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
    const {data:{user},error:userError}=await admin.auth.getUser(token);
    if(userError||!user) return json({error:"Authentication required"},401);

    const body=await req.json().catch(()=>({}));
    const tenantId=required(body?.tenant_id);
    const orderId=required(body?.order_id);
    if(!tenantId||!orderId) return json({error:"tenant_id and order_id are required"},400);

    const {data:membership}=await admin.from("tenant_memberships")
      .select("tenant_id,role_code,status")
      .eq("tenant_id",tenantId).eq("user_id",user.id).eq("status","active").maybeSingle();
    if(!membership) return json({error:"You do not have access to this TradeFlow workspace."},403);

    const {data:order,error:orderError}=await admin.from("tenant_domain_orders")
      .select("id,tenant_id,hostname,status,retail_amount,currency,metadata")
      .eq("id",orderId).eq("tenant_id",tenantId).maybeSingle();
    if(orderError||!order) return json({error:"Domain order not found."},404);
    if(order.status!=="payment_confirmed" && order.status!=="registrant_details_saved")
      return json({error:"This domain order is not ready for registrant details."},409);

    const registrant={
      registrant_name:required(body?.registrant_name),
      organisation:required(body?.organisation)||null,
      address_line1:required(body?.address_line1),
      address_line2:required(body?.address_line2)||null,
      city:required(body?.city),
      region:required(body?.region)||null,
      postal_code:required(body?.postal_code),
      country_code:required(body?.country_code).toUpperCase(),
      email:required(body?.email).toLowerCase(),
      phone:required(body?.phone)
    };

    if(!registrant.registrant_name||!registrant.address_line1||!registrant.city||!registrant.postal_code||!registrant.email||!registrant.phone)
      return json({error:"Please complete all required registrant fields."},400);
    if(!emailRegex.test(registrant.email)) return json({error:"Enter a valid registrant email address."},400);
    if(!countryRegex.test(registrant.country_code)) return json({error:"Select a valid country."},400);

    const {data:saved,error:savedError}=await admin.from("tenant_domain_registrants")
      .upsert({tenant_id:tenantId,domain_order_id:orderId,...registrant,confirmed_at:new Date().toISOString()},{onConflict:"domain_order_id"})
      .select("id,domain_order_id,confirmed_at")
      .single();
    if(savedError) return json({error:"Unable to save registrant details.",details:savedError.message},500);

    await admin.from("tenant_domain_orders").update({
      status:"registrant_details_saved",
      metadata: {registrant_details_saved:true, registrant_email:registrant.email}
    }).eq("id",orderId);

    return json({status:"SUCCESS",order_id:orderId,hostname:order.hostname,registrant_id:saved.id,confirmed_at:saved.confirmed_at});
  }catch(e){
    return json({error:e instanceof Error?e.message:String(e)},500);
  }
});