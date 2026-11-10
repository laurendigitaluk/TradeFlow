import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors={ "Access-Control-Allow-Origin":"https://owner.laurendigital.co.uk", "Access-Control-Allow-Headers":"authorization, apikey, content-type", "Access-Control-Allow-Methods":"POST, OPTIONS" };
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json"}});
Deno.serve(async(req:Request)=>{
 if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
 if(req.method!=="POST")return json({error:"Method not allowed"},405);
 const url=Deno.env.get("SUPABASE_URL"),anon=Deno.env.get("SUPABASE_ANON_KEY"),service=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
 if(!url||!anon||!service)return json({error:"Server configuration incomplete"},500);
 const auth=req.headers.get("Authorization")||"";
 const userClient=createClient(url,anon,{global:{headers:{Authorization:auth}}});
 const {data:{user},error:userError}=await userClient.auth.getUser();
 if(userError||!user)return json({error:"Sign in required"},401);
 const admin=createClient(url,service);
 const {data:membership}=await admin.from("platform_memberships").select("id").eq("user_id",user.id).eq("status","active").limit(1).maybeSingle();
 if(!membership)return json({error:"Platform owner access required"},403);
 let body:any;try{body=await req.json()}catch{return json({error:"Invalid JSON"},400)}
 if(body?.action!=="test_provider"||!["gemini","groq","openrouter"].includes(body?.provider_key))return json({error:"Unsupported action"},400);
 const provider=body.provider_key;
 const {data:cfg,error:cfgError}=await admin.from("platform_cloud_ai_providers").select("provider_key,model_id,enabled,free_tier_confirmed,status").eq("provider_key",provider).maybeSingle();
 if(cfgError||!cfg)return json({error:"Provider is not configured"},404);
 if(!cfg.enabled||!cfg.free_tier_confirmed)return json({error:"Provider is disabled or free-tier status has not been confirmed"},409);
 const {data:key,error:keyError}=await admin.rpc("get_cloud_ai_provider_secret",{p_provider_key:provider});
 if(keyError||!key)return json({error:"Provider key is not available in the server vault"},409);
 let endpoint="",headers:Record<string,string>={};
 if(provider==="gemini"){endpoint="https://generativelanguage.googleapis.com/v1beta/models";headers={"x-goog-api-key":key};}
 if(provider==="groq"){endpoint="https://api.groq.com/openai/v1/models";headers={Authorization:"Bearer "+key};}
 if(provider==="openrouter"){endpoint="https://openrouter.ai/api/v1/models";headers={Authorization:"Bearer "+key};}
 try{
  const response=await fetch(endpoint,{headers,signal:AbortSignal.timeout(12000)});
  const text=await response.text();
  if(!response.ok){
   const cooldown=response.status===402||response.status===429||response.status===403;
   await admin.from("platform_cloud_ai_providers").update({status:cooldown?"cooldown":"error",cooldown_until:cooldown?new Date(Date.now()+60*60*1000).toISOString():null,last_error:"Provider check returned HTTP "+response.status,last_checked_at:new Date().toISOString(),updated_at:new Date().toISOString()}).eq("provider_key",provider);
   return json({ok:false,error:"Provider returned HTTP "+response.status+"; it has not been used for research.",paused:cooldown},502);
  }
  let data:any;try{data=JSON.parse(text)}catch{data={}};
  let models=Array.isArray(data.models)?data.models:(Array.isArray(data.data)?data.data:[]);
  const modelAvailable=models.some((m:any)=>m.name===("models/"+cfg.model_id)||m.id===cfg.model_id);
  await admin.from("platform_cloud_ai_providers").update({status:"ready",cooldown_until:null,last_error:null,last_checked_at:new Date().toISOString(),updated_at:new Date().toISOString()}).eq("provider_key",provider);
  return json({ok:true,provider_key:provider,model_id:cfg.model_id,model_listed:modelAvailable,models_checked:models.length,note:modelAvailable?"Configured model appears in provider model list.":"Connection works, but the configured model was not found in the returned model list; check the exact model ID."});
 }catch(e){
  const message=e instanceof Error?e.message:"Provider connection failed";
  await admin.from("platform_cloud_ai_providers").update({status:"error",last_error:message.slice(0,500),last_checked_at:new Date().toISOString(),updated_at:new Date().toISOString()}).eq("provider_key",provider);
  return json({error:"Provider connection failed: "+message},502);
 }
});