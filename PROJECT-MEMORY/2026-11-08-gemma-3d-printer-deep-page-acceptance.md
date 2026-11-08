# Project Memory — Gemma 3D Printer deep-page LIVE acceptance

Date: 8 November 2026 (UTC)
Scope: TradeFlow LIVE, category `3d-printers-equipment`, branch `3d-printers` only.

## Production and worker state
- Production head: `3b55d43acec4ad4abb5f8e5b9530f169d3c1d3f3`.
- PR #292 (deep-page excerpt, one page per Ollama call, deterministic raw fallback) merged at 12:03:49 UTC.
- PR #293 (3D-only prompt refinement: compact one-object JSON, explicit price/package distinctions, bounded recent guidance) merged at 12:40:19 UTC.
- LIVE task `owner-3d-printers-deep-extraction-acceptance-20261108-1235` completed 6/6 subtasks at 13:04:33 UTC. Worker `DESKTOP-LVASEUB-80700` started at 12:27:37 UTC, before #293 merged, and stopped cleanly at 13:12:26 UTC. No active or pending 3D tasks remain.
- The run confirms PR #292 was installed: 11 fetched pages generated 11 one-page Gemma calls. It does not test PR #293 because the worker loaded the previous prompt before that merge.

## Latest measured results
- Aggregate: 86 searches, 19 product pages discovered, 11 fetched/captured, 11 Gemma calls, 9 extraction failures.
- New lane: 55 searches, 13 discovered, 11 fetched; 8 new review rows and 3 existing rows enriched.
- Used lane: 31 searches, 6 discovered, 0 fetched and 0 captures.
- The 8 new rows retain 58 visible GBP price mentions across 41,015 captured characters. Their top-level price and evidence-type fields remain null; preserve all price contexts and do not infer which option belongs to the requested printer.
- LIVE review queue: 52 rows (42 new, 6 used, 4 combined), all `needs_research`; 3 top-level prices, 1 structured evidence type, 0 approved and 0 imported.

## First loss points
- Used: source eligibility/discovery and then direct fetch, before Gemma. All 6 discovered used pages failed fetch; eBay returned 403/404, and other routes returned 404. The 123-3D refurbished, 3DGBIRE reconditioned and SecondHand collection checks returned zero exact-model links for the tested Neptune 4 Pro.
- ELEGOO UK remains `research_scope=new_uk`, so the official pre-owned route is excluded from used tasks. PR #291 proposes the narrow update but remains open and its migration is not applied.
- New: page fetch improved to 11/13, but 9/11 Gemma extraction calls failed. Raw fallback retained the pages. These failures occurred under the pre-#293 prompt and are not a valid test of the merged prompt refinement.
- New-lane route errors include Amazon 404, 3DFLO timeout, 3D Prima 404 and 123-3D redirect to an ineligible page. No access-control bypass was attempted.
- Parent completion remains misleading: the parent result contains 6 subtask outputs, but Common Room's final status reports only the final used subtask's zero captures. PR #289 remains open.

## Outstanding production fixes
- Open: #288 Bambu UK collection route; #289 aggregate parent completion; #290 Creality UK locale URL deduplication (stacked on #287, needs retarget/rebase); #291 ELEGOO used-source eligibility (migration not applied).
- Merged: #287 Combo identity, #292 deep-page extraction, #293 prompt refinement.
- Next: after explicit approval, run the existing production updater in place, preserve the dedicated private TradeFlow `.env` and `TRADEFLOW_GEMMA_ENV_FILE`, verify the worker/Ollama start, then run one controlled 3D-only acceptance using the #293 prompt. Do not queue duplicate research before installation. Never approve or import evidence automatically.


## 8 November 2026 — second LIVE 3D-printer acceptance

- LIVE task `owner-3d-printers-chatgpt-evidence-batch-20261108-1315` completed 6/6 subtasks, 13:18:34–14:29:23 UTC, worker `DESKTOP-LVASEUB-83292`.
- Aggregate: 123 searches, 30 individual pages discovered, 18 fetched/captured, 18 Gemma calls and 10 extraction failures. Route metrics: 159 attempts; 42 found; 78 empty; 39 errors; 15 pagination pages followed; 11 page-fetch errors. Every fetched page was retained.
- Previous acceptance: 86 searches, 19 discovered, 11 fetched, 9 extraction failures. Current discovery-to-fetch is 60.0% versus 57.9%; extraction failure rate is 55.6% versus 81.8%. Product mix differs, and the worker does not publish a local source checksum; the task began after PR #293 merged but exact prompt installation is not independently attested.
- Current task wrote 12 new review rows and enriched 6 existing rows. LIVE queue: 64 rows, all `needs_research`; 3 top-level prices, 61 rows with raw GBP mentions, 63 null top-level evidence types, 0 approved, 0 imported. Task provenance counts are 42 `uk_new`, 16 `uk_both`, 6 `uk_used`.
- The combined `uk_both` batch captured three clear used/pre-owned pages (ELEGOO pre-owned Neptune 4 Pro, Gumtree Bambu A1 and Gumtree Bambu A1 Combo) and one Gumtree K1 Max listing whose page explicitly says brand new. The raw condition wording remains for ChatGPT; no automatic lane classification is applied.
- First measurable loss is still direct fetching: 30 discovered, 18 fetched. Route failures include eBay 403/404, Uni3Dverse 404, Bambu Shopify 404, Amazon 404, SecondHand 404, 3DFLO timeout and 123-3D 429. Do not bypass access controls.
- ELEGOO source scope remains `new_uk`; the combined `uk_both` playbook nevertheless reached its pre-owned Neptune 4 Pro page. PR #291 remains needed for dedicated `uk_used` tasks; its migration is not applied.
- Confirmed duplicate Amazon capture: the same Bambu A1 Combo ASIN `B0GQMN8VLS` was captured with and without trailing `/ref=sxin_14_sbv_search_btf`. Production hashes the full URL, creating two review rows. PR #296 extends PR #290's 3D-only canonicaliser to normalise this exact attribution suffix; CI run 42490718687 passed. Historical queue rows are untouched.
- Worker is idle, no active/pending tasks, last heartbeat 14:29:23 UTC. No stopped event was recorded for the new worker, so idle process liveness remains unverified.
- No task enqueue, LIVE data mutation, approval/import, TEST crossover, secret or Research PC change was made.
