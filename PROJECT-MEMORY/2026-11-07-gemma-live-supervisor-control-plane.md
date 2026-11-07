# Project memory — Gemma LIVE supervisor control plane

The user's agreed operating model is LIVE-only for genuine research tasks and candidate evidence. TEST is retained for code/migration/regression work; never delete or copy existing TEST records.

Branch: feature/gemma-dashboard-supervisor-20261107.
LIVE Supabase: gxsrajtqzdjvmceqcpgv.
TEST Supabase: nnsshnfkjcflucjrftzi.

LIVE now has task and candidate review queues. Dashboard owner RPCs are authenticated by active platform_memberships. Worker RPCs are service-role-only. Dashboard has task submission and queue views. Worker source now targets LIVE for polling, approved source registry reads, candidate staging and telemetry.

Important: Research PC has NOT been updated/restarted. No end-to-end run has been verified. Candidate approval is a review state only, not a write to catalogue_master_products or shared_market_evidence. Do not claim deployment. Preserve local .env file during any PC update. LIVE Stripe and subscriber data are outside this change.
