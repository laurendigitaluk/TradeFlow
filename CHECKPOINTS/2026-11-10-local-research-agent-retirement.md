# Checkpoint — Research-worker platform retirement (final status)

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Environment: TradeFlow LIVE

## Owner instruction and scope
The owner instructed that the local research-worker platform and its new-evidence lab-search workflow be removed from the website, PC and GitHub. The owner explicitly declined a local backup. This checkpoint records the completed retirement and remaining verification items. It does not authorise deleting TradeFlow catalogue or market-evidence data.

## Confirmed website/GitHub changes
- PR #352 merged with commit `78a62072e53f6ec121f218f2f16dbf8900df24ec`, removing owner-dashboard navigation and HTML sections for the AI research control centre and shared agent room, plus associated JavaScript polling, queue submission, telemetry, source-management, review and messaging UI.
- Production `platform-owner-dashboard.html` and `platform-owner-dashboard.js` were read back and contained zero Gemma/agent-control/common-room references.
- Removed all remaining Gemma and AI Agent Common Room selectors from production `platform-owner-dashboard.css` (commit `b1715b59cd599ff338f5ff502f3e7ec575fbac98`).
- Removed the worker README, PowerShell updater and Node entrypoint from GitHub `main` in commits `8fee859e7c3175e5a8931b6739c8186144721f3c`, `8751c598891ed55ab52b1de2722526e6b91c04a3` and `bed23823c466756b408a39d7990f7538238e31d7`.
- Production has no `tools/tradeflow-gemma-agent` or desktop worker runtime directory.

## LIVE Supabase retirement
- Applied migration version `20261110173027`, `retire_research_agent_runtime_permissions_20261110`.
- Read-only privilege verification confirmed the retired worker/control-plane RPC family is not executable by service_role, authenticated or anon.
- Edge Function inventory contains no dedicated research-worker Edge Function.
- No tables or rows were dropped or cleared. Historical queues, logs, messages and source registry remain for audit only.

## Preserved LIVE data at verification
- catalogue_master_products: 47,410
- catalogue_master_categories: 38
- shared_market_evidence: 4,542
- tenant_catalogue_selections: 23,993
- platform_ai_agent_tasks: 35
- platform_ai_agent_status: 12
- platform_ai_agent_activity: 14,808
- platform_ai_agent_messages: 451
- platform_catalogue_research_queue: 75
- platform_research_sources: 119

## PC status from owner-supplied execution output
- Removed and verified absent: `C:\\CTFGemma2`, `C:\\TFGemma`, and `%LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre`.
- Removed: both scheduled tasks, all identified desktop worker/control-centre shortcuts, and the TradeFlow startup shortcut.
- Model `gemma3:4b` removal was attempted; final `ollama list` verification is still outstanding.
- Ollama application remains installed because no registered uninstaller was found.
- Chrome Gemma Desktop web-app registration was identified in `chrome://apps`; final uninstall confirmation is outstanding.
- No backup was created, as explicitly requested by the owner.

## Remaining GitHub limitation
The connected GitHub action set supports repository file deletion and branch creation/update but exposes no branch-ref deletion action. Therefore old specialist, archive, checkpoint and feature branch refs cannot be deleted directly through this connection. This does not leave a worker runtime on the production website or PC. Do not use a local GitHub CLI workaround unless the owner specifically requests it.

## Non-negotiable preservation rules
Never delete catalogue products, categories, manufacturer/model/package data, existing market evidence, tenant/customer/subscriber data, Stripe settings, published websites or historical audit data as part of this retirement. Do not inspect or use the separate GearCashOut project. Keep the database migration history intact. Any future market research supplied for catalogue use is review-only until the owner/ChatGPT independently verifies it; no automatic approval or import.


## Additional GitHub branch cleanup — 10 November 2026

After the default-branch runtime files were removed, the seven active specialist branches and their seven dated archive branches were also cleaned. The worker runtime directories (`tools/tradeflow-gemma-agent`, `tools/tradeflow-gemma-desktop`, `tools/gemma-agent-isolation`, where present) and the dedicated `.github/workflows/gemma-research-tests.yml` workflow were deleted from those 14 branch heads. This removed 35 files from each specialist/archive branch (36 from the 3D-printer archive branch). The branch refs themselves remain because the connected GitHub actions do not expose branch deletion. Other old feature/fix/checkpoint refs remain historical development refs; they are not the production website runtime. Do not treat those refs as active workers.
