import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!,SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{"Content-Type":"application/json"}});
Deno.serve(async(req:Request)=>{
 if(req.method!=="POST")return json({error:"Method not allowed"},405);
 const auth=req.headers.get("Authorization")||"";if(!auth.startsWith("Bearer "))return json({error:"Unauthorized"},401);
 const {data:{user},error:userError}=await admin.auth.getUser(auth.slice(7));if(userError||!user)return json({error:"Unauthorized"},401);
 let body:Record<string,unknown>;try{body=await req.json()}catch{return json({error:"Invalid JSON"},400)}
 const tenantId=String(body.tenant_id||""),connectionId=String(body.connection_id||"");if(!tenantId||!connectionId)return json({error:"tenant_id and connection_id are required"},400);
 const {data:allowed,error:allowError}=await admin.rpc("has_tenant_permission",{p_tenant_id:tenantId,p_user_id:user.id,p_permission:"tenant.manage"});if(allowError||allowed!==true)return json({error:"Not authorised"},403);
 const {data:connection,error:connectionError}=await admin.from("shipping_provider_connections").select("id,provider,environment,api_client_id,status").eq("id",connectionId).eq("tenant_id",tenantId).maybeSingle();
 if(connectionError||!connection)return json({error:"Shipping connection not found"},404);
 if(connection.provider!=="parcel2go")return json({error:"Provider not supported by this tester"},400);
 const {data:secret,error:secretError}=await admin.rpc("shipping_provider_secret_for_service",{p_connection_id:connectionId});if(secretError||!secret)return json({error:"Provider credential could not be read securely"},500);
 const host=connection.environment==="live"?"https://www.parcel2go.com":"https://sandbox.parcel2go.com";
 const form=new URLSearchParams({grant_type:"client_credentials",scope:"public-api",client_id:connection.api_client_id,client_secret:String(secret)});
 const response=await fetch(host+"/auth/connect/token",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded"},body:form.toString()});
 const raw=await response.text();let payload:Record<string,unknown>={};try{payload=JSON.parse(raw)}catch{}
 if(!response.ok){await admin.from("shipping_provider_connections").update({status:"error",last_tested_at:new Date().toISOString(),updated_at:new Date().toISOString()}).eq("id",connectionId);return json({ok:false,status:"error",message:String(payload.error_description||payload.error||raw||"Parcel2Go authentication failed")},400)}
 await admin.from("shipping_provider_connections").update({status:"connected",last_tested_at:new Date().toISOString(),connected_at:new Date().toISOString(),updated_at:new Date().toISOString()}).eq("id",connectionId);
 return json({ok:true,status:"connected",provider:"parcel2go",environment:connection.environment});
});