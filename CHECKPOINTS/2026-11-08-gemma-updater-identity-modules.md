# Gemma Research PC updater compatibility checkpoint

Date: 8 November 2026 (UTC)
Scope: TradeFlow Gemma local Research PC updater.
Base: current production after Gemma exact printer matcher merge.
Branch: fix/gemma-updater-identity-modules-20261108.

## Diagnosis
The production task worker imports `agent-identity.mjs`. The previous safe updater's source-file allow-list omitted that module and its test, so an in-place update would install the new task-worker but not its required imported module. The updater also did not execute the identity test suite.

## Change
- Add `agent-identity.mjs` and `agent-identity.test.mjs` to the updater download/backup/install allow-list.
- Run the identity test suite with task-group and source-playbook tests before and after installation.
- Preserve existing .env validation and no-secret-output behaviour.

## Safety
No Research PC files or processes have been changed by this branch. No .env, credentials, Supabase rows, source registry, queue or catalogue records changed. CI and review required before using the updater.

## Next action
After merge, use the production updater with the confirmed existing TradeFlow install path and private .env path. Confirm syntax and tests pass, worker heartbeat appears in LIVE, then run the controlled 3D printer task. Do not queue the task before worker update is complete.
