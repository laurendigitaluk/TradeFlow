# Manual AI research batch size and simplified prompt — 11 November 2026

## Request
Increase manual AI research batches beyond ten products and simplify the generated research instructions so the assistant covers every product instead of spending excessive effort on repeated searches and leaving pages unchecked.

## Findings before change
- LIVE batch 53505b75-76cc-4af1-b961-c4134dfc48c9 contains 100 selected products, products_per_prompt=10, and prompt_count=10. The report provided by the owner was prompt 1 of 10 and contained ten product records. The database had created ten prompt records; the first report did not represent all 100 products.
- LIVE dashboard selector offered 5, 10, 15 and 20 products, but 10 was selected by default.
- LIVE RPC allowed 5/10/15/20 and accepted up to 500 selected products overall.
- Previous prompt required at least five searches per product and the strict submit validator independently enforced at least five search queries per finding and five searches plus two source sites for not_found.
- Category-specific UK source directory is appended by the existing trigger and must be preserved.
- TEST project nnsshnfkjcflucjrftzi has no platform_manual_ai_research_batches or platform_manual_ai_research_prompts tables; TEST branch main does not contain the Manual AI Research Centre. Do not represent this feature as tested on TEST.

## Changes applied to LIVE
- Applied migration 20261111000002_manual_ai_research_20_product_default_and_simplified_prompt.
- Updated platform_owner_create_manual_ai_research_batch default argument from 10 to 20. The accepted values remain 5, 10, 15 and 20; maximum is 20 products per individual prompt. Overall selection limit remains 500.
- Replaced the verbose five-search research instructions with concise coverage-first instructions: one targeted new search and one targeted used search as starting point; targeted follow-up only when needed; open direct product/listing pages; preserve exact model/package distinctions; label alternative packages and snippets/category pages comparison-only; aim for up to two distinct sources per condition; account for every selected product.
- Updated platform_owner_submit_manual_ai_research_response so findings require at least two actual search queries, and not_found entries require at least two actual searches and two source sites. Existing identity, source, GBP, quote, condition, availability, date and complete-product-coverage validation remains.
- Updated dashboard HTML selector to default to 20 products and asset cache reference to v54.
- Updated dashboard JS display and selection fallback values to 20.
- Updated both system and AI operating manuals.

## Preservation
- Existing saved batches, prompts, drafts, submitted reports, review queue, master catalogue and shared_market_evidence were not modified.
- No TEST, tenant/customer/order/payment, Stripe, or valuation data was changed.
- Category-specific source directory trigger remains active and unchanged.

## Verification performed
- LIVE function definition confirms default 20 and simplified coverage-first prompt.
- LIVE response validator confirms two-query minimum for findings and two-query/two-source minimum for not_found.
- Existing database check constraint still allows only 5/10/15/20.
- No new research batch was created as a test; owner-created batches and saved work were preserved.
- Worker deployment and signed-in browser acceptance remain to be confirmed before considering the dashboard update fully visible.


## Follow-up correction

- The dashboard has a separate regenerate RPC for unstarted saved prompts. It was also updated and deployed to LIVE in migration 20261111000003_manual_ai_refresh_uses_simplified_research_prompt, so newly generated and regenerated prompts use the same simplified instructions. The existing owner/status checks and draft/submission protection remain.
- Migration file committed at bdda4bb9a8abf8793d12bc799a3aa19fa7a72a28.
