import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
const RESEND_API_URL="https://api.resend.com/emails";
const SUPABASE_URL=Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase=createClient(SUPABASE_URL,SERVICE_ROLE_KEY);
const json=(b:unknown,s=200)=>new Response(JSON.stringify(b),{status:s,headers:{"Content-Type":"application/json"}});
function escapeHtml(v:unknown){return String(v??"").replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;").replaceAll('"',"&quot;").replaceAll("'","&#39;")}
function render(t:string,p:Record<string,unknown>){return t.replace(/{{\s*([a-zA-Z0-9_.-]+)\s*}}/g,(_m,k)=>{const v=k.split(".").reduce((a:unknown,x:string)=>a&&typeof a==="object"&&x in (a as Record<string,unknown>)?(a as Record<string,unknown>)[x]:"",p);return escapeHtml(v)})}
async function expectedCronSecret(){const {data,error}=await supabase.rpc("notification_processor_auth_secret");if(error)throw error;return data as string}
Deno.serve(async(req:Request)=>{
 if(req.method!=="POST")return json({error:"Method not allowed"},405);
 const supplied=req.headers.get("x-tradeflow-cron-secret")||"",expected=await expectedCronSecret();
 if(!supplied||!expected||supplied!==expected)return json({error:"Unauthorized"},401);
 const resendApiKey=Deno.env.get("RESEND_API_KEY");if(!resendApiKey)return json({ok:false,status:"not_configured",message:"RESEND_API_KEY is not configured."},503);
 const {data:queue,error:claimError}=await supabase.rpc("claim_notification_queue_batch",{p_limit:20});
 if(claimError)return json({ok:false,error:claimError.message},500);
 const results:Record<string,unknown>[]=[];
 for(const item of (queue||[]) as Record<string,unknown>[]){const id=String(item.id);try{
  const settings=(item.email_settings||{}) as Record<string,unknown>,fromEmail=String(settings.sender_email||"");
  if(!fromEmail||settings.email_enabled!==true)throw new Error("Business email sending is not enabled.");
  if(String(settings.sender_verification_status||"")!=="verified")throw new Error("Business sending address is not verified.");
  const payload=(item.payload||{}) as Record<string,unknown>,subject=render(String(item.subject||""),payload),html=render(String(item.body_template||""),payload),senderName=String(settings.sender_name||""),from=senderName?senderName+" <"+fromEmail+">":fromEmail;
  const body:Record<string,unknown>={from,to:[String(item.recipient_email)],subject,html};if(settings.reply_to_email)body.reply_to=String(settings.reply_to_email);
  const response=await fetch(RESEND_API_URL,{method:"POST",headers:{Authorization:"Bearer "+resendApiKey,"Content-Type":"application/json","Idempotency-Key":String(item.idempotency_key)},body:JSON.stringify(body)});
  const txt=await response.text();let provider:Record<string,unknown>;try{provider=JSON.parse(txt)}catch{provider={raw:txt}}
  if(!response.ok)throw new Error(String(provider.message||provider.error||txt||"Resend request failed"));
  const {error:e}=await supabase.rpc("mark_notification_sent",{p_id:id,p_provider:"resend",p_provider_message_id:String(provider.id||"")});if(e)throw e;
  results.push({id,status:"sent",provider_message_id:provider.id||null});
 }catch(e){const message=e instanceof Error?e.message:String(e);const {error:fe}=await supabase.rpc("mark_notification_failed",{p_id:id,p_error:message});results.push({id,status:"failed",error:fe?fe.message:message})}}
 return json({ok:true,processed:results.length,results});
});
