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
