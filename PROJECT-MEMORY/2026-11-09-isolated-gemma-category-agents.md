# Project memory — isolated Gemma category agents (2026-11-09)

Owner requirement: one independent Gemma per category, each with its own Git branch, independent local folder/Git clone, source code, tests, launcher, updater and category instructions. Shared only: existing local Ollama model service and existing private TradeFlow ENV file by path. No shared Node worker or multi-category Gemma execution lane.

Architecture branch: `feature/gemma-isolated-agent-foundation-20261109`.
Base: production commit `9b2027528243735a2fff35f9abc671673f864032`.
Category branches created:
- `gemma/3d-printers` — canonical key `3d-printers-equipment`
- `gemma/gaming` — `gaming-consoles-accessories`
- `gemma/cameras` — `cameras`
- `gemma/drones` — `drones`
- `gemma/metal-detectors` — `metal-detectors`
- `gemma/mobile-phones` — `mobile-phones`
- `gemma/laptops` — `laptops`

Each branch has its own `tools/tradeflow-gemma-agent/agent.config.json` with exactly one enabled key and its own sourceBranch value. Branches were created as separate refs from the isolated-agent foundation; future branch changes do not propagate automatically.

Implementation in foundation branch:
- Single-agent config validator and task-group isolation guard plus tests.
- Task worker now uses the per-folder agent config, includes category in worker identity, rejects mixed/out-of-scope tasks and uses category-specific Common Room identity rather than a hard-coded 3D Printer identity.
- Category-local start and update scripts.
- Installer to create seven independent sparse clones and desktop shortcuts, sharing only a pointer to the existing private ENV path.
- CI workflow extended for new PowerShell launchers and isolation tests.

Existing local install, current running process, private ENV, Ollama service, LIVE/TEST Supabase data, research queue, source lists and evidence have not been changed by this GitHub work. Installer is not yet run; no new agent folders or shortcuts exist on the PC. Do not stop the existing worker while the eight-product batch is active. Do not start a second 3D Printer process until the current batch is complete.

Next: finish CI and PR review; run installer once; verify folder/branch/config isolation; switch only 3D Printer runtime after active batch completion; test one 3D task then a block task; checkpoint/lock 3D before any Gaming changes.
