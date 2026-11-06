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


## Follow-up — source registry schema and balanced probing

- Applied the initial `platform_research_sources` registry migration to TradeFlow TEST (`nnsshnfkjcflucjrftzi`) and LIVE (`gxsrajtqzdjvmceqcpgv`).
- Applied the metadata-alignment migration to both environments. The registry now carries the same operational metadata fields used by GearCashOut (including search URL template and source status/verification fields).
- Seeded both environments with the same curated set of 20 established sources from the existing GearCashOut registry. This copies public source-directory metadata only; no GearCashOut catalogue, product, evidence, customer or credential data was copied. Insert used `ON CONFLICT DO NOTHING`.
- Updated the agent to read the TEST registry, select UK sources in balanced new/used/official lanes, and probe sources in bounded groups of four. Overseas sources are not treated as UK evidence.
- Added support for future source-specific `{query}`, `{model}` and `{manufacturer}` URL templates.
- TEST and LIVE registry seed sets are aligned. No catalogue/evidence rows or queue rows were changed.
- The source-balancing follow-up commit still requires GitHub CI and one controlled Research PC dry-run. Do not enqueue or import research until source URLs, product identity and prices are independently validated.



## Follow-up: deep collection-page discovery (6 November 2026)

- User identified a concrete discovery gap: a UK collection page exposed multiple usable product listings, but Gemma stopped at the collection page and did not follow through to individual items.
- Opened PR #256: https://github.com/laurendigitaluk/TradeFlow/pull/256
- Search terms now prioritise manufacturer + model + UK retail intent and omit internal package labels.
- Agent can fetch up to six UK collection/category pages and extract up to twelve matching individual product URLs from each; relative URLs are resolved and duplicates removed.
- Collection pages are discovery-only and cannot become evidence. Individual direct product pages must still pass UK URL eligibility, visible GBP price, exact model, condition and availability checks.
- Obvious sibling variants (Max, Plus, Pro, Ultra, Combo, SE, V2) are excluded from base-model matches.
- CI passed run 42223386531: 32 tests, 32 passed. The PR is ready to merge into the existing feature branch. No production deployment, catalogue/evidence write, TEST/LIVE queue write or importer run occurred.


## Research PC update handoff (6 November 2026)

- Added `Update-TradeFlow-Gemma.ps1` to the TradeFlow feature branch (commit `839f8d43885cd8f81a53923147e92ed365cdbbbe`).
- Added README instructions (commit `e84d067e8c9057dc45670f2366c3533083d28e99`).
- Updater downloads the approved feature branch archive, checks local agent folder, existing TradeFlow `.env`, and Node 22+, preserves `.env`, task files, logs and node_modules, updates code, runs tests, and restores previous code if tests fail.
- This is a safe handoff for the Research PC; the local update and controlled Creality collection dry-run have not yet been run. No queue, catalogue, evidence or production writes are made by the updater.


## Research PC updater fault and recovery fix (6 November 2026)

- User's first updater run failed while PowerShell extracted the full GitHub repository ZIP; screenshot showed path resolution failures in unrelated nested migration archive files.
- The first updater's rollback guard was insufficient if extraction failed before backup completion. That version must not be reused.
- Replaced extraction with a short system-drive temporary directory and selective extraction of only `tools/tradeflow-gemma-agent` via .NET ZipArchive.
- Backup is now verified before any rollback; rollback only runs when both the prior launcher and agent entry point are present in backup. Recovery mode can repopulate incomplete code when TradeFlow `.env` remains available.
- Corrected updater latest commit: `3f90d3aa8789d759791c51e3c815edc64c5dca7c`. Local recovery/update and dry-run have not yet been confirmed. No research/import/deployment actions were performed.


## Dry-run discovery-yield correction (6 November 2026)

