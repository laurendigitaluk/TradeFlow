# TradeFlow Gemma — 3D Printers telemetry identity finding

Date: 7 November 2026 (UTC)
Category: `3d-printers-equipment`
Branch: `3d-printers`
Environment inspected: LIVE only (`gxsrajtqzdjvmceqcpgv`)

## Finding
The LIVE task `owner-sigma-105-dg-dn-macro-art-new-used-20261107-2332` was a Sigma 105mm F2.8 DG DN Macro Art lens task. Its payload had `category_slug=lenses` and `branch_slug=photography-lenses`, but incorrectly carried `agent_key=3d-printers-equipment`. It completed two subtasks (uk_new and uk_used) with 0 search results, 0 product pages, 0 captures and 0 evidence writes. Its 14 approved sources were lens-category sources; 16 routes were attempted, 9 failed and 7 were empty.

The worker's old `agentIdentity()` used the supplied agent key before the explicit category. As a result, those two lens subtasks incremented the 3D Printers `tasks_completed` counter from 49 to 51. The 3D counters for candidates/evidence remained 70/40. This is telemetry attribution contamination, not 3D product research progress.

## LIVE 3D state
- Worker status: idle; current_task null; last_error null.
- The 3D status row's last heartbeat is refreshed by the misrouted lens task. Production sends the periodic heartbeat during an active claim, not during idle polling; stale idle timestamps must not alone be interpreted as a dead worker.
- Latest genuine 3D research task remains `owner-3d-printers-controlled-rerun-20261107-2225`, completed 7 November 2026 at 22:54:46 UTC.
- Review queue: 40 rows, all `needs_research`; 3 have top-level observed prices, 1 has an evidence type, 0 approved, 0 imported, 0 enriched. No queue rows were created or updated after the 22:54 run.
- No new 3D printer task was queued.

## Proposed correction
PR #283: https://github.com/laurendigitaluk/TradeFlow/pull/283
- New helper `resolveAgentIdentity()` remaps only the observed mismatch case: supplied `agent_key=3d-printers-equipment` plus an explicit non-3D `category_slug` uses that category's key for telemetry/Common Room attribution.
- Correct 3D tasks retain the 3D key. Other supplied agent keys retain existing behaviour.
- Five regression tests cover correct 3D identity, Sigma/lenses mismatch, correct non-3D assignment, preservation of other supplied keys and fallback behaviour.
- This is attribution-only. No task, source, queue, evidence, catalogue, approval/import, TEST/LIVE or secret changes.

Status: proposed on a new feature branch; CI pending at checkpoint creation. Do not merge/deploy or update the Research PC without review and explicit owner approval.


## Verification update — 7 November 2026

- Initial PR CI run 42425821009 completed successfully with 32 tests, but inspection of its logs showed the workflow's explicit test command did not include the new `agent-identity.test.mjs` file. Therefore that run did not execute the five new regression tests.
- The PR branch now updates `.github/workflows/gemma-research-tests.yml` to include `agent-identity.test.mjs` in the test command.
- The exact new module and five regression tests were run locally with Node's test runner: 5 passed, 0 failed. A new GitHub Actions run covering the updated workflow has not yet been observed; do not describe the new tests as CI-verified.
- PR #283 remains open and unmerged. No deployment, Research PC update, worker restart, database mutation or new task was performed.
