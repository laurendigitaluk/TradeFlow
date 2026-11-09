# Checkpoint — Gemma Desktop Control Centre (9 November 2026)

## Baseline
- Production branch: `production`
- Production base commit: `e81ede671bfc03e73dc16169638011372b5b6117`
- Feature branch: `feature/gemma-desktop-control-centre-20261109`
- Pull request: #325 (open, ready for review)
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- TEST Supabase: `nnsshnfkjcflucjrftzi`

## Files added/changed in PR
- `tools/tradeflow-gemma-desktop/agents.json`
- `tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1`
- `tools/tradeflow-gemma-desktop/Run-TradeFlow-Gemma-Supervisor.ps1`
- `tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1`
- `tools/tradeflow-gemma-desktop/README.md`
- `tools/tradeflow-gemma-agent/src/desktop-control.mjs` and test
- `tools/tradeflow-gemma-agent/src/task-worker.mjs` (optional scoped mode only; legacy mode unchanged when no desktop config path is set)
- `tools/tradeflow-gemma-agent/src/source-playbooks.mjs` and tests (new categories only; 3D/Gaming blocks preserved)
- updater, launcher, CI workflow and both manuals
- `supabase/migrations/20261109150000_gemma_agent_scoped_task_claim.sql`

## Restore/safety notes
- No production files changed; PR is not merged.
- No Supabase migration applied.
- No LIVE/TEST queue, source, catalogue, evidence, approvals or imports changed.
- No Research PC update/restart/start performed.
- Existing private .env was not accessed outside read-only target validation logic in the installer code; it remains untouched on the PC.
- Do not start desktop service until the migration is deployed to LIVE.
- If the scoped RPC is missing, desktop worker stops with `requires_migration` and does not use the generic queue claim.
- Existing 3D-printer and Gaming behaviour must remain unchanged.

## Verification update
- Final reviewed feature head: `4acc456eff89d971981ad69766395a801e83df0d`.
- GitHub Actions run #448 passed all workflow steps, including Node tests, PowerShell parser checks and Owner Dashboard JavaScript syntax.
- PR remains unmerged; no migration has been applied to LIVE or TEST.
- TEST source registry was read-only checked: 51 enabled UK records. It was not modified; desktop runtime targets LIVE only.
