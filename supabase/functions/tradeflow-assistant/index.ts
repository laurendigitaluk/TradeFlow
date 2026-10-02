import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json"}});
const fail=(message:string,status:number)=>json({error:message},status);

Deno.serve(async(req:Request)=>{
  if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
  if(req.method!=="POST")return fail("POST required",405);
  const auth=req.headers.get("Authorization");if(!auth)return fail("Authentication required",401);
  const token=auth.replace(/^Bearer\s+/i,"");
  const supabaseUrl=Deno.env.get("SUPABASE_URL"),serviceRoleKey=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const publishableKey=Deno.env.get("SUPABASE_ANON_KEY")||Deno.env.get("SUPABASE_PUBLISHABLE_KEY")||"";
  if(!supabaseUrl||!serviceRoleKey||!publishableKey)return fail("Assistant service configuration is incomplete",500);

  const userClient=createClient(supabaseUrl,publishableKey,{global:{headers:{Authorization:`Bearer ${token}`}}});
  const {data:{user},error:userError}=await userClient.auth.getUser(token);
  if(userError||!user)return fail("Authentication required",401);

  const body=await req.json().catch(()=>null);
  const tenantId=typeof body?.tenant_id==="string"?body.tenant_id.trim():"";
  const question=typeof body?.question==="string"?body.question.trim():"";
  const mode=typeof body?.mode==="string"?body.mode:"help";
  if(!tenantId)return fail("tenant_id is required",400);
  if(!question)return fail("question is required",400);
  if(question.length>4000)return fail("Question is too long.",400);
  if(!["help","research"].includes(mode))return fail("Unsupported assistant mode.",400);

  const {data:membership,error:membershipError}=await userClient.from("tenant_memberships")
    .select("tenant_id,role_code,status").eq("tenant_id",tenantId).eq("user_id",user.id).eq("status","active").maybeSingle();
  if(membershipError||!membership)return fail("You do not have access to this TradeFlow business.",403);

  const admin=createClient(supabaseUrl,serviceRoleKey);
  const {data:tenant,error:tenantError}=await admin.from("tenants").select("id,name").eq("id",tenantId).maybeSingle();
  if(tenantError||!tenant)return fail("TradeFlow business could not be resolved.",404);

  return json({
    status:"accepted",
    assistant:{mode,provider:"not_configured",read_only:true,tenant_id:tenantId,tenant_name:tenant.name,user_id:user.id,role:membership.role_code,question},
    next_step:"AI provider connection is intentionally not configured yet. No AI request or external provider charge was made."
  });
});