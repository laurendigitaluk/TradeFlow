# Project Memory — Gemma 3D Printer Evidence Prompt

Date: 7 November 2026
Status: merged to production; awaiting Research PC update and runtime acceptance.

## User intent
The 3D Printer Gemma agent must search deeply and return a broad set of UK new/used market evidence and useful borderline leads for ChatGPT to inspect. Gemma does not approve or import evidence. Work on one category agent at a time; current scope is only category `3d-printers-equipment`, branch `3d-printers`.

## Current implementation
- PR #274 merged to production at `7a906f696d0e25f4d977efd755234eed67e8ee6d`.
- Extraction prompt in `tools/tradeflow-gemma-agent/src/agent.mjs` now explicitly requires exact manufacturer/model/package matching, printer-only vs Combo/bundle separation, UK GBP-only prices, precise condition wording and conflict reporting.
- Ambiguous or incomplete direct exact-model pages are borderline ChatGPT-inspection leads, not silently omitted.
- Gemma receives three page excerpts per Ollama call (up to 2,600 characters each); context remains 4,096 and output budget is 1,024.
- Fetched direct pages matching the task model but not classified by Gemma are retained as borderline leads.
- Existing category source allow-lists, direct product-page eligibility, downstream evidence validation and no-auto-import review gate remain authoritative.

## Verification
- GitHub Actions run 42407437564 passed syntax checks and Gemma task/website-playbook tests.
- System handbook, AI operating manual and Gemma research diagnostic roadmap updated.
- Checkpoint: `CHECKPOINTS/2026-11-07-gemma-3d-printer-evidence-prompt.md`.
- LIVE Common Room learning note created: `2142f289-abac-4858-b524-07ef6dfe56e9`.
- LIVE research queue read-only check showed one existing 3D printer / `3d-printers` candidate in `needs_research`; no active task was running at the time of the check.
- No catalogue imports, approvals, research task enqueue, Supabase schema changes, TEST/LIVE data sync, or Cloudflare changes.

## Research PC deployment
Confirmed dedicated TradeFlow install folder:
`C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent`

Confirmed private TradeFlow .env:
`C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent\.env`

Preserve this .env and the `TRADEFLOW_GEMMA_ENV_FILE` mechanism. Never use or alter the separate GearCashOut configuration. The existing updater `tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1` downloads the production source files, checks syntax/tests, backs up the existing src files, installs the reviewed files, and leaves .env untouched. The updater README now has the confirmed install and env paths.

## Next test
1. Check the running worker window; stop it cleanly with Ctrl+C before replacing files. The LIVE task queue had no active tasks at the last check.
2. Run the updater in place with `-StartWorker`.
3. Verify updater tests pass and the worker starts against LIVE.
4. Run a small controlled batch across multiple 3D printer manufacturers and both printer-only and combo/package examples.
5. Inspect candidate counts, borderline findings, exact product/package identity, UK GBP price evidence, availability conflicts, source failures and runtime duration.
6. ChatGPT validates every finding. Do not auto-approve/import or start another category until this first agent passes the controlled test.
