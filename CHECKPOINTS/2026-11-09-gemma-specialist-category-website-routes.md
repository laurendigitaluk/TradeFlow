# Checkpoint: Gemma specialist category website routes — 9 November 2026

## Objective
Prepare one independently switchable Gemma specialist for each of the seven TradeFlow product-research categories, with registered website coverage and a safe Windows Control Centre installation path.

## Verified current implementation
- PR #325: Windows Research Control Centre and one persistent queue supervisor.
- Seven independent switches: 3D Printers, Gaming Consoles, Drones, Metal Detectors, Mobile Phones, Laptops, Cameras.
- One Ollama execution lane; no seven-process concurrency.
- LIVE UK source registry: 119 records, 116 enabled; existing records retained.
- Re-audited the full source-playbook category blocks. The earlier missing-domain count was caused by an incorrect block boundary; all registered domains already had site definitions except Aetha UK (aetha.global), whose entry lacked a discovery route. Added its verified UK homepage route. No source registry rows were changed.
- Added regression coverage to protect existing category site instructions, homepage discovery routes and dedicated Amazon/eBay metal-detector search patterns. First CI run exposed the Aetha route gap; the fix is committed and CI must pass against the final head.
- Updated system handbook, AI operating manual and project memory.

## Key implementation files
- tools/tradeflow-gemma-desktop/agents.json
- tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1
- tools/tradeflow-gemma-desktop/Run-TradeFlow-Gemma-Supervisor.ps1
- tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1
- tools/tradeflow-gemma-agent/src/desktop-control.mjs
- tools/tradeflow-gemma-agent/src/task-worker.mjs
- tools/tradeflow-gemma-agent/src/source-playbooks.mjs
- tools/tradeflow-gemma-agent/src/source-playbooks.test.mjs
- supabase/migrations/20261109150000_gemma_agent_scoped_task_claim.sql

## Current branch and verification
- Branch: feature/gemma-desktop-control-centre-20261109
- PR: #325
- Latest source/test commit: 74705aebb170487b8d3015cd654d466430be2727
- Documentation and memory commits follow the code commit.
- Re-check CI against final PR head before merge; the earlier successful CI run predates the additional source-route regression test.

## Not done / rollout gates
- Do not claim LIVE deployment or Research PC installation is complete.
- Do not apply the scoped-claim migration until PR review/merge and explicit deployment step.
- After merge, apply migration to LIVE only, then install from production on the Research PC.
- Installer must reuse existing private .env without copying, printing or overwriting it, and must refuse to overwrite an active legacy worker.
- Run a bounded acceptance task per specialist and verify LIVE raw captures appear in the existing review queue. Do not start a broad category batch as an installation test.
- TEST remains untouched and separate.
