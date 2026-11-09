# TradeFlow Gemma — isolated category-agent architecture

Date: 2026-11-09
Status: architecture branch and seven category branches prepared; Gemma Research Tests CI passed on 2026-11-09 (run 42716626875); Research PC installation/acceptance pending.
Architecture branch: `feature/gemma-isolated-agent-foundation-20261109`
Production base commit: `9b2027528243735a2fff35f9abc671673f864032`

## Owner requirement

One complete, independent Gemma installation per product category. Each Gemma has its own Git branch, independent Git clone and local folder on the Research PC. A code change made in one Gemma folder/branch must not change another Gemma. The only shared runtime resource is the existing local Ollama model service; the only shared configuration file is the existing private TradeFlow ENV, read by path and never copied.

This explicitly replaces the previous Research Control Centre model of one persistent supervisor and one shared Node/Gemma execution lane with seven enabled category switches. That multi-switch design is not the target architecture and must not be used to develop the category Gemmas.

## Independent category branches and PC folders

| Gemma | Git branch | PC folder | canonical LIVE agent key |
|---|---|---|---|
| 3D Printers | `gemma/3d-printers` | `C:\CTFGemma2\Gemma-3D-Printers` | `3d-printers-equipment` |
| Gaming | `gemma/gaming` | `C:\CTFGemma2\Gemma-Gaming` | `gaming-consoles-accessories` |
| Cameras | `gemma/cameras` | `C:\CTFGemma2\Gemma-Cameras` | `cameras` |
| Drones | `gemma/drones` | `C:\CTFGemma2\Gemma-Drones` | `drones` |
| Metal Detectors | `gemma/metal-detectors` | `C:\CTFGemma2\Gemma-Metal-Detectors` | `metal-detectors` |
| Mobile Phones | `gemma/mobile-phones` | `C:\CTFGemma2\Gemma-Mobile-Phones` | `mobile-phones` |
| Laptops | `gemma/laptops` | `C:\CTFGemma2\Gemma-Laptops` | `laptops` |

Each folder is a separate Git clone, not a Git worktree. Each clone has its own `.git`, branch, working tree, source, tests, agent config and updater. Clones use sparse checkout for `tools/tradeflow-gemma-agent` to avoid downloading the website application into every agent folder. Branches share ancestry only; there is no automatic branch sync, merge or code propagation.

## Shared ENV and Ollama

- Shared private ENV remains at the owner's existing verified path: `C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent\.env`.
- The installer writes only the ENV file path into `C:\CTFGemma2\Gemma-Shared\TradeFlow.env.path`. It never copies, prints, backs up or modifies secret values.
- Each agent launcher sets `TRADEFLOW_GEMMA_ENV_FILE` to that same existing file.
- Each agent has its own `agent.config.json`, with exactly one canonical `enabledAgentKeys` value and its own `sourceBranch`.
- Ollama remains the existing local model service. Independent Node processes load their own category code and instructions but call the same local Ollama endpoint. Do not install duplicate Ollama services or models per category.

## Runtime isolation

- `Start-Gemma-Agent.ps1` starts the worker from that clone only, verifies the current Git branch matches the local config, checks one-agent configuration and prevents duplicate start from the same folder.
- The worker reads the per-folder config path through `TRADEFLOW_GEMMA_AGENT_CONFIG`.
- It calls the service-role-only `platform_ai_agent_claim_task_for_agents` RPC with one allowed agent key. The RPC claims only homogeneous tasks belonging to that agent key; mixed-category task groups are not claimable.
- A second in-process guard rejects any task group or subtask whose resolved category identity is outside the installation's one allowed agent key.
- Common Room identity, greeting and messages are category-specific. The old hard-coded 3D Printer Common Room identity is removed from the isolated worker path.
- `Update-Gemma-Agent.ps1` updates only the current clone from its own configured branch and refuses to update while that clone's worker is running.
- No agent is auto-started by the installer. Each desktop shortcut starts only its selected Gemma. The user can switch by stopping one process and starting another; concurrent independent processes are technically separate, but do not start several at once until local Ollama capacity has been verified.

## Installer

`tools/gemma-agent-isolation/Install-Gemma-Agents.ps1`:
1. Detects the current known private ENV path or asks for the existing path once.
2. Writes a path pointer only under `Gemma-Shared`.
3. Clones the seven named branches into seven independent folders using sparse checkout.
4. Verifies branch name, one-key agent config and per-agent launcher.
5. Creates one desktop shortcut per Gemma and a Gemma Switchboard shortcut.
6. Does not stop, update, overwrite or start the existing Research PC installation or any running worker. Existing destination folders are skipped, never overwritten.

The installer itself is downloaded and run once by the owner after CI passes. It cannot create folders on the Research PC remotely.

## Existing work preserved

- Existing working installation remains at `C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent`.
- Existing Gemma Desktop/Research Control Centre remains untouched during this feature work.
- Existing 3D Printer routes/playbook, source registry, queued work, evidence and review rows remain untouched.
- Existing Gaming rollout and other category configurations remain untouched.
- No Supabase schema, RPC, queue, source, task or evidence data is changed by this architecture branch.
- The 3D Printer eight-product batch already running under the existing process must complete before the owner switches the 3D Printer runtime to the new clone. Do not run both 3D Printer copies simultaneously against the same queue.

## Acceptance gates

1. CI parses all PowerShell scripts, checks all Node source syntax and passes the new isolation tests plus existing Gemma regression suites.
2. Confirm all seven Git branches exist and each branch config names exactly its own category.
3. Run the installer once; verify seven separate folders, seven distinct Git branch names, seven independent `.git` directories and seven desktop shortcuts. Verify the shared ENV file itself was not copied.
4. Start only Gemma 3D Printers from its new folder after the existing batch is complete. Verify LIVE status/worker identity and one-category claim behaviour.
5. Queue one small controlled 3D Printer task, then a block-sized task; verify the 3D worker claims only 3D Printer tasks and writes evidence as before.
6. Lock the 3D Printer branch and folder checkpoint before starting any work on Gaming.
7. When developing Gaming, make changes only in `gemma/gaming` and `C:\CTFGemma2\Gemma-Gaming`. Do not cherry-pick or merge those changes into the locked 3D Printer branch.
8. Repeat one category at a time for Cameras, Drones, Metal Detectors, Mobile Phones and Laptops.

## Known limitations and do-not-do list

- GitHub branches and scripts are created, but local folders/shortcuts are not yet installed and no new isolated worker has been started.
- The old desktop Control Centre remains a shared supervisor and is not the launcher for these independent instances.
- Do not use `Update-TradeFlow-Gemma.ps1 -SourceBranch production` against an isolated agent. Use its category-local `Update-Gemma-Agent.ps1`, which reads the branch name from that folder's config.
- Do not put any private ENV values or service-role keys in GitHub, agent configs, shortcuts, logs or ChatGPT.
- Do not change the shared RPC or LIVE queue to accommodate an individual agent without separate review.
