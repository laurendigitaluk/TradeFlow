# TradeFlow LIVE Security Continuation Checkpoint — 22 October 2026

## Environment
- Repository: `laurendigitaluk/TradeFlow`
- Branch: `production`
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- TEST remains reference-only and was not changed.

## Changes applied
1. LIVE migration `20261022144655_secure_test_registration_and_scope_domain_rpcs_20261022` was applied and source-controlled at the matching timestamped migration path.
2. `admin_complete_test_registration` and `staff_complete_test_registration` now require active test-lab tenants, not just reserved slugs.
3. Tenant-explicit versions of the custom-domain status/request RPCs now validate the authenticated user's active membership and `website.manage` permission for the exact selected tenant.
4. Legacy domain RPC signatures remain available for existing single-tenant sessions, but fail closed when the user has multiple active tenant memberships.
5. `domain-settings.js` now sends `p_tenant_id` with both RPC calls.
6. The published-content active-tenant migration source filename was aligned with remote LIVE migration version `20261022143445`.
7. Source for `platform-create-complimentary-subscriber` was restored to the production branch and the function was deployed to LIVE version 2. JWT verification remains enabled. CORS now explicitly allows POST/OPTIONS, stale TEST wording is corrected, and raw RPC details / invited user ID are no longer returned to the browser.

## Verification performed
- LIVE migration history confirms versions `20261022143445` and `20261022144655`.
- SQL privilege checks confirm the new domain RPC signatures are SECURITY DEFINER, `anon` cannot execute them, and `authenticated` can.
- LIVE has zero active reserved test slugs and zero active test-lab tenants at this snapshot.
- The deployed complimentary-subscriber Edge Function source exactly matches the source-controlled production file; deployed version is 2, JWT verification is true.
- Verification did not create domain requests, invitations, or business records.

## Not yet verified
- No browser-level signed-in subscriber domain request/status smoke test was run.
- No controlled owner-portal complimentary subscriber invitation/provisioning test was run.
- Full tenant-isolation and payment/Stripe end-to-end tests remain outstanding.
- Continue reviewing remaining authenticated SECURITY DEFINER functions and enable leaked-password protection through supported Auth configuration. LIVE has an active `tradeflow-notification-queue` cron job running every minute via `net.http_post`, using Vault secrets named `tradeflow_project_url` and `tradeflow_notification_processor_secret` and the `x-tradeflow-cron-secret` header. `process-notification-queue` is version 10 with JWT verification disabled but checks that secret. Do not move `pg_net` or alter the cron job until the queue path is regression-tested.
- Do not bulk-merge TEST into LIVE; branches previously diverged substantially.
- Do not change catalogue, pricing, or evidence ingestion in this workstream.


### Post-change Supabase advisor snapshot — 22 October 2026, 14:50 UTC

- Security: 8 anonymous-executable SECURITY DEFINER RPCs (reviewed as intended public catalogue/published-content/plan endpoints); 167 authenticated-executable SECURITY DEFINER functions requiring continued individual review; `pg_net` extension reported in `public`; leaked-password protection disabled.
- Performance: 65 unindexed foreign keys, 166 RLS init-plan warnings, 64 unused-index notices, 14 multiple-permissive-policy warnings, 3 duplicate-index notices, and an informational Auth connection-allocation warning.
- These advisor findings are not proof of exploitable vulnerabilities on their own. Do not blanket-revoke RPCs or drop indexes. Prioritize authorization review of privileged functions and verify each index/policy against actual query plans and workload before changing it.
