# Project memory — 3D-printer Gemma timeout recovery

Date: 9 November 2026 UTC
Repository: `laurendigitaluk/TradeFlow`
Production base: `de1b8d4e12edf0102cea28f935a763826ff1c06b`
Feature branch: `fix/gemma-3d-printer-timeout-recovery-20261109`

## LIVE scope and current state
- Supabase LIVE project: `gxsrajtqzdjvmceqcpgv`.
- Exact category/branch: `3d-printers-equipment` / `3d-printers`.
- 20 exact registered task rows, 57 product subtasks; all 20 completed, 0 queued/running/failed.
- Latest task: `owner-live-3d-printers-worker-check-neptune4pro-20261109-1445`, worker `DESKTOP-LVASEUB-78412`, 14:44:43–15:03:59 UTC.
- Category status after task: idle; `tasks_completed=86`, `candidates_found=125`, `evidence_queued=65`; category heartbeat 15:03:59 UTC. Generic worker status is idle but its last generic heartbeat remains 12:39:53 UTC; active-task category telemetry did refresh during the run.

## Latest LIVE Neptune 4 Pro metrics
- 29 search results; 6 exact product pages discovered; 3 inspected/fetched; 3 product-page fetch errors.
- 26 approved-source route attempts: 11 matches, 9 empty, 6 failed; 3 pagination pages followed; 0 collection errors.
- 3 fetched pages retained; 2 Gemma batches; 3 extraction failures; 0 accepted candidates; 3 borderline captures.
- Gemma extraction: 1,129,543 ms (18m49s); task total: 1,155,676 ms (19m16s).
- First batch (two pages) timed out after five minutes. Two serial per-page retries then consumed 9m21s; one hit output-token limit and one timed out. Neither produced structured output. The final one-page batch returned one structured observation in about 4m27s.
- Actual Ollama HTTP requests were 4 (one initial two-page batch, two single-page retries, one final one-page batch), while existing `gemma_calls=2` counts batches, not HTTP requests.
- All three page captures were retained in the task result: 42,206, 14,328 and 3,506 captured characters. Source excerpts were 9,999, 10,000 and 3,506 characters.
- All three review writes were `duplicate-skipped` against already imported records. New=0, enriched=0, staged=0. Do not mutate imported/reviewed queue rows or create duplicate rows as part of this fix.

## First loss in the latest run
- Search to page discovery: 29 → 6.
- Discovery to fetched page: 6 → 3; 3 product-page fetch errors.
- Gemma: the first two-page batch timeout triggered two serial retries with the same five-minute timeout; both retries failed, adding 9m21s without structured observations.
- Queue: 3 captures → 0 new/enriched rows because all source/model records already existed as imported queue rows. This is expected dedupe protection; raw task results remain available, but no new review item was staged.

## Proposed code change — PR #333
- On a multi-page 3D-printer batch timeout only, skip serial per-page retries and retain the deterministic full raw captures for ChatGPT.
- Non-timeout failures (output-token-limit, malformed JSON, missing source IDs) retain the existing single-page recovery.
- Other categories and the normal initial Ollama timeout remain unchanged.
- Add `gemma_http_requests` for actual HTTP requests and `gemma_recovery_skipped` for skipped page retries; preserve `gemma_calls` as the existing batch count for dashboard compatibility.
- Two regression tests cover timeout fallback/full-page retention and preservation of token-limit recovery/request counting.
- Estimated replay: remove the measured 9m21s serial-recovery interval from the 19m16s task; approximately 9m54s if subsequent stages are unchanged. This is an estimate, not a LIVE runtime retest.

## Previous fixes checked
- PR #320 is merged to production and the latest LIVE task confirms `extraction_batch_started` / `extraction_batch_completed` events.
- PR #302 is merged and its strict price-observation contract remains in production.
- PR #331 (idle heartbeat) is open, mergeable; Actions run #510 passed.
- PR #332 (full-page capture, Creality model route, ELEGOO used-lane migration) is open, mergeable; Actions run #506 passed. Migration `20261109140000` is not applied; LIVE ELEGOO source remains `new_uk`.
- PR #297's older global 30–90 second timeout approach is stale/unmergeable and not copied: the latest successful single-page extraction required about 4m27s, so shortening all normal calls would risk suppressing useful extraction.

## Review queue and catalogue snapshot
- 65 historical queue rows: 28 imported, 37 rejected, 0 open.
- 28 queue rows link to active evidence (23 UK-new, 5 UK-used); queue metadata is incomplete: 27 imported rows lack reviewer ID and 8 imported rows lack review timestamp. Do not infer identities or backfill.
- Exact 3D-printer branch shared evidence: 238 UK-new rows (221 active) and 21 UK-used rows (21 active), all GBP.
- Latest task added no queue row and changed no evidence.

## Safeguards
No task queued, no worker restarted, no Supabase source/task/review/evidence/catalogue row changed, no approval/import, no migration applied, no TEST/LIVE data copied, and no secret/private `.env` accessed or modified. PR only; no merge/deploy.
