# Checkpoint — bounded 3D-printer Gemma timeout recovery

Date: 9 November 2026 UTC
Production base: `de1b8d4e12edf0102cea28f935a763826ff1c06b`
Branch: `fix/gemma-3d-printer-timeout-recovery-20261109`
Scope: LIVE `3d-printers-equipment` / `3d-printers` only.

## Finding
The latest LIVE Neptune 4 Pro task completed 14:44:43–15:03:59 UTC (19m16s). It found 29 search results, 6 exact product pages, fetched 3 and retained 3 captures. The first two-page Gemma batch timed out after five minutes. Production then retried both pages serially using the same timeout; both retries failed (one output-token limit, one timeout), consuming another 9m21s without structured output. The final one-page batch returned one structured observation in about 4m27s. Total Gemma extraction time was 18m49s.

All three queue writes were duplicate-skipped against already imported records: 0 new, 0 enriched, 0 staged. Do not create duplicate queue rows or alter imported review/evidence history.

## Proposed repair
PR #333 skips serial per-page retries after a multi-page 3D-printer batch timeout, retaining deterministic raw captures for ChatGPT. Non-timeout failures keep the existing single-page recovery. Other categories and normal initial timeouts are unchanged. Adds actual request and recovery-skipped telemetry without changing the existing batch-count field.

## Retest
Two regression tests cover:
1. A timed-out 3D-printer batch makes one HTTP request, skips two serial retries, and retains both full raw captures.
2. An output-token-limit failure still makes the two single-page recovery requests and counts all three HTTP requests.

Replay estimate: approximately 9m54s instead of 19m16s if subsequent stages are unchanged; estimated saving 9m21s. This is not a Research PC runtime test.

## Release gate
CI must pass. Do not merge/deploy or install on the Research PC without verification and explicit owner approval. Preserve the existing private `.env` and TEST/LIVE control-plane separation. No task, source, queue, evidence, approval or import changes were made.
