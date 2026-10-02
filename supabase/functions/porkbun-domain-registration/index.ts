import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const API_KEY=Deno.env.get("PORKBUN_API_KEY")!;
const SECRET=Deno.env.get("PORKBUN_SECRET_API_KEY")!;
const headers={"Content-Type":"application/json","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});
const pbHeaders={"X-API-Key":API_KEY,"X-Secret-API-Key":SECRET,"Content-Type":"application/json"};

Deno.serve(async req=>{
  if(req.method==="OPTIONS") return new Response("ok",{headers});
  if(req.method!=="POST") return json({error:"Method not allowed"},405);
  const auth=req.headers.get("Authorization");
  if(!auth) return json({error:"Authentication required"},401);

  let orderId="", tenantId="";
  try{
    const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
    const token=auth.replace(/^Bearer\s+/i,"");
    const {data:{user},error:userError}=await admin.auth.getUser(token);
    if(userError||!user) return json({error:"Authentication required"},401);

    const body=await req.json().catch(()=>({}));
    tenantId=String(body?.tenant_id||"");
    orderId=String(body?.order_id||"");
    if(!tenantId||!orderId) return json({error:"tenant_id and order_id are required"},400);

    const {data:member}=await admin.from("tenant_memberships").select("tenant_id").eq("tenant_id",tenantId).eq("user_id",user.id).eq("status","active").maybeSingle();
    if(!member) return json({error:"You do not have access to this TradeFlow workspace."},403);

    const {data:order}=await admin.from("tenant_domain_orders").select("id,tenant_id,hostname,tld,status,term_years,registrar_cost_usd,metadata").eq("id",orderId).eq("tenant_id",tenantId).maybeSingle();
    if(!order) return json({error:"Domain order not found."},404);
    if(!["registrant_details_saved","failed"].includes(order.status)) return json({error:"The domain is not ready for TEST registration/reconciliation."},409);
    if(Number(order.term_years||1)!==1) return json({error:"The current Porkbun TEST registration path is limited to one year.",term_years:order.term_years},409);

    const {data:registrant}=await admin.from("tenant_domain_registrants").select("id,registrant_name,organisation,address_line1,address_line2,city,region,postal_code,country_code,email,phone").eq("domain_order_id",orderId).eq("tenant_id",tenantId).maybeSingle();
    if(!registrant) return json({error:"Saved registrant details not found."},409);

    const dryRun=order.metadata?.porkbun_dry_run_would_succeed===true;
    if(!dryRun) return json({error:"A successful Porkbun dry run is required before sandbox registration."},409);
    const existingSandboxOrderId=String(order.provider_order_id||"");
    const sandboxAlreadyRegistered=Boolean(existingSandboxOrderId)&&order.metadata?.porkbun_sandbox===true;

    const cost=Math.round(Number(order.registrar_cost_usd||0)*100);
    if(!Number.isFinite(cost)||cost<=0) return json({error:"The saved registrar cost is invalid."},409);

    const registeringMetadata={
      ...(order.metadata||{}),
      porkbun_registration_started_at:new Date().toISOString(),
      porkbun_registrant_record_id:registrant.id
    };
    await admin.from("tenant_domain_orders").update({status:"registering",failure_reason:null,metadata:registeringMetadata}).eq("id",orderId);

    let created={orderId:existingSandboxOrderId,requestId:order.metadata?.porkbun_registration_request_id||null};
    if(!sandboxAlreadyRegistered){
      const createRes=await fetch("https://api.porkbun.com/api/json/v3/domain/create/"+encodeURIComponent(order.hostname),{
        method:"POST",
        headers:{...pbHeaders,"Idempotency-Key":"tradeflow-register-"+order.id},
        body:JSON.stringify({cost,agreeToTerms:"yes"})
      });
      const providerCreated=await createRes.json().catch(()=>null);
      if(!createRes.ok||providerCreated?.status!=="SUCCESS"){
        const reason=providerCreated?.code?String(providerCreated.code)+": "+String(providerCreated.message||""):String(providerCreated?.message||"Porkbun registration failed.");
        await admin.from("tenant_domain_orders").update({status:"failed",failure_reason:reason,metadata:{...registeringMetadata,porkbun_registration_failed_at:new Date().toISOString(),porkbun_response_request_id:providerCreated?.requestId||null}}).eq("id",orderId);
        return json({error:"Porkbun sandbox registration failed.",provider_code:providerCreated?.code||null,provider_message:providerCreated?.message||null},502);
      }
      created={orderId:String(providerCreated.orderId),requestId:providerCreated.requestId||null};
    }

    const orderMetadata={...registeringMetadata,porkbun_provider_order_id:String(created.orderId),porkbun_registration_request_id:created.requestId||null,porkbun_sandbox:true};

    const contact={
      firstName:String(registrant.registrant_name).trim().split(/\s+/)[0],
      lastName:String(registrant.registrant_name).trim().split(/\s+/).slice(1).join(" ")||"Registrant",
      organization:registrant.organisation||"",
      address1:registrant.address_line1,
      address2:registrant.address_line2||"",
      city:registrant.city,
      state:registrant.region||"",
      postalCode:registrant.postal_code,
      country:registrant.country_code,
      phone:String(registrant.phone).replace(/^\+/,"").replace(/\D/g,""),
      phoneCountryCode:String(registrant.phone).match(/^\+(\d{1,3})/)?.[1] || (registrant.country_code==="GB"?"44":""),
      email:registrant.email
    };

    const normalize=(value:unknown)=>String(value??"").trim().toLowerCase();
    const expectedFirst=normalize(contact.firstName);
    const expectedLast=normalize(contact.lastName);
    const expectedEmail=normalize(contact.email);
    const expectedPostal=normalize(contact.postalCode);

    const getContacts=async()=>{
      const res=await fetch("https://api.porkbun.com/api/json/v3/domain/getContacts/"+encodeURIComponent(order.hostname),{headers:{"X-API-Key":API_KEY,"X-Secret-API-Key":SECRET}});
      const body=await res.json().catch(()=>null);
      return {res,body};
    };
    const matchesSavedRegistrant=(body:any)=>{
      const current=body?.contacts?.registrant;
      if(!current) return false;
      const currentNameFirst=normalize(current.firstName);
      const currentNameLast=normalize(current.lastName);
      const currentEmail=normalize(current.email);
      const currentPostal=normalize(current.postalCode);
      return currentEmail===expectedEmail && currentPostal===expectedPostal &&
        currentNameFirst===expectedFirst && currentNameLast===expectedLast;
    };

    // A .uk/.co.uk registration can already have the correct registrant stored by
    // Porkbun while the registry side of updateContacts returns V096. Check the
    // authoritative Porkbun contact record before treating that response as fatal.
    const existingContacts=await getContacts().catch(()=>null);
    const contactAlreadyApplied=Boolean(existingContacts?.res?.ok && matchesSavedRegistrant(existingContacts.body));

    if(!contactAlreadyApplied){
      const contactRes=await fetch("https://api.porkbun.com/api/json/v3/domain/updateContacts/"+encodeURIComponent(order.hostname),{
        method:"POST",
        headers:pbHeaders,
        body:JSON.stringify({contact,dryRun:true})
      });
      const contactPreview=await contactRes.json().catch(()=>null);
      if(!contactRes.ok||contactPreview?.status!=="SUCCESS"){
        const reason=contactPreview?.code?String(contactPreview.code)+": "+String(contactPreview.message||""):String(contactPreview?.message||"Porkbun registrant validation failed.");
        await admin.from("tenant_domain_orders").update({status:"registrant_details_saved",failure_reason:"Saved registrant requires provider contact validation: "+reason,provider_order_id:String(created.orderId),metadata:{...orderMetadata,porkbun_contact_dry_run_failed:true}}).eq("id",orderId);
        return json({error:"Sandbox registration succeeded, but the saved registrant could not be validated for application.",provider_order_id:created.orderId,provider_code:contactPreview?.code||null,provider_message:contactPreview?.message||null},502);
      }

      const contactRes2=await fetch("https://api.porkbun.com/api/json/v3/domain/updateContacts/"+encodeURIComponent(order.hostname),{
        method:"POST",
        headers:pbHeaders,
        body:JSON.stringify({contact})
      });
      const contactApplied=await contactRes2.json().catch(()=>null);
      if(!contactRes2.ok||contactApplied?.status!=="SUCCESS"){
        const postFailureContacts=await getContacts().catch(()=>null);
        const appliedDespiteRegistryError=Boolean(postFailureContacts?.res?.ok && matchesSavedRegistrant(postFailureContacts.body));
        if(!appliedDespiteRegistryError){
          const reason=contactApplied?.code?String(contactApplied.code)+": "+String(contactApplied.message||""):String(contactApplied?.message||"Porkbun registrant update failed.");
          await admin.from("tenant_domain_orders").update({status:"registrant_details_saved",failure_reason:"Saved registrant could not be applied: "+reason,provider_order_id:String(created.orderId),metadata:{...orderMetadata,porkbun_contact_update_failed:true}}).eq("id",orderId);
          return json({error:"Sandbox registration succeeded, but applying the saved registrant failed.",provider_order_id:created.orderId,provider_code:contactApplied?.code||null,provider_message:contactApplied?.message||null},502);
        }
      }
    }

    const domainRes=await fetch("https://api.porkbun.com/api/json/v3/domain/get/"+encodeURIComponent(order.hostname),{headers:{"X-API-Key":API_KEY,"X-Secret-API-Key":SECRET}});
    const domainInfo=await domainRes.json().catch(()=>null);
    if(!domainRes.ok||domainInfo?.status!=="SUCCESS"||!domainInfo?.domain){
      const reason=domainInfo?.code?String(domainInfo.code)+": "+String(domainInfo.message||""):String(domainInfo?.message||"Unable to verify registered domain.");
      await admin.from("tenant_domain_orders").update({status:"failed",failure_reason:"Sandbox registration completed but provider reconciliation lookup failed: "+reason,provider_order_id:String(created.orderId),metadata:{...orderMetadata,porkbun_reconciliation_lookup_failed:true}}).eq("id",orderId);
      return json({error:"Sandbox registration completed but provider reconciliation could not be verified.",provider_order_id:created.orderId},502);
    }

    const expiresAt=domainInfo.expireDate?new Date(domainInfo.expireDate.replace(" ","T")+"Z").toISOString():null;
    const registeredAt=domainInfo.createDate?new Date(domainInfo.createDate.replace(" ","T")+"Z").toISOString():new Date().toISOString();
    const tenantDomainMetadata={
      sandbox:true,
      source:"tenant_domain_order",
      domain_order_id:order.id,
      provider_order_id:String(created.orderId),
      provider_request_id:created.requestId||null,
      registrant_record_id:registrant.id,
      contact_updated:true
    };

    const {data:existing}=await admin.from("tenant_domains").select("id").eq("tenant_id",tenantId).eq("hostname",order.hostname).maybeSingle();
    let domainRow;
    if(existing){
      const {data:updated,error}=await admin.from("tenant_domains").update({
        hostname:order.hostname,status:"active",domain_type:"custom",acquisition_source:"domain_purchase",registrar_provider:"porkbun",registrar_domain_id:null,registered_at:registeredAt,expires_at:expiresAt,auto_renew:true,provider_metadata:tenantDomainMetadata,updated_at:new Date().toISOString()
      }).eq("id",existing.id).select("id").single();
      if(error) throw new Error("Unable to reconcile tenant domain: "+error.message);
      domainRow=updated;
    }else{
      const {data:createdDomain,error}=await admin.from("tenant_domains").insert({
        tenant_id:tenantId,hostname:order.hostname,status:"active",domain_type:"custom",is_primary:false,acquisition_source:"domain_purchase",registrar_provider:"porkbun",registrar_domain_id:null,registered_at:registeredAt,expires_at:expiresAt,auto_renew:true,provider_metadata:tenantDomainMetadata
      }).select("id").single();
      if(error) throw new Error("Unable to create tenant domain reconciliation: "+error.message);
      domainRow=createdDomain;
    }

    const finalMetadata={...orderMetadata,porkbun_registration_completed_at:new Date().toISOString(),porkbun_expire_date:domainInfo.expireDate||null,porkbun_contact_updated:true,porkbun_reconciled_tenant_domain_id:domainRow.id};
    const {error:orderUpdateError}=await admin.from("tenant_domain_orders").update({status:"registered",provider_order_id:String(created.orderId),provider_domain_id:null,purchased_at:registeredAt,expires_at:expiresAt,failure_reason:null,metadata:finalMetadata}).eq("id",orderId);
    if(orderUpdateError) throw new Error("Domain was reconciled but order finalisation failed: "+orderUpdateError.message);

    return json({status:"SUCCESS",order_id:orderId,hostname:order.hostname,provider:"porkbun",provider_order_id:String(created.orderId),provider_domain_id:null,registered_at:registeredAt,expires_at:expiresAt,tenant_domain_id:domainRow.id,sandbox:true});
  }catch(e){
    const message=e instanceof Error?e.message:String(e);
    if(orderId){
      const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
      await admin.from("tenant_domain_orders").update({status:"failed",failure_reason:message}).eq("id",orderId).eq("status","registering");
    }
    return json({error:message},500);
  }
});