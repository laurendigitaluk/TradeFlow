# TradeFlow Gemma Research Pipeline — Diagnostic Roadmap

Updated: 7 November 2026
Status: LIVE control plane and dashboard task/review UI implemented on feature branch; Research PC rollout and end-to-end acceptance pending.

## Operating boundary
- LIVE project gxsrajtqzdjvmceqcpgv is the only authoritative research task and evidence-review queue.
- TEST project nnsshnfkjcflucjrftzi remains for software development, migrations and regression fixtures. Existing TEST records remain untouched.
- Gemma discovers candidate UK market evidence. Owner/ChatGPT verifies; no autonomous approval or master catalogue/evidence write is permitted.

## User action and entry points
- Platform Owner dashboard: platform-owner-dashboard.html → Gemma Control Centre.
- Task submission: platform-owner-dashboard.js → platform_owner_enqueue_ai_agent_task.
- Task list: platform_owner_list_ai_agent_tasks.
- Candidate review list: platform_owner_list_catalogue_research_queue.
- Candidate decision: platform_owner_review_catalogue_research_item.
- Research PC worker: tools/tradeflow-gemma-agent/src/task-worker.mjs.
- Research and evidence extraction: tools/tradeflow-gemma-agent/src/agent.mjs.
- Telemetry: tools/tradeflow-gemma-agent/src/agent-telemetry.mjs → platform_ai_agent_report_event.

## Data path
1. Platform owner submits a task through authenticated dashboard RPC.
2. LIVE platform_ai_agent_tasks stores the task; only service-role worker RPCs can claim, heartbeat, complete or fail it.
3. Research PC worker polls LIVE. It reports worker/task progress to LIVE telemetry.
4. Agent reads enabled platform_research_sources from LIVE. Category scope and source host checks remain fail-closed.
5. Candidate evidence is validated for exact product, direct UK source URL, visible GBP price, condition and evidence type.
6. Candidate is deduplicated and staged in LIVE platform_catalogue_research_queue.
7. Owner reviews candidate. Approval in this queue is a review decision only; it does not itself write shared_market_evidence or create a catalogue product.

## Supabase tables, functions and security
- LIVE tables: platform_ai_agent_tasks, platform_catalogue_research_queue, platform_ai_agent_status, platform_ai_agent_activity, platform_research_sources, catalogue_master_products, shared_market_evidence.
- Queue tables have RLS enabled; direct public/anon/authenticated table privileges revoked. Worker task RPCs are service-role-only.
- Owner RPCs check auth.uid() against active platform_memberships.
- No browser service-role key. Existing Research PC local environment is still holding TEST and LIVE credentials; do not copy secrets into dashboard or expose them in browser code.

## Failure points and diagnostics
- No fresh worker heartbeat: Research PC has not installed/started the current worker or LIVE URL/key is invalid.
- Task remains queued: worker polling/credentials/network or LIVE claim RPC issue.
- Task failed: inspect platform_ai_agent_tasks.last_error and matching LIVE platform_ai_agent_activity.
- No candidate rows: inspect source registry category_slugs, search provider output, direct-page eligibility, visible GBP price and extraction validation events.
- Queue candidate duplicate: dedupe_key unique constraint intentionally suppresses duplicate source/evidence rows.
- Category absent in LIVE master category registry: do not enqueue that category until the master data discrepancy is resolved.

## Known limitations / next acceptance gates
- Research PC has not yet been updated/restarted with this branch.
- Dashboard browser sign-in, task submit, worker claim, heartbeat, completion and candidate handoff must be tested as one end-to-end run.
- The first controlled task should be Creality K1. Confirm only 3D-printer-approved sources plus explicit universal Amazon UK/eBay UK are used; exclude gaming, drone and camera sources.
- Review queue approval is not an evidence import. A separately audited trusted server-side import workflow is required before shared_market_evidence writes.
- No production deployment claim until PR merge and the production Cloudflare Worker commit/runtime are independently verified.
