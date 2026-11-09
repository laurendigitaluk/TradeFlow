# Project memory — TradeFlow LIVE ELEGOO used-lane eligibility

Updated: 9 November 2026, 13:12 UTC
Project: TradeFlow LIVE `gxsrajtqzdjvmceqcpgv`
TEST: `nnsshnfkjcflucjrftzi`
Scope: category `3d-printers-equipment`, branch `3d-printers`
Production base: `b47bff3f7b6e370e20ffdb2f3a87a82dafbf8631`
Feature branch: `fix/gemma-elegoo-used-lane-current-production-20261109`
PR: #323

## Source eligibility finding
The existing enabled ELEGOO UK manufacturer source row is assigned to the 3D-printer category and GB, but its scope is `new_uk`. Production maps that to the UK-new lane and excludes it from pure `uk_used` tasks. The production playbook already has the correct separate FDM and pre-owned collection routes; the missing part is source eligibility.

LIVE exact row: `ELEGOO UK`, `uk.elegoo.com`, manufacturer, GB, enabled, category `3d-printers-equipment`, scope `new_uk`.
TEST read-only query: no ELEGOO UK row.
LIVE migration history: version `20261108093000` absent.

## Proposed fix
Update only that exact existing LIVE row to `research_scope='all'` using an update-only migration guarded by every identifying field and current scope. This does not create/copy a TEST row. Keep the existing routes:
- `uk_new` → `/collections/fdm-printers`
- `uk_used` → `/collections/pre-owned-3d-printer`
- `uk_both` → both routes.

Collection pages are discovery only; only exact individual printer listings with current availability, condition, package and GBP price may be handed to ChatGPT for review. No automatic approval/import.

## Current LIVE research state
Exactly 19 registered task rows match the category/branch, with 56 product subtasks; all completed, zero queued/running/failed. Latest completion 01:56:42 UTC.
- Ender-3 V3 KE: 11 search results, 0 product pages, 0 fetched, 0 Gemma calls; 28 routes, 11 matches, 11 empty, 6 errors, two collection JSON 404s.
- K1 Max: 11 search results, 1 product page fetched, 0 Gemma calls because it predates PR #320 merge, one raw capture, duplicate-skipped against the existing imported K1 Max record.
Historical batches: 13:15 = 123 search / 30 discovered / 18 fetched / 18 Gemma calls / 10 failures; 16:45 = 104 / 21 / 11 / 7 / 5; 20:16 = 123 / 83 / 51 / 27 / 20.

## Worker status
Category row idle; counters 85 completed / 122 candidates; category heartbeat 01:56:42 UTC, worker ID `DESKTOP-LVASEUB-84452`.
Generic queue worker idle; worker ID `DESKTOP-LVASEUB-78412`, last status update 12:39:53 UTC. Starts at 12:14:25, 12:34:18, 12:35:53 and 12:39:53 have no matching stop events for the later IDs. Treat as possible sequential restarts, not proof of concurrent workers. Local Research PC supervisor.log and worker stderr are required to diagnose exits. Production does not heartbeat during idle polling; PR #322 is the existing global heartbeat proposal and is based on an old production commit.

## Review queue and evidence
65 historical queue rows: 28 imported, 37 rejected, 0 open. Linked active shared evidence: 23 UK-new, 5 UK-used, all GBP. One new and one used record have sold-out/unavailable notes. Current queue source_excerpt and page_capture.captured_text maximum is 10,000 characters across 62 captured records; 3 records have no page capture. Reviewer audit: 27/28 imported rows lack reviewed_by, 8 imported rows lack reviewed_at, all 37 rejected rows lack reviewed_by, and 64/65 queue rows have null evidence_type. Do not infer identities or backfill/rewrite historical decisions.

## Related PRs
- PR #320 is merged to production; current production `isCaptureOnlyResearchTask()` is Gaming-only, so 3D printers use Gemma/Ollama extraction. No post-merge 3D-printer runtime task exists.
- PR #327 is open/unmerged, based on production `1b76e6e4...`. It preserves full 3D-printer page captures after successful Gemma extraction and scopes the Creality Ender-3 V3 collection route to matching models. CI run #484 succeeded. Fixture: 10,000/40,642 (24.6%) → 40,642/40,642 (100%). Production has since advanced with documentation-only commits; rebase is required before merge.
- PR #322 is the generic idle-heartbeat proposal, based on old production and unmergeable; do not duplicate it in this category-only repair.
- PR #324 is closed unmerged, superseded by PR #327.

## Safety and release gate
No migration applied, no LIVE source row changed, no task queued, no worker restarted, no queue/evidence/catalogue/review row changed, no evidence approved/imported. TEST has no source row and no data was copied. No private .env or secrets accessed or changed. After PR review and explicit owner approval, apply the migration through the normal deployment process, then run one bounded ELEGOO uk_used task. Do not merge/deploy or queue work without approval.


## Verification update — 9 November 2026, 13:13 UTC

- Rebased code/test head: `dd396989be673df0184b0afdfbff5e4e019dea93`, built from production `b47bff3f7b6e370e20ffdb2f3a87a82dafbf8631`.
- GitHub Actions Gemma Research Tests run #492 (ID `42623521038`) completed successfully; the workflow's single job passed. The run metadata does not expose the test count, so no numerical count is claimed here.
- Current production has advanced to `5be5ed7cd1e26a63cb88ca0b73d09bf88ac7eb71`; GitHub reports PR #323 mergeable against the current production branch.
- The migration remains unapplied; LIVE ELEGOO scope remains `new_uk`; TEST still has no matching source row. No research task, source row, review record, evidence, approval or import was changed.
- No merge, deployment or Research PC restart was performed.
