# Project memory — Windows Gemma Research Control Centre

Date: 9 November 2026 (UTC)
PR: #325 — https://github.com/laurendigitaluk/TradeFlow/pull/325
Branch: feature/gemma-desktop-control-centre-20261109
Base production commit: e81ede671bfc03e73dc16169638011372b5b6117

## User requirement
The owner wants a Windows desktop application to control each Gemma product-research specialist independently. The background supervisor should start with Windows, remain available while idle, and process only work arriving through TradeFlow LIVE or when the owner enables the relevant specialist from its desktop shortcut.

## LIVE source registry audit
- LIVE UK source records: 119 total; 116 enabled.
- Enabled source coverage, including shared universal sources: 3D printers 15; Gaming 17; Drones 21; Metal Detectors 13; Mobile Phones 23; Laptops 12; Cameras 24.
- Counts overlap because shared universal and multi-category sources are included in each relevant category.
- No source rows were added, removed or changed.
- Existing 3D-printer and gaming source playbooks were preserved.
- New category playbooks added for drones, metal detectors, mobile phones, laptops and cameras, using current category-scoped source records and recorded UK catalogue paths. Discovery pages remain non-evidence; exact individual product pages are required.

## Desktop implementation
- Seven canonical product-research switches: 3d-printers-equipment, gaming-consoles-accessories, drones, metal-detectors, mobile-phones, laptops, cameras.
- Legacy 3d-printers and gaming-consoles identities are included as aliases of their canonical switches.
- Catalogue Importer remains owner-approval-gated. Release Monitor is not yet connected to the catalogue product-research queue and is not exposed as an executable switch.
- One local supervisor and one Node queue worker are used to avoid queue races and uncontrolled concurrent Ollama execution.
- Local config contains enabled keys and service state only. The existing private .env remains in its existing location.
- Per-agent queue isolation is implemented by new service-role-only RPC `platform_ai_agent_claim_task_for_agents(text,text[],integer)`. A task is claimable only when every subtask resolves to an enabled specialist. Mixed-agent tasks remain queued until all included specialists are enabled.
- Desktop mode never falls back to the existing generic claim RPC. If the scoped RPC is missing, worker writes `requires_migration` and exits safely.
- Disabling a specialist prevents new claims; a task already running is allowed to finish. Global stop is also graceful.
- Windows installer updates the existing Gemma worker via its reviewed updater, preserves .env, creates the Control Centre and seven shortcuts, and registers the supervisor at user sign-in. It refuses to overwrite an already running legacy worker.

## Preservation / deployment boundary
- No LIVE or TEST migration applied.
- No LIVE or TEST source registry changes.
- No task queued, no research run started, no evidence/candidate/approval/import rows changed.
- No Research PC install, worker restart or worker start performed.
- No TEST data copied to LIVE; no Stripe, tenant, subscriber or website data changed.
- Existing 3D-printer extraction/capture behaviour and Gaming capture-only behaviour are not changed.

## Pending gates
1. CI run for PR #325 must pass, including Node tests and PowerShell parser checks.
2. Review SQL migration and merge PR #325 only with owner approval.
3. Apply the scoped-claim migration to LIVE only after merge/approval.
4. Install on Research PC from production; preserve .env and stop any old worker cleanly first.
5. Verify one background worker, all enabled specialists waiting, and disabled specialists not claiming tasks.
6. Run bounded TEST acceptance before any controlled LIVE task. Verify raw capture handoff and no automatic catalogue import.
