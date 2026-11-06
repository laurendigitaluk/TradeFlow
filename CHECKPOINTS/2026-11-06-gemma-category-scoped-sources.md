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
- The current branch contains 36 test declarations in `test/agent.test.mjs` and 2 in `test/release-monitor.test.mjs` (38 across the two inspected test files). The earlier Research PC run reported 38 tests passing. The count matches the earlier Research PC report of 38 tests, but the actual suite on this updated branch still needs to be executed; a matching count alone does not prove the installed files are identical or that the new tests pass.
- TEST `platform_ai_agent_tasks` and `platform_catalogue_research_queue` both currently contain zero rows. The 3D-printer agent telemetry is cumulative (23 tasks completed / 3 candidates found / 0 evidence queued); the latest K1 event at 16:18:17 UTC explicitly reports zero candidates, zero queued, and Gemma not called because no fetched product page showed a visible GBP price. This was before the new category-scope configuration and is not a post-change test.
- The Research PC has not yet downloaded this branch. Do not claim a category-filtered end-to-end run until the PC runs the updated package, full tests pass, and a controlled dry-run demonstrates only allowed source domains are fetched.

## Search query hardening — 6 November 2026

The category scope is now applied at query-construction time as well as result filtering. `buildCategoryScopedSearchQuery()` appends `site:domain` operators for the allowed UK domains only, grouped with OR. If no source is configured for a category, the general web search is skipped (fail-closed). Returned result URLs are still checked against the same category + manufacturer allowlist before page fetch. Tests cover that a DJI/drone query includes DJI and universal marketplaces but excludes GAME, while a gaming query includes GAME and excludes DJI.

This is a code-only enhancement; the already-applied TEST/LIVE source registry migration is unchanged. PR #261 remains open and unmerged. The new Node tests have not been executed by GitHub Actions or on the Research PC yet.

## Targeted routing smoke test — 6 November 2026

An isolated Node.js smoke test of the new routing helpers passed 5/5 cases: category isolation, manufacturer matching, universal marketplace wildcard, result-host filtering, and `site:`-restricted search query construction. This is a focused helper smoke test, not the complete TradeFlow Gemma package test suite. The two inspected package test files currently contain 36 agent tests and 2 release-monitor tests (38 declarations); the complete `npm test` run on the updated branch remains outstanding.

## CI diagnostic and correction — 6 November 2026

The first GitHub Actions run for PR #261 (run `42271395436`) failed before executing the tests. Node 24 rejected over-escaped regular-expression literals in the newly added source-domain normaliser (`SyntaxError: Invalid regular expression flags`). This was a code syntax defect, not a database or model/runtime failure.

Correction committed as `b66626b9ddd8d606260ad9ba707c3dab4cd07360`: replaced the fragile regular-expression stripping with explicit hostname string normalisation (scheme, www prefix and path removal). The isolated Node smoke test of the corrected routing helpers passed 5/5. A fresh full GitHub Actions run for the corrected head is still pending; keep PR #261 open and do not merge until it passes.

## Full GitHub Actions verification — 6 November 2026

The corrected PR head completed the GitHub Actions workflow **TradeFlow Gemma agent tests** successfully:
- Workflow run #156, ID `42271575330`
- Head commit `a9cec7cd95ad8aee9098cd30656ec39f8c16dfec`
- Node.js 24
- **41 tests passed, 0 failed**

The earlier syntax-error run was superseded by the hostname-normalisation fix. The current PR #261 is still open and unmerged; GitHub currently reports `mergeable=false`. Do not force or bypass a merge. Resolve/refresh the PR mergeability state before merging into the previous fix branch. Research PC installation and an end-to-end category-filtered dry-run remain outstanding.

## Latest PR-head verification — 6 November 2026

The latest workflow run for the current PR head also passed:
- GitHub Actions run #158, ID `42271722093`
- Head commit `4b116df4e4cc75cb625e7e556332d80658a43de4`
- **41 passed, 0 failed**

This supersedes the earlier pending-rerun note. PR #261 remains open and unmerged; the connector still reports `mergeable=false`, so no merge has been attempted. The next operational gate is to install this verified branch on the Research PC and run the controlled category-filtered dry-run.

## Research PC / queue status — 6 November 2026

The latest TEST telemetry check shows the 3D-printer agent is idle with its last heartbeat at 16:18:17 UTC (23 cumulative tasks, 3 cumulative candidates, 0 evidence queued). That last K1 task completed with 0 evidence candidates; no page contained a visible GBP price and Gemma was not called. This run predates category-scoped source routing.

The TEST `platform_ai_agent_tasks` table and `platform_catalogue_research_queue` both currently contain zero rows. Drones, mobile phones and metal-detectors agent telemetry rows have no heartbeat yet. The Research PC has not demonstrated installation of the category-scoped branch. Do not assume the persistent worker is running or submit research tasks to it until the local package is updated and its heartbeat/test run is verified.
