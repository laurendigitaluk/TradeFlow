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

## LIVE inbox audit — 11 November 2026, 20:30 UTC

### Current retrieval result
- platform_catalogue_research_queue contains zero rows with agent_name beginning 'Manual AI Research ·', and zero rows with a broader Manual AI Research name or raw_payload.research_method of manual_ai_chat/manual_ai_report_table.
- LIVE has 75 queue rows in total, all from the Gemma lanes: 28 imported, 10 needs_research and 37 rejected. None are Manual AI Research candidates.
- platform_research_reports is empty. The Bionic Research Inbox Edge Function is a separate workflow and its submit action stores a report only; it does not import evidence.
- LIVE has two current ChatGPT batches, each with one 20-product prompt, both prompt status ready. Prompt IDs cc5e8462-feda-45f0-b4ba-6f6ae33bbce8 and 4e9d16d5-baae-4fb7-8617-2e3a0a829cb5. Both have null response_text, null response_draft and null response_submitted_at. Their original prompts and 20-product snapshots remain saved; they are not submissions and have no candidates to review.
- The earlier AKASO batch 1b46e2ba-75ae-499f-83c5-05a07695edba and prompt 3e633e82-d5c1-4804-b6e3-2b37f1ec83fc recorded in the 10 November checkpoint are no longer present in the LIVE batch/prompt tables. The 13 historical candidate IDs documented in that checkpoint are also absent from the current queue. The selective cleanup RPC can delete chosen Manual AI queue rows while preserving already imported evidence; current database state does not retain an audit trail identifying which deletion action removed those historical rows.
- Active shared evidence currently totals 4,490 rows: 2,157 uk_new and 2,333 uk_used. These are existing catalogue evidence counts, not imports made by this audit.

### Import-path recheck
- platform_owner_submit_manual_ai_research_response validates the submitted response and stages findings as pending_review queue candidates. It does not insert into shared_market_evidence.
- platform_owner_stage_manual_ai_report stores the full response and stages extracted report-table references as explicitly unverified comparison candidates. It does not verify or import.
- platform_owner_match_manual_ai_comparison only assigns a same-manufacturer/model/category catalogue package. platform_owner_verify_manual_ai_comparison stamps source verification metadata after owner checks. Neither writes evidence.
- platform_owner_review_catalogue_research_item only changes review status and reviewer metadata. Approval is not import.
- Current public-function inventory has no function inserting into shared_market_evidence for this workflow. No trigger exists on either the queue or shared evidence table. Authenticated has SELECT only on shared_market_evidence; INSERT is granted to service_role/postgres only.
- The separate tradeflow-research-mcp Edge Function exposes read-only catalogue/evidence/report retrieval and Bionic report submission. Its description and implementation explicitly state it does not create catalogue evidence. tradeflow-cloud-ai-manager stages Cloud AI candidates into the queue, not shared evidence.

### Outcome
- Candidates reviewed in this run: 0 (none outstanding in LIVE).
- Source pages opened/verified in this run: 0/0 (no active candidate URLs).
- Evidence records imported: 0.
- Duplicates skipped: 0.
- Candidates rejected: 0.
- Further research: the two saved 20-product prompts (40 products total) remain unsubmitted; no response is stored.
- No code or database change and no deployment occurred.

### Exact remaining backend blocker
A narrow owner-authorised, idempotent import RPC/path is still missing. It must require an approved queue candidate, raw_payload.source_verified=true, a direct supported source type and URL, an exact live_master_product_id including correct package mapping, GBP price, evidence type, condition, availability, observed date and excerpt. It must deduplicate against the existing unique (source_name, source_record_key) constraint and existing product/source/price/type evidence, insert the shared evidence record atomically, then set live_evidence_id and imported_at on the queue row. Used evidence must remain reference-only and excluded from automatic buying valuation. Build and test this path before any deployment; do not write directly to the table or use service-role credentials from the browser.

## Raw JSON intake correction and AKASO report processing — 11 November 2026, 21:15 UTC

