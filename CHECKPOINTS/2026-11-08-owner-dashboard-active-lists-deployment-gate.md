# Owner dashboard active-list deployment gate

Date: 8 November 2026 (UTC)

## LIVE database state
- Research queue: 65 total 3D-printer records, 28 imported, 37 rejected; zero open queue rows across all categories.
- AI-agent tasks: 20 completed, zero queued/running/failed.
- Processed records remain in database history; do not delete them.

## TEST database state
- Zero open research queue rows.
- One queued 3D-printer smoke-test task: owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-02 (Creality Ender-3 V3 KE), plus one completed task.
- Keep the queued TEST smoke test until deliberately processed or cancelled.

## Current production UI/RPC behavior
- platform-owner-dashboard.html headings: “Outstanding research tasks” and “Research awaiting review”.
- platform-owner-dashboard.js loadGemmaTasks() requests p_status='active' (queued/running/failed only).
- platform-owner-dashboard.js loadGemmaQueue() requests p_status='open' (pending_review/needs_research/approved only).
- platform_owner_list_ai_agent_tasks and platform_owner_list_catalogue_research_queue implement those filters.
- Completed tasks and imported/rejected evidence remain in database history, hidden from default dashboard lists.
- worker/index.js sets Cache-Control: no-store on owner dashboard HTML/JS.

## Deployment issue
The user screenshot still shows the old “Queued and completed tasks” heading and processed records. This does not match current production HTML/JS or LIVE RPC definitions. The Cloudflare Worker named tradeflow (wrangler.jsonc) has not been verified/deployed from the latest production commit. Repository has no GitHub Actions deployment workflow.

Next action: check Cloudflare Workers & Pages > tradeflow > Deployments and deploy the latest production commit. Then hard-refresh the owner dashboard and confirm empty states. Do not delete completed history or rewrite statuses to compensate for stale assets. No Cloudflare deployment was performed from this session.
