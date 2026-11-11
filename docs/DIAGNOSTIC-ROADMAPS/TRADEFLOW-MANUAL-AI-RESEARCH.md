# TradeFlow Manual AI Research — Developer Diagnostic Roadmap

Updated: 11 November 2026
Target: TradeFlow LIVE only
Status: Manual prompt generation V2 applied and read back. Candidate submission, source verification and safe shared-evidence import remain separate stages.

## Purpose and boundaries

Map the owner-operated manual web-research path from catalogue selection through saved prompt, assistant report, candidate queue, human review and (future) evidence import. This is distinct from the optional Cloud AI provider scheduler and from the retired local Gemma worker.

LIVE Supabase project: gxsrajtqzdjvmceqcpgv
TEST Supabase project: nnsshnfkjcflucjrftzi — do not change for this workflow.

Do not modify tenant/customer/subscription/Stripe/published-site data. Used-market evidence is reference-only and must not affect automatic buying valuations.

## User action and front-end entry points

- Owner Dashboard page: platform-owner-dashboard.html.
- Front-end controller: platform-owner-dashboard.js.
- Manual workspace section and selectors use the manual-ai-* IDs in platform-owner-dashboard.html.
- Product/category selection uses the existing catalogue picker; it is not a separate product catalogue.
- Actual front-end functions inspected:
  - loadManualAiResearchBatches()
  - renderManualAiResearchBatches()
  - createManualAiResearchBatch()
  - refreshManualAiResearchPrompt()
  - copyManualAiPrompt()
  - tryParseManualAiJsonReply()
  - parseManualAiReportTables()
  - submitManualAiResearchResponse()
  - reviewCloudAiCandidate()
- The page supports saving a draft, copying a generated prompt, opening the chosen assistant, pasting a full report and submitting a structured response or staging parsed report-table comparisons.

## LIVE database objects and RPCs

Core tables:
- platform_manual_ai_research_batches — batch owner, assistant, product/prompt counts and status.
- platform_manual_ai_research_prompts — exact selected product UUIDs, product snapshot, generated prompt, draft/response and prompt status.
- platform_catalogue_research_queue — normalised review candidates and comparisons.
- catalogue_master_products, catalogue_master_manufacturers, catalogue_master_categories, catalogue_master_branches — authoritative product identity.
- shared_market_evidence — active shared new/used market evidence.
- platform_research_sources — owner-maintained category-specific source directory.

Owner RPCs:
- platform_owner_list_gemma_research_categories()
- platform_owner_list_gemma_research_products(text,text,text,integer)
- platform_owner_list_manual_ai_research_batches(integer)
- platform_owner_create_manual_ai_research_batch(uuid[],text,integer,text)
- platform_owner_refresh_manual_ai_research_prompt(uuid)
- platform_owner_save_manual_ai_research_draft(uuid,text)
- platform_owner_submit_manual_ai_research_response(uuid,text)
- platform_owner_stage_manual_ai_report(uuid,text,jsonb)
- platform_owner_list_catalogue_research_queue(text,integer)
- platform_owner_review_catalogue_research_item(uuid,text,text)
- platform_owner_verify_manual_ai_comparison(uuid)

The owner RPCs are SECURITY DEFINER and authenticated EXECUTE is granted; anon EXECUTE is denied for the inspected create/list/refresh/draft/submit/review/verify functions. Owner membership checks are inside the RPCs. Do not bypass them with direct table writes.

Prompt source:
- public.platform_manual_ai_research_prompt_instructions() — quality V2 instructions.
- Both create-batch and refresh-prompt RPCs call this helper.
- BEFORE INSERT/UPDATE trigger trg_platform_manual_ai_category_sources calls platform_inject_manual_ai_category_sources(), appending the current category-specific source directory. Preserve this trigger.

## Intended data flow

1. Owner selects active master-catalogue product UUIDs and chooses assistant + products-per-prompt.
2. platform_owner_create_manual_ai_research_batch() validates selected active IDs and creates batches/prompts.
3. Each prompt stores product_ids and products_snapshot, including manufacturer/model/package and existing evidence counts/references. The category-source trigger appends the current source directory.
4. Owner copies the prompt to the selected AI assistant and runs live UK research.
5. Front-end tryParseManualAiJsonReply() recognises a fenced JSON block or extracts a raw JSON object for routing. The full raw response is sent to the backend.
6. platform_owner_submit_manual_ai_research_response() validates the structured JSON and stages valid findings as pending_review records in platform_catalogue_research_queue. It does not insert shared_market_evidence.
7. If the response is report/table-only, the UI calls platform_owner_stage_manual_ai_report(). That RPC extracts table rows and stages them as explicitly unverified comparison references. It does not verify pages or import evidence.
8. Owner reviews the queue. platform_owner_review_catalogue_research_item() changes queue status only. platform_owner_verify_manual_ai_comparison() records source verification after a direct page has been opened and a product match exists; it does not import evidence.
9. A separate authorised, idempotent import action is required before a verified candidate can become a shared_market_evidence row. No such Manual AI queue importer was found in the LIVE public function inventory at this checkpoint.

