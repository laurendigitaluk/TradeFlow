# Checkpoint — Gemma 3D Printers telemetry identity isolation

Date: 7 November 2026 (UTC)
Scope: `3d-printers-equipment / 3d-printers` only
Branch: `feature/gemma-3d-printer-agent-identity-guard-20261107`
PR: https://github.com/laurendigitaluk/TradeFlow/pull/283

## Verified baseline
- Production branch is at `6941fba5b7b74cf4f005cf0e6cbfca7905c8f4e4`.
- LIVE 3D status before the unrelated Sigma task: 49 completed subtasks, 70 candidates, 40 evidence queued.
- The Sigma lens task was created at 23:31:04 UTC and completed at 23:31:38 UTC. Its two payload subtasks had `agent_key=3d-printers-equipment`, but `category_slug=lenses` and `branch_slug=photography-lenses`.
- The lens task produced 0 search results, 0 product pages, 0 captures and 0 evidence writes. It incremented the 3D status counter by two (49 → 51), leaving candidates/evidence at 70/40.
- LIVE 3D review queue remains 40 `needs_research` rows, 3 with top-level prices, 1 with an evidence type, 0 approved, 0 imported and 0 enriched. No row was created or updated after the previous 3D run.

## Change
- Extract identity resolution into `src/agent-identity.mjs`.
- Only when the supplied key is the 3D Printers agent key and an explicit non-3D category slug is present, use the explicit category key for telemetry/Common Room attribution.
- Preserve all other agent-key behaviour and correctly assigned 3D tasks.
- Add five regression tests.
- Update System Handbook, AI Operating Manual, diagnostic roadmap and project memory.

## Verification / safety
- CI is expected to run on PR #283; record the exact test result after completion.
- No Supabase data, source registry, queue, evidence, catalogue, approvals or imports were changed.
- No TEST/LIVE crossover, credentials, local .env, Research PC files, worker process, merge, deployment or new research task was touched.
- This PR only corrects future attribution. Historical 3D `tasks_completed=51` is not rewritten.
