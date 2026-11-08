# Project Memory — Gemma 3D-printer locale URL deduplication

Date: 8 November 2026 UTC
Scope: TradeFlow LIVE review capture pipeline; category \`3d-printers-equipment\`, branch \`3d-printers\` only.

## Evidence and diagnosis

The latest completed LIVE batch remains \`owner-3d-printers-exact-identity-acceptance-20261108-0032\` (8/8 subtasks, 00:32:26–00:47:00 UTC): 85 searches, 15 product pages discovered, 6 fetched/captured, 4 Gemma calls, 2 extraction failures, 114 approved-source route attempts, 27 routes with matches, 55 empty routes, 32 route errors, 9 individual page-fetch errors, 4 new review rows and 2 existing rows enriched.

The LIVE review queue contains 44 rows: 34 \`uk_new\`, 6 \`uk_used\`, 4 \`uk_both\`. All remain \`needs_research\`; 0 approved and 0 imported. There are 3 top-level observed prices, 2 enrichment histories and 1 reviewer marker. No row was changed during this diagnosis.

Two newly captured Creality K1 Max standard rows refer to the same official product page:
- \`2dd01133-6475-44ad-8929-41a39000728c\`: URL includes \`?country=GB&currency=GBP\`, dedupe key \`capture-c74ad6371630b05a515784e7d154d251\`.
- \`2b64aa24-1204-42d7-9876-665a1e71c473\`: URL has no query string, dedupe key \`capture-7bd623690b41ad8b515f18706925c96b\`.

Both are unreviewed \`needs_research\` raw captures. Both page titles match; captured text is exactly 2,327 characters with identical MD5 \`243fb8ad8cf142264ff4ff8c86edb824\`; their visible GBP price mentions are identical (17 mentions). The only material URL difference is the Creality UK locale selector pair. The production raw-capture key hashes the exact URL, which allowed two queue rows.

## Proposed code correction

PR #290 adds \`capture-identity.mjs\` and tests. For the exact 3D-printer category/branch and Creality UK product-detail path only, one \`country=GB\` plus one \`currency=GBP\` pair is removed when deriving the capture identity. Other query parameters (including product variants), other locale values, duplicate/partial selector pairs, other hosts/routes and all other categories/branches remain unchanged.

The queue top-level URL and dedupe key use the canonical URL. The exact fetched URL remains preserved in raw payload fields, including \`original_source_url\`, \`evidence.source_url\` and page-capture URL. No historical LIVE rows are automatically merged, deleted or rewritten.

Regression tests cover equivalent URLs, variant parameter preservation, non-GB/GBP values, partial/duplicate selectors, other hosts/routes, non-3D scope and malformed URLs. GitHub Actions run 42465620424 passed 52/52 tests with zero failures, including source syntax and Owner Dashboard JavaScript syntax checks. This is PR-branch verification only, not Research PC or LIVE runtime verification. The updater and GitHub workflow now include the new module and test.

## Release dependency

PR #290 is stacked on PR #287 because both modify \`agent.mjs\`. Review/merge #287 first, then retarget/rebase #290 to production. Both remain unmerged/undeployed pending explicit approval and CI. No LIVE/TEST data, queue, source registry, catalogue, task dispatch, credentials, private \`.env\` or Research PC runtime changed. No task queued; no evidence approved/imported.
