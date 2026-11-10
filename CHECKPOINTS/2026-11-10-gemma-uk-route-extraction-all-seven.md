# Checkpoint — Anycubic UK routes, matcher and extraction repair

Date: 10 November 2026 UTC  
Repository: laurendigitaluk/TradeFlow  
Base: current production  
Feature branch: fix/gemma-research-route-extraction-all-seven-20261110  
Scope: LIVE research code path for 3D printers; shared source/test synchronisation for seven isolated specialist branches.

## Pre-change checks
- Reviewed LIVE Supabase source registry, task, agent status, activity handovers and raw review queue for task owner-3d-printers-equipment-1794272051590.
- Reviewed production agent.mjs, source-playbooks.mjs, tests, 3D Printer roadmap, both canonical TradeFlow manuals, seven-agent updater and isolated-agent configs.
- Reviewed PRs #332, #337, #339, #340 and #341 and their recorded fixes. PR #332, #337, #339 and #340 are merged. PR #341 is open but diverged 22 commits ahead / 44 behind production; GitHub reports it not mergeable. Its matcher correction is carried forward to this current-production-based replacement branch; do not merge stale PR #341.
- LIVE task completed normally. The task contained five subtasks, not six; Kobra S1 Standard was not queued. Worker returned idle. No source registry or evidence rows were changed by this preflight.

## LIVE evidence loss baseline
Five subtask handovers:
- Kobra 3 Max V2 Combo: 15 search results, 4 product pages discovered, 2 fetched, 2 captures enriched, extraction timed out.
- Kobra 3 Max V2 Standard: 22 search results, 2 pages discovered, 1 fetched, 1 new raw capture, extraction timed out.
- Kobra 4 Standard: 9 search results, 2 pages discovered, 1 fetched, 1 existing capture enriched, extraction timed out.
- Kobra 4 ACE 2 Pro Combo: zero results/pages; generic routes empty and eBay 403.
- Kobra S1 ACE 2 Pro Combo: two official Anycubic pages discovered/fetched, two new raw captures, extraction timed out.
- Total: six retained/staged captures (three new, three enriched); four extraction batch timeouts. New queue records remain needs_research with observed_price/evidence_type NULL. No evidence approval or import.

## Code changes in this branch
1. 3D-only matcher now applies accessory exclusion to product title and terminal URL slug, not the full parent taxonomy path. Preserves exact model, sibling-model, package and accessory checks.
2. Anycubic UK Kobra 4 adds direct Combo URL /products/kobra-4-combo-3d-printer alongside Standard.
3. 3DJake UK Anycubic discovery now uses /anycubic-3d-printer-and-accessories/anycubic-3d-printer, follows the printer category and pagination, and rejects parts/accessories at the actual product level.
4. 123-3D new Anycubic discovery now uses /collections/anycubic-3d-printers; used/refurbished remains /collections/refurbished-printers. Lane isolation is preserved. Kobra 3 Max, Kobra 3 V2 and ACE Pro are not substituted for Max V2 / ACE 2 Pro.
5. eBay UK adds the approved ANYCUBIC FDM seller category as discovery alongside exact-model search. HTTP 403 remains blocked; no bypass.
6. 3D-printer extraction now processes one product page per Gemma call and allows one bounded 90-second inference attempt (previously two pages per call and 45 seconds). Other categories retain existing two-page batches and timeout. Complete raw captures remain the fallback.

## Seven-worker scope
Shared worker files and tests must be synchronised to:
- gemma/3d-printers
- gemma/gaming
- gemma/cameras
- gemma/drones
- gemma/metal-detectors
- gemma/mobile-phones
- gemma/laptops

Keep each branch's isolated agent.config.json unchanged. After production merge and branch CI, run the existing production Control Centre Update all workers operation. It preflights all seven folders/configs/branch refs and shared ENV pointer, waits for current work to finish without force-killing Node, updates sequentially from each branch and restarts only previously running workers whose update succeeded. Verify every log. Do not touch .env contents or copy TEST data into LIVE.

## Verification and deployment status
- New production-based feature branch created.
- Code and test files updated; canonical manuals and 3D Printer roadmap updated.
- CI and PR review pending at checkpoint creation.
- Seven category-branch synchronisation pending.
- Research PC update-all operation not run; no worker stopped/restarted.
- No Supabase source registry, schema, queue, catalogue, evidence, approval/import, Stripe, tenant/customer or secret changes.
- LIVE remains separate from TEST.

## Acceptance gate
1. CI passes on the replacement PR.
2. Carry the same shared agent/playbook/test updates to all seven isolated branches without changing their category config.
3. Merge reviewed replacement PR and confirm production deployment.
4. Run Update all workers from the existing Control Centre; check all seven per-agent logs and status.
5. Run bounded six-product Anycubic LIVE acceptance and inspect structured evidence/raw captures, route metrics, timeout metrics and completion persistence.
6. Keep all candidates unverified until ChatGPT/owner review. Do not import evidence as part of the repair.
