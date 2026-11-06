# GearCashOut research parity checkpoint

Date: 2026-11-06
Branch: `fix/gemma-gearcashout-research-parity-20261106`

## Purpose
Restore the proven GearCashOut research-discovery architecture in TradeFlow. Previous TradeFlow work copied only part of the approach and omitted Google discovery, explicit Amazon UK discovery and an approved-source registry.

## Changes in this branch
- Added optional Google Web Search Service and Google Programmable Search support using TradeFlow-owned `.env` settings.
- Added dedicated exact-model Amazon UK discovery queries. Amazon search pages remain discovery-only and are rejected as evidence; direct ASIN pages remain required.
- Added `platform_research_sources` migration for an approved TradeFlow source registry, separate from GearCashOut's source table.
- Added read-only TEST registry probing for approved retailer/marketplace domains using common site-search routes; discovered links still pass the same direct-product and evidence gates.
- Expanded provider diagnostics to include Google and approved-source lanes.
- Added regression tests for Google API use and Amazon UK query generation.

## Safety boundaries
- TradeFlow `.env` only; GearCashOut `.env` is not read, copied, moved or overwritten.
- No GearCashOut source rows, product catalogue data, customer data or evidence copied.
- Gemma remains a verifier/extractor; no automatic catalogue/evidence writes.
- TEST review queue remains the only research handoff; approved importer remains separate.
- Migration is proposed in GitHub only; do not claim it is applied until independently applied and verified in TEST and LIVE.
- No production deployment or live data changes.

## Verification still required
- CI for this branch.
- Apply the source registry migration separately to TEST and LIVE, verify table/RLS parity, and seed only approved TradeFlow sources after review.
- Add Google settings to the TradeFlow `.env` only if the existing Google integration credentials are authorised for TradeFlow use; do not expose or paste keys in chat.
- One controlled Research PC dry-run should report Google/provider/approved-source counts, Amazon UK discoveries, eligible URLs, fetch failures, fetched price-bearing pages, Gemma calls and accepted candidates. Keep dry-run; do not enqueue/import until evidence is independently validated.
