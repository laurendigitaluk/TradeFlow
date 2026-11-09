# Checkpoint — ELEGOO UK used-lane eligibility (current production)

Date: 9 November 2026, 13:12 UTC
Scope: TradeFlow LIVE category `3d-printers-equipment`, branch `3d-printers`.
Production base: `b47bff3f7b6e370e20ffdb2f3a87a82dafbf8631`.
Review branch: `fix/gemma-elegoo-used-lane-current-production-20261109`.
Review PR: #323.

## Confirmed defect
LIVE has an enabled ELEGOO UK manufacturer source row assigned to `3d-printers-equipment`, country GB, but `research_scope='new_uk'`. Production `getResearchSourceLane()` classifies it as new-only; `isResearchTypeAllowedSource()` excludes it from `uk_used` before the pre-owned collection route can be probed.

Existing routes are already correct:
- New: `https://uk.elegoo.com/collections/fdm-printers`
- Used: `https://uk.elegoo.com/collections/pre-owned-3d-printer`
These are discovery pages only. Individual exact-model pages must be fetched and checked for package, condition, current availability and GBP price. Sold-out pages are not current used evidence.

## Proposed correction
Update only the exact existing enabled ELEGOO UK manufacturer row to `research_scope='all'`, guarded by source name, domain, source kind, GB country, enabled flag, category slug and current `new_uk` scope. Do not add or copy source rows. TEST has no matching ELEGOO row; LIVE migration version `20261108093000` is absent and has not been applied.

## Current LIVE state
- 19 exact category/branch task rows; 56 product subtasks; 19 completed, zero active/queued/failed.
- Latest Ender-3 V3 KE: 11 search results, 0 exact pages, 0 fetched, 0 Gemma calls; 28 routes (11 matches, 11 empty, 6 failed), two Creality collection JSON 404s.
- Latest K1 Max: 11 search results, 1 page discovered/fetched, 0 Gemma calls because it predates PR #320 merge, one raw capture, duplicate-skipped against existing imported K1 Max UK-new evidence.
- Generic worker status idle, worker ID `DESKTOP-LVASEUB-78412`, last update 12:39:53 UTC; category status last heartbeat 01:56:42 UTC. Multiple later worker-start IDs have no matching stop events; inspect local supervisor/worker logs rather than infer concurrency.
- Queue: 65 historical rows (28 imported, 37 rejected, 0 open). Linked active evidence: 23 UK-new and 5 UK-used, all GBP. One unavailable/sold-out note in each lane. Reviewer metadata is incomplete; do not backfill identities.
- LIVE source registry: 13 category-specific sources plus two universal marketplaces. Category-specific scopes: five new_uk, four used_uk, three official, one all. ELEGOO is the new_uk source targeted by this PR.

## Verification
The regression test is added to the current production test file. CI will run on the rebased PR head. No source row or migration has been changed in Supabase. No task queued, worker restarted, evidence approved or imported. TEST/LIVE data and secrets remain separate.

## Related open correction
PR #327 independently fixes full-page retention after successful Gemma extraction and removes the unrelated Ender-3 V3 collection route from K1 Max. It is open/unmerged and now needs a production rebase before merge.


## Verification update — 9 November 2026, 13:13 UTC

- Rebased code/test head: `dd396989be673df0184b0afdfbff5e4e019dea93`, built from production `b47bff3f7b6e370e20ffdb2f3a87a82dafbf8631`.
- GitHub Actions Gemma Research Tests run #492 (ID `42623521038`) completed successfully; the workflow's single job passed. The run metadata does not expose the test count, so no numerical count is claimed here.
- Current production has advanced to `5be5ed7cd1e26a63cb88ca0b73d09bf88ac7eb71`; GitHub reports PR #323 mergeable against the current production branch.
- The migration remains unapplied; LIVE ELEGOO scope remains `new_uk`; TEST still has no matching source row. No research task, source row, review record, evidence, approval or import was changed.
- No merge, deployment or Research PC restart was performed.
