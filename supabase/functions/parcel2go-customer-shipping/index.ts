import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{"Content-Type":"application/json"}});

function num(v:unknown,min=0){const n=Number(v);return Number.isFinite(n)&&n>min?n:null}
function iso3(code:string){const c=String(code||"GB").toUpperCase();return c==="GB"?"GBR":c}
function addressForQuote(a:any){
  return {
    Country:iso3(a.country_code),
    Postcode:a.postcode,
    Town:a.city,
    County:a.county||undefined,
    Street:a.line1,
    Property:"",
  }
}
function addressForOrder(a:any){
  return {
    ContactName:a.recipient_name||"",
    Organisation:a.company_name||"",
    Email:a.email||"",
    Phone:a.phone||"",
    Property:"",
    Street:a.line1,
    Locality:a.line2||"",
    Town:a.city,
    County:a.county||"",
    Postcode:a.postcode,
    CountryIsoCode:iso3(a.country_code),
    CountryId:0,
    SpecialInstructions:""
  }
}
async function authUser(req:Request){
  const h=req.headers.get("Authorization")||"";
  if(!h.startsWith("Bearer ")) return null;
  const token=h.slice(7);
  const {data:{user},error}=await admin.auth.getUser(token);
  return error||!user?null:user;
}
async function tokenFor(connection:any){
  const {data:secret,error}=await admin.rpc("shipping_provider_secret_for_service",{p_connection_id:connection.id});
  if(error||!secret) throw Error("Provider credential could not be read securely.");
  const host=connection.environment==="live"?"https://www.parcel2go.com":"https://sandbox.parcel2go.com";
  const form=new URLSearchParams({grant_type:"client_credentials",scope:"public-api",client_id:connection.api_client_id,client_secret:String(secret)});
  const r=await fetch(host+"/auth/connect/token",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded","Accept":"application/json"},body:form.toString()});
  const text=await r.text();let b:any={};try{b=JSON.parse(text)}catch{}
  if(!r.ok) throw Error(String(b.error_description||b.error||text||"Parcel2Go authentication failed"));
  return {host,token:b.access_token};
}
async function loadContext(userId:string,tenantId:string,acquisitionId:string,addressId?:string){
  const {data:customer}=await admin.from("customers").select("id,auth_user_id,first_name,last_name,email,phone,tenant_id").eq("tenant_id",tenantId).eq("auth_user_id",userId).maybeSingle();
  if(!customer) throw Error("Customer account is not linked to this subscriber.");
  const {data:acq}=await admin.from("acquisitions").select("id,tenant_id,status,customer_id,agreed_total,currency,shipping_provider,shipping_provider_connection_id,shipping_method,shipping_quote_session_id").eq("tenant_id",tenantId).eq("id",acquisitionId).maybeSingle();
  if(!acq||acq.customer_id!==customer.id) throw Error("Shipping acquisition not found.");
  if(!["accepted","awaiting_item"].includes(acq.status)) throw Error("This sale is not currently at the shipping stage.");
  if(acq.shipping_provider!=="parcel2go"||!acq.shipping_provider_connection_id) throw Error("Parcel2Go is not enabled for this sale.");
  const {data:connection}=await admin.from("shipping_provider_connections").select("id,provider,status,environment,api_client_id").eq("id",acq.shipping_provider_connection_id).eq("tenant_id",tenantId).maybeSingle();
  if(!connection||connection.provider!=="parcel2go"||connection.status!=="connected") throw Error("The subscriber's Parcel2Go connection is not currently connected.");
  const addressQuery=admin.from("customer_addresses").select("id,address_type,recipient_name,company_name,line1,line2,city,county,postcode,country_code,is_default").eq("tenant_id",tenantId).eq("customer_id",customer.id);
  const {data:addresses}=addressId?await addressQuery.eq("id",addressId):await addressQuery.order("is_default",{ascending:false}).limit(1);
  const address=addresses?.[0];
  if(!address) throw Error("Add a delivery address to your customer account before requesting a shipping quote.");
  const {data:profile}=await admin.from("tenant_public_profiles").select("business_name,address_line1,address_line2,city,county,postcode,country_code,public_email,public_phone").eq("tenant_id",tenantId).maybeSingle();
  if(!profile?.address_line1||!profile?.city||!profile?.postcode) throw Error("The subscriber's collection address is incomplete. Ask the subscriber to complete Business Settings.");
  const {data:items}=await admin.from("acquisition_items").select("buying_item_id").eq("tenant_id",tenantId).eq("acquisition_id",acquisitionId).limit(1);
  const buyingItemId=items?.[0]?.buying_item_id;
  const {data:item}=buyingItemId?await admin.from("buying_items").select("title,description,quantity").eq("tenant_id",tenantId).eq("id",buyingItemId).maybeSingle():{data:null};
  return {customer,acq,connection,address,profile,item:item||{title:"Item",description:null,quantity:1}};
}

Deno.serve(async(req:Request)=>{
  if(req.method!=="POST") return json({error:"Method not allowed"},405);
  const user=await authUser(req);
  if(!user) return json({error:"Unauthorized"},401);
  let body:any;try{body=await req.json()}catch{return json({error:"Invalid JSON"},400)}
  const tenantId=String(body.tenant_id||""),acquisitionId=String(body.acquisition_id||""),action=String(body.action||"quote");
  if(!tenantId||!acquisitionId) return json({error:"tenant_id and acquisition_id are required"},400);
  try{
    if(action==="quote"||action==="create_order") return json({error:"Shipping is arranged by the subscriber. Customer-paid Parcel2Go checkout is not part of the TradeFlow selling workflow."},409);
    const ctx=await loadContext(user.id,tenantId,acquisitionId,body.address_id?String(body.address_id):undefined);
    const {host,token}=await tokenFor(ctx.connection);
    if(action==="quote"){
      const weight=num(body.weight),length=num(body.length),width=num(body.width),height=num(body.height);
      if(!weight||!length||!width||!height) return json({error:"Enter the parcel weight and all three dimensions before requesting a quote."},400);
      const quotePayload={
        CollectionAddress:addressForQuote({country_code:"GB",postcode:ctx.profile.postcode,city:ctx.profile.city,county:ctx.profile.county,line1:ctx.profile.address_line1}),
        DeliveryAddress:addressForQuote(ctx.address),
        Parcels:[{Value:Number(ctx.acq.agreed_total||0),Weight:weight,Length:length,Width:width,Height:height}]
      };
      const response=await fetch(host+"/api/quotes",{method:"POST",headers:{"Content-Type":"application/json","Authorization:"Bearer "+token,"Accept":"application/json"},body:JSON.stringify(quotePayload)});
      const text=await response.text();let payload:any={};try{payload=JSON.parse(text)}catch{}
      if(!response.ok) return json({error:String(payload.message||payload.error||text||"Parcel2Go quote failed")},400);
      const {data:session,error}=await admin.from("shipping_quote_sessions").insert({
        tenant_id:tenantId,acquisition_id:acquisitionId,customer_id:ctx.customer.id,provider:"parcel2go",
        provider_connection_id:ctx.connection.id,status:"quoted",request_payload:{...quotePayload,customer_address_id:ctx.address.id},
        response_payload:payload
      }).select("id,created_at").single();
      if(error||!session) throw Error("The quote was returned but could not be saved.");
      await admin.from("acquisitions").update({
        shipping_quote_session_id:session.id,
        shipping_parcel_weight:weight,
        shipping_parcel_length:length,
        shipping_parcel_width:width,
        shipping_parcel_height:height,
        shipping_status:"quoted",
        shipping_status_updated_at:new Date().toISOString()
      }).eq("id",acquisitionId).eq("tenant_id",tenantId);
      const quotes=Array.isArray(payload.Quotes)?payload.Quotes:[];
      return json({ok:true,action:"quote",quote_session_id:session.id,quotes});
    }
    if(action==="create_order"){
      const sessionId=String(body.quote_session_id||"");
      if(!sessionId) return json({error:"quote_session_id is required"},400);
      const {data:qs}=await admin.from("shipping_quote_sessions").select("id,status,request_payload,response_payload,customer_id,provider_connection_id").eq("id",sessionId).eq("tenant_id",tenantId).eq("acquisition_id",acquisitionId).eq("customer_id",ctx.customer.id).maybeSingle();
      if(!qs) throw Error("Shipping quote not found.");
      if(qs.status!=="quoted"&&qs.status!=="order_created") throw Error("This shipping quote is no longer available.");
      const quotes=Array.isArray(qs.response_payload?.Quotes)?qs.response_payload.Quotes:[];
      const idx=Number(body.quote_index);
      if(!Number.isInteger(idx)||idx<0||idx>=quotes.length) throw Error("Select a valid shipping service.");
      const selected=quotes[idx];
      const service=selected?.Service||selected?.service||selected?.ServiceCode||selected?.serviceCode;
      if(!service) throw Error("Parcel2Go did not return a bookable service code for this quote.");
      const reqPayload=qs.request_payload||{};
      const parcel=reqPayload.Parcels?.[0];
      const collectionAddress=addressForOrder({recipient_name:ctx.customer.first_name+" "+(ctx.customer.last_name||""),email:ctx.customer.email,phone:ctx.customer.phone,line1:ctx.profile.address_line1,line2:ctx.profile.address_line2,city:ctx.profile.city,county:ctx.profile.county,postcode:ctx.profile.postcode,country_code:ctx.profile.country_code||"GB"});
      const deliveryAddress=addressForOrder({...ctx.address,email:ctx.customer.email,phone:ctx.customer.phone});
      const itemId=crypto.randomUUID();
      const orderPayload={Items:[{Id:itemId,CollectionDate:String(body.collection_date||new Date(Date.now()+86400000).toISOString()),Service:service,Parcels:[{Id:crypto.randomUUID(),Height:Number(parcel.Height),Length:Number(parcel.Length),EstimatedValue:Number(ctx.acq.agreed_total||0),Weight:Number(parcel.Weight),Width:Number(parcel.Width),DeliveryAddress:deliveryAddress,ContentsSummary:String(ctx.item.title||"Item").slice(0,100)}],CollectionAddress:collectionAddress}],CustomerDetails:{Email:ctx.customer.email,Forename:ctx.customer.first_name,Surname:ctx.customer.last_name||""}};
      const response=await fetch(host+"/api/orders",{method:"POST",headers:{"Content-Type":"application/json","Authorization":"Bearer "+token,"Accept":"application/json"},body:JSON.stringify(orderPayload)});
      const text=await response.text();let payload:any={};try{payload=JSON.parse(text)}catch{}
      if(!response.ok) return json({error:String(payload.message||payload.error||text||"Parcel2Go order creation failed")},400);
      const paymentUrl=payload?.Links?.payment||payload?.Links?.payment_url||payload?.Links?.Payment||null;
      const trackingUrl=payload?.Links?.["tracking-page"]||payload?.Links?.tracking||null;
      const orderId=payload?.OrderId||payload?.orderId||null;
      await admin.from("shipping_quote_sessions").update({status:"order_created",selected_service:selected,provider_order_id:orderId,payment_url:paymentUrl,tracking_url:trackingUrl,response_payload:payload,updated_at:new Date().toISOString()}).eq("id",sessionId);
      await admin.from("acquisitions").update({shipping_quote_session_id:sessionId,shipping_provider_order_id:orderId,shipping_payment_url:paymentUrl,shipping_tracking_url:trackingUrl,shipping_status:"awaiting_payment",shipping_status_updated_at:new Date().toISOString(),shipping_service:String(selected?.ServiceName||selected?.serviceName||selected?.Name||service),shipping_carrier:String(selected?.Courier||selected?.courier||"Parcel2Go")}).eq("id",acquisitionId).eq("tenant_id",tenantId);
      return json({ok:true,action:"order_created",order_id:orderId,payment_url:paymentUrl,tracking_url:trackingUrl,total_price:payload?.TotalPrice,total_vat:payload?.TotalVat});
    }
    return json({error:"Unsupported action"},400);
  }catch(e){return json({error:e instanceof Error?e.message:String(e)},400)}
});