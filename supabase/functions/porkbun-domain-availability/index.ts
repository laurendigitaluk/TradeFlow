import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json"}});
const normaliseDomain=(value:string)=>value.trim().toLowerCase().replace(/^https?:\/\//i,"").split("/")[0].replace(/\.$/,"");
const domainRegex=/^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$/i;
const customerPriceGbp=(usdPrice:unknown,pricing:any)=>{const usd=Number(usdPrice),rate=Number(pricing?.usd_to_gbp_rate),markup=Number(pricing?.markup_percent);if(!Number.isFinite(usd)||usd<0||!Number.isFinite(rate)||rate<=0||!Number.isFinite(markup)||markup<0)return null;return Math.round(usd*rate*(1+markup/100)*100)/100};

Deno.serve(async(req:Request)=>{
 if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
 if(req.method!=="POST")return json({error:"POST required"},405);
 const auth=req.headers.get("Authorization");if(!auth)return json({error:"Authentication required"},401);
 const supabaseUrl=Deno.env.get("SUPABASE_URL"),serviceRoleKey=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),apiKey=Deno.env.get("PORKBUN_API_KEY"),secretApiKey=Deno.env.get("PORKBUN_SECRET_API_KEY"),apiBase="https://api.porkbun.com/api/json/v3";
 if(!supabaseUrl||!serviceRoleKey)return json({error:"Supabase service configuration is missing"},500);
 if(!apiKey||!secretApiKey)return json({error:"Porkbun API is not configured on this TradeFlow TEST environment."},503);
 try{
  const token=auth.replace(/^Bearer\s+/i,""),admin=createClient(supabaseUrl,serviceRoleKey);
  const {data:{user},error:userError}=await admin.auth.getUser(token);if(userError||!user)return json({error:"Authentication required"},401);
  const {data:pricing,error:pricingError}=await admin.from("platform_domain_pricing_settings").select("markup_percent,usd_to_gbp_rate,fx_source,fx_series,fx_basis,fx_period_start,fx_period_end,fx_review_threshold_percent,fx_last_reviewed,fx_source_url").eq("id",1).maybeSingle();
  if(pricingError||!pricing)return json({error:"Domain pricing settings are not configured on this TradeFlow TEST environment."},503);
  const body=await req.json().catch(()=>({})),requestedDomains=Array.isArray(body?.domains)?body.domains.map((v:unknown)=>normaliseDomain(String(v||""))).filter(Boolean):[],requestedDomain=normaliseDomain(String(body?.domain||body?.domain_name||""));
  if(requestedDomains.length>25)return json({error:"A maximum of 25 domains can be checked in one request."},400);
  const pricingMeta={currency:"GBP",markup_percent:Number(pricing.markup_percent),usd_to_gbp_rate:Number(pricing.usd_to_gbp_rate),fx_source:pricing.fx_source,fx_series:pricing.fx_series,fx_basis:pricing.fx_basis,fx_period_start:pricing.fx_period_start,fx_period_end:pricing.fx_period_end,fx_review_threshold_percent:Number(pricing.fx_review_threshold_percent),fx_last_reviewed:pricing.fx_last_reviewed};
  if(requestedDomains.length>0){
   const validDomains=requestedDomains.filter(d=>domainRegex.test(d));if(!validDomains.length)return json({error:"No valid domains were supplied."},400);
   const providerResponse=await fetch(apiBase+"/domain/checkDomain",{method:"POST",headers:{"X-API-Key":apiKey,"X-Secret-API-Key":secretApiKey,"Content-Type":"application/json"},body:JSON.stringify({domains:validDomains})});
   const text=await providerResponse.text();let providerBody:any=null;try{providerBody=text?JSON.parse(text):null}catch{providerBody={raw:text}};
   if(!providerResponse.ok||providerBody?.status!=="SUCCESS")return json({error:"Porkbun availability request failed.",provider_status:providerResponse.status,provider_code:providerBody?.code||null,provider_message:providerBody?.message||null,request_id:providerBody?.requestId||null},502);
   const checked=Object.entries(providerBody?.domains||{}).map(([domain,value]:[string,any])=>({status:value?.avail==="yes"?"available":value?.avail==="no"?"unavailable":"unknown",domain,available:value?.avail==="yes",availability:value?.avail||null,type:value?.type||null,price:value?.price||null,currency:"USD",customer_price_gbp:value?.avail==="yes"?customerPriceGbp(value?.price,pricing):null,first_year_promo:value?.firstYearPromo||null,regular_price:value?.regularPrice||null,premium:value?.premium||null,minimum_duration:value?.minDuration||null}));
   const unresolved=Array.isArray(providerBody?.unresolved)?providerBody.unresolved.map((domain:string)=>({status:"unknown",domain,available:null})):[];
   const invalid=Array.isArray(providerBody?.invalid)?providerBody.invalid.map((domain:string)=>({status:"invalid",domain,available:null})):[];
   return json({status:"SUCCESS",results:[...checked,...unresolved,...invalid],sandbox:providerBody?.sandbox===true,provider:"porkbun",pricing:pricingMeta,request_id:providerBody?.requestId||null});
  }
  if(!requestedDomain)return json({error:"domain is required"},400);
  if(!domainRegex.test(requestedDomain))return json({error:"Enter a valid full domain name, for example tradeflow-test-84726.com."},400);
  const providerResponse=await fetch(apiBase+"/domain/checkDomain/"+encodeURIComponent(requestedDomain),{method:"POST",headers:{"X-API-Key":apiKey,"X-Secret-API-Key":secretApiKey,"Content-Type":"application/json"},body:JSON.stringify({domain:requestedDomain})});
  const text=await providerResponse.text();let providerBody:any=null;try{providerBody=text?JSON.parse(text):null}catch{providerBody={raw:text}};
  if(!providerResponse.ok||providerBody?.status!=="SUCCESS")return json({error:"Porkbun availability request failed.",provider_status:providerResponse.status,provider_code:providerBody?.code||null,provider_message:providerBody?.message||null,request_id:providerBody?.requestId||null},502);
  const response=providerBody?.response||{};
  return json({status:"SUCCESS",domain:requestedDomain,available:response.avail==="yes",availability:response.avail||null,type:response.type||null,price:response.price||null,currency:"USD",customer_price_gbp:response.avail==="yes"?customerPriceGbp(response.price,pricing):null,first_year_promo:response.firstYearPromo||null,regular_price:response.regularPrice||null,premium:response.premium||null,minimum_duration:response.minDuration||null,sandbox:providerBody?.sandbox===true,provider:"porkbun",pricing:pricingMeta,request_id:providerBody?.requestId||null});
 }catch(error){return json({error:error instanceof Error?error.message:String(error)},500)}
});