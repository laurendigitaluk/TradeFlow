# Project Memory — Owner dashboard active-list deployment gate

Date: 8 November 2026.

The user wants processed Gemma research to disappear from the active owner dashboard while completed history remains stored.

Current production source is already correct:
- platform-owner-dashboard.html headings: Outstanding research tasks; Research awaiting review.
- platform-owner-dashboard.js calls platform_owner_list_ai_agent_tasks with p_status='active' and platform_owner_list_catalogue_research_queue with p_status='open'.
- LIVE RPC active filter = queued/running/failed only; open queue filter = pending_review/needs_research/approved only.
- Completed task/evidence history remains in the database, hidden from the default lists.
- worker/index.js sets Cache-Control: no-store for owner dashboard HTML and JS.

LIVE database: 65 3D-printer queue records, 28 imported, 37 rejected; 0 open queue rows across all categories; 20 completed tasks; 0 active tasks.
TEST database: 0 open queue rows; 1 queued 3D-printer smoke task for Creality Ender-3 V3 KE (owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-02), 1 completed task. Do not cancel the queued smoke task without review.

The user screenshot still displays the older “Queued and completed tasks” heading and processed rows. This is a deployment mismatch, not a LIVE DB filter problem. Worker name is tradeflow from wrangler.jsonc. There is no GitHub Actions deploy workflow. Verify Cloudflare Workers & Pages > tradeflow > Deployments and deploy the latest production commit; then hard-refresh the dashboard. No Cloudflare deployment was performed. Do not delete completed history or change statuses to compensate for stale frontend assets.
