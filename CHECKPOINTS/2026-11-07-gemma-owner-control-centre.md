# Checkpoint — Gemma Owner Control Centre — 7 November 2026

## Branch
`feature/gemma-owner-control-centre-20261107` (created from `production`).

## Implemented in this increment
- Added Gemma Control Centre navigation and panel to the Platform Owner dashboard.
- Connected it to the existing LIVE owner-only telemetry RPC `platform_owner_get_ai_agent_control_centre(integer)`.
- Added agent counts, running count, completed-task/candidate/evidence totals, heartbeat freshness labels, agent table, latest 60 activity events and manual refresh.
- Added styling and updated AI Operating Manual and System Handbook.

## Verified database facts
- LIVE telemetry tables currently contain 11 agent rows and 526 activity events.
- LIVE RPC is executable by `authenticated` and not by `anon`; function checks active `platform_memberships`.
- LIVE does not have `platform_ai_agent_tasks` or the claim/complete/fail/heartbeat RPCs.
- TEST has the task queue and queue RPCs. Current Research PC worker polls TEST. Dashboard is read-only in this increment.

## Safety boundary
No schema/data changes, queue writes, catalogue/evidence imports, tenant/customer/order/payment/Stripe changes or Cloudflare deployment occurred. Do not describe the dashboard as deployed or task-controllable. Next phase: decide and implement a single owner-authenticated LIVE control plane, move worker polling deliberately, test in TEST, then deploy the dashboard to LIVE.
