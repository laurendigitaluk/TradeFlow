# Checkpoint — Gemma research-agent retirement reconciliation

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
LIVE project: gxsrajtqzdjvmceqcpgv

## Scope
Retire the local category research-worker platform, desktop supervisor/control-centre, shared agent-room runtime and associated new-evidence lab workflow. This does not include TradeFlow's core Cloudflare router, tenant manual Research Centre, or separate TradeFlow Assistant.

## Verified LIVE state
- LIVE project ACTIVE_HEALTHY.
- Retirement migration `20261110173027_retire_research_agent_runtime_permissions_20261110` is present in migration history.
- 12 agent-status rows are all idle.
- 35 task rows: 34 completed, 1 failed; no queued/running rows in the current snapshot.
- No execution grants remain for the retired RPC family to PUBLIC, anon, authenticated or service_role.
- No dedicated Gemma/research-worker Edge Function remains in the active function inventory.
- The separate `tradeflow-assistant` function remains untouched.

## Preserved LIVE records
47,410 master products; 38 master categories; 4,542 shared market-evidence rows; 23,993 tenant catalogue selections; 35 historical tasks; 12 status rows; 14,808 activity rows; 451 messages; 75 queue rows; 119 approved source-registry rows. No catalogue/evidence, customer, tenant, Stripe, published website or transaction records were deleted.

## GitHub reconciliation on production
- Public catalogue page and stylesheet updated: “Catalogue & AI Research” changed to “Product Catalogue”; AI-assisted research promotion removed; catalogue browser and evidence explanation retained.
- Removed retired operational documentation:
  - `docs/3D-PRINTER-GEMMA-AGENT-DIAGNOSTIC-ROADMAP.md`
  - `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-GEMMA-DESKTOP-CONTROL-CENTRE.md`
  - `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-GEMMA-RESEARCH-PIPELINE.md`
  - `docs/GEMMA-ISOLATED-AGENT-ARCHITECTURE.md`
  - `docs/TRADEFLOW-DEEP-SOURCE-RESEARCH-ROADMAP.md`
- Preserved historical checkpoints, project-memory records and applied migration files.
- `worker/index.js` and `wrangler.jsonc` are essential Cloudflare application routing/configuration, not Gemma runtime.
- `buying-research.html/js` is a separate manual tenant Research Centre writing `tenant_buying_research`; it is not the retired global agent workflow.

## GitHub limitations
The seven specialist and seven dated archive branch heads were previously cleaned. Older Gemma feature/fix/checkpoint branch refs and historical commits remain visible because the connected GitHub operations do not expose branch deletion or history purging. They are not production runtime. Do not claim the refs/history have been erased.

## Verification still pending
Cloudflare-served browser verification of the updated public catalogue page and the public route smoke test. Production GitHub commits are not deployment proof. No local PC changes or backup were made in this reconciliation.
