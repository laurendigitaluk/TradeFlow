# Gemma LIVE supervisor control plane checkpoint

Date: 7 November 2026
Branch: feature/gemma-dashboard-supervisor-20261107

## User decision
LIVE is the sole authoritative product research queue and evidence-review environment. TEST remains for software development and regression only. Existing TEST records are preserved.

## Implemented
- LIVE migration created platform_ai_agent_tasks and platform_catalogue_research_queue with RLS and restricted grants.
- LIVE worker claim/heartbeat/complete/fail RPCs are service-role-only.
- Owner RPCs added for enqueueing tasks, listing tasks, listing research candidates and recording review decisions; each checks active platform_memberships.
- Platform Owner dashboard gained task submission, task queue and LIVE candidate queue panels.
- Research agent code changed to read approved research sources from LIVE and stage candidates in LIVE.
- Worker code changed to poll LIVE; telemetry code reports to LIVE only.
- Both manuals updated; diagnostic roadmap added.

## Verified
- LIVE contains platform_ai_agent_tasks and platform_catalogue_research_queue.
- LIVE also contains shared_market_evidence and catalogue_master_products.
- RLS is enabled on both new queue tables.
- Migration was applied successfully to LIVE.
- Existing TEST queue and data were not changed by this work.

## Not yet verified
- Research PC has not been updated or restarted.
- No end-to-end dashboard → LIVE task → PC claim → research → LIVE review candidate run has occurred.
- No catalogue product or shared_market_evidence write is implemented by this feature.
- Feature branch is not production deployment.

## Next
1. Add/verify CI tests for LIVE-only queue routing and dashboard task submission.
2. Confirm the candidate review queue insertion and category-scoped source registry in LIVE.
3. Update Research PC code without overwriting its separate .env configuration.
4. Run Creality K1 controlled task from dashboard and verify each hop.
5. Only after acceptance, merge and independently verify production Worker deployment.
