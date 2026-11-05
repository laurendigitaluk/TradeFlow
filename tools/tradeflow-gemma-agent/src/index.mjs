import { readFile } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runTask } from './agent.mjs';
import { reportAgent } from './agent-telemetry.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const args=process.argv.slice(2);const enqueue=args.includes('--enqueue');
if(args.includes('--apply'))throw new Error('--apply is retired: Gemma can only enqueue candidates for ChatGPT review');
const taskPath=args.find(x=>!x.startsWith('--'));
if(!taskPath)throw new Error('Usage: npm start -- tasks/example.json [--enqueue]');
const env={...process.env};const envText=await readFile(resolve(root,'.env'),'utf8');
for(const line of envText.split(/\r?\n/)){const m=line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);if(m&&env[m[1]]===undefined)env[m[1]]=m[2].replace(/^['"]|['"]$/g,'');}
const roster=JSON.parse(await readFile(resolve(root,'tasks/agent-roster.json'),'utf8'));
const rosterByKey=new Map(roster.map(x=>[x.agent_key,x]));
const input=JSON.parse(await readFile(resolve(process.cwd(),taskPath),'utf8'));const tasks=Array.isArray(input)?input:[input];
const limit=Math.max(1,Math.min(4,Number(env.WORKER_CONCURRENCY||2)));const results=[];let next=0;
async function worker(){while(next<tasks.length){const i=next++;const task=tasks[i];const key=task.agent_key||String(task.category_slug||task.branch_slug||'general').toLowerCase().replace(/[^a-z0-9]+/g,'-');const identity=rosterByKey.get(key)||{agent_key:key,agent_name:'Gemma — '+(task.category_slug||task.branch_slug||'Research'),category:task.category_slug||task.branch_slug||'General research'};const taskKey=task.task_key||task.model||task.search_query||'catalogue-research';await reportAgent(env,{...identity,status:'running',current_task:taskKey,event_type:'task_started',task_key:taskKey,message:'Started research: '+taskKey});
try{const result=await runTask(task,env,{enqueue,onProgress:async progress=>reportAgent(env,{...identity,status:'running',current_task:taskKey,event_type:'progress',task_key:taskKey,message:'Checking source '+progress.checked+' of '+progress.total+': '+progress.source,details:{stage:progress.stage,checked:progress.checked,total:progress.total}})});const found=(result.candidates||[]).filter(x=>x.evidence_type).length;const queued=(result.writes||[]).filter(x=>x.status==='queued-for-chatgpt-review').length;await reportAgent(env,{...identity,status:'idle',current_task:null,event_type:'task_completed',task_key:taskKey,message:'Finished '+taskKey+': '+found+' evidence candidates found; '+queued+' queued for review.',tasks_completed_delta:1,candidates_found_delta:found,evidence_queued_delta:queued,details:{mode:enqueue?'enqueue':'dry-run'}});results[i]=result;}catch(e){await reportAgent(env,{...identity,status:'error',current_task:taskKey,event_type:'task_failed',task_key:taskKey,message:'Research task failed: '+e.message,last_error:e.message});results[i]={status:'failed-closed',task,error:e.message};}}}
await Promise.all(Array.from({length:Math.min(limit,tasks.length)},worker));
console.log(JSON.stringify({mode:enqueue?'ENQUEUE FOR CHATGPT REVIEW':'DRY RUN',workers:limit,results},null,2));
if(results.some(x=>x.status==='failed-closed'))process.exitCode=1;
