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


## Selective prompt deletion — 11 November 2026

- Added checkbox selection to every active prompt and every completed prompt in the collapsed report history. Each batch now offers Select all prompts, Delete selected and Delete all prompts in this batch.
- Added owner-only RPC `platform_owner_delete_manual_ai_research_prompts(uuid[])`, applied through migrations 20261111000004 and 20261111000005. It deletes only selected prompt records owned by the signed-in platform owner, updates remaining batch counts/status, and removes empty batch shells.
- Deleting a submitted prompt removes the saved report text from this dashboard. Evidence candidates already sent to the review queue and shared market evidence are preserved. No prompt records were deleted during implementation.
- Verified the function definition, authenticated EXECUTE grant and anon denial; JavaScript parses successfully; dashboard controls are present; asset cache is v56.
- Manuals updated. TEST remains untouched because this workspace is not present in TEST.


## Global prompt selection and processed queue cleanup — 11 November 2026

- Replaced batch-local prompt deletion controls with one global toolbar. Select all prompts across all batches now selects every prompt checkbox in the loaded batch list, including checkboxes inside collapsed completed-report history. Delete selected removes only checked prompt IDs across batches.
- Evidence review loader now retrieves AI queue records across statuses and separates 13 pending_review items from 75 processed records in a collapsed history. Reviewing an item moves it out of the active pending list. Processed history remains inspectable and has checkboxes for manual queue-row deletion.
- Added owner-gated RPC `platform_owner_delete_catalogue_research_queue_items(uuid[])` in migration `20261111000006_manual_ai_queue_selective_cleanup`. It only deletes queue rows for Cloud AI Research Manager and Manual AI Research agents. It never deletes shared_market_evidence rows or imported catalogue evidence.
- LIVE queue count at inspection: 88 total = 28 imported, 37 rejected, 10 needs_research, 13 pending_review. The user's stated 316 count was not present in this queue table; no bulk deletion was performed. Need identify which other list/table contains the 316 before clearing it.
- JS syntax passed; HTML cache reference v57. Manuals updated. TEST untouched. No queue, evidence or prompt records deleted during implementation.