### Root cause
- Browser helper tryParseManualAiJsonReply() already finds a raw JSON object embedded in the complete assistant reply.
- submitManualAiResponse() sent the entire raw textarea value to platform_owner_submit_manual_ai_research_response.
- The database function only extracted fenced ```json blocks, then cast the full response to jsonb. A readable report followed by raw/unfenced JSON therefore failed with the misleading fenced-code-block error.
- New helper platform_extract_manual_ai_json_response(text) finds the opening brace immediately before the schema_version marker, scans balanced braces while respecting JSON strings and escapes, and returns the embedded object. The submit RPC uses it and retains the complete submitted response in response_text.
- Second validation issue: the old role rule forced all opened marketplace_listing sources with exact package matches to catalogue_evidence. That rejected conservative comparison_only results and generic eBay shop/search pages. The revised rule permits a conservative comparison_only label and only treats product-shaped eBay/Amazon listing URLs as direct marketplace product pages. Generic shop/search/category pages stay comparison_only.

### LIVE migrations
- 20261111210818_manual_ai_accept_embedded_unfenced_json
- 20261111210908_manual_ai_allow_conservative_comparison_references
- Both migrations applied to LIVE and stored under supabase/migrations in production.

### Supplied AKASO report submitted
- Prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8, batch 3b8febea-ef87-4158-b2b6-0beab943edf0.
- The supplied attached JSON was valid raw JSON, 14,484 characters, schema_version tradeflow_manual_research_v1, with 6 findings and 15 not_found entries covering the 20-product prompt.
- A transaction-only dry run returned submitted=true, 6 candidates created, 0 findings rejected, 15 not_found. It was rolled back.
- The actual supported owner RPC then submitted the attached JSON. Prompt and batch now completed; full supplied JSON is saved in response_text; 6 pending_review comparison-only queue rows were created.
- Source verification: 5 pages opened (4 original source URLs plus one related direct eBay listing discovered from results); exact original URL accessibility was partial. The eBay AKASO 360 listing is ended and title is Motorcycle Combo, not Standard Combo. The eBay Brave 4 Pro direct listing found from the search result displayed £116.37 and a damaged-box title, not £94.61. PriceSpy currently displays £140.00, not £95.61. eBay shop/search pages did not substantiate the report's other exact prices/model-package claims. No candidate passed direct source/current-price verification.
- Existing active evidence lookup found exact product/source URL/price/type duplicates for all six candidate rows:
  - Brave 4 Pro eBay UK £94.61 uk_new → existing evidence 52f61e1a-5394-483d-88a9-5e1ada1a6ea2
  - Brave 4 Pro PriceSpy £95.61 uk_new → 00d65c34-8dda-4247-b727-46eeab119bf7
  - Brave 4 Elite eBay UK £82.86 uk_new → cda65796-15e1-4663-9117-23c8523eaa76
  - AKASO 360 Standard Combo eBay £378.72 uk_used → 2ba18a7a-2f55-41d1-9c94-17944157640b
  - Brave 4 Standalone eBay £36.75 uk_used → 1e0d66f9-aa76-4aec-b223-76f7a02d70eb
  - Brave 7 Motorcycle Bundle eBay £152.95 uk_new → 71b2006b-5cb5-445d-a6ee-416d36f486ac
- All six candidate rows were reviewed through platform_owner_review_catalogue_research_item and marked rejected with duplicate/source notes. Final queue status: 6 rejected, 0 imported, 0 linked to shared evidence. No new shared_market_evidence rows. Active evidence count remained 4,490 (2,157 uk_new, 2,333 uk_used).
- The 360 listing may represent an alternative package: catalogue snapshot has an AKASO 360 Motorcycle Combo product. Existing evidence is currently attached to Standard Combo even though the source title says Motorcycle Combo. Flag this for a separate controlled correction; do not duplicate or silently move the evidence.

### Remaining
- The second saved 20-product AKASO prompt remains ready/unsubmitted.
- The dedicated authorised queue-to-shared_market_evidence importer remains missing.
- No customer/tenant/Stripe/subscription, TEST, valuation, or unrelated catalogue data changed.


## 12 November 2026 — ChatGPT-to-dashboard research status updates

The existing AI Research Centre now includes a **ChatGPT research updates** panel. It reads the existing `tradeflow-research` thread through the owner-authenticated `platform_owner_list_ai_agent_messages` RPC and displays messages from `sender_kind='chatgpt_supervisor'` / `sender_key='chatgpt'`. The panel loads at owner-dashboard sign-in, has a manual Refresh updates control, and refreshes every 30 seconds while an owner session is active. Messages are stored in the existing `platform_ai_agent_messages` table; no new notification queue, importer, API key or provider has been added.

ChatGPT can post a progress or completion notice to that existing thread through the connected LIVE Supabase database connection, using `sender_kind='chatgpt_supervisor'`, `sender_key='chatgpt'`, `sender_name='ChatGPT'`, `thread_key='tradeflow-research'`, `recipient_key='platform_owner'`, and `message_type='status_update'`. Each notice should identify its batch scope, verified LIVE evidence imports, comparison-only/unverified references retained, and unresolved items. **Never state a batch is complete or imported until LIVE database read-back confirms the result.** This dashboard message is a status/communication channel; it does not itself import catalogue evidence. The existing evidence verification and authorised import path remains mandatory.

Initial LIVE notice inserted and read back successfully: `f273893d-a387-443f-8a95-1a93e90caca0` (12 November 2026). Front-end files: `platform-owner-dashboard.html` and `platform-owner-dashboard.js` (script cache version 59). TEST was not modified.
