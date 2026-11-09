# Project memory — 3D-printer full-page capture after Gemma extraction

Date: 9 November 2026 (UTC)
PR: #324 — https://github.com/laurendigitaluk/TradeFlow/pull/324
Branch: `fix/gemma-3d-full-page-capture-preservation-20261109`

Production source inspection found a regression after PR #320 restored Gemma extraction. The 3D fetch path can retain up to 100,000 characters, and the deterministic fallback retains all of them. But successful structured extraction in `extractBatch()` truncated `source_excerpt` and `page_capture.captured_text` to 10,000; `runTask()` also truncated the top-level excerpt. This is the first confirmed loss point after a page has been fetched and Gemma has returned a structured finding.

PR #324 introduces `shouldRetainFullPageCapture()`: full retention for 3D printers and existing capture-only Gaming, 10,000 characters for other categories. It applies the helper to extraction output and final queue handoff. No extraction, price-validation, unverified-capture, dedupe, approval or import behaviour is otherwise changed.

The new regression test uses a successful mocked Ollama response and a 40,642-character page. Expected before/after: 10,000 characters (24.6%) → 40,642 (100%), recovering 30,642 characters. A non-3D assertion preserves the 10,000-character bound. GitHub Actions Gemma Research Tests run #431 (run ID 42593779100) passed on code/test commit 745f9f439bee4efac4e6d666819f75851823b028. The subsequent PR commits only update documentation; no code or test file changed after that run. The PR remains open and unmerged. Do not merge or deploy without explicit owner approval.

No LIVE/TEST database, task queue, source registry, review queue, catalogue evidence, Research PC installation, private `.env` or secret was changed. No task was queued and no evidence was approved/imported.
