# Checkpoint — TradeFlow 3D-printer review snapshot versioning

Date: 2026-11-09
Scope: `3d-printers-equipment` / `3d-printers`.
Branch: `fix/gemma-3d-review-snapshot-versioning-20261109` (stacked on PR #332 branch).

## Current position
The latest LIVE Neptune 4 Pro task completed at 15:03:59 UTC under worker `DESKTOP-LVASEUB-78412`. It searched 29 results, discovered 6 product pages, fetched 3, retained 3 full captures, and produced 2 Gemma batches with 3 extraction failures. Runtime was 19m 16s, of which 18m 49s was Gemma extraction.

All three queue writes were `duplicate-skipped`. The matching imported queue rows held only 9,998, 10,000 and 3,493 characters, while the task retained 42,206, 14,328 and 3,506 characters. The latest page observations also differed in price/availability context. The review queue therefore did not receive the new source snapshots.

## Repair
The branch adds a deterministic snapshot fingerprint and a revision key. Exact repeats remain idempotent. Changed captures against imported/rejected/reviewed rows become new `needs_research` review items; previous rows remain immutable. Changed captures against unreviewed pending rows use the existing guarded enrichment history. New rows remain `unverified_capture`; no auto-approval/import.

It also records actual Ollama HTTP requests separately from extraction batches and counts pages retained as raw fallback after failed 3D-printer batches.

## Tests required
- Same page fingerprint => same key and duplicate skip.
- Changed GBP price/context => distinct revision key.
- Previously truncated versus full-page capture => distinct revision key.
- Imported/rejected rows => new revision, no mutation.
- Unreviewed pending row => guarded enrichment.
- Same revision repeated => no duplicate.
- Batch timeout => actual HTTP request and raw fallback counts are accurate.

## Verification still required
- GitHub Actions on this branch must pass.
- Review PR #332 parent and the stacked snapshot PR together.
- No LIVE installation or test task until explicit approval.
- After approval, install on the Research PC without changing its private `.env`; then run one bounded 3D-printer task and verify that materially changed same-URL pages appear as new ChatGPT review captures while exact repeats remain skipped.
- Verify new/used separation and no automatic approval/import.

## Environment safety
No TEST/LIVE data copied. No LIVE queue/catalogue/evidence rows modified. No source registry or migration changed. No secrets accessed. No worker restarted. No research task queued.

### Final review record — PR #334
- Consolidated production-based PR: https://github.com/laurendigitaluk/TradeFlow/pull/334
- Current code head at CI verification: `a01b3caa7f2bcbe4aaa128c3a1d2ce50e88c4e3e`.
- GitHub Actions run #537 passed: 105 tests passed, 0 failed; PowerShell, Node and Owner Dashboard syntax checks passed.
- PR #332 and PR #333 were closed as superseded by #334 to prevent competing versions. PR #331 remains the separate generic idle-heartbeat proposal.
- PR #334 remains open, unmerged and undeployed. The Research PC 45-second timeout and changed-snapshot queue handoff still require a controlled runtime acceptance test after explicit approval.

## Read-only snapshot replay result
The production-style fingerprint was replayed against the actual three latest Neptune 4 Pro task captures and their matching imported LIVE queue rows. All 3/3 fingerprints changed: 3DJake 10,000→14,328 chars (4→7 unique price/context observations); ELEGOO UK 9,998→42,206 chars (14→52); 3D Prima 3,493→3,506 chars (2→8). Each would create a new `needs_research` revision; exact repeats remain idempotent. This was a read-only calculation: zero queue rows were inserted or modified.
