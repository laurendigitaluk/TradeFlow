import os from 'node:os';
import { combineProductResearchTasks } from './task-groups.mjs';
import { readFile } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runTask } from './agent.mjs';
import { reportAgent } from './agent-telemetry.mjs';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const envPath=process.env.TRADEFLOW_GEMMA_ENV_FILE||resolve(root,'.env');
const env={...process.env};
const envText=await readFile(envPath,'utf8');
for(const line of envText.split(/\r?\n/)){
 const m=line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
 if(m&&env[m[1]]===undefined)env[m[1]]=m[2].replace(/^['"]|['"]$/g,'');
}
const testUrl=env.TRADEFLOW_TEST_URL;
const testKey=env.TRADEFLOW_TEST_SERVICE_ROLE_KEY;
const liveUrl=env.TRADEFLOW_LIVE_URL;
const liveKey=env.TRADEFLOW_LIVE_SERVICE_ROLE_KEY;
if(!testUrl||!testKey||!liveUrl||!liveKey)throw new Error('TradeFlow TEST and LIVE URLs and service-role keys must be configured in the local .env file.');
if(new URL(testUrl).hostname!=='nnsshnfkjcflucjrftzi.supabase.co')throw new Error('TEST URL does not match the approved TradeFlow TEST project.');
if(new URL(liveUrl).hostname!=='gxsrajtqzdjvmceqcpgv.supabase.co')throw new Error('LIVE URL does not match the approved TradeFlow LIVE project.');
const db={url:testUrl.replace(/\/$/,''),key:testKey};
const workerId=(os.hostname()+'-'+process.pid).slice(0,120);
const pollMs=Math.max(5000,Math.min(60000,Number(env.GEMMA_POLL_INTERVAL_MS)||15000));
const leaseSeconds=600;
let stopping=false;
process.on('SIGINT',()=>{stopping=true;});
process.on('SIGTERM',()=>{stopping=true;});

async function rpc(name,args){
 const response=await fetch(db.url+'/rest/v1/rpc/'+name,{
  method:'POST',
  headers:{apikey:db.key,Authorization:'Bearer '+db.key,'Content-Type':'application/json'},
  body:JSON.stringify(args),signal:AbortSignal.timeout(20000)
 });
 const body=await response.text();
 if(!response.ok)throw new Error('TEST task queue '+name+' returned HTTP '+response.status+': '+body.slice(0,500));
 return body?JSON.parse(body):null;
}
async function safeReport(record){
 try{await reportAgent(env,record);}catch(error){console.error('[telemetry]',error.message);}
}
function agentIdentity(task){
 const key=String(task.agent_key||task.category_slug||task.branch_slug||'general-research').toLowerCase().replace(/[^a-z0-9]+/g,'-');
 return {agent_key:key,agent_name:'Gemma — '+(task.category_slug||task.branch_slug||'Catalogue research'),category:task.category_slug||task.branch_slug||'General research'};
}
async function processClaim(claim){
 const payload=claim.payload||{};
 if(claim.task_type!=='catalogue_research')throw new Error('Unsupported task type: '+claim.task_type);
 const tasks=combineProductResearchTasks(Array.isArray(payload.tasks)?payload.tasks:(Array.isArray(payload)?payload:[payload]));
 if(!tasks.length)throw new Error('Task payload contains no research tasks.');
 const outputs=[];
 const heartbeat=setInterval(()=>rpc('platform_ai_agent_heartbeat_task',{p_task_id:claim.id,p_worker_id:workerId,p_lease_seconds:leaseSeconds}).catch(e=>console.error('[heartbeat]',e.message)),45000);
 try{
  for(const task of tasks){
   if(stopping)throw new Error('Worker stopping before all subtasks completed.');
   const identity=agentIdentity(task);
   const taskKey=claim.task_key;
   await safeReport({...identity,status:'running',current_task:taskKey,event_type:'task_started',task_key:taskKey,message:'Started queued research task '+taskKey});
   const result=await runTask(task,env,{
    enqueue:true,
    onProgress:async p=>safeReport({...identity,status:'running',current_task:taskKey,event_type:'progress',task_key:taskKey,message:'Checking source '+p.checked+' of '+p.total+': '+p.source,details:{stage:p.stage,checked:p.checked,total:p.total,queue_task_id:claim.id}})
   });
   outputs.push(result);
   const candidates=(result.candidates||[]).filter(x=>x.evidence_type).length;
   const queued=(result.writes||[]).filter(x=>x.status==='queued-for-chatgpt-review').length;
   await safeReport({...identity,status:'idle',current_task:null,event_type:'task_completed',task_key:taskKey,message:'Completed '+taskKey+': '+candidates+' verified candidates; '+queued+' staged for owner review.',tasks_completed_delta:1,candidates_found_delta:candidates,evidence_queued_delta:queued,details:{queue_task_id:claim.id,mode:'background-queue'}});
  }
  await rpc('platform_ai_agent_complete_task',{p_task_id:claim.id,p_worker_id:workerId,p_result:{task_key:claim.task_key,subtasks:outputs.length,results:outputs}});
  console.log('[completed]',claim.task_key,'subtasks:',outputs.length);
 }catch(error){
  await rpc('platform_ai_agent_fail_task',{p_task_id:claim.id,p_worker_id:workerId,p_error:error.message}).catch(e=>console.error('[queue failure report]',e.message));
  await safeReport({agent_key:'gemma-task-worker',agent_name:'Gemma Task Worker',category:'Task control',status:'error',current_task:claim.task_key,event_type:'task_failed',task_key:claim.task_key,message:'Queued task failed: '+error.message,last_error:error.message,details:{queue_task_id:claim.id}});
  console.error('[failed]',claim.task_key,error.stack||error.message);
 }finally{clearInterval(heartbeat);}
}

console.log('[TradeFlow Gemma] background worker started');
console.log('[TradeFlow Gemma] worker:',workerId,'poll interval:',pollMs+'ms');
console.log('[TradeFlow Gemma] control plane: TEST only; evidence candidates go to owner review queue.');
await safeReport({agent_key:'gemma-task-worker',agent_name:'Gemma Task Worker',category:'Task control',status:'idle',event_type:'worker_started',message:'Persistent TradeFlow Gemma worker connected and polling TEST task queue.',details:{worker_id:workerId,poll_interval_ms:pollMs}});
while(!stopping){
 try{
  const claimed=await rpc('platform_ai_agent_claim_task',{p_worker_id:workerId,p_lease_seconds:leaseSeconds});
  const task=Array.isArray(claimed)?claimed[0]:claimed;
  if(task?.id){console.log('[claimed]',task.task_key,'attempt',task.attempts);await processClaim(task);}
  else await new Promise(resolve=>setTimeout(resolve,pollMs));
 }catch(error){
  console.error('[poll error]',error.message);
  await new Promise(resolve=>setTimeout(resolve,Math.min(60000,pollMs*2)));
 }
}
await safeReport({agent_key:'gemma-task-worker',agent_name:'Gemma Task Worker',category:'Task control',status:'idle',event_type:'worker_stopped',message:'TradeFlow Gemma worker stopped cleanly.',details:{worker_id:workerId}});
console.log('[TradeFlow Gemma] worker stopped');
