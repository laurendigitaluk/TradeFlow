# Project Memory — ELEGOO UK pre-owned 3D-printer research lane

Date: 8 November 2026 (UTC)
Scope: TradeFlow LIVE Gemma, category `3d-printers-equipment`, branch `3d-printers` only.
Status: Proposed on feature branch `fix/gemma-elegoo-preowned-lane-scope-20261108`; not merged or deployed.

## Verified LIVE baseline
- Latest parent task remains `owner-3d-printers-exact-identity-acceptance-20261108-0032`, 8/8 subtasks, 00:32:26–00:47:00 UTC.
- Aggregate: 85 search results; 15 product pages discovered; 6 fetched/captured; 4 Gemma calls; 2 extraction failures; 114 approved-source route attempts; 27 route matches; 55 empty routes; 32 route errors; 9 direct page-fetch errors.
- New lane: 32 searches, 7 pages discovered, 5 fetched. Used lane: 53 searches, 8 pages discovered, 1 fetched.
- LIVE review queue: 44 rows, all `needs_research`; 3 top-level prices; 2 enrichment histories; 1 reviewer marker; 0 approved and 0 imported.
- No active or pending 3D research task. Worker status idle; last heartbeat 00:47 UTC; Research PC current connection not verified.

## Confirmed source-scope mismatch
- LIVE has one enabled `ELEGOO UK` manufacturer source row for GB and category `3d-printers-equipment`, but its `research_scope` is `new_uk`.
- Production `getResearchSourceLane()` maps this row to `uk_new`; `isResearchTypeAllowedSource()` excludes it from used tasks before the website route builder runs.
- Production playbook already defines `uk_new` → `/collections/fdm-printers` and `uk_used` → `/collections/pre-owned-3d-printer`. Existing route tests cover those URLs.
- Fresh public inspection of the UK pre-owned collection shows 27 products, UK/GBP context and displayed prices from £39 to £370; some listings are sold out. It is a discovery page only; direct listing pages must be fetched and checked.
- TEST has no ELEGOO UK source row. The proposed update-only migration will be a no-op in TEST and will not copy LIVE source data.

## Proposed correction
- Migration `20261108093000_enable_elegoo_uk_3d_printer_used_lane.sql` changes only the exact existing enabled ELEGOO UK manufacturer row for this category from `new_uk` to `all`.
- Category assignment still prevents other categories; `isRelevantApprovedSource()` still restricts manufacturer sources to the requested manufacturer; `routesByResearchType` preserves new/used route separation.
- Regression test covers new/used eligibility, exact lane routes and rejection for other manufacturers/categories.
- Production source loader currently allows up to 100 source rows and rotates all lane-relevant sources in batches of four; no 12-source cap remains.

## Safety and release
- PR #291 is review-only. No migration applied, no source registry row changed, no research task queued, no evidence approved/imported, no TEST/LIVE data copied, no secrets or Research PC files touched.
- After approval and deployment, verify one Elegoo used task includes the source and probes only the pre-owned collection, then follows exact product pages. Keep sold-out listings out of current used-price evidence.
