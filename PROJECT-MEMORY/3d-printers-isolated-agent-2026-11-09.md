# 3D Printers Gemma project memory — 9 November 2026

Owner requirement: one independent Gemma per category. This work is confined to branch `gemma/3d-printers` and PC clone `C:\CTFGemma2\Gemma-3D-Printers`. Do not modify any other category branch or folder.

## Current runtime
- Independent 3D Printer Gemma was started from the new local folder on 9 Nov 2026.
- LIVE control plane: `gxsrajtqzdjvmceqcpgv`.
- Canonical key: `3d-printers-equipment`.
- Config branch: `gemma/3d-printers`.
- Screenshot showed all eight isolation/startup tests passing and the worker polling LIVE at 15 seconds.
- Supabase activity recorded a worker_started event for the isolated key. No new research batch has yet been completed by this new process.
- Keep only one 3D Printer process active against LIVE. Do not run the old shared 3D Printer worker concurrently.

## Findings and targeted changes
- Existing Anycubic route playbook contains UK collection/search routes and direct model routes for Kobra 3 Max V2, Kobra 4 and Kobra S1.
- New regression test covers both Kobra 3 Max V2 machine-only and ACE 2 Pro Combo direct routes, Kobra 4 direct route, Kobra S1 combo route, plus collection/search routes.
- The prior eight-product task `owner-3d-printers-equipment-1794264123497` failed at `platform_ai_agent_complete_task` with PostgREST `PGRST102 Empty or invalid json`. It had performed product page fetches and extraction, but the full task result was not saved.
- The exact cause of PGRST102 was not conclusively proven. The worker had been duplicating large raw page captures in the task completion JSON even though captures are already stored separately in the review queue. A targeted compact-summary change removes raw captures and long excerpts from the task completion payload while retaining product identity, capture URLs, classification, price observations, queue-write references, metrics and bounded failures.
- Compact result helper and regression tests live in `src/task-result-summary.mjs` and `src/task-result-summary.test.mjs`.
- CI run `42720630028` passed after the compact-summary and Anycubic-route tests.

## Next
1. Stop the current independent 3D Printer worker cleanly.
2. Run the folder-local `Update-Gemma-Agent.ps1 -Environment LIVE` from this clone. It updates only `gemma/3d-printers`.
3. Restart Gemma 3D Printers from its desktop shortcut.
4. Queue one controlled block of 3D Printer tasks (the intended eight Anycubic model/package tasks are suitable once the owner dashboard queue is refreshed).
5. Confirm all tasks complete without PGRST102, inspect route attempts, page fetches and review queue captures. Keep evidence unapproved pending ChatGPT/owner review.
6. Lock this branch/folder at a verified checkpoint before any Gaming work.

Do not update the old shared Research Control Centre, other category clones, Supabase schema, queue RPCs or category source configuration as part of this fix.
