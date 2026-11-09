# Checkpoint — isolated Gemma category branches and folders

Date: 2026-11-09
Status: GitHub foundation and seven branch refs created; Research PC install not yet performed.

## Verified
- Production base SHA: `9b2027528243735a2fff35f9abc671673f864032`.
- New architecture branch: `feature/gemma-isolated-agent-foundation-20261109`.
- Category branches: `gemma/3d-printers`, `gemma/gaming`, `gemma/cameras`, `gemma/drones`, `gemma/metal-detectors`, `gemma/mobile-phones`, `gemma/laptops`.
- Each category branch has a branch-specific single-key `agent.config.json`.
- The isolated worker code uses a per-install config path and a one-category task claim, checks task-group identity again in process, and posts Common Room messages under the relevant category identity.
- Per-agent start/update scripts and a seven-clone sparse-checkout installer have been added to the foundation branch.
- Shared ENV is referenced by path only; installer does not copy or print secrets.

## CI verification
- Gemma Research Tests run 42716626875 passed: PowerShell syntax, Node source syntax, existing Gemma task/website tests, new isolation tests and Owner Dashboard JS syntax.
- Initial run 42716552736 failed only because the new test expected different wording from the existing unknown-agent validator; the assertion was corrected and the rerun passed.

## Not yet verified
- Local PC folders, independent Git clones, shortcuts and switchboard have not yet been created.
- No isolated agent has been started.
- Current shared worker/desktop installation remains untouched. Existing 3D Printer eight-product batch must finish before changing the active runtime.

## Restore / isolation rule
Never run the isolated updater against the old shared installation. Each new folder must update only from its own `agent.config.json.sourceBranch`. Never merge Gaming, Cameras, Drones or another category branch into the locked 3D Printer branch. Shared Ollama and shared ENV are not shared code.
