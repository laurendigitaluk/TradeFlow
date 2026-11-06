import { readFile } from 'node:fs/promises';
import { combineProductResearchTasks } from './task-groups.mjs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runTask } from './agent.mjs';
import { reportAgent } from './agent-telemetry.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const enqueue = args.includes('--enqueue');
if (args.includes('--apply')) throw new Error('--apply is retired: Gemma can only enqueue candidates for ChatGPT review');
const taskPath = args.find(x => !x.startsWith('--'));
if (!taskPath) throw new Error('Usage: npm start -- tasks/example.json [--enqueue]');

// One configuration source for interactive runs and the background worker:
// the TradeFlow agent folder's .env, unless an explicit path is supplied.
const configPath = process.env.TRADEFLOW_GEMMA_ENV_FILE || resolve(root, '.env');
const env = { ...process.env };
const envText = await readFile(configPath, 'utf8');
for (const line of envText.split(/\r?\n/)) {
  const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
  if (match && env[match[1]] === undefined) env[match[1]] = match[2].replace(/^['"]|['"]$/g, '');
}

const roster = JSON.parse(await readFile(resolve(root, 'tasks/agent-roster.json'), 'utf8'));
const rosterByKey = new Map(roster.map(item => [item.agent_key, item]));
const input = JSON.parse(await readFile(resolve(process.cwd(), taskPath), 'utf8'));
const tasks = combineProductResearchTasks(Array.isArray(input) ? input : [input]);
const limit = Math.max(1, Math.min(4, Number(env.WORKER_CONCURRENCY || 2)));
const results = [];
let next = 0;

async function worker() {
  while (next < tasks.length) {
    const index = next++;
    const task = tasks[index];
    const key = task.agent_key || String(task.category_slug || task.branch_slug || 'general').toLowerCase().replace(/[^a-z0-9]+/g, '-');
    const identity = rosterByKey.get(key) || {
      agent_key: key,
      agent_name: 'Gemma — ' + (task.category_slug || task.branch_slug || 'Research'),
      category: task.category_slug || task.branch_slug || 'General research'
    };
    const taskKey = task.task_key || task.model || task.search_query || 'catalogue-research';
    await reportAgent(env, { ...identity, status: 'running', current_task: taskKey, event_type: 'task_started', task_key: taskKey });
    try {
      const result = await runTask(task, env, {
        enqueue,
        onProgress: async progress => {
          const message = progress.message || (progress.source ? 'Checking source: ' + progress.source : progress.stage);
          console.log('[' + taskKey + '] ' + message);
          await reportAgent(env, {
            ...identity, status: 'running', current_task: taskKey, event_type: 'progress', task_key: taskKey,
            message,
            details: { stage: progress.stage, checked: progress.checked, total: progress.total, source: progress.source || null }
          });
        }
      });
      const found = (result.candidates || []).filter(item => item.evidence_type).length;
      const queued = (result.writes || []).filter(item => item.status === 'queued-for-chatgpt-review').length;
      await reportAgent(env, {
        ...identity, status: 'idle', current_task: null, event_type: 'task_completed', task_key: taskKey,
        message: 'Finished ' + taskKey + ': ' + found + ' evidence candidates found; ' + queued + ' queued for review.',
        tasks_completed_delta: 1, candidates_found_delta: found, evidence_queued_delta: queued,
        details: { mode: enqueue ? 'enqueue' : 'dry-run' }
      });
      results[index] = result;
    } catch (error) {
      await reportAgent(env, {
        ...identity, status: 'error', current_task: taskKey, event_type: 'task_failed', task_key: taskKey,
        message: 'Research task failed: ' + error.message, last_error: error.message
      });
      results[index] = { status: 'failed-closed', task, error: error.message };
    }
  }
}

await Promise.all(Array.from({ length: Math.min(limit, tasks.length) }, worker));
console.log(JSON.stringify({ mode: enqueue ? 'ENQUEUE FOR CHATGPT REVIEW' : 'DRY RUN', workers: limit, results }, null, 2));
if (results.some(item => item.status === 'failed-closed')) process.exitCode = 1;
