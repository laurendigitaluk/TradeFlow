# Checkpoint — isolated 3D Printers Gemma

Date: 2026-11-09
Branch: `gemma/3d-printers`
Local clone: `C:\CTFGemma2\Gemma-3D-Printers`
Agent key: `3d-printers-equipment`
Environment: LIVE

## Verified
- The new independent 3D Printer worker launched from its own clone.
- Startup/isolation tests shown on PC: 8 passed, 0 failed.
- Worker startup log confirmed branch `gemma/3d-printers`, canonical 3D Printer key, LIVE project and 15-second poll interval.
- Supabase recorded a worker_started event for the isolated agent.
- CI run `42720630028` passed the 3D Printer branch tests, including compact task-result summary and Anycubic direct-route tests.
- Other six category clones/branches have not been changed by the 3D Printer task-result fix.

## Changes on this branch, not yet installed locally
- Compact task completion result to avoid duplicating raw page captures already staged in review queue.
- Bounded route failure details and product-level summaries retained.
- Anycubic route regression tests cover Kobra 3 Max V2 Standard/ACE 2 Pro Combo, Kobra 4 and Kobra S1.
- Documentation additions in Human Manual, AI Operating Manual and 3D Printer Diagnostic Roadmap.

## Not yet verified
- New isolated worker has not yet completed a fresh research batch.
- Compact completion fix has not yet been installed on the Research PC.
- Eight-product batch completion after the fix remains unverified.
- 3D Printer Gemma is not yet locked as accepted.

## Safe next sequence
1. Stop only the independent 3D Printer worker cleanly.
2. Run `C:\CTFGemma2\Gemma-3D-Printers\tools\tradeflow-gemma-agent\Update-Gemma-Agent.ps1 -Environment LIVE`.
3. Restart only Gemma 3D Printers.
4. Queue and verify one controlled eight-product batch.
5. Confirm task status completed, compact completion payload accepted, page captures staged, and no other category claimed.
6. Save a final acceptance checkpoint. Only then move to Gaming.

Never merge this category branch into another Gemma branch. Never update other category folders as part of this checkpoint.


## 10 November 2026 — current verified checkpoint

### 10 November 2026 — 3D Printers post-merge LIVE verification

The latest LIVE parent task `owner-3d-printers-equipment-1794272051590` completed normally with five product subtasks. It returned 48 search results, discovered 10 individual product pages, fetched 6 and retained/staged 6 page captures (three new records and three enrichments). Four of four Gemma extraction batches timed out under the pre-merge 45-second batching policy. The compact task-result helper submitted a 9,811-byte parent result; the earlier PGRST102 completion error did not recur on this five-product batch.

The 6 staged captures remain review-only. The pending queue currently has 8 `needs_research` records: 2 typed UK-new and 6 unclassified; there are no typed UK-used pending captures. The latest batch's six writes were 3 new and 3 enrichments; the Kobra 4 Standard enrichment retained its existing UK-new £159 observation, while the other raw captures remain unclassified. Active shared evidence is 239 UK-new and 21 UK-used. No catalogue evidence was approved or imported.

The first loss in this run was search-to-exact-page discovery (48 results to 10 individual pages), followed by page fetching (10 discovered to 6 fetched). The largest avoidable post-fetch loss was Gemma extraction: all four batches timed out, although all six raw captures were preserved. PR #348 merged to production at 01:17:10 UTC (merge commit `83ee9fdf533cac92bbf4bcc96384205ee31ea7f5`) and adds verified Anycubic/3DJake/123-3D/eBay routes plus one-page, 90-second 3D-printer extraction. The latest task predates that merge, so no post-merge Research PC runtime acceptance has yet occurred.

The LIVE status row reports the 3D-printer agent idle, with no current task and a heartbeat at 01:21:21 UTC from worker `DESKTOP-LVASEUB-3d-printers-equipment-132732`. The local installed commit is not reported, so the heartbeat does not prove that PR #348's post-merge code is installed.

A second defect was confirmed in the actual review-queue write path: raw `item_condition_text` and `availability_text` snippets are copied into the normalized queue columns. Six pending rows have condition values over 100 characters and eight have availability values over 100 characters. The earlier PR #346 added and tested a normalization helper but did not call it from the final database row builder; its tests therefore did not prove the persisted row was corrected. The new 3D-only branch centralizes the final row builder, calls the helper at extraction/validation/persistence boundaries, and tests the actual persisted-row shape. Raw snippets and full page captures remain in `raw_payload.evidence` and `page_capture`.

The same 3D-only branch separates heartbeat event stage (`stage=heartbeat`) from the active research stage (`active_stage`). The latest task produced 8 heartbeat activity rows, 4 of which were incorrectly labelled `extraction_batch_started`, inflating stage counts. The updater, launcher and CI already referenced the telemetry and installer-manifest tests, but the test files were absent from the branch; this branch supplies them and verifies the download/preflight contract.

PR #348's own merge/checkpoint records say shared worker source/tests were synchronised across all seven isolated category branches. That cross-category synchronization occurred outside this 3D-only follow-up. No additional branch or code changes were made to other categories here. Keep subsequent work confined to `gemma/3d-printers`.

The LIVE schema has no dedicated project-memory/checkpoint table in any schema; the repository's `PROJECT-MEMORY` and `CHECKPOINTS` files remain the durable project record. The category-scoped Common Room is stored separately in `platform_ai_agent_messages`.

## Safe next sequence
1. Review the new 3D-only PR and the separate field-mapping history; do not merge or install without explicit approval.
2. Update only the dedicated 3D Printer Research PC clone from the approved `gemma/3d-printers` branch. Preserve its private `.env` and one-key `agent.config.json`.
3. Verify updater preflight, launcher preflight and all Node tests before starting the worker.
4. Confirm the worker logs the LIVE project ID and the expected branch/version. Do not infer the installed commit from the Supabase heartbeat alone.
5. Run one bounded 3D-printer LIVE acceptance only after approval. Confirm one page per Gemma call, 90-second bound, source-route attempts, exact model/package checks, compact parent completion, and normalized queue fields with raw text preserved.
6. Inspect the ChatGPT review queue manually. No evidence approval/import is authorised by this checkpoint.
7. Keep all other category workers/branches and TEST data untouched.
