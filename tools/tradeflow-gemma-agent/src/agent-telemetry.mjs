import { resolveControlPlane, TRADEFLOW_PROJECTS } from './control-plane.mjs';
function target(name,env){const p='TRADEFLOW_'+name+'_';const url=env[p+'URL'],key=env[p+'SERVICE_ROLE_KEY'];if(!url||!key)return null;if(new URL(url).hostname!==TRADEFLOW_PROJECTS[name]+'.supabase.co')throw new Error('Incorrect '+name+' telemetry target');return{name,url:url.replace(/\/$/,''),key};}
async function send(t,event){const r=await fetch(t.url+'/rest/v1/rpc/platform_ai_agent_report_event',{method:'POST',headers:{apikey:t.key,Authorization:'Bearer '+t.key,'Content-Type':'application/json'},body:JSON.stringify(event),signal:AbortSignal.timeout(10000)});const text=await r.text();if(!r.ok)throw new Error(t.name+' telemetry '+r.status+': '+text.slice(0,300));return text?JSON.parse(text):null;}
export async function reportAgent(env,record){const event={p_agent_key:record.agent_key,p_agent_name:record.agent_name,p_category:record.category||null,p_status:record.status||'idle',p_current_task:record.current_task||null,p_event_type:record.event_type||'heartbeat',p_message:record.message||record.agent_name+' heartbeat',p_task_key:record.task_key||null,p_tasks_completed_delta:record.tasks_completed_delta||0,p_candidates_found_delta:record.candidates_found_delta||0,p_evidence_queued_delta:record.evidence_queued_delta||0,p_last_error:record.last_error||null,p_details:record.details||{}};const selected=resolveControlPlane(env);const targets=[target(selected.name,env)];if(!targets.length)throw new Error(selected.name+' agent telemetry credentials are required');const results=await Promise.allSettled(targets.map(t=>send(t,event)));const output=results.map((r,i)=>({environment:targets[i].name,ok:r.status==='fulfilled',error:r.status==='rejected'?r.reason.message:null}));for(const r of output)if(!r.ok)console.warn('Agent telemetry failed for '+r.environment+': '+r.error);return output;}


export function buildWorkerHeartbeatDetails({activeStage=null,queueTaskId=null,workerId=null}={}){
 return {
  stage:'heartbeat',
  active_stage:activeStage||null,
  heartbeat:true,
  queue_task_id:queueTaskId||null,
  worker_id:workerId||null
 };
}
