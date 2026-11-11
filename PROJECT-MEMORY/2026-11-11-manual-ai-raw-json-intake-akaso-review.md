# TradeFlow Manual AI raw JSON intake fix and AKASO review — 11 November 2026

The user clarified that valid JSON had been pasted into the Owner Dashboard Manual AI response box. The attached 14,484-character raw JSON file is valid tradeflow_manual_research_v1 with 6 findings and 15 not_found entries covering the 20-product AKASO prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8.

Root cause: browser tryParseManualAiJsonReply could extract embedded raw JSON, but sent the entire response text to the submit RPC. The database RPC only extracted fenced JSON and tried to cast the whole readable report + raw JSON to jsonb. This returned a misleading fenced-code-only error.

LIVE migrations:
- 20261111210818_manual_ai_accept_embedded_unfenced_json: balanced-brace JSON extractor respecting strings and escapes; submit RPC extracts raw or fenced object and retains full supplied response text.
- 20261111210908_manual_ai_allow_conservative_comparison_references: assistant can conservatively downgrade to comparison_only; generic marketplace shop/search/category URLs remain comparison_only; product-shaped eBay /itm/ and Amazon /dp/ /gp/product/ can qualify for direct listing role only under exact-package/opened checks.

Tests: parser validated actual attached file (6 findings/15 not_found) and synthetic embedded raw/fenced examples. Actual owner RPC dry-run rolled back and returned 6 candidates, 0 rejected, 15 not_found. Then actual supported RPC submitted the supplied JSON to prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8. Prompt and batch completed; 6 comparison-only queue candidates created; complete supplied JSON (14,484 chars) and source links saved.

Source verification: 5 pages opened including related direct eBay listing discovered from search. AKASO 360 listing ended and title is Motorcycle Combo, not Standard Combo. Brave 4 Pro eBay direct listing found in search shows £116.37 with damaged-box title, not £94.61. PriceSpy now shows £140, not £95.61. Generic eBay shop/search pages did not substantiate other submitted exact prices/package claims.

All 6 candidates were exact duplicates of existing active shared evidence by product/source URL/price/type. They were reviewed via the authorised owner review RPC and marked rejected with duplicate/source notes. Final: 6 rejected, 0 imported, 0 linked. Active evidence remains 4,490 (2,157 uk_new; 2,333 uk_used). No evidence insert/update was performed.

Potential catalogue correction: AKASO 360 eBay listing says Motorcycle Combo, while existing matching evidence is attached to Standard Combo; LIVE catalogue has same-model Motorcycle Combo product. Do not silently move evidence.

Remaining: second AKASO 20-product prompt unsubmitted; authorised idempotent queue-to-shared_market_evidence importer still absent. No TEST/commercial/customer data changed. Both manuals and diagnostic roadmap updated.
