# TradeFlow Gemma — Free local search provider

**Date:** 5 November 2026  
**Branch:** feature/tradeflow-gemma-agent-foundation-20261105  
**Status:** Implemented in GitHub feature branch; Research PC installation and runtime verification pending.

## Decision

The user requires zero expenditure for search because Gemma will perform high-volume product, used/new pricing-evidence and official product-release research. Do not use Brave Search API or any paid search API, subscription, credit pack, or payment-card registration. No provider requiring payment may be enabled without a separate explicit user decision.

## Implementation

- `src/agent.mjs`: exported `searchWebResults` uses local SearXNG JSON API at `SEARXNG_BASE_URL`, default `http://127.0.0.1:8080`. Adds UK GBP query context and English-UK language; maps title, URL and snippet into the existing source pipeline.
- `src/release-monitor.mjs`: official manufacturer release discovery also uses local SearXNG and retains its official-domain allowlist and direct-page verification.
- `.env.example`: removed `BRAVE_SEARCH_API_KEY`; added `SEARXNG_BASE_URL`.
- `docker-compose.yml`: SearXNG container, port bound to loopback only (127.0.0.1:8080).
- `searxng/settings.yml`: enables JSON search format.
- `Start-TradeFlow-Gemma.ps1`: checks local SearXNG JSON endpoint before tests/research.
- `test/agent.test.mjs`: added no-key local endpoint and unavailable-service tests.
- `README.md`: documents free local setup and upstream engine rate-limit caveat.

## Limits and security

SearXNG software is free/open source and this architecture does not require an API subscription or payment card. Upstream search engines may rate-limit or block automated queries; therefore do not promise unlimited throughput. The worker must fail closed if search is unavailable and must not invent source URLs. Local SearXNG is bound to loopback, not exposed to the LAN.

## Verification boundary

GitHub feature-branch edits are committed. Research PC has not yet downloaded this revision, Docker Desktop/SearXNG have not yet been installed or started, and `npm test` has not yet been run against this revised branch on the PC. No Supabase database, queue, catalogue, evidence, tenant, payment, Stripe, Worker or deployment changes were made. TEST and LIVE application branches remain untouched.


## External Research PC secrets configuration — 5 November 2026

Preserve the existing separate GearCashOut configuration folder. The Gemma PowerShell launcher and Node entry point now read the existing secrets file at `C:\\GearCashOut-Config\\.env` by default; an alternate path can be supplied through `TRADEFLOW_GEMMA_ENV_FILE`. Do not create a new `.env` inside the downloaded repository, copy `.env.example` over the existing secrets file, or move/rename the GearCashOut config folder. The launcher validates required TradeFlow TEST/LIVE setting names and project hostnames without printing secret values. SearXNG uses its built-in local default unless `SEARXNG_BASE_URL` is already configured. Changes are committed on the Gemma feature branch only; no PC config, Supabase data or deployment has been changed.


## Gemma Research PC extraction performance correction — 5 November 2026

Research PC runtime diagnosis confirmed that local SearXNG and direct manufacturer-page retrieval work: the tested Creality UK page returned HTTP 200 and 5,807 characters of extracted text in approximately 1.25 seconds. A direct Ollama chat request using the installed `gemma3:4b` model did not complete within a 60-second diagnostic window. The installed model was visible in `ollama ps` with a 4,096-token context. The earlier agent implementation used the generic 30-second HTTP helper for Ollama extraction and allowed two research workers to issue model calls concurrently; this was too restrictive for the Research PC runtime.

Correction committed to the Gemma feature branch:
- Ollama extraction now uses its own configurable timeout: `OLLAMA_TIMEOUT_MS`, default 180,000 ms and bounded to 60,000–300,000 ms.
- Ollama requests are serialized through a process-local queue to avoid competing Gemma 3 4B inference requests from concurrent research workers.
- Requests keep the model loaded for 10 minutes, use deterministic temperature 0, cap output at 256 tokens, and explicitly use the installed 4,096-token context.
- Direct-page text supplied to the model is capped at 10,000 characters to reduce context overflow risk.
- SearXNG request timeout, page-fetch timeout, Supabase request timeout, evidence validation, UK/GBP rules, exact TEST/LIVE product matching and review-queue boundary are unchanged.
- Timeout errors now identify the Ollama extraction stage and configured duration.

Runtime evidence before correction: two dry runs completed with zero verified candidates and no queue writes. The TEST research queue remained at zero rows; LIVE has no research queue table and was not written. No catalogue/evidence, tenant, customer, payment, Stripe, schema, RLS, RPC, Edge Function, Worker or deployment changes were made.

Commit: `64e78d95f3f114ec73c4f9eee6b2b71abd3fe85b`.
Status: source and documentation updated on the feature branch; Research PC download and one post-fix validation run remain outstanding. Do not use `-Enqueue` until a dry run returns valid, reviewable evidence candidates.
