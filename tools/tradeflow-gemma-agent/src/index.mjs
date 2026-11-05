import { readFile } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runTask } from './agent.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const args=process.argv.slice(2); const enqueue=args.includes('--enqueue'); if(args.includes('--apply')) throw new Error('--apply is retired: Gemma can only enqueue candidates for ChatGPT review'); const taskPath=args.find(x=>!x.startsWith('--'));
if(!taskPath)throw new Error('Usage: npm start -- tasks/example.json [--enqueue]');
const env={...process.env}; const envText=await readFile(resolve(root,'.env'),'utf8');
for(const line of envText.split(/\r?\n/)){const m=line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);if(m&&env[m[1]]===undefined)env[m[1]]=m[2].replace(/^['"]|['"]$/g,'');}
const input=JSON.parse(await readFile(resolve(process.cwd(),taskPath),'utf8'));const tasks=Array.isArray(input)?input:[input];
const limit=Math.max(1,Math.min(4,Number(env.WORKER_CONCURRENCY||2)));const results=[];let next=0;
async function worker(){while(next<tasks.length){const i=next++;try{results[i]=await runTask(tasks[i],env,{enqueue});}catch(e){results[i]={status:'failed-closed',task:tasks[i],error:e.message};}}}
await Promise.all(Array.from({length:Math.min(limit,tasks.length)},worker));
console.log(JSON.stringify({mode:enqueue?'ENQUEUE FOR CHATGPT REVIEW':'DRY RUN',workers:limit,results},null,2));if(results.some(x=>x.status==='failed-closed'))process.exitCode=1;