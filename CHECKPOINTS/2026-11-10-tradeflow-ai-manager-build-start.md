# Checkpoint — TradeFlow AI Manager build start

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Feature branch: feature/tradeflow-ai-manager-desktop-20261110
Scope: New standalone Windows desktop manager for free-only cloud AI research orchestration.

## User-authorised outcome
Build a desktop application so the owner can run weekly product-catalogue pricing-evidence scans and research new products with minimal manual interaction. Rotate across multiple free cloud providers when one reaches its limit, persist progress, resume automatically and never incur paid usage. Keep Bionic only if compatible.

## Pre-change inspection completed
- Retrieved current project continuity checkpoints and Bionic Research Inbox handoff.
- Inspected GitHub repository, branch roles, production branch head, system/AI manuals and current tree.
- Confirmed TEST project `nnsshnfkjcflucjrftzi` and LIVE project `gxsrajtqzdjvmceqcpgv` are ACTIVE_HEALTHY.
- Inspected LIVE table inventory, catalogue/evidence/report schemas, migration history, Edge Function inventory and deployed Research MCP source.
- Confirmed 28,394 active master products, 4,542 evidence rows and zero submitted research reports at inspection.
- Confirmed old research-worker runtime was retired and its RPC grants revoked; historical task rows remain and must not be reused.
- Confirmed deployed LIVE Research MCP has five tools, but the GitHub production source currently contains only three. This source/runtime divergence must be reconciled before any MCP change.
- Confirmed TEST has no Research MCP Edge Function yet.

## Safety boundaries
- No LIVE schema, Edge Function, product, evidence, customer, tenant, Stripe or website changes made.
- No old Gemma worker/runtime restored.
- No paid provider fallback or automatic billing.
- Research reports remain `submitted_for_review`; no automatic evidence import.
- TEST and LIVE remain separate.

## Next implementation work
Build the desktop shell and provider/queue core on this isolated feature branch. Then add and test required MCP pagination/source-registry capabilities on TEST before enabling catalogue-wide research. Do not claim the application is production-ready until Windows packaging, quota failover, resumability, MCP connection and end-to-end TEST report submission are verified.