- First post-update Research PC dry-run completed safely but found only one irrelevant Mojeek newsletter page; eligible URLs 0, fetched pages 0, Gemma calls 0, accepted candidates 0. No queue/catalogue/evidence writes.
- Identified source coverage gap: the 20-source registry was predominantly camera-focused and had no Creality official store entry.
- Added Creality UK Official Store to TEST and LIVE registries identically (domain `store.creality.com`, GB, manufacturer, official, priority 1, search template `https://store.creality.com/uk/search?type=product&q={query}`). Registry parity is now 21 sources in each environment.
- Approved-source probing now accepts exact-model collection/category hubs as discovery-only results alongside direct product pages. They are expanded by the bounded collection stage and never become evidence.
- Added unit test for collection discovery eligibility vs direct evidence eligibility. Code commits: `6e9572391a1d70e91a06ecaad68495a13137b51d`, `2badce15eebf59e2ccc046cd257605f7d787df15`.
- Local Research PC still needs this follow-up code update and one more controlled Creality K1 dry-run. No catalogue/evidence writes or production deployment.


## Direct Creality collection route and source diagnostics (6 November 2026)

- Second local run passed 33/33 tests but still returned one irrelevant Mojeek result, 0 eligible URLs and 0 fetched pages. The Creality approved-source probe was not yielding results.
- Inspection showed the probe silently swallowed database/HTTP errors and used Shopify's generic `/search?q=` route, which did not yield usable model links.
- Updated both TEST and LIVE Creality source rows to use the known K1 Series collection URL directly: `https://store.creality.com/uk/collections/k1-series-3d-printer`.
- Approved-source probe now returns a model-matching collection page as a discovery candidate so it enters the bounded collection expansion path; direct product links are fetched individually and collection pages are never evidence.
- Added visible progress diagnostics for registry errors, route failures, empty search results and successful approved-source matches.
- Independent page inspection confirms the collection contains the base K1 listing and variant listings, with the base K1 product URL `https://store.creality.com/uk/products/k1-speedy-3d-printer`.
- Latest code commit: `9225590c49f20e88cff3882cec63319fa89dbde7`. Local update/dry-run remains pending; no catalogue/evidence writes.


## Shopify collection JSON discovery fallback (6 November 2026)

- Latest Research PC run successfully fetched the Creality K1 Series collection page but extracted zero matching product links. Browser-rendered collection visibly contains New K1 Max, Carbon Fiber Ready K1C 2025 and Flash Sale K1 cards.
- Root cause: collection parser depended on ordinary anchor text, which does not expose the dynamically rendered Shopify product cards reliably.
- Added fallback to Shopify collection public `products.json?limit=50` endpoint when HTML extraction returns zero exact-model products. Product title/handle is matched to exact model; K1 Max and K1C are excluded; direct UK product URL is then fetched through existing validation/GBP checks. JSON/collection metadata is not evidence.
- Added test for exact K1 inclusion and sibling variant exclusion. Commits: `431d27b8d97f29acd0cbe4013e150eeb79b7db5b`, `de86a657187c1c949ea45d7daffdbed50ca924e8`.
- Local updater and dry-run remain pending. No catalogue or evidence writes.


## Manufacturer-specific source routing and Shopify regex repair (6 November 2026)

- User identified an invalid query: DJI manufacturer search was being called with a Creality K1 printer query. DJI/Sony manufacturer sources must only be searched for matching DJI/Sony product tasks; UK retailers and marketplaces remain cross-brand sources.
- Implemented `isRelevantApprovedSource` filter before source group selection. Creality tasks skip DJI/Sony manufacturer sources and retain Creality official plus UK retailers/marketplaces. Missing manufacturer fails closed. Tests cover these rules.
- Research PC updater caught an invalid escaped regular expression in the Shopify collection JSON fallback. The updater safely restored previous code, preserving .env/tasks/logs.
- Fixed regex and added fail-closed test. CI passed: run 42231223625, PR #257. Squash merge SHA `23bd99b6b17c915bd41e5e1d8c625196503e8669` into feature branch.
- Current next step: one corrected local update/test, then one Creality K1 dry-run. No queue/catalogue/evidence writes.
