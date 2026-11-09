# Checkpoint — Gemma Desktop Control Centre (9 November 2026)

## Baseline
- Production branch: production
- Production base commit: e81ede671bfc03e73dc16169638011372b5b6117
- Feature branch: feature/gemma-desktop-control-centre-20261109
- Pull request: #325 (open, unmerged, mergeable)
- Code/test head: 14da7fa38fec9a75cf95137985a49d20a2208abb
- Latest code CI: GitHub Actions run #472 passed all steps, including 92 Gemma tests (0 failures), PowerShell syntax, Node syntax and Owner Dashboard JavaScript syntax.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv
- TEST Supabase: nnsshnfkjcflucjrftzi

## Implementation
- Windows Control Centre and seven specialist shortcuts under tools/tradeflow-gemma-desktop.
- One sign-in background supervisor and one queue worker/Ollama execution lane.
- Seven switches: 3D Printers, Gaming Consoles, Drones, Metal Detectors, Mobile Phones, Laptops, Cameras. Gaming is one switch for PlayStation/Xbox/Nintendo branches; legacy agent keys are aliases.
- Desktop config is local and contains no credentials. Existing private .env path is reused and not copied, printed or overwritten.
- Worker claims through service-role-only platform_ai_agent_claim_task_for_agents(text,text[],integer). Every subtask must belong to an enabled agent. Desktop mode has no fallback to the legacy unscoped claim.
- Disable prevents new claims; active task finishes. Global stop is graceful. Missing RPC stops with requires_migration.
- Installer refuses to overwrite an active worker and creates the supervisor scheduled task plus Control Centre and seven specialist shortcuts.

## Website configuration
- LIVE registry: 119 UK source records, 116 enabled. Category coverage including universal sources: 3D Printers 15, Gaming 17, Drones 21, Metal Detectors 13, Mobile Phones 23, Laptops 12, Cameras 24.
- No source registry rows changed in LIVE or TEST.
- 3D-printer playbook/extraction unchanged. Gaming capture-only handoff unchanged; gaming discovery routes completed for verified UK retailers and console manufacturer sites.
- New/missing source-domain entries and homepage/category routes completed for Drones, Metal Detectors, Mobile Phones and Cameras; Laptops routes retained.
- Approved global sources accept UK locale path segments uk, gb, en-uk, en_uk, en-gb, en_gb and gb-en only when the host matches an approved source record.
- store.dji.com is skipped because it redirects to sign-in. Discovery routes never count as evidence; exact individual product/listing pages are required.

## Restore/safety notes
- No production code merged; PR #325 remains unmerged.
- No Supabase migration applied to LIVE or TEST.
- No LIVE/TEST queue, task, source registry, catalogue, evidence, approval or import rows changed.
- No Research PC update/restart/start performed.
- Existing private .env remains untouched on the PC.
- Desktop supervisor is LIVE-only; TEST remains separate.
- LIVE schema inspection found no dedicated project-memory/checkpoint table; repository docs/checkpoints are the durable record.

## Next steps
1. Obtain owner approval to merge PR #325.
2. Apply the additive scoped-claim migration to LIVE only after merge/approval.
3. Install on Research PC from production; stop any old manual worker cleanly before installation.
4. Verify supervisor and seven switches; run one bounded LIVE review-only acceptance task.
5. Confirm raw capture appears in the existing LIVE review queue; no automatic approval/import.
