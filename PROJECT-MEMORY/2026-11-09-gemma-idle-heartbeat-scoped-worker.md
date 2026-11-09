# Project memory — current-production Gemma idle heartbeat

Date: 9 November 2026 (UTC)
Repository: `laurendigitaluk/TradeFlow`
Base: production `de1b8d4e12edf0102cea28f935a763826ff1c06b`
Feature branch: `fix/gemma-idle-heartbeat-scoped-worker-20261109`
PR #331: https://github.com/laurendigitaluk/TradeFlow/pull/331

## LIVE finding
Scope checked: category `3d-printers-equipment`, branch `3d-printers`, LIVE project `gxsrajtqzdjvmceqcpgv` only.
- 19 exact registered task rows and 56 product subtasks; 19 completed, 0 queued/running/failed.
- Latest 3D task completed 2026-11-09 01:56:42 UTC.
- Generic worker status: idle, no active task/error, worker `DESKTOP-LVASEUB-78412`, last update 12:39:53 UTC.
- Worker start events at 12:14:25, 12:34:18, 12:35:53 and 12:39:53 UTC. Previous clean stop at 12:12:42 UTC was for worker `DESKTOP-LVASEUB-115172`; later starts have no clean stop event. This does not prove concurrent processes or establish cause. Research PC supervisor/worker logs are needed.
- Current production worker emits `worker_started` but no periodic idle heartbeat. It only updates category telemetry during active processing. Thus a stale timestamp cannot prove that an idle process has stopped.

## Current-production correction
PR #322 was based on older production commit `e81ede671bfc03e73dc16169638011372b5b6117`; its worker diff predates the desktop-control-centre scoped claim change. The new branch is based on current production `de1b8d4e12edf0102cea28f935a763826ff1c06b` and ports only the heartbeat feature while preserving:
- desktop config and enabled-agent handling;
- `platform_ai_agent_claim_task_for_agents` for desktop mode;
- the existing unscoped claim only for the legacy non-desktop launcher;
- all category task, source, extraction, evidence and review behaviour.

The helper suppresses the initial heartbeat until the first successful queue poll or a valid no-agent idle configuration, then emits a generic `gemma-task-worker` / `Task control` heartbeat at a bounded cadence (minimum 60 seconds, maximum five minutes). It suppresses heartbeats during polling, task processing, shutdown, overlapping telemetry and after an unsuccessful poll. It does not write category-specific status.

## Regression tests
Four tests cover cadence bounds, invalid poll intervals, healthy-idle suppression, and generic-only telemetry. The canonical launcher, updater and GitHub Actions workflow include the test. The current code/test head passed Gemma Research Tests run #509.

## Data and safety
No research task was queued; no worker was restarted; no source registry row, migration, task, queue, evidence, approval or import was changed. No TEST data was read or copied. No private `.env` or secret value was accessed, printed or changed. The LIVE desktop-scoped claim migration remains as already deployed.

## Acceptance gate
After review/merge and explicit owner approval, update the existing Research PC installation without changing its private `.env`, run the installed test suite, and verify repeated idle heartbeats from the same LIVE worker ID. Do not queue a research task solely to test worker liveness.


## Verification
GitHub Actions Gemma Research Tests run #509 passed on current head `5e25a8360fd58a4045e09b9c0cb61005ce572d09`. PowerShell updater syntax, Node syntax, the full Gemma test command (including four idle-heartbeat regressions), and Owner Dashboard JavaScript syntax passed. Both Workers Builds checks (`tradeflow` and `tradeflow-test`) passed. PR #331 is ready for review and mergeable; it remains unmerged and no deployment was performed.
