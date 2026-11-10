# Gemma Specialist Idle Heartbeat — 10 November 2026

## Purpose
Ensure each isolated Gemma worker reports a reliable category-scoped idle heartbeat so the owner dashboard does not mistake a healthy idle worker for a stopped process.

## Implementation
- Shared worker reports the assigned specialist identity, worker ID and `stage=idle_poll`.
- Idle heartbeat cadence is bounded from 60 seconds to five minutes; current 15-second queue polling uses 60 seconds.
- Emit only after a successful queue poll and while no task, poll or other heartbeat is in progress.
- Suppress during processing, failed polls, shutdown and disabled/no-agent assignments.
- Queue polling waits for an in-flight idle heartbeat to finish, preventing idle telemetry racing a task claim.
- Existing 45-second active-task heartbeat and queue lease heartbeat remain unchanged.
- Helper and regression test are packaged by the updater and checked by the canonical launcher and GitHub Actions.

## Isolation and safety
Do not overwrite each worker's category-specific one-key `agent.config.json` or private LIVE `.env`. No Supabase migration, queue mutation, research enqueue, evidence approval, TEST/LIVE copy or Research PC restart is part of this source change.

## Release status
Owner authorised PRs #349, #350 and #351 to merge in order; all three are merged. The common idle-heartbeat implementation is synchronised to all seven specialist branches. The 3D Printer parent-completion correction is specific to `gemma/3d-printers`; it is not copied into the other six workers.

## Acceptance gate
The Research PC installation still requires the existing LIVE updater to be run on the PC. Verify two or more idle heartbeat events from the same worker ID for each specialist before declaring runtime liveness fixed. Do not enqueue research solely to test heartbeats. After liveness passes, run a separately authorised bounded research acceptance and inspect task claim, active progress, parent completion and review-queue handover. Evidence remains subject to ChatGPT/owner review.
