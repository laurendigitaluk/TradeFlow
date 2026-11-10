# Checkpoint — Research-worker platform retirement

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Target: TradeFlow LIVE and GitHub

The owner instructed removal of the local research-worker platform and its new-evidence lab-search workflow from the website, PC and GitHub. The owner declined a local backup.

## GitHub changes
- LIVE owner dashboard HTML and JavaScript have zero worker/control-centre/common-room references.
- Removed all retired worker and shared-agent-room selectors from LIVE `platform-owner-dashboard.css`.
- Deleted the worker README, PowerShell updater and Node entry point from the default `main` branch.
- Updated both system manuals on `main` and `production` with the final retirement and data-preservation boundary.
- Recorded the already-applied LIVE retirement migration in the repository at `supabase/migrations/20261110173027_retire_research_agent_runtime_permissions_20261110.sql`.

## LIVE database
The runtime/control-plane RPC family is no longer executable by service_role, authenticated or anon. No database tables or historical rows were deleted. The product catalogue, categories, market evidence, queue, source registry, worker activity and message history are preserved as data/audit history. No Stripe, tenant, customer or published website records were changed.

## PC status from owner-supplied execution output
The folders `C:\\CTFGemma2`, `C:\\TFGemma` and `%LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre` were removed and verified absent. The two scheduled tasks, desktop worker/control-centre shortcuts and startup shortcut were removed. The Ollama model removal was attempted but needs a final `ollama list` check; Ollama itself remains installed because no registered uninstaller was found. Chrome web-app uninstall confirmation is still outstanding. No backup was created, as requested.

## Remaining limitation
The connected GitHub actions support file deletion and ref updates but do not expose a branch-ref deletion action. Existing worker-related feature/archive/checkpoint branch refs therefore remain. The production runtime is not present in the production branch tree, and the default-branch runtime files have been removed. Do not attempt to delete catalogue or historical data to compensate for the remaining Git branch refs.


## GitHub branch cleanup addendum — 10 November 2026

The seven specialist worker branches and seven dated archive branches were cleaned at their current heads. Removed the worker runtime directories and dedicated worker-test workflow from all 14 heads. This removed 35 files per branch, except the 3D-printer archive branch (36). The refs remain because the connected GitHub actions do not expose a branch-delete operation. Other historical feature/fix/checkpoint branches remain as non-deployed development history.