## Security and data access

- platform_manual_ai_research_batches and platform_manual_ai_research_prompts are accessed through owner RPCs, not direct browser table access.
- shared_market_evidence has an authenticated SELECT policy limited to is_active rows. No authenticated INSERT policy was found. service_role has table privileges, but this is not permission to write from the browser or bypass the intended import boundary.
- Candidate review RPC requires an active platform_memberships row and only updates platform_catalogue_research_queue status.
- Do not write directly to shared_market_evidence or treat queue approval as evidence import.
- Keep source URL, source name, price, currency, evidence type, condition, availability, observed date, excerpt and original report provenance intact.

## Quality V2 prompt rules — LIVE migration 20261111135455

Source file: supabase/migrations/20261111000400_manual_ai_research_quality_prompt_v2.sql

- Three distinct actual product-specific searches per product: exact package, UK new retail, UK used; add a fourth targeted same-model alternative-package search when useful.
- Verify exact manufacturer/model and identity-defining suffix, revision, mount or other variant.
- Open direct retailer/individual listing pages. Snippets, category pages, aggregators, editorial pages and blocked pages remain comparison_only.
- Keep catalogue_package_name separate from actual package_name. Only exact package + opened direct page + supported source kind can be catalogue_evidence.
- Keep new/used, refurbished/open-box/opened-never-used/sealed, availability and VAT basis separate.
- Check existing references and deduplicate source URL + price + evidence type.
- Output readable report, then exactly one fenced JSON block. Required JSON fields align with the LIVE intake validator.
- V2 instructions are centralised so new batches and owner-triggered prompt refreshes use identical rules.

## Known failure points and second-test findings

Second Blackmagic camera test report, saved as Pasted text (2).txt:
- Ten selected products; 38 findings; zero not_found.
- All 38 findings were comparison_only.
- 32 findings were snippet_only.
- Six findings were marked opened, but all came from Blackmagic's multi-product UK product-list page, not individual product/listing pages. No direct retailer/marketplace/used-dealer listing page was opened.
- 35 findings listed one search query; three listed two.
- Source kinds: 28 retailer_product_page, eight category_page, one manufacturer_product_page and one price_aggregator.
- The report's JSON used a plain “json” label and raw JSON, not a fenced JSON block. The intake RPC expects a fenced block when prose precedes the JSON; otherwise it attempts to parse the entire report as JSON.
- Existing evidence references in the prompt snapshot were not re-verified. Some source pages/prices were stale, ex-VAT, package-mismatched or unavailable.

At review:
- The report was a Library file, not a submitted LIVE prompt response.
- The LIVE queue had zero Manual AI pending_review candidates.
- The two most recent AKASO batches (20 products each, created 13:31 and 13:39 UTC) were ready/unsubmitted; they were not altered.
- No catalogue or shared evidence rows were changed.

## Verification and recovery checklist

When a new report arrives:
1. Retrieve the original prompt, product snapshot and full response from platform_manual_ai_research_prompts; do not ask for pasted excerpts if the connected record exists.
2. Confirm every selected product ID is represented.
3. Check query count, model identity, exact package, source_kind, page_access, GBP, excerpt and observed date.
4. Open each direct source URL independently. Search snippets and category pages cannot become verified catalogue evidence.
5. Match same-model alternative packages only after checking the LIVE catalogue. Do not force sibling models or suffix variants.
6. Check duplicate URL + product + price + evidence type.
7. Stage/review only through the owner RPCs.
8. Before import, inspect the actual importer implementation, grants, RLS and constraints. If no importer exists, stop and document the exact gap.
9. After any supported import, read back shared_market_evidence and confirm master_product_id, package, type, condition, price and URL.
10. Update both manuals and the matching checkpoint/project memory.

## Current state and next step

- LIVE prompt V2 helper exists and is called by both create and refresh functions.
- Existing ready prompts remain unchanged until the owner uses the authorised Refresh prompt action.
- No new report candidates or evidence were imported.
- The next useful test is to refresh one ready prompt, run the improved prompt, submit the complete report with the fenced JSON block, then assess whether direct-page evidence improves.
- A dedicated safe Manual AI evidence importer remains a separate backend requirement; do not infer that review approval performs an import.


### Independent source spot-check — 11 November 2026

- Opened Blackmagic's individual Cinema Camera 6K product page. It identifies the exact model and currently displays £2,069; the page footer states MSRP excludes VAT. The second-test report recorded £1,219 ex VAT from the multi-product page. Treat that report value as stale/unconfirmed, not current catalogue evidence.
- Opened Production Gear's individual Micro Studio Camera 4K G2 product page. It identifies the model and currently displays £744 ex VAT / £892.80 inc VAT. The report recorded £870 inc VAT from a snippet. Do not accept the snippet value without reconciling it against the live page.
- Wex and MPB sample URLs returned cache misses in this independent check; their prices remain unverified here.
- These spot checks were for prompt-quality assessment only. No price was submitted to the LIVE queue or imported into shared_market_evidence.
