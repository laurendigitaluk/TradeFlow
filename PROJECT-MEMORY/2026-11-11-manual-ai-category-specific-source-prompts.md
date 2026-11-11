# Manual AI category-specific source prompts — 11 November 2026

## Request
The Owner Dashboard AI Research Centre must generate a prompt from the selected catalogue category and include the websites assigned to that category in the owner-managed source directory.

## Inspected starting state
- Repository: `laurendigitaluk/TradeFlow`, branch `production`.
- Existing category product picker: `platform-owner-dashboard.js` functions `loadCloudAiCatalogueCategories`, `onCloudAiCategoryChange`, `loadCloudAiCatalogueProducts`, and `createManualAiResearchBatch`.
- Existing source directory: `public.platform_research_sources`, including `category_slugs`, `enabled`, `country_code`, `research_scope`, `homepage_url`, and `search_url_template`.
- Existing RPC `platform_owner_list_research_sources(p_category_slug)` already filtered sources by category or wildcard, but manual prompt generation did not include that directory.
- Product snapshots created by the batch RPC already include `category_slug` and `category_name`.

## Change deployed
- Added trigger function `public.platform_inject_manual_ai_category_sources()` and trigger `trg_platform_manual_ai_category_sources` on `public.platform_manual_ai_research_prompts` BEFORE INSERT OR UPDATE OF `prompt_text, products_snapshot`.
- It derives categories from the product snapshot, selects enabled GB source rows assigned to the category or universal `*`, excludes `research_scope='overseas'`, and appends source names, source kinds, scopes, homepages and optional search URL templates.
- Added instructions to inspect individual product pages, verify exact model/package/condition/availability/GBP price, record actual URLs, and continue broader UK discovery.
- The marked section is replaced idempotently on prompt refresh. New and refreshed prompts receive the same source-directory treatment.
- Initial implementation was immediately corrected to use `chr(10)` and marker-based removal, avoiding literal backslash-n text and making refresh idempotent.

## Deployment
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (TRADEFLOW LIVE).
- Applied migrations: `20261111000000_manual_ai_category_specific_source_prompts` and `20261111000001_manual_ai_category_source_prompt_newline_fix`.
- GitHub commits on `production`: initial migration `46e8be336b57f41b95d65af63ef55b1dbd39dc79`; follow-up files include corrected migration, manuals and this checkpoint.

## Acceptance test requested
Owner to generate an Action Cameras prompt and a Drones prompt, confirming each contains the corresponding enabled website list and does not contain overseas sources. Also refresh an unstarted prompt to confirm the source section is regenerated without duplication.

## Boundaries
No TEST database or tenant data changed. No catalogue/evidence rows, approval statuses, valuation logic, customer/tenant records, domains, Stripe or subscriptions changed. Evidence still requires human review and explicit approval.
