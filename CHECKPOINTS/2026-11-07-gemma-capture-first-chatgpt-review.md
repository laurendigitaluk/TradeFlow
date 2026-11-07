# Gemma capture-first research handoff checkpoint

Date: 7 November 2026
Repository: laurendigitaluk/TradeFlow
Production merge: 6b5f8cd514efade38062ae34f5cee5cc25fee5ff
PR: https://github.com/laurendigitaluk/TradeFlow/pull/277
CI: https://github.com/laurendigitaluk/TradeFlow/actions/runs/42409174813

## User decision
Gemma must bring back whatever it finds. ChatGPT decides what is relevant, accurate and usable. Gemma must not decide what evidence should be accepted or discarded.

## Implementation
- Extraction prompt requests factual observations for every fetched direct product/listing page, not a verified/borderline subset.
- Model matching is broad so Combo, Max/Plus/Pro, bundles, accessories and upgrade pages containing the requested model are retained for ChatGPT to classify.
- Every fetched page is staged in LIVE `platform_catalogue_research_queue` as `evidence_candidate`, status `needs_research`.
- Captures retain up to 10,000 characters of extracted page text, exact source URL/title, Gemma observations, and all visible GBP price mentions with nearby context.
- Multi-price product pages preserve every price and package context; no arbitrary single price selection when multiple prices appear.
- If Gemma returns malformed JSON, omits a page or fails, the original fetched page is retained as a raw capture.
- Ollama uses two-page batches and 3,500-character excerpts; longer page text is stored separately.
- Worker handover counts now describe page captures rather than approved evidence candidates.

## Safety
- Approved UK source/category restrictions remain in place.
- All captured records stay in `needs_research`; this is not an approval or import.
- No catalogue/shared-evidence writes, Supabase schema changes, TEST/LIVE sync, Cloudflare changes, or credential/.env changes.
- Only `3d-printers-equipment` / `3d-printers` is in scope.

## Verification
- CI run 42409174813 passed syntax checks and Gemma task/playbook tests.
- LIVE queue schema inspected: nullable evidence fields and `needs_research` status support raw captures; no migration needed.
- LIVE currently has three 3D-printer queue items in `needs_research` (point-in-time count).
- Production GitHub source is updated. Research PC deployment and post-merge runtime acceptance are still pending.

## Next test
1. Update Research PC in place using the existing updater; preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE.
2. Verify worker starts and polls LIVE.
3. Run a small 3D-printer batch across manufacturers, machine-only and combo packages.
4. Confirm each fetched direct page creates a needs_research capture, including pages Gemma fails to parse.
5. ChatGPT inspects full text, checks live source URLs, resolves package/price/condition/availability, and only then decides whether evidence should enter the catalogue.
