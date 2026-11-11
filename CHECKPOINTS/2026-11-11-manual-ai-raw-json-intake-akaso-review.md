# Checkpoint — Manual AI raw JSON intake fix and AKASO review

Date: 11 November 2026, 21:15 UTC
Environment: TradeFlow LIVE only
Repo: laurendigitaluk/TradeFlow, production
Supabase LIVE: gxsrajtqzdjvmceqcpgv

## User's correction and supplied file
User stated that the JSON had been pasted into the dashboard's response box. The attached file Pasted text (20261111-205435).txt is valid raw JSON, 14,484 characters:
- schema_version tradeflow_manual_research_v1
- 6 findings
- 15 not_found
- Covers all 20 product IDs in prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8.
The browser parser accepted raw JSON embedded in a complete response, but submitted the entire textarea content. The database RPC previously only extracted fenced ```json blocks, so readable report + raw JSON failed its JSON cast and returned a misleading message.

## LIVE backend corrections
1. Migration 20261111210818_manual_ai_accept_embedded_unfenced_json:
   - Added public.platform_extract_manual_ai_json_response(text), a balanced-brace scanner that respects JSON string quoting and escaped characters.
   - Updated platform_owner_submit_manual_ai_research_response to extract the JSON object before schema_version from raw or fenced response text.
   - Complete submitted text is still stored in response_text.
   - Invalid JSON now produces a specific parse error.
2. Migration 20261111210908_manual_ai_allow_conservative_comparison_references:
   - Allows assistant to downgrade source to comparison_only.
   - Generic marketplace shop/search/category URLs remain comparison_only.
   - Marketplace listing qualifies as direct catalogue evidence only when exact package, opened, and product URL path is eBay /itm/, Amazon /dp/ or /gp/product/.
   - This does not verify/import evidence; source verification remains required.

## Tests
- Parser tested against actual attached 14,484-character JSON: extracted object schema_version tradeflow_manual_research_v1; 6 findings; 15 not_found.
- Parser tested with raw JSON embedded after readable report text and with fenced JSON.
- Dry-run of the actual submit RPC in a transaction: submitted=true, 6 candidates, 0 rejected, 15 not_found. Transaction rolled back.
- Actual owner-authorised RPC submission completed prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8 / batch 3b8febea-ef87-4158-b2b6-0beab943edf0.
- Prompt completed; candidates_created=6; findings_rejected=0; response_text length 14,484; original JSON and all source links saved.
- Six queue candidates were created as comparison_only and pending_review, no live_master_product_id, no live_evidence_id.

## Source review and duplicates
Opened five pages (four original URLs accessible plus a related direct eBay listing discovered via the search result). No reported source price passed verification:
- AKASO 360 eBay direct listing £378.72 is ended and title is Motorcycle Combo, not Standard Combo.
- Brave 4 Pro eBay item found from search results currently £116.37, damaged-box title, not submitted £94.61.
- PriceSpy Brave 4 Pro currently £140.00, not submitted £95.61.
- Generic eBay shop/search pages do not substantiate the reported exact Brave 4, Brave 4 Elite and Brave 7 prices/packages.
All six findings matched existing active evidence by same product/source URL/price/type:
- Brave 4 Pro eBay £94.61 uk_new → 52f61e1a-5394-483d-88a9-5e1ada1a6ea2
- Brave 4 Pro PriceSpy £95.61 uk_new → 00d65c34-8dda-4247-b727-46eeab119bf7
- Brave 4 Elite eBay £82.86 uk_new → cda65796-15e1-4663-9117-23c8523eaa76
- AKASO 360 Standard Combo eBay £378.72 uk_used → 2ba18a7a-2f55-41d1-9c94-17944157640b
- Brave 4 Standalone eBay £36.75 uk_used → 1e0d66f9-aa76-4aec-b223-76f7a02d70eb
- Brave 7 Motorcycle Bundle eBay £152.95 uk_new → 71b2006b-5cb5-445d-a6ee-416d36f486ac
All six queue candidates were reviewed using the authorised owner review RPC and marked rejected with duplicate/source reasons. Final queue status: 6 rejected, 0 imported, 0 linked. Active shared_market_evidence remains 4,490 (2,157 new, 2,333 used). No new evidence was imported.

Potential catalogue correction: AKASO 360 listing title is Motorcycle Combo, but the existing evidence row is attached to Standard Combo. LIVE catalogue contains a Motorcycle Combo package for the same AKASO 360 model. Do not silently move evidence; investigate through controlled correction.

## Remaining blockers and boundaries
- Second 20-product AKASO prompt remains ready/unsubmitted.
- Dedicated authorised queue-to-shared_market_evidence importer is still missing.
- No customer, tenant, Stripe, subscription, TEST, valuation, or unrelated catalogue data changed.
- No evidence records were inserted or edited in this work.
- Production front-end did not need a JS change; server-side intake fix applied directly to LIVE.
- Both manuals and the Manual AI diagnostic roadmap updated.
