# Gemma category-scoped source routing checkpoint

Date: 6 November 2026
Branch: `fix/gemma-category-scoped-sources-20261106`
Previous branch: `fix/gemma-brand-filter-shopify-json-20261106`

## User requirement

Research websites must be selectable by product category. Gaming websites must not be used for drone research; drone websites must not be used for gaming; camera sites must not be used for 3D-printer research. This applies to both approved-source probes and generic web-search result URLs before page retrieval.

## Root cause

TEST and LIVE each had 27 enabled `platform_research_sources` records with no category field. The worker selected sources globally, with a manufacturer-only filter. This allowed unrelated retailers to be probed across product categories.

## Schema and configuration change

Migration: `supabase/migrations/20261106170000_add_category_scopes_to_platform_research_sources.sql`
Migration name: `add_category_scopes_to_platform_research_sources_20261106`

- Added `category_slugs text[] NOT NULL DEFAULT '{}'`.
- Added GIN index `platform_research_sources_category_slugs_gin`.
- Empty array means the source is ineligible for all categories.
- `*` is reserved for Amazon UK and eBay UK only.
- Added 24 category-relevant UK sources for gaming, mobile phones, 3D printers and metal detectors.
- Scoped all 27 existing sources, including DJI/Heliguy/HobbyRC to drone categories, Creality to 3D printers, camera retailers to camera/video categories, and CeX to selected electronics categories.
- Manufacturer sources must match both the requested category and manufacturer.

Applied separately and verified:
- TEST project `nnsshnfkjcflucjrftzi`, Supabase link `link_6a8b3c7f2f208191851663ebc14853ab`.
- LIVE project `gxsrajtqzdjvmceqcpgv`, Supabase link `link_6ad13c4afe848191899041a0a95b487d`.

Both environments: 51 total/enabled sources, 47 category-scoped, 2 wildcard. Registry hash: `f11a7f068809bc4646ac33fceda81a53` in both.

Category-specific source counts (not including the two universal wildcard rows):
- 3D printers: 3
- Drones: 6
- Gaming consoles/accessories: 12
- Mobile phones: 11
- Metal detectors: 6

Negative routing checks returned zero gaming-only sources in drone scope and zero drone-only sources in gaming scope.

Four records remain unmapped/fail-closed: Vinted UK, Adorama, B&H Photo Video and KEH Camera. The latter three are US sources and also fail the GB country gate.

## Code changes

Files:
- `tools/tradeflow-gemma-agent/src/agent.mjs`
- `tools/tradeflow-gemma-agent/test/agent.test.mjs`

The worker reads `category_slugs`, applies exact category + manufacturer filters, and filters generic search-result URLs against allowed source domains before fetch/Ollama. Unapproved domains are logged and discarded. Approved source probing remains balanced across UK-new, UK-used and official lanes.

Added tests for exact category matching, missing-category fail-closed, wildcard source behaviour, manufacturer + category combined matching, and category host filtering.

## Outstanding verification

- Full Node test suite / GitHub CI pending. Prior PC report of 38 passing tests predates these new tests.
- Research PC has not yet been updated to this branch.
- Controlled exact-product dry-run still required after CI passes and local code update.
- Do not enqueue or import until a valid candidate is returned and ChatGPT/owner validates it.
- No catalogue products, evidence, review queue, tenant/customer/order/payment/Stripe data or application deployments changed.

## Separate category-master discrepancy

TEST has active category `laptops` (ID `6761efc2-9a89-44ac-a18c-349867effc77`); LIVE has no matching active/inactive category row. Retailer scopes include `laptops`, but do not run/import laptop research until the LIVE category master is reconciled.

## Project memory

No application-level memory/checkpoint tables were found in either Supabase project; the only name matches were PostgreSQL system catalog tables. This checkpoint and `PROJECT-MEMORY/2026-11-06-gemma-category-scoped-sources.md` are the GitHub continuity records.


## Verification addendum — 6 November 2026, after PR #261 opened

- Pull request #261 is open: https://github.com/laurendigitaluk/TradeFlow/pull/261. It is not merged and must not be merged until the test/runtime gap is resolved.
- GitHub returned no workflow runs or commit status checks for the PR head. The container cannot reach GitHub to clone the branch, so the complete Node test suite has not been executed in this session.
- The current branch contains 35 test declarations in `test/agent.test.mjs` and 2 in `test/release-monitor.test.mjs`. The earlier Research PC run reported 38 tests passing. Treat this as a possible local/branch version difference and reconcile the installed package with the PR branch before treating the earlier 38-test result as validation of this change.
- TEST `platform_ai_agent_tasks` and `platform_catalogue_research_queue` both currently contain zero rows. The 3D-printer agent telemetry is cumulative (23 tasks completed / 3 candidates found / 0 evidence queued); the latest K1 event at 16:18:17 UTC explicitly reports zero candidates, zero queued, and Gemma not called because no fetched product page showed a visible GBP price. This was before the new category-scope configuration and is not a post-change test.
- The Research PC has not yet downloaded this branch. Do not claim a category-filtered end-to-end run until the PC runs the updated package, full tests pass, and a controlled dry-run demonstrates only allowed source domains are fetched.
