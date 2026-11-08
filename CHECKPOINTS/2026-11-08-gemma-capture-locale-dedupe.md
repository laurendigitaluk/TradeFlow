# Gemma 3D-printer capture URL deduplication

Date: 8 November 2026 UTC
Scope: category \`3d-printers-equipment\`, branch \`3d-printers\` only.

## Baseline
- LIVE parent task: \`owner-3d-printers-exact-identity-acceptance-20261108-0032\`, 8/8 subtasks.
- 85 searches; 15 pages discovered; 6 fetched/captured; 4 extraction calls; 2 extraction failures.
- 114 approved-source route attempts; 27 matches; 55 empty; 32 errors; 9 page-fetch errors.
- New lane: 32 searches, 7 discovered, 5 fetched/captured.
- Used lane: 53 searches, 8 discovered, 1 fetched/captured.
- LIVE review queue: 44 rows (34 new, 6 used, 4 both); all \`needs_research\`; zero approved/imported.

## Confirmed duplicate
Two new Creality K1 Max standard rows contain the same page title and identical captured page text (2,327 characters; MD5 \`243fb8ad8cf142264ff4ff8c86edb824\`). One source URL has \`?country=GB&currency=GBP\`, the other has no query. Production hashed the exact URL, creating two dedupe keys and two review rows for one product page.

## PR #290
Branch: \`fix/gemma-3d-capture-locale-dedupe-20261108\`
Base: PR #287 branch \`fix/gemma-combo-slug-package-detection-20261108\` (stacked dependency).

- Add a 3D-printer-only canonical capture URL helper for the exact Creality UK product path.
- Remove only a single exact GB/GBP locale pair from the dedupe identity.
- Preserve all other query parameters and preserve the original fetched URL in raw payload.
- Add regression tests and include them in the updater and GitHub Actions workflow.
- No existing LIVE rows are rewritten or removed.

## Verification / safety
GitHub Actions run 42465620424 passed 52/52 tests with zero failures, including syntax checks. This verifies the PR branch only; no local Research PC or LIVE runtime retest is possible without the approved updater. PR #287 must be merged before PR #290 is retargeted to production. No merge/deploy, queue changes, source changes, task enqueue, approvals/imports, TEST/LIVE crossover, secret or private environment changes occurred.
