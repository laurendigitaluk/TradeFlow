# TradeFlow AI Manager — Developer Diagnostic Roadmap

Date: 10 November 2026
Status: Initial build / architecture discovery
Repository: laurendigitaluk/TradeFlow
Development branch: feature/tradeflow-ai-manager-desktop-20261110
TEST project: nnsshnfkjcflucjrftzi
LIVE project: gxsrajtqzdjvmceqcpgv

## User outcome

A simple Windows desktop application that runs weekly catalogue pricing-evidence research and research for newly added products. It should require minimal user interaction, persist progress, rotate between independently rate-limited genuinely free cloud AI providers, and never incur charges. Bionic may remain as an optional UI if its capabilities prove compatible, but the manager must not depend on Bionic's paid cloud plan.

## Mandatory safety boundaries

- No automatic paid fallback, credit purchase, subscription or billing activation.
- Provider requests must stop safely at quota/rate limits; unfinished jobs remain queued.
- Store provider keys locally using Windows Credential Manager; never store keys in source control, SQLite plaintext, logs or Supabase.
- Do not send customer, tenant, transaction, Stripe or other private operational data to free model providers. Only public master-catalogue product descriptors and public market evidence may be used.
- TEST and LIVE remain isolated. No TEST data copied to LIVE.
- No direct writes to master products or shared_market_evidence in the first release. Submit findings to the existing private Research Inbox for review.
- Never revive retired Gemma worker RPCs, task claims, agent status, Common Room or old desktop supervisor.
- Keep the existing TradeFlow Assistant separate.
- Do not deploy schema, function or runtime changes to LIVE until the new manager has been tested against TEST and explicitly released.

## Current verified system state (10 November 2026)

### GitHub

- Repository: laurendigitaluk/TradeFlow.
- Default branch `main` is TEST/staging development.
- `production` is the LIVE release branch.
- LIVE production branch head at inspection: cb525d802351935f2cb4ff2e09ffd48c96c3cc0e.
- Development feature branch created from main: `feature/tradeflow-ai-manager-desktop-20261110`.
- Latest retirement checkpoints:
  - `CHECKPOINTS/2026-11-10-gemma-retirement-reconciliation.md`
  - `CHECKPOINTS/2026-11-10-research-worker-platform-retirement-final.md`
  - `CHECKPOINTS/2026-11-10-tradeflow-bionic-research-inbox.md`

### Supabase

- LIVE: `gxsrajtqzdjvmceqcpgv`, eu-west-2, ACTIVE_HEALTHY.
- TEST: `nnsshnfkjcflucjrftzi`, eu-west-2, ACTIVE_HEALTHY.
- LIVE counts at inspection: 47,410 master products, 28,394 active products, 19,016 inactive products, 4,542 shared evidence rows (2,333 UK used GBP and 2,157 UK new GBP; remaining active evidence types/currency must be rechecked before any selection logic).
- LIVE `platform_research_reports`: 0 rows at inspection.
- Historical `platform_ai_agent_tasks`: 35 rows (34 completed, 1 failed); no queue/runtime reactivation permitted.
- LIVE `platform_ai_settings`: previously confirmed `active_provider='none'`, `allowed_providers=['none']`, `gemma_enabled=false`, `subscriber_provider_enabled=false`. Do not alter.
- TEST currently has `tradeflow-assistant` but no `tradeflow-research-mcp` Edge Function. No TEST MCP endpoint has yet been deployed.

### Existing LIVE Research MCP

Endpoint: `https://gxsrajtqzdjvmceqcpgv.supabase.co/functions/v1/tradeflow-research-mcp`

The existing MCP is active (deployed version 3, verify_jwt=false, bearer token required via Edge Function secret `TRADEFLOW_RESEARCH_MCP_TOKEN`). The bearer token must never be copied into GitHub, chat, logs or provider payloads.

