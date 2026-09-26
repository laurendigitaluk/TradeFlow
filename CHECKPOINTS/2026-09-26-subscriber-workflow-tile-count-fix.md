# Subscriber dashboard workflow tile fix — 26 September 2026

## Issue
The dashboard's upper transaction panel correctly showed 2 new customer requests, but the six workflow tiles remained at "— / LOADING".

## Root cause
The tile loader called `subscriber_get_business_workflow_counts`. That function used `public.private.is_tenant_member(...)` while its `search_path` was empty. The live database rejected the function with a cross-database reference error, so the JavaScript catch handler left the tiles in their initial loading state.

## Repair
Updated `public.subscriber_get_business_workflow_counts(uuid)` to use the same tenant-membership and `buying.view` permission check already used successfully by `subscriber_get_business_workflow`, with a safe `pg_catalog, public` search path.

## Verification
Direct live database count for Camerashack tenant:
- Total buying items: 3
- Active buying items: 2

The expected Buying tile count is therefore 2. The existing upper workflow panel independently reports the same two active customer requests.

## Scope
No buying records or workflow states were changed. Only the dashboard tile-count RPC was repaired.
