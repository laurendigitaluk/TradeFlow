import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_SECRET_KEY=Deno.env.get("STRIPE_SECRET_KEY");
const headers={"Content-Type":"application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});

Deno.serve(async req=>{
  if(req.method==="OPTIONS") return new Response("ok",{headers});
  if(req.method!=="POST") return json({error:"Method not allowed"},405);
  const auth=req.headers.get("Authorization");
  if(!auth) return json({error:"Authentication required"},401);
  if(!STRIPE_SECRET_KEY) return json({error:"Stripe payment reconciliation is not configured."},503);

  try{
    const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
    const token=auth.replace(/^Bearer\s+/i,"");
    const {data:{user},error:userError}=await admin.auth.getUser(token);
    if(userError||!user) return json({error:"Authentication required"},401);

    const body=await req.json().catch(()=>({}));
    const tenantId=String(body?.tenant_id||"");
    const orderId=String(body?.order_id||"");
    if(!tenantId||!orderId) return json({error:"tenant_id and order_id are required"},400);

    const {data:membership}=await admin.from("tenant_memberships")
      .select("tenant_id").eq("tenant_id",tenantId).eq("user_id",user.id).eq("status","active").maybeSingle();
    if(!membership) return json({error:"You do not have access to this TradeFlow workspace."},403);

    const {data:order,error:orderError}=await admin.from("tenant_domain_orders")
      .select("id,tenant_id,hostname,status,retail_amount,currency,payment_provider,payment_reference,metadata")
      .eq("id",orderId).eq("tenant_id",tenantId).maybeSingle();
    if(orderError||!order) return json({error:"Domain order not found."},404);
    if(order.status==="payment_confirmed"||order.status==="registrant_details_saved"||order.status==="registered")
      return json({status:"CONFIRMED",order_id:order.id,order_status:order.status,hostname:order.hostname});

    if(order.payment_provider!=="stripe"||!String(order.payment_reference||"").startsWith("cs_"))
      return json({error:"This domain order does not have a valid Stripe Checkout session reference."},409);

    const stripeRes=await fetch("https://api.stripe.com/v1/checkout/sessions/"+encodeURIComponent(order.payment_reference),{
      headers:{Authorization:"Bearer "+STRIPE_SECRET_KEY}
    });
    const session=await stripeRes.json().catch(()=>null);
    if(!stripeRes.ok) return json({error:session?.error?.message||"Unable to verify the Stripe Checkout payment."},502);

    const metadata=session?.metadata||{};
    if(String(metadata.domain_order_id||"")!==order.id || String(metadata.tenant_id||"")!==order.tenant_id)
      return json({error:"Stripe Checkout metadata does not match this TradeFlow domain order."},409);

    const expectedAmount=Math.round(Number(order.retail_amount||0)*100);
    const paidAmount=Number(session?.amount_total||0);
    const paidCurrency=String(session?.currency||"").toUpperCase();
    if(session?.mode!=="payment") return json({error:"The Stripe Checkout session is not a payment session."},409);
    if(paidAmount!==expectedAmount || paidCurrency!==String(order.currency||"GBP").toUpperCase())
      return json({error:"Stripe payment amount or currency does not match the TradeFlow domain order."},409);

    if(session?.payment_status!=="paid"){
      return json({status:"PENDING",order_id:order.id,order_status:order.status,stripe_payment_status:session?.payment_status||null,stripe_session_status:session?.status||null});
    }

    const mergedMetadata={
      ...(order.metadata||{}),
      stripe_checkout_session_id:session.id,
      stripe_payment_status:session.payment_status,
      stripe_reconciled_at:new Date().toISOString(),
      stripe_customer_id:session.customer||null
    };
    const {error:updateError}=await admin.from("tenant_domain_orders").update({
      status:"payment_confirmed",
      payment_provider:"stripe",
      payment_reference:session.id,
      failure_reason:null,
      metadata:mergedMetadata,
      updated_at:new Date().toISOString()
    }).eq("id",order.id).eq("tenant_id",tenantId).eq("status","pending_payment");
    if(updateError) return json({error:updateError.message},500);

    return json({status:"CONFIRMED",order_id:order.id,order_status:"payment_confirmed",hostname:order.hostname});
  }catch(e){
    return json({error:e instanceof Error?e.message:String(e)},500);
  }
});