# Checkpoint — Preserve full 3D-printer page captures after Gemma extraction

Date: 9 November 2026 (UTC)
Repository: laurendigitaluk/TradeFlow
Base: production `e81ede671bfc03e73dc16169638011372b5b6117`
Branch: `fix/gemma-3d-full-page-capture-preservation-20261109`
PR: #324 — https://github.com/laurendigitaluk/TradeFlow/pull/324

## Confirmed loss point

The 3D-printer fetch path calls `extractRelevantPageText()` with `maxChars: 100000`. The deterministic 3D fallback retains the full fetched page. However, when Gemma returns a structured finding successfully, `extractBatch()` sliced both `source_excerpt` and `page_capture.captured_text` to 10,000 characters. The outer `runTask()` handoff also sliced the top-level excerpt to 10,000. Therefore successful extraction could discard up to 90,000 characters before the ChatGPT review queue, while the fallback path retained the page.

This is separate from the PR #320 capture-mode correction: 3D printers must use Gemma/Ollama, but full-page retention must not depend on whether a task is capture-only.

## Correction in PR #324

- Adds `shouldRetainFullPageCapture(task)`, true for 3D printers and the existing capture-only Gaming flow, false for other categories.
- Uses that helper for successful structured extraction's `source_excerpt` and `page_capture.captured_text`.
- Uses it again when `runTask()` constructs the final review-queue candidate.
- Leaves other categories at the existing 10,000-character cap.
- Leaves price validation, unverified status, dedupe, owner review, approval and import boundaries unchanged.

## Regression tests

`agent-speed.test.mjs` now:
- checks full-page-retention scope (3D printers and Gaming true; drones false);
- stubs a successful Ollama response for a 40,642-character 3D-printer page and asserts both stored text fields retain all 40,642 characters;
- asserts a non-3D category remains capped at 10,000 characters.

Before/after fixture: 10,000 / 40,642 characters (24.6%) → 40,642 / 40,642 (100%); 30,642 characters recovered. This is a deterministic code-path fixture, not a LIVE runtime measurement.

The test is already included in `.github/workflows/gemma-research-tests.yml` and `Update-TradeFlow-Gemma.ps1`.

## Safety and verification

- CI pending on PR #324's final head; do not merge or deploy without explicit owner approval.
- No research task was queued.
- No Research PC installation/restart, Supabase mutation, source registry change, queue/evidence change, approval or import was performed.
- TEST/LIVE separation, private `.env` and all secrets remain untouched.

## Runtime acceptance after approval

After the approved Research PC update, run one bounded 3D-printer review-only task and compare the fetched text length with both queue `source_excerpt` and `raw_payload.evidence.page_capture.captured_text`. Both must retain the complete source text up to the existing 100,000-character fetch limit. Confirm `extraction_batch_started`, Gemma calls greater than zero, raw capture retention and no automatic approval/import.