Deployed tools verified from current Supabase function source:
1. `search_catalogue` — read-only product/package substring search, maximum 40 results.
2. `get_existing_evidence` — read-only evidence for one master product, maximum 100.
3. `list_research_reports` — read-only report list.
4. `get_research_report` — read-only report retrieval.
5. `submit_research_report` — writes report + private Markdown/JSON objects to the Research Inbox with status `submitted_for_review`; does not create products, approve evidence or write shared evidence.

### Critical source-control divergence

The current deployed LIVE Edge Function source has five tools, while `production` GitHub file `supabase/functions/tradeflow-research-mcp/index.ts` currently contains only three tool registrations (`search_catalogue`, `get_existing_evidence`, `submit_research_report`). Reconcile this divergence before modifying or redeploying the MCP. Treat deployed LIVE source as current runtime truth; do not overwrite it with the older repository copy.

### Missing capabilities for automated catalogue-wide research

The existing MCP does not provide:
- Cursor/paginated enumeration of active master products (its search tool is limited to 40 substring matches).
- Read-only access to the approved research-source registry `platform_research_sources`.
- A resumable server-side research queue for this new manager.
- A web-search/retrieval mechanism that works independently of whichever model provider is active.
- Any approved direct evidence-import tool (intentionally absent).

Therefore the desktop app must not claim it can scan all 28,394 active products yet. These are prerequisites to implement and test on TEST.

## Proposed application architecture

Windows desktop app (lightweight Python/Tkinter initially; packaged as a signed/unsigned Windows installer or portable executable after CI validation):

- Desktop UI: dashboard, provider setup/status, research queue, run history, settings.
- Local SQLite: durable job queue, per-product checkpoint, provider quota state, run logs without secrets.
- Windows Credential Manager: provider API keys and MCP bearer token.
- Provider router: independent adapters for free-only Groq, Google Gemini free tier, and OpenRouter models explicitly marked `:free`; optional providers only after their billing/overage behaviour is proven to be hard-stopped.
- Provider policy: no paid model IDs; OpenRouter model must end in `:free`; no credit top-ups; no billing activation; HTTP 429/quota errors mark provider unavailable until reset; never retry through a paid route.
- MCP client: use existing authenticated LIVE Research MCP only for read-only catalogue/evidence access and report submission. Discover tool list at runtime and refuse full-catalogue mode unless pagination/source tools are present.
- Research execution: one product or small deterministic batch per durable job; validate model output against a strict JSON schema; attach source URLs, GBP prices, condition, availability, observed date and provenance; reject unverifiable/mismatched evidence.
- Scheduling: weekly scan when the PC is running; scan newly added products on next run; resume from last committed job; pause when all providers are limited/offline; no background execution while PC is powered off.
- Bionic: optional integration only after verifying its custom-provider/MCP compatibility. Do not require Bionic or its paid plan.

## Planned delivery stages

1. Desktop shell, secure credential storage, provider health checks, strict free-only routing and local resumable queue.
2. MCP client and compatibility check against current LIVE tools; keep report-only behaviour.
3. Add paginated product enumeration and approved-source registry read tools to TEST MCP; reconcile deployed/source-control mismatch first.
4. Add compliant search/retrieval layer and deterministic evidence validation; confirm provider free quotas and no-billing setup.
5. End-to-end TEST run with a small sample; verify saved reports and pause/resume on simulated 429/quota exhaustion.
6. Update both system manuals, this roadmap and project checkpoint; obtain release approval before any LIVE deployment.
7. Build Windows installer through GitHub Actions; user should only need a normal installer and one-time provider/MCP authorisation, not manual PowerShell commands.

## Known limitations

- Free cloud quotas are finite, provider-controlled and can change. Multi-provider failover increases combined free capacity but cannot guarantee unlimited or uninterrupted service.
- A desktop app only runs scheduled jobs while the PC is powered on and connected to the internet.
- Current Research MCP is report-only and cannot import approved evidence into `shared_market_evidence`.
- The number of active products is 28,394; a literal fresh web search for every product every week may exceed combined free quotas. The job planner must prioritise new products and stale/missing evidence and report the remainder transparently.
