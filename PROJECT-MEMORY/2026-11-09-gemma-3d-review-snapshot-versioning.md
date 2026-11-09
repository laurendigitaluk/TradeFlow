# TradeFlow LIVE Gemma — 3D-printer review snapshot versioning

Date: 2026-11-09
Scope: category `3d-printers-equipment`, branch `3d-printers` only.
Feature branch: `fix/gemma-3d-review-snapshot-versioning-20261109`
Parent repair branch: `fix/gemma-3d-discovery-capture-elegoo-used-20261109` (PR #332; not merged).

## LIVE baseline
- Exact registered research tasks: 20.
- Completed tasks: 20; completed product subtasks: 57.
- Running: 0; queued: 0; failed: 0.
- Latest task: `owner-live-3d-printers-worker-check-neptune4pro-20261109-1445`.
- Worker ID: `DESKTOP-LVASEUB-78412`.
- Latest category heartbeat/completion: 2026-11-09 15:03:59 UTC.
- Generic worker status remains idle; its generic heartbeat was last recorded at 12:39:53 UTC because the current production worker does not refresh the heartbeat while idle.
- No newer scoped task appeared in this check.

## Latest task metrics
- Search results: 29.
- Approved sources probed: 12.
- Approved source routes attempted: 26; 11 matches, 9 empty, 6 failed.
- Individual product pages discovered: 6; fetched: 3.
- Product-page fetch errors: 3 (eBay UK HTTP 403).
- Gemma batches: 2; extraction failures: 3.
- Actual Ollama HTTP requests are not yet reported separately in production; the proposed code adds `gemma_http_requests`.
- Runtime: 19m 16s; Gemma extraction stage: 18m 49s.
- Three full page captures retained in task results: 42,206, 14,328 and 3,506 characters.
- All three review-queue writes returned `duplicate-skipped`.

## Confirmed first loss after successful fetch
The three page URLs already existed in imported queue rows. The stored page captures were 9,998, 10,000 and 3,493 characters. The new captures were materially different: full-page lengths changed and the page price/availability observation sets changed. The new task results retained the full captures, but the queue's base dedupe key (manufacturer + model + package key + exact source URL) treated each same-URL capture as a duplicate. The imported rows are terminal and intentionally cannot be enriched, so the newer captures never became ChatGPT review items.

The first earlier loss in the overall pipeline remains search-to-exact-product-page discovery: 29 search results -> 6 exact pages discovered -> 3 fetched. This snapshot issue is a later loss after fetch and capture.

## Queue state (unchanged)
- 65 historical review records: 28 imported, 37 rejected, 0 open.
- Linked active evidence: 23 UK-new, 5 UK-used (28 records).
- 27 imported queue rows lack reviewer ID; 8 imported rows also lack review timestamp; all 37 rejected rows lack reviewer ID. Do not reconstruct reviewer identities or alter historical decisions.
- No review queue row, catalogue product or shared evidence row was changed.

## Proposed correction
The new feature branch preserves the base capture key and introduces a material snapshot fingerprint:
- GBP price amounts and nearby contexts.
- Product title, package/variant, condition, availability and location observations.
- A 1 KB capture-size bucket to detect previously truncated versus full-page captures.
- A small normalised text fallback when structured observations are absent.

Repeat handling:
- Same fingerprint: duplicate skip.
- Changed fingerprint on an unreviewed `needs_research` row: existing guarded compare-and-swap enrichment history.
- Changed fingerprint on imported/rejected/reviewed row: insert a separate `needs_research` revision row with a snapshot-specific dedupe key. Do not modify the prior row.
- Revision rows remain `unverified_capture`; no evidence type, reviewer, approval or import is fabricated.

The code also adds `gemma_http_requests` and `gemma_recovery_skipped` metrics while preserving `gemma_calls` as the existing batch counter.

## Safety and release gate
- No LIVE or TEST database writes were made in this repair.
- No source registry row or migration was changed.
- No research task was queued and no worker was restarted.
- No evidence was approved or imported.
- No private `.env` or secrets were accessed or changed.
- The branch is stacked on PR #332 and must be reviewed together with its parent. No merge or deployment without explicit approval.
- The 45-second 3D-printer Gemma timeout in PR #332 remains unverified on the Research PC. Raw full-page fallback is retained if Gemma times out.
