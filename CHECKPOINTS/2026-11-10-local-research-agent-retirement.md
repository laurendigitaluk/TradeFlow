# Checkpoint — Local research-agent retirement

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Target environment: TradeFlow LIVE

## Authorisation
The owner explicitly instructed: “Okay, remove everything.” Scope includes the Windows local worker installation, desktop launchers and model, owner website controls, GitHub worker code/branches and dedicated backend runtime. Preserve TradeFlow catalogue, categories, product/evidence data, historical queue and audit history.

## Recovery point
- Production HEAD at checkpoint: 8907cfa3183addd50f1d391d8bbd420f2efa1f5f
- Recovery branch: checkpoint-pre-gemma-retirement-20261110
- Retirement work branch: retire-gemma-system-20261110

## LIVE baseline captured read-only
- platform_ai_agent_tasks: 35
- platform_ai_agent_status: 12
- platform_ai_agent_activity: 14,808
- platform_ai_agent_messages: 451
- platform_catalogue_research_queue: 75
- platform_research_sources: 119
- 20 related RPC/function routines were present in information_schema.routines.
- Seven related tables were identified, including tenant_buying_research; do not assume all seven are exclusively agent-owned.

## Windows inventory supplied by owner
- C:\\CTFGemma2: category folders and shared agent files.
- C:\\TFGemma: earlier installation clone.
- %LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre: dashboard, supervisor, config, logs and backups.
- Scheduled tasks: TradeFlow Gemma Research Agent (Ready) and TradeFlow Gemma Research Supervisor (Disabled).
- Startup entry: TradeFlow Gemma.lnk.
- Nine desktop shortcuts, including seven category launchers, two control-centre launchers and one Chrome app shortcut.
- Ollama contains gemma3:4b only; no other model was listed.
- No matching Windows services or running worker processes were found in the supplied checks.

## Work completed in retirement branch
- Removed owner-dashboard navigation links to the agent control centre and common room.
- Removed both corresponding HTML sections.
- Removed associated JavaScript polling, worker queueing, telemetry, research-source management, review UI and common-room messaging code from the owner dashboard.
- Appended this retirement and preservation boundary to the AI Operating Manual, System Handbook and both diagnostic roadmaps.

## Not yet completed
- Browser/Node syntax and dashboard regression tests.
- PR review and production merge/deployment.
- Dedicated GitHub worker code retirement and specialist branch archival/deletion.
- Supabase RPC dependency audit and retirement migration. Do not delete historical tables or records.
- Windows scheduled-task/startup/shortcut/model/application removal and final verification.

## Explicit safety constraints
Do not delete catalogue products, categories, evidence, research queue rows or historical agent activity/messages. Do not touch LIVE Stripe, tenant/customer records, domains or subscriber-published data. Do not inspect or use the separate GearCashOut project. Preserve the recovery branch and historical checkpoints.


## Production retirement progress
- PR #352 merged to production: commit 78a62072e53f6ec121f218f2f16dbf8900df24ec.
- Gemma owner dashboard HTML and JS read back from production with zero matching system/UI/RPC namespace strings.
- PR workflow gemma-research-tests passed.
- LIVE migration `retire_research_agent_runtime_permissions_20261110` revoked execution of the worker runtime and retired owner dashboard RPCs from all standard roles including service_role.
- Historical data counts verified unchanged: 35 tasks, 12 status rows, 14,808 activity rows, 451 messages, 75 catalogue research queue rows and 119 research sources.
- No database tables or historical rows were deleted.
- Not yet completed: local Windows removal, specialist branch archival/deletion, worker source cleanup and live CDN/browser verification.
