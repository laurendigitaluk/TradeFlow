import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);

const cors={
  "Access-Control-Allow-Origin":"*",
  "Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods":"POST, OPTIONS"
};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json"}});

function num(v:unknown,min=0){const n=Number(v);return Number.isFinite(n)&&n>min?n:null}
function iso3(code:string){const c=String(code||"GB").toUpperCase();return c==="GB"?"GBR":c}
function quoteAddress(a:any){
  return {Country:iso3(a.country_code),Postcode:a.postcode,Town:a.city,County:a.county||undefined,Street:a.line1,Property:""};
}
function orderAddress(a:any){
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
  };
}
async function authUser(req:Request){
  const h=req.headers.get("Authorization")||"";
  if(!h.startsWith("Bearer "))return null;
  const token=h.slice(7);
  const {data:{user},error}=await admin.auth.getUser(token);
  return error||!user?null:user;
}
async function canManageBuying(userId:string,tenantId:string){
  const {data:m}=await admin.from("tenant_memberships").select("role_code").eq("tenant_id",tenantId).eq("user_id",userId).eq("status","active").maybeSingle();
  if(!m?.role_code)return false;
  const {data:r}=await admin.from("roles").select("id").eq("code",m.role_code).maybeSingle();
  const {data:p}=await admin.from("permissions").select("id").eq("code","buying.manage").maybeSingle();
  if(!r?.id||!p?.id)return false;
  const {data:rp}=await admin.from("role_permissions").select("role_id").eq("role_id",r.id).eq("permission_id",p.id).maybeSingle();
  return Boolean(rp);
}
async function tokenFor(connection:any){
  const {data:secret,error}=await admin.rpc("shipping_provider_secret_for_service",{p_connection_id:connection.id});
  if(error||!secret)throw Error("Provider credential could not be read securely.");
  const host=connection.environment==="live"?"https://www.parcel2go.com":"https://sandbox.parcel2go.com";
  const form=new URLSearchParams({grant_type:"client_credentials",scope:"public-api",client_id:connection.api_client_id,client_secret:String(secret)});
  const r=await fetch(host+"/auth/connect/token",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded","Accept":"application/json"},body:form.toString()});
  const text=await r.text();let b:any={};try{b=JSON.parse(text)}catch{}
  if(!r.ok)throw Error(String(b.error_description||b.error||text||"Parcel2Go authentication failed"));
  return {host,token:b.access_token};
}
function firstLink(links:any,needles:string[]){
  const wanted=needles.map(n=>String(n).toLowerCase());
  function walk(v:any,key=""):string|null{
    if(v==null)return null;
    const keyLower=String(key).toLowerCase();
    if(typeof v==="string"){
      if(wanted.some(n=>keyLower.includes(n))&&(v.startsWith("http://")||v.startsWith("https://")))return v;
      return null;
    }
    if(Array.isArray(v)){
      for(const item of v){const hit=walk(item,key);if(hit)return hit}
      return null;
    }
    if(typeof v!=="object")return null;
    for(const candidate of ["href","Href","url","Url","uri","Uri"]){
      const value=v[candidate];
      if(typeof value==="string"&&wanted.some(n=>keyLower.includes(n)||String(candidate).toLowerCase().includes(n))&&(value.startsWith("http://")||value.startsWith("https://")))return value;
    }
    for(const [k,value] of Object.entries(v)){
      const hit=walk(value,k);
      if(hit)return hit;
    }
    return null;
  }
  return walk(links);
}
function orderIdFrom(payload:any){
  return payload?.OrderId??payload?.OrderID??payload?.orderId??payload?.orderID??payload?.Id??payload?.id??payload?.Order?.Id??payload?.order?.id??null;
}
function scalar(v:any){
  return typeof v==="string"||typeof v==="number" ? v : null;
}
function nestedScalar(v:any,keys:string[]){
  if(v==null)return null;
  const direct=scalar(v);
  if(direct!==null)return direct;
  if(typeof v!=="object")return null;
  for(const key of keys){
    const value=scalar(v?.[key]);
    if(value!==null)return value;
  }
  return null;
}
function normaliseQuote(q:any,index:number){
  const serviceObj=q?.Service??q?.service??null;
  const courierObj=q?.Courier??q?.courier??q?.Carrier??q?.carrier??null;
  const priceObj=q?.TotalPrice??q?.totalPrice??q?.Price??q?.price??q?.Total??q?.total??q?.Amount??q?.amount??null;
  const serviceCode=nestedScalar(serviceObj,["Code","ServiceCode","Id","ID","id"]) ??
    nestedScalar(q,["ServiceCode","serviceCode","Code","code","ServiceId","serviceId"]) ?? null;
  const serviceName=nestedScalar(serviceObj,["Name","ServiceName","Description","ServiceDescription","Title"]) ??
    nestedScalar(q,["ServiceName","serviceName","Name","name","Description","description"]) ??
    (serviceCode ? String(serviceCode) : "Shipping service");
  const carrier=nestedScalar(courierObj,["Name","CourierName","CarrierName","Description","Code"]) ??
    nestedScalar(q,["CourierName","courierName","CarrierName","carrierName"]) ??
    "Parcel2Go";
  const price=nestedScalar(priceObj,["Amount","Value","Total","Price","Net","Gross"]) ??
    nestedScalar(q,["TotalPrice","totalPrice","Price","price","Total","total","Amount","amount"]) ?? null;
  const currency=nestedScalar(priceObj,["Currency","currency","CurrencyCode","currencyCode"]) ??
    nestedScalar(q,["Currency","currency","CurrencyCode","currencyCode"]) ?? "GBP";
  const delivery=nestedScalar(serviceObj,["DeliveryDate","EstimatedDeliveryDate","TransitTime","DeliveryTime","DeliveryDescription"]) ??
    nestedScalar(q,["DeliveryDate","deliveryDate","EstimatedDeliveryDate","estimatedDeliveryDate","TransitTime","transitTime","DeliveryTime","deliveryTime"]) ?? null;
  return {
    index,
    service_code:serviceCode===null?null:String(serviceCode),
    service_name:String(serviceName),
    carrier:String(carrier),
    price,
    currency:String(currency),
    delivery:delivery===null?null:String(delivery),
    raw:q
  };
}
async function loadContext(userId:string,tenantId:string,itemId:string){
  if(!(await canManageBuying(userId,tenantId)))throw Error("Permission required: buying.manage");
  const {data:item}=await admin.from("buying_items").select("id,buying_request_id,title,description,quantity,purchase_stage").eq("tenant_id",tenantId).eq("id",itemId).maybeSingle();
  if(!item)throw Error("Buying item not found.");
  if(!["awaiting_item","shipping"].includes(item.purchase_stage))throw Error("Integrated shipping is only available while awaiting the customer item.");
  const {data:request}=await admin.from("buying_requests").select("id,customer_id").eq("tenant_id",tenantId).eq("id",item.buying_request_id).maybeSingle();
  if(!request?.customer_id)throw Error("Customer record not found for this request.");
  const {data:customer}=await admin.from("customers").select("id,first_name,last_name,email,phone").eq("tenant_id",tenantId).eq("id",request.customer_id).maybeSingle();
  if(!customer)throw Error("Customer record not found.");
  const {data:address}=await admin.from("customer_addresses").select("id,address_type,recipient_name,company_name,line1,line2,city,county,postcode,country_code,is_default").eq("tenant_id",tenantId).eq("customer_id",customer.id).eq("address_type","shipping").order("is_default",{ascending:false}).limit(1).maybeSingle();
  if(!address)throw Error("The customer has not added a delivery address yet.");
  const {data:profile}=await admin.from("tenant_public_profiles").select("business_name,address_line1,address_line2,city,county,postcode,country_code,public_email,public_phone").eq("tenant_id",tenantId).maybeSingle();
  if(!profile?.address_line1||!profile?.city||!profile?.postcode)throw Error("The subscriber's collection address is incomplete. Complete Business Settings first.");
  const {data:connection}=await admin.from("shipping_provider_connections").select("id,provider,status,environment,api_client_id").eq("tenant_id",tenantId).eq("provider","parcel2go").eq("status","connected").maybeSingle();
  if(!connection)throw Error("Connect and test Parcel2Go in Shipping Settings first.");
  const {data:shipping}=await admin.from("buying_item_shipping").select("shipping_provider_order_id,shipping_payment_url,shipping_tracking_url,shipping_label_url,shipping_qr_url").eq("tenant_id",tenantId).eq("buying_item_id",itemId).maybeSingle();
  return {item,customer,address,profile,connection,shipping};
}
async function getQuotes(ctx:any,tokenInfo:any,weight:number,length:number,width:number,height:number){
  const payload={
    CollectionAddress:quoteAddress({country_code:ctx.profile.country_code||"GB",postcode:ctx.profile.postcode,city:ctx.profile.city,county:ctx.profile.county,line1:ctx.profile.address_line1}),
    DeliveryAddress:quoteAddress(ctx.address),
    Parcels:[{Value:0,Weight:weight,Length:length,Width:width,Height:height}]
  };
  const r=await fetch(tokenInfo.host+"/api/quotes",{method:"POST",headers:{"Content-Type":"application/json","Authorization":"Bearer "+tokenInfo.token,"Accept":"application/json"},body:JSON.stringify(payload)});
  const text=await r.text();let body:any={};try{body=JSON.parse(text)}catch{}
  if(!r.ok)throw Error(String(body.message||body.error||text||"Parcel2Go quote failed"));
  const raw=Array.isArray(body.Quotes)?body.Quotes:[];
  return {payload,raw,quotes:raw.map((q:any,i:number)=>normaliseQuote(q,i))};
}
Deno.serve(async(req:Request)=>{
  if(req.method==="OPTIONS")return new Response("ok",{status:200,headers:cors});
  if(req.method!=="POST")return json({error:"Method not allowed"},405);
  const user=await authUser(req);if(!user)return json({error:"Unauthorized"},401);
  let body:any;try{body=await req.json()}catch{return json({error:"Invalid JSON"},400)}
  const tenantId=String(body.tenant_id||""),itemId=String(body.buying_item_id||""),action=String(body.action||"quote");
  if(!tenantId||!itemId)return json({error:"tenant_id and buying_item_id are required"},400);
  try{
    const ctx=await loadContext(user.id,tenantId,itemId);
    const weight=num(body.weight),length=num(body.length),width=num(body.width),height=num(body.height);
    if(!weight||!length||!width||!height)return json({error:"Enter parcel weight and all three dimensions before requesting a quote."},400);
    const tokenInfo=await tokenFor(ctx.connection);
    const quoted=await getQuotes(ctx,tokenInfo,weight,length,width,height);
    if(action==="quote"){
      await admin.from("buying_item_shipping").upsert({
        tenant_id:tenantId,buying_item_id:itemId,shipping_method:"automated",shipping_provider:"parcel2go",
        shipping_provider_connection_id:ctx.connection.id,shipping_status:"ready_for_customer_quote",shipping_status_updated_at:new Date().toISOString()
      },{onConflict:"buying_item_id"});
      return json({ok:true,action:"quote",quotes:quoted.quotes});
    }
    if(action==="create_order"){
      const serviceCode=String(body.service_code||"");
      if(!serviceCode)return json({error:"Select a Parcel2Go service first."},400);
      const selected=quoted.quotes.find((q:any)=>String(q.service_code||"")===serviceCode);
      if(!selected)return json({error:"That Parcel2Go service is no longer available. Request a fresh quote."},409);
      const rawSelected=quoted.raw[selected.index];
      const service=selected.service_code;
      const parcelValue=0;
      const collectionAddress=orderAddress({recipient_name:ctx.profile.business_name||"Subscriber",email:ctx.profile.public_email||"",phone:ctx.profile.public_phone||"",line1:ctx.profile.address_line1,line2:ctx.profile.address_line2,city:ctx.profile.city,county:ctx.profile.county,postcode:ctx.profile.postcode,country_code:ctx.profile.country_code||"GB"});
      const deliveryAddress=orderAddress({...ctx.address,email:ctx.customer.email,phone:ctx.customer.phone});
      const orderPayload={
        Items:[{
          Id:crypto.randomUUID(),
          CollectionDate:String(body.collection_date||new Date(Date.now()+86400000).toISOString()),
          Service:service,
          Parcels:[{
            Id:crypto.randomUUID(),Height:height,Length:length,EstimatedValue:parcelValue,Weight:weight,Width:width,
            DeliveryAddress:deliveryAddress,
            ContentsSummary:String(ctx.item.title||"Item").slice(0,100)
          }],
          CollectionAddress:collectionAddress
        }],
        CustomerDetails:{Email:ctx.customer.email,Forename:ctx.customer.first_name,Surname:ctx.customer.last_name||""}
      };
      const response=await fetch(tokenInfo.host+"/api/orders",{method:"POST",headers:{"Content-Type":"application/json","Authorization":"Bearer "+tokenInfo.token,"Accept":"application/json"},body:JSON.stringify(orderPayload)});
      const text=await response.text();let payload:any={};try{payload=JSON.parse(text)}catch{}
      if(!response.ok)return json({error:String(payload.message||payload.error||text||"Parcel2Go order creation failed")},400);
      const links=payload?.Links||payload?.links||payload?._links||payload?.LinksObject||{};
      const paymentUrl=firstLink(links,["payment","checkout","pay"]);
      const trackingUrl=firstLink(links,["tracking","track"]);
      const labelUrl=firstLink(links,["label","pdf","document"]);
      const qrUrl=firstLink(links,["qr","barcode"]);
      const orderId=orderIdFrom(payload);
      console.log("Parcel2Go create_order response",{
        status:response.status,
        keys:Object.keys(payload||{}),
        link_keys:links&&typeof links==="object"&&!Array.isArray(links)?Object.keys(links):[],
        order_id:orderId,
        has_payment_url:Boolean(paymentUrl),
        has_label_url:Boolean(labelUrl),
        has_qr_url:Boolean(qrUrl)
      });
      if(!orderId){
        return json({
          error:"Parcel2Go accepted the request but did not return an order ID.",
          provider_status:response.status,
          response_keys:Object.keys(payload||{})
        },502);
      }
      const {error:saveError}=await admin.from("buying_item_shipping").upsert({
        tenant_id:tenantId,buying_item_id:itemId,shipping_method:"automated",shipping_provider:"parcel2go",
        shipping_provider_connection_id:ctx.connection.id,shipping_provider_order_id:orderId,
        shipping_payment_url:paymentUrl,shipping_tracking_url:trackingUrl,shipping_label_url:labelUrl,shipping_qr_url:qrUrl,
        shipping_carrier:selected.carrier,shipping_service:selected.service_name,
        shipping_status:paymentUrl?"awaiting_payment":(labelUrl||qrUrl?"ready_for_customer":"order_created"),
        shipping_status_updated_at:new Date().toISOString(),
        shipping_instructions:"Parcel2Go integrated shipment created. Complete Parcel2Go payment before the item is sent."
      },{onConflict:"buying_item_id"});
      if(saveError)throw Error("Parcel2Go order was created but TradeFlow could not save the shipping handoff: "+saveError.message);
      return json({ok:true,action:"create_order",order_id:orderId,payment_url:paymentUrl,tracking_url:trackingUrl,label_url:labelUrl,qr_url:qrUrl,service:selected});
    }
    return json({error:"Unsupported action"},400);
  }catch(e){return json({error:e instanceof Error?e.message:String(e)},400)}
});