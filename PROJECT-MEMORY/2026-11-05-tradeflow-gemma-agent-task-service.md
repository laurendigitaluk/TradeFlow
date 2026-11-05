# TradeFlow Gemma task service checkpoint


## Persistent ChatGPT-controlled Gemma task service — 5 November 2026

The previous GearCashOut Research PC operating pattern was recovered from prior project history: Windows logon startup shortcut → supervisor → local worker → Ollama/Gemma → 15-second polling → automatic worker restart. The old GearCashOut agent/configuration is preserved and is not modified. TradeFlow now implements the equivalent as a separate agent service.

### Implemented on the feature branch
- TEST-only control-plane table: `public.platform_ai_agent_tasks`; no task queue table is added to LIVE.
- Task states: queued, running, completed, failed, cancelled. Claims use row locking with `FOR UPDATE SKIP LOCKED`, worker identity, lease expiry, attempt count and retry after abandoned leases.
- Service-role-only RPCs: `platform_ai_agent_claim_task`, `platform_ai_agent_heartbeat_task`, `platform_ai_agent_complete_task`, `platform_ai_agent_fail_task`. Direct anon/authenticated table access is revoked and RLS is enabled.
- Local worker: `tools/tradeflow-gemma-agent/src/task-worker.mjs`; polls TEST every 15 seconds, claims one task at a time, renews its lease, runs the existing verified research pipeline, stages evidence candidates in the TEST owner-review queue and reports task progress to TEST and LIVE telemetry.
- Windows supervisor: `Start-TradeFlow-Gemma-Service.ps1`; restarts the Node worker after an exit. Installer: `Install-TradeFlow-Gemma-Service.ps1`; registers a per-user Windows logon scheduled task and starts it.
- Worker reads the new TradeFlow local `.env` in its own agent folder by default or `TRADEFLOW_GEMMA_ENV_FILE`; it does not read, overwrite or modify `C:\\GearCashOut-Config\\.env`.
- No task can directly write master catalogue products or evidence. The existing owner-review queue and separate approved importers remain the approval boundary.

### Backend verification
Migration `20261105210000_platform_ai_agent_task_queue.sql` applied successfully to TEST project `nnsshnfkjcflucjrftzi`. Verified `public.platform_ai_agent_tasks` exists and contains zero tasks immediately after migration. RPC execute privileges are granted to service_role; anon/authenticated grants are revoked. LIVE schema and catalogue data were not changed.

### Current state / remaining installation
Source and migration are committed on `feature/tradeflow-gemma-agent-foundation-20261105`. The Research PC has not yet downloaded the new worker/supervisor files or registered the Windows scheduled task. One final user-side installation is required because ChatGPT cannot install software or create Windows scheduled tasks on the local PC. After installation, task assignment and progress/results can be handled through the connected TEST Supabase control plane without repeated PowerShell commands.

### Operating boundaries
- ChatGPT submits a task to the TEST control-plane queue; it does not connect directly to the PC or expose service-role credentials.
- The PC polls TEST and runs local Ollama + SearXNG; evidence candidates are staged for owner review only.
- TEST and LIVE product identity is independently resolved by the existing research pipeline; product/evidence imports remain separate and approved.
- Worker leases expire after 10 minutes and are renewed every 45 seconds while processing. Poll interval defaults to 15 seconds.
- Do not merge/deploy to production or apply task-control schema to LIVE as part of this setup step.
