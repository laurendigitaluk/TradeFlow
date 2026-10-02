import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!, SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_SECRET_KEY=Deno.env.get("STRIPE_SECRET_KEY"), PORKBUN_API_KEY=Deno.env.get("PORKBUN_API_KEY"), PORKBUN_SECRET=Deno.env.get("PORKBUN_SECRET_API_KEY");
const headers={"Content-Type":"application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});
const domainRegex=/^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$/i;
const normalise=(v:string)=>v.trim().toLowerCase().replace(/^https?:\/\//i,"").split("/")[0].replace(/\.$/,"");
const price=(usd:number,rate:number,markup:number)=>Math.round(usd*rate*(1+markup/100)*100)/100;
Deno.serve(async req=>{
 if(req.method==="OPTIONS")return new Response("ok",{headers});
 if(req.method!=="POST")return json({error:"Method not allowed"},405);
 if(!STRIPE_SECRET_KEY||!PORKBUN_API_KEY||!PORKBUN_SECRET)return json({error:"Domain payment services are not configured on this TradeFlow TEST environment."},503);
 const auth=req.headers.get("Authorization");if(!auth)return json({error:"Authentication required"},401);
 try{
  const token=auth.replace(/^Bearer\s+/i,""),admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
  const {data:{user},error:userError}=await admin.auth.getUser(token);if(userError||!user)return json({error:"Authentication required"},401);
  const body=await req.json().catch(()=>({})),tenantId=String(body?.tenant_id||""),hostname=normalise(String(body?.domain||""));
  if(!tenantId||!hostname)return json({error:"tenant_id and domain are required"},400);
  if(!domainRegex.test(hostname))return json({error:"Enter a valid domain name."},400);
  const {data:membership}=await admin.from("tenant_memberships").select("tenant_id,role_code,status").eq("tenant_id",tenantId).eq("user_id",user.id).eq("status","active").maybeSingle();
  if(!membership)return json({error:"You do not have access to this TradeFlow workspace."},403);
  const {data:pricing}=await admin.from("platform_domain_pricing_settings").select("markup_percent,usd_to_gbp_rate,fx_source,fx_basis,fx_period_start,fx_period_end").eq("id",1).maybeSingle();
  if(!pricing)return json({error:"Domain pricing settings are not configured."},503);
  const {data:existing}=await admin.from("tenant_domain_orders").select("id,status,retail_amount,currency,payment_reference,hostname").eq("tenant_id",tenantId).eq("hostname",hostname).in("status",["pending_payment","payment_confirmed","registrant_details_saved","submitted","registering","registered"]).order("created_at",{ascending:false}).limit(1).maybeSingle();
  if(existing?.status==="registered")return json({error:"This domain is already registered in TradeFlow.",order_id:existing.id},409);
  if(existing?.status==="payment_confirmed"||existing?.status==="registrant_details_saved")return json({error:"This domain has already been paid for. Continue with registrant details.",order_id:existing.id,requires_registrant_details:true},409);
  const provider=await fetch("https://api.porkbun.com/api/json/v3/domain/checkDomain/"+encodeURIComponent(hostname),{method:"POST",headers:{"X-API-Key":PORKBUN_API_KEY,"X-Secret-API-Key":PORKBUN_SECRET,"Content-Type":"application/json"},body:JSON.stringify({domain:hostname})});
  const providerBody=await provider.json().catch(()=>null);if(!provider.ok||providerBody?.status!=="SUCCESS")return json({error:"Unable to recheck the domain with Porkbun.",provider_code:providerBody?.code||null},502);
  const p=providerBody.response||{};if(p.avail!=="yes")return json({error:"That domain is no longer available. Please search again."},409);
  const usd=Number(p.price),retail=price(usd,Number(pricing.usd_to_gbp_rate),Number(pricing.markup_percent));if(!Number.isFinite(usd)||retail<=0)return json({error:"Porkbun returned an invalid domain price."},502);
  let orderId=existing?.id;
  if(!orderId){
   const {data:newOrder,error}=await admin.from("tenant_domain_orders").insert({tenant_id:tenantId,operation:"register",hostname,tld:"."+hostname.split(".").slice(1).join("."),term_years:1,status:"pending_payment",currency:"GBP",retail_amount:retail,registrar_cost:usd,registrar_cost_usd:usd,fx_rate_gbp_per_usd:Number(pricing.usd_to_gbp_rate),markup_percent:Number(pricing.markup_percent),pricing_source:pricing.fx_source,pricing_period_start:pricing.fx_period_start,pricing_period_end:pricing.fx_period_end,metadata:{provider:"porkbun",sandbox:providerBody?.sandbox===true,registrar_price_currency:"USD",fx_basis:pricing.fx_basis,first_year_promo:p.firstYearPromo||null,regular_price:p.regularPrice||null,premium:p.premium||null}}).select("id").single();
   if(error)return json({error:"Unable to create the domain order.",details:error.message},500); orderId=newOrder.id;
  }else{
   const {error}=await admin.from("tenant_domain_orders").update({status:"pending_payment",retail_amount:retail,registrar_cost:usd,registrar_cost_usd:usd,fx_rate_gbp_per_usd:Number(pricing.usd_to_gbp_rate),markup_percent:Number(pricing.markup_percent),pricing_source:pricing.fx_source,pricing_period_start:pricing.fx_period_start,pricing_period_end:pricing.fx_period_end,failure_reason:null}).eq("id",orderId);
   if(error)return json({error:"Unable to refresh the domain order pricing.",details:error.message},500);
  }
  if(existing?.payment_reference?.startsWith("cs_")){
   const old=await fetch("https://api.stripe.com/v1/checkout/sessions/"+encodeURIComponent(existing.payment_reference),{headers:{Authorization:"Bearer "+STRIPE_SECRET_KEY}});
   if(old.ok){const session=await old.json();if(session.status==="open"&&session.url)return json({checkout_url:session.url,session_id:session.id,order_id:orderId,retail_amount:retail,reused:true});}
  }
  const origin=req.headers.get("origin")||"https://laurendigitaluk.github.io/TradeFlow",base=origin.includes("laurendigitaluk.github.io")?"https://laurendigitaluk.github.io/TradeFlow":origin;
  const params=new URLSearchParams();params.set("mode","payment");params.append("allowed_payment_method_types[]","card");
  params.set("success_url",base+"/domain-registrant.html?domain_payment=success&order_id="+encodeURIComponent(orderId));params.set("cancel_url",base+"/domain-purchase.html?domain_payment=cancelled&order_id="+encodeURIComponent(orderId));params.set("client_reference_id",orderId);params.set("customer_creation","if_required");
  params.set("line_items[0][quantity]","1");params.set("line_items[0][price_data][currency]","gbp");params.set("line_items[0][price_data][unit_amount]",String(Math.round(retail*100)));params.set("line_items[0][price_data][product_data][name]","TradeFlow domain registration — "+hostname);
  params.set("metadata[tenant_id]",tenantId);params.set("metadata[domain_order_id]",orderId);params.set("metadata[hostname]",hostname);params.set("payment_intent_data[metadata][tenant_id]",tenantId);params.set("payment_intent_data[metadata][domain_order_id]",orderId);params.set("payment_intent_data[metadata][hostname]",hostname);
  const stripeRes=await fetch("https://api.stripe.com/v1/checkout/sessions",{method:"POST",headers:{Authorization:"Bearer "+STRIPE_SECRET_KEY,"Content-Type":"application/x-www-form-urlencoded","Idempotency-Key":"tradeflow-domain-"+orderId+"-"+crypto.randomUUID()},body:params});
  const stripe=await stripeRes.json().catch(()=>null);if(!stripeRes.ok)return json({error:stripe?.error?.message||"Stripe Checkout session creation failed."},502);
  await admin.from("tenant_domain_orders").update({payment_provider:"stripe",payment_reference:stripe.id,metadata:{provider:"porkbun",stripe_checkout_session_id:stripe.id,sandbox:providerBody?.sandbox===true}}).eq("id",orderId);
  return json({checkout_url:stripe.url,session_id:stripe.id,order_id:orderId,retail_amount:retail,currency:"GBP",registrar_cost_usd:usd,fx_rate_gbp_per_usd:Number(pricing.usd_to_gbp_rate),markup_percent:Number(pricing.markup_percent)});
 }catch(e){return json({error:e instanceof Error?e.message:String(e)},500)}
});