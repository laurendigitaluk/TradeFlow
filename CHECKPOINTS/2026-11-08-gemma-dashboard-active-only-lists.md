# Gemma owner dashboard active-only lists checkpoint

Date: 8 November 2026 (UTC)
Branch: fix/gemma-dashboard-active-only-lists-20261108
PR: #309 (merged to production; LIVE RPC migration applied)
Environment audited: TradeFlow LIVE.

## Root cause confirmed from current production code

- platform-owner-dashboard.js loadGemmaQueue explicitly sent p_status='all' to platform_owner_list_catalogue_research_queue. This returned imported/rejected history as if it were outstanding work.
- loadGemmaTasks omitted status filtering; platform_owner_list_ai_agent_tasks returned the newest 50 tasks regardless of status, including completed tasks.
- This was dashboard query behaviour, not Gemma continuing to generate active tasks.

## LIVE state at audit

- Research queue: 65 3D-printer records, 28 imported and 37 rejected, zero pending_review/needs_research/approved rows.
- Agent task table: 20 tasks, all status completed.
- No queue rows or task rows were deleted. Cloudflare Worker/static asset deployment is not independently confirmed.

## Intended dashboard contract

- Research queue active view: pending_review, needs_research, approved.
- Research queue completed history: imported/rejected, retained in DB and retrievable via p_status='completed' or 'all', but hidden from active dashboard.
- Agent task active view: queued, running, failed.
- Completed/cancelled tasks remain in DB but hidden from active dashboard. Failed remains visible until resolved or cancelled.
- Dashboard headings: Outstanding research tasks; Research awaiting review.
- Empty states tell owner that completed records are retained in database history.

## Changes on PR #309

- platform-owner-dashboard.js sends p_status='active' for tasks and p_status='open' for queue.
- platform-owner-dashboard.html updates the two section headings.
- Migration supabase/migrations/20261108223000_gemma_dashboard_active_only_lists.sql replaces the owner task-list RPC with a status-filtered version and extends the research-queue RPC with open/completed views.
- Migration preserves the owner-membership authorization check and authenticated execution grants.
- SQL DDL syntax-checked in a rollback transaction, then applied to LIVE after PR #309 passed CI and merged. Both new RPC signatures and authenticated execute grants verified.
- No records deleted, no worker restarted, no TEST/LIVE data copied.

## Deployment verification

After front-end deployment/browser refresh:
1. Confirm Research Queue active view is empty while 28 imported and 37 rejected remain retrievable.
2. Confirm Outstanding research tasks is empty while all 20 completed tasks remain stored.
3. Queue one controlled task; verify queued/running/failed remains visible as appropriate and disappears only after terminal completion.
4. Confirm no effect on task claim/complete/fail worker RPCs.

## Next category

No explicit next-category choice was found in the retrieved project history. Do not start a guessed category. Latest 3D-printer next product identified in prior planning was Anycubic Kobra 3 Max V2 — Standard Printer; the user now requests moving to the next product category after dashboard cleanup, so establish the intended category when the dashboard fix is deployed.
