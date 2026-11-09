# Project memory — LIVE 3D-printer research watch (9 November 2026)

## Scope
- Supabase project: TradeFlow LIVE `gxsrajtqzdjvmceqcpgv`.
- Exact category/branch: `3d-printers-equipment` / `3d-printers`.
- Production base inspected: `292fe9c4ae7cf896d9568abf5cab3267597f0713`.
- Current repair: PR #326, branch `fix/gemma-3d-capture-and-model-route-scope-20261109`.

## Current operational state
- Exactly 19 registered tasks match the category and branch; 56 product subtasks; 19 completed, 0 running, 0 queued, 0 failed.
- Latest 3D-printer task completion: 2026-11-09 01:56:42 UTC.
- Category status remains idle with counters 85 completed / 122 candidates and legacy worker ID `DESKTOP-LVASEUB-84452`.
- Generic worker status is idle, polling every 15 seconds. Latest worker ID `DESKTOP-LVASEUB-78412`, last update 12:39:53 UTC.
- Worker start events at 12:34:18 (`114300`), 12:35:53 (`116344`) and 12:39:53 (`78412`) have no matching stop events for the first two. The supervisor waits for its child and retries after 15 seconds, so these may be sequential restarts after an unclean exit; telemetry alone does not prove concurrent workers. Inspect Research PC `supervisor.log` and worker stderr logs before concluding.
- Supabase telemetry does not expose the local desktop config path or enabled specialist list. The current worker's use of the scoped desktop claim mode is therefore not confirmed by status rows alone.

## Latest 3D-printer results
- Ender-3 V3 KE: 11 search results, 0 exact product pages discovered, 0 fetched, 0 Gemma calls; 28 approved-source route attempts, 11 matches, 11 empty, 6 failed; two Creality collection JSON 404s.
- K1 Max: 11 search results, 1 product page discovered/fetched, 0 Gemma calls because it ran before PR #320 merged; one raw candidate; queue write `duplicate-skipped` against existing active LIVE UK-new evidence at £589.
- Both tasks predate PR #320's production merge. There is no post-merge 3D-printer task proving the Research PC is running the restored Gemma path.

## First loss points
1. Latest Ender-3 V3 KE loss is search-to-exact-product-page discovery: 11 search results yielded no individual page.
2. K1 Max page fetch succeeded, but the task predates the PR #320 extraction restoration and made zero Gemma calls.
3. Successful structured Gemma extraction still truncated `source_excerpt` and `page_capture.captured_text` to 10,000 characters, despite a 100,000-character fetch allowance. The LIVE queue's maximum stored excerpt is 10,000 characters.
4. K1 Max was also sent to the Ender-3 V3 collection route. This is model-family over-probing; PR #326 makes that route conditional on the requested model.

## Source and route state
- 13 category-specific enabled 3D-printer sources: 4 `used_uk`, 5 `new_uk`, 3 `official`, 1 `all`; plus two universal marketplaces (Amazon UK and eBay UK), 15 total.
- Recurring failures: Uni3Dverse 404, eBay 403/404, Amazon 404, SecondHand.org.uk 404, Creality Shopify collection products JSON 404.
- Creality FDM HTML collection page is publicly rendered and lists 11 products including K1 Max. The Ender-3 V3 collection page lists SE, Mega and Neo, not the requested KE. The worker's raw HTML parser did not extract product anchors before the JSON endpoint returned 404. Do not invent a replacement endpoint; verify raw fetch and endpoint behaviour first.
- ELEGOO remains `new_uk`; PR #323's proposed used-lane scope change is still unmerged.

## Review queue and evidence
- Exact branch queue: 65 rows; 28 imported, 37 rejected, 0 open.
- Linked active evidence: 23 `uk_new`, 5 `uk_used`; all 28 linked rows are GBP-priced.
- 27/28 imported queue rows lack `reviewed_by`; 8 imported rows also lack `reviewed_at`; all 37 rejected rows lack `reviewed_by`.
- Queue `evidence_type` is null on 64/65 rows, while linked shared evidence has the new/used classification. Do not backfill reviewer identities or change historical review decisions without owner direction.

## PR #326 — current-production repair
- PR: https://github.com/laurendigitaluk/TradeFlow/pull/326
- Branch: `fix/gemma-3d-capture-and-model-route-scope-20261109`.
- Base: `292fe9c4ae7cf896d9568abf5cab3267597f0713`.
- Code/test commit: `a49413970c6576e5422688d9f8f847195cb40c75`.
- CI run #474, ID `42619554386`: success; PowerShell syntax, Node syntax, Gemma/website playbook tests and Owner Dashboard JavaScript all passed.
- Full-page fixture: 10,000/40,642 (24.6%) → 40,642/40,642 (100%), recovering 30,642 characters.
- K1 Max route fixture: Ender-3 V3 family route removed; Ender-3 V3 KE retains it.
- PR remains open, unmerged and not deployed. PR #324 is the stale predecessor based on `e81ede...`; PR #326 is the current-production replacement.

## Desktop worker and migration
- PR #325 is merged to production as `b20123fd8f832388011589ac8e7f9e602bb98f08`.
- LIVE migration `20261109115602_gemma_agent_scoped_task_claim` is present. Scoped RPC is SECURITY DEFINER; service_role EXECUTE is true and authenticated EXECUTE is false. TEST does not have the RPC.
- Production branch later advanced to `eba7951e0884aeb8c825768eb01b94b3e4bfd9a7`; the latest successful CI run #473 tested the earlier PR #325 merge commit, not this later desktop UI/launcher head.
- Existing PRs #322 (idle heartbeat), #323 (ELEGOO used lane), and #324 (full-page capture) remain open and stale against the newer production base. PR #326 supersedes #324 for the capture correction.

## Safety
- No research task queued or duplicated.
- No worker started/stopped by this watch.
- No LIVE source, queue, catalogue, evidence, review, approval or import rows changed.
- No TEST data copied into LIVE. No private `.env` or secrets accessed or changed.
- The Supabase Common Room post function requires a service-role JWT; the available SQL context is postgres with no service-role JWT. Do not bypass the RPC by direct table insert. Repository project memory/checkpoint files are updated instead.
