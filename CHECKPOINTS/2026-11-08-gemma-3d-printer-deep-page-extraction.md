# 3D Printer Gemma Deep-Page Extraction Checkpoint

Date: 8 November 2026
Repository: laurendigitaluk/TradeFlow
Feature branch: fix/gemma-3d-deep-page-extraction-20261108
Pull request: https://github.com/laurendigitaluk/TradeFlow/pull/292
Base: production
Base commit: 62017c2668bd9122d09885dc73839a5447c18452

## User goal
Finish the first Gemma agent (3D Printers & Equipment) so it returns useful factual product-page observations for ChatGPT to assess. Do not work on other category agents yet. Gemma must not approve or import evidence.

## LIVE findings
- LIVE project: gxsrajtqzdjvmceqcpgv.
- 3D category/branch: 3d-printers-equipment / 3d-printers.
- Review queue: 44 rows, all unapproved/unimported.
- Only 1 row had a top-level observed_price; 43 rows had evidence_type null.
- Failure detail counts: 21 unrecognised Gemma JSON findings envelopes; 14 Ollama timeouts; 2 malformed/truncated JSON outputs; 4 other/misclassified observations; 3 rows with no extraction issue text.
- The fetcher retained full page text, but the production prompt passed only the first 2,200 characters to Gemma. Prices, package choices and condition/availability wording further down a page could be missed.
- Existing source registry includes official manufacturer, UK retailer, used/refurbished dealer, Amazon UK, eBay UK and Gumtree routes. The 3D lane/source rules are separate from the extraction-depth failure.

## Code changes in PR #292
- buildDeepPageExcerpt() creates a bounded 6,200-character excerpt from across the fetched page, including all available GBP price contexts (up to 12), model/package wording, condition, stock/availability and UK-location clues.
- extractionBatchSizeForTask() uses one page per Ollama call only for the 3D-printer branch. Other categories remain at two pages.
- 3D extraction prompt requests one compact JSON observation object for the single page, reducing multi-page array/envelope failure and output burden.
- fallbackPageCapture() now structures deterministic 3D observations when Gemma times out or returns malformed output: price mentions/context, package/variant wording, condition wording, availability wording and location clues. Full page text remains attached.
- Multiple prices are preserved; no single printer price is guessed when multiple package prices are present.
- All results remain unverified and in needs_research; no approval/import behaviour changed.

## Verification
- First CI attempt exposed three test/helper issues; corrected.
- GitHub Actions run 42477880080: 50 passed, 0 failed.
- Source syntax and owner dashboard JavaScript syntax passed.
- PR #292 was merged into production with squash commit 65730838d5f32cbf923973d5a32a87f8454a0c07 after explicit owner approval. Post-merge production CI is pending; Research PC update has not yet happened. No Research PC update or LIVE queue write performed by this PR work.

## Deployment and acceptance
1. PR #292 is merged. Confirm post-merge production CI succeeds.
2. Update existing Research PC installation using the current production updater. Preserve the existing TradeFlow .env, TRADEFLOW_GEMMA_ENV_FILE, Ollama installation and GearCashOut config. Do not paste or change secrets.
3. Verify the running worker version and fresh heartbeat.
4. Run a controlled 3D-only batch across several printer models, including both new and used tasks.
5. Compare pages discovered, fetched, Gemma calls, extraction failures, structured observation fields and fallback captures.
6. Confirm page captures show exact product title/model, package/Combo options, all GBP price contexts, condition, availability and source URL.
7. ChatGPT manually reviews each candidate. No automatic catalogue/evidence approval or import.


Post-merge status (8 November 2026): Owner approved PR #292. Merged to production as `65730838d5f32cbf923973d5a32a87f8454a0c07`. Pull-request CI passed 50/50 tests. Production push CI run `42478484235` was queued/in progress at checkpoint update. Research PC source has not yet been updated; no LIVE worker restart has occurred.

## Post-merge LIVE acceptance run — 8 November 2026, 12:21–13:12 UTC

This section supersedes the earlier post-merge note that the Research PC had not yet exercised PR #292. The worker had been updated with PR #292 before the latest run; it had not yet loaded PR #293 when the task started.

- Task: `owner-3d-printers-deep-extraction-acceptance-20261108-1235`; completed 6/6 subtasks at 13:04:33 UTC.
- Worker: `DESKTOP-LVASEUB-80700`; started 12:27:37 UTC, emitted regular 45-second heartbeats, and stopped cleanly at 13:12:26 UTC. No active or pending 3D tasks remain.
- PR #292 merged at 12:03:49 UTC. PR #293 merged at 12:40:19 UTC, after this worker process had started. The run therefore exercised #292 but not the #293 prompt. One Gemma call per fetched page (11 calls for 11 pages) confirms the #292 one-page path was active.
- Totals: 86 searches, 19 product pages discovered, 11 fetched/captured, 11 Gemma calls, 9 extraction failures; 80 approved-source route attempts, 24 with matches, 39 empty, 17 route errors and 8 direct page-fetch errors.
- New: 55 searches, 13 discovered, 11 fetched/captured; 8 new raw review rows and 3 existing rows enriched. Used: 31 searches, 6 discovered, 0 fetched/captured.
- The 8 new rows retain 58 visible GBP price mentions across 41,015 captured characters. All 8 remain unverified, with no top-level `observed_price` or `evidence_type` set. Multiple package/option prices must remain contextual; do not infer a single printer price.
- Queue total is 52 rows (42 new, 6 used, 4 combined), all `needs_research`; 3 top-level prices, 1 structured evidence type, 0 approved and 0 imported.
- Used lane's first loss is before Gemma: all 6 discovered pages failed fetch; eBay returned 403/404 and other source routes returned 404. The 123-3D refurbished, 3DGBIRE reconditioned and SecondHand collections returned no exact-model links for the tested Neptune 4 Pro. ELEGOO UK remains `new_uk`, excluding its pre-owned route; PR #291 is open and its migration is not applied.
- New-lane route failures include Amazon 404, 3DFLO timeout, 3D Prima 404 and 123-3D ineligible redirect. No access controls were bypassed.
- The 9/11 extraction failures came from the pre-#293 prompt because the worker started before the #293 merge. Raw fallback retained all 11 fetched pages; the #293 prompt still needs an in-place Research PC update and a fresh acceptance run.
- PR #289 remains open; the parent task result has all 6 subtask results, but Common Room completion still reports only the final `uk_used` subtask's zero captures. PR #288 and #290 remain open; PR #291 remains open and unapplied.
- No source registry, task queue, review row, catalogue, approval/import state, TEST data, secrets, private `.env`, or Research PC file was changed by this monitoring run. No new task was queued.


## Second LIVE acceptance run — 8 November 2026, 13:18–14:29 UTC

- Task: `owner-3d-printers-chatgpt-evidence-batch-20261108-1315`; completed 6/6 subtasks at 14:29:23 UTC on worker `DESKTOP-LVASEUB-83292`. The worker status is now idle, with no active task, no pending task and no reported error. Last heartbeat: 14:29:23 UTC. No worker-stopped event was recorded for this worker; process liveness while idle is not independently confirmed.
- The task began after PR #293 merged at 12:40:19 UTC and after the previous worker's 13:12:26 UTC clean stop. This is the first post-#293 timing window, but the Research PC does not publish a source checksum, so the exact local prompt version is not cryptographically attested.
- Aggregate: 123 search results; 30 individual product pages discovered; 18 fetched/captured; 18 one-page Gemma calls; 10 extraction failures. Route totals: 159 attempts, 42 routes with matches, 78 empty routes, 39 route errors, 15 pagination pages followed and 11 individual page-fetch errors. No challenge pages were bypassed.
- Compared with the previous 12:35 acceptance run (86 searches, 19 discovered, 11 fetched, 9 extraction failures), this run found 11 more pages and fetched 7 more. Discovery-to-fetch rose from 57.9% to 60.0%. Extraction failure rate fell from 81.8% (9/11) to 55.6% (10/18); the samples differ by product mix, so this is directional rather than a controlled A/B test. All 18 fetched pages were retained for ChatGPT, including all 10 extraction failures.
- Queue writes: 12 new review rows and 6 append-only enrichments. The 64-row LIVE queue is entirely `needs_research`; 3 rows have top-level observed prices, 61 contain raw GBP price observations, 63 have null top-level `evidence_type`, and none is approved or imported. Queue task provenance: 42 `uk_new`, 16 `uk_both`, 6 `uk_used`.
- All six subtasks in this task used `uk_both`. The captures include three clearly used/pre-owned observations (ELEGOO pre-owned Neptune 4 Pro, Gumtree Bambu A1 and Gumtree Bambu A1 Combo) plus a Gumtree K1 Max listing explicitly described as brand new. The queue deliberately leaves lane/evidence type unclassified when Gemma has not supplied a reliable structured observation; ChatGPT must inspect the raw condition and page context.
- First measured loss remains before extraction: 30 discovered pages became 18 fetched, so 12 were not fetched. The 11 page-fetch errors and repeated source-route failures include eBay HTTP 403/404, Uni3Dverse HTTP 404, Bambu Shopify collection HTTP 404, Amazon route HTTP 404, SecondHand HTTP 404, 3DFLO timeout and one 123-3D HTTP 429. Do not bypass access controls.
- ELEGOO's LIVE source row remains `new_uk`, but this `uk_both` task did reach and capture the dedicated pre-owned Neptune 4 Pro page. PR #291 is still relevant to dedicated `uk_used` tasks; the combined task path is not evidence that the source-scope migration has been applied.
- Confirmed duplicate: the Bambu A1 Combo ASIN `B0GQMN8VLS` was captured twice, once at the direct `/dp/{ASIN}` URL and once with trailing `/ref=sxin_14_sbv_search_btf`. Both became separate `needs_research` rows because production hashes the complete source URL. PR #296, stacked on #290, extends the 3D-only canonicaliser to remove only this Amazon UK attribution suffix. Its CI run 42490718687 passed. No existing queue rows were merged or changed.
- PR #288 (Bambu route), #289 (aggregate completion), #290 (capture URL canonicalisation), #291 (ELEGOO dedicated used scope) and #294 (documentation) remain open. PR #296 is open and mergeable against #290's feature branch; merge #290 first, then retarget/rebase #296 to production and rerun CI.
- No research task was queued. No source registry, queue, catalogue, approval/import state, TEST data, secrets, private `.env` or Research PC configuration was changed by this acceptance review.
