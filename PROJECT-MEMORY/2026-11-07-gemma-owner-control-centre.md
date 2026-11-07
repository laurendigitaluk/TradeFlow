# Project memory — Gemma Owner Control Centre — 7 November 2026

The user wants one page in the Platform Owner dashboard to supervise ChatGPT (supervisor) and Gemma specialist research agents. Branch `feature/gemma-owner-control-centre-20261107` adds a read-only telemetry panel using the existing LIVE `platform_owner_get_ai_agent_control_centre` RPC. It shows agent statuses, stale heartbeat interpretation, counts and recent activity.

Critical architecture finding: LIVE has 11 agent status rows and 526 activity events; owner RPC is authenticated-only and checks active platform membership. LIVE does not have the task queue table or worker claim/complete/fail/heartbeat RPCs. TEST does have them, and the current PC worker polls TEST. Do not submit tasks from the LIVE dashboard by directly writing TEST with browser credentials. Next phase must migrate a single secure queue/control plane and update the worker deliberately, preserving owner authentication and existing evidence review gates.

Current increment has no database or deployment changes. Docs updated: AI Operating Manual and System Handbook. Checkpoint: `CHECKPOINTS/2026-11-07-gemma-owner-control-centre.md`.
