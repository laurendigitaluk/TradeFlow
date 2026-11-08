# Project Memory — Gemma owner dashboard active-only lists

Date: 8 November 2026.

User reported that both the Research Queue and “Queued and completed tasks” dashboard sections grow indefinitely. Screenshots show processed research captures and completed tasks still listed.

Root cause verified in current production source:
- platform-owner-dashboard.js loadGemmaQueue sends p_status='all'.
- platform-owner-dashboard.js loadGemmaTasks omits status filter.
- platform_owner_list_ai_agent_tasks(integer) returns latest tasks regardless of status.
- This is dashboard history-query behaviour, not evidence that Gemma is still processing.

LIVE state:
- Research queue for 3D printers: 65 rows total; 28 imported, 37 rejected; zero open rows.
- Agent tasks: 20 rows, all completed.
- No rows deleted.

Fix prepared on PR #309 branch fix/gemma-dashboard-active-only-lists-20261108:
- Research queue active view uses p_status='open' => pending_review, needs_research, approved. Completed imported/rejected rows retained and retrievable through completed/all filters.
- Task active view uses p_status='active' => queued, running, failed. Completed/cancelled tasks retained but hidden. Failed remains visible until resolved/cancelled.
- UI labels updated to “Outstanding research tasks” and “Research awaiting review”.
- SQL migration 20261108223000_gemma_dashboard_active_only_lists.sql updates owner RPCs, preserving authorization.
- SQL DDL syntax-checked in a rollback transaction, then applied to LIVE after PR #309 passed CI and merged. Both RPC signatures and authenticated execute grants verified.
- No records deleted, no worker restarted, no TEST/LIVE data copied.

After merge, LIVE migration is applied and historical counts are unchanged. Verify Cloudflare Worker/static asset deployment and browser refresh; then confirm the two active lists display empty states. No next category explicitly specified in prior retrieved history; do not guess. Latest 3D-printer product sequence had Anycubic Kobra 3 Max V2 Standard Printer, but user has asked to move to the next product category after dashboard cleanup.