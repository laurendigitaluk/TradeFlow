import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const API_KEY=Deno.env.get("PORKBUN_API_KEY")!;
const SECRET=Deno.env.get("PORKBUN_SECRET_API_KEY")!;
const headers={"Content-Type":"application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});

Deno.serve(async req=>{
  if(req.method==="OPTIONS") return new Response("ok",{headers});
  if(req.method!=="POST") return json({error:"Method not allowed"},405);
  const auth=req.headers.get("Authorization");
  if(!auth) return json({error:"Authentication required"},401);
  try{
    const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
    const token=auth.replace(/^Bearer\s+/i,"");
    const {data:{user},error:userError}=await admin.auth.getUser(token);
    if(userError||!user) return json({error:"Authentication required"},401);

    const body=await req.json().catch(()=>({}));
    const tenantId=String(body?.tenant_id||"");
    const orderId=String(body?.order_id||"");
    if(!tenantId||!orderId) return json({error:"tenant_id and order_id are required"},400);

    const {data:member}=await admin.from("tenant_memberships").select("tenant_id").eq("tenant_id",tenantId).eq("user_id",user.id).eq("status","active").maybeSingle();
    if(!member) return json({error:"You do not have access to this TradeFlow workspace."},403);

    const {data:order}=await admin.from("tenant_domain_orders").select("id,tenant_id,hostname,tld,status,registrar_cost_usd,term_years,metadata").eq("id",orderId).eq("tenant_id",tenantId).maybeSingle();
    if(!order) return json({error:"Domain order not found."},404);
    if(order.status!=="registrant_details_saved") return json({error:"Save registrant details before validating registration."},409);

    const {data:registrant}=await admin.from("tenant_domain_registrants").select("id,registrant_name,organisation,address_line1,address_line2,city,region,postal_code,country_code,email,phone").eq("domain_order_id",orderId).eq("tenant_id",tenantId).maybeSingle();
    if(!registrant) return json({error:"Registrant details not found."},409);

    const requirementsRes=await fetch("https://api.porkbun.com/api/json/v3/domain/getRegistrationRequirements/"+encodeURIComponent(order.tld.replace(/^\./,"")),{headers:{"X-API-Key":API_KEY,"X-Secret-API-Key":SECRET}});
    const requirements=await requirementsRes.json().catch(()=>null);
    if(!requirementsRes.ok||requirements?.status!=="SUCCESS") return json({error:"Porkbun could not return registration requirements.",provider_code:requirements?.code||null},502);
    if(requirements.apiRegisterable===false) return json({error:"Porkbun does not allow this TLD to be registered through its API.",reason:requirements.notApiRegisterableReason||null},409);

    const missing=["registrant_name","address_line1","city","postal_code","country_code","email","phone"].filter(k=>!String(registrant[k]??"").trim());
    if(missing.length) return json({error:"Saved registrant data is incomplete for registration.",missing},409);

    const cost=Math.round(Number(order.registrar_cost_usd||0)*100);
    if(!Number.isFinite(cost)||cost<=0) return json({error:"The saved registrar cost is invalid."},409);
    if(Number(order.term_years||1)!==1) return json({error:"The current Porkbun registration path is limited to a one-year TEST registration.",term_years:order.term_years},409);

    const dryRes=await fetch("https://api.porkbun.com/api/json/v3/domain/create/"+encodeURIComponent(order.hostname),{
      method:"POST",
      headers:{"X-API-Key":API_KEY,"X-Secret-API-Key":SECRET,"Content-Type":"application/json","Idempotency-Key":"tradeflow-dryrun-"+order.id},
      body:JSON.stringify({cost,agreeToTerms:"yes",dryRun:true})
    });
    const result=await dryRes.json().catch(()=>null);
    if(!dryRes.ok||result?.status!=="SUCCESS") return json({error:"Porkbun registration validation failed.",provider_code:result?.code||null,provider_message:result?.message||null},502);

    const mergedMetadata={
      ...(order.metadata||{}),
      porkbun_registration_dry_run:true,
      porkbun_dry_run_would_succeed:result.wouldSucceed===true,
      porkbun_dry_run_cost_usd:Number(result.cost||0)/100,
      porkbun_dry_run_request_id:result.requestId||null,
      porkbun_requirements_checked_at:new Date().toISOString(),
      porkbun_registrant_record_id:registrant.id
    };
    await admin.from("tenant_domain_orders").update({metadata:mergedMetadata}).eq("id",orderId);

    return json({
      status:"SUCCESS",
      order_id:orderId,
      hostname:order.hostname,
      tld:order.tld,
      api_registerable:requirements.apiRegisterable===true,
      saved_registrant_record_id:registrant.id,
      registrant_fields_checked:missing.length===0,
      would_succeed:result.wouldSucceed===true,
      cost_usd:Number(result.cost||0)/100,
      duration_years:Number(result.duration||1),
      sufficient_funds:result.sufficientFunds===true,
      request_id:result.requestId||null,
      message:result.message||null
    });
  }catch(e){ return json({error:e instanceof Error?e.message:String(e)},500); }
});