# Checkpoint — Manual AI Research quality V2 after second Blackmagic camera test

Date: 11 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: production
Target: TradeFlow LIVE Supabase project gxsrajtqzdjvmceqcpgv
Scope: Review the second manual AI research test and improve prompt generation. LIVE only.

## User request
Review the evidence just added by the second manual research test and rewrite the prompts so the research produces stronger, verifiable evidence. Preserve the original report and sources. Do not touch TEST, unrelated catalogue data, tenants/customers, subscriptions, Stripe or published websites.

## Pre-change inspection
- Checked current production dashboard source, both manuals, existing manual AI research checkpoints and the Cloud AI research diagnostic roadmap.
- Checked LIVE prompt batches, prompt snapshots/responses, research queue, report inbox, relevant RPC definitions, function grants, triggers, RLS and shared evidence access.
- Confirmed no public LIVE tables for project memory/checkpoints; repository PROJECT-MEMORY and CHECKPOINTS remain the durable records.
- Checked the latest LIVE migration history and existing production migration files before creating the new migration.

## Second test report reviewed
Source: Library file Pasted text (2).txt, created 11 November 2026 12:10 UTC.
Scope: Ten Blackmagic Design camera catalogue products.

Structured report analysis:
- 38 findings; 0 not_found entries.
- 38/38 findings were comparison_only; 0 were catalogue_evidence.
- 32/38 were page_access=snippet_only.
- Six findings were marked opened, but all six referenced Blackmagic's multi-product UK product-list page (category_page), not an individual manufacturer/retailer/listing page. No individual retailer, marketplace or used-dealer product page was opened.
- 35/38 findings had one search query; 3/38 had two. This fell short of the LIVE intake's two-query minimum for 35 findings and demonstrated weak research coverage.
- Source kinds: 28 retailer_product_page, 8 category_page, 1 manufacturer_product_page and 1 price_aggregator.
- Several results mixed ex-VAT manufacturer MSRP with VAT-inclusive retailer prices; some snippets appeared stale, some listings were unavailable, and some package/mount details did not match the selected catalogue package.
- Existing references were noted but not re-opened/re-verified.
- The readable report was followed by a plain “json” label and raw JSON, not a fenced JSON code block. The structured intake RPC extracts a fenced JSON block when prose precedes it, so the submitted form would not reliably parse this report as supplied.

Conclusion: The test found many price mentions but no verified direct-source evidence. The key quality problem is source access and identity/price association, not simply a need for more search-result snippets.

## LIVE prompt change

Migration source:
supabase/migrations/20261111000400_manual_ai_research_quality_prompt_v2.sql

Applied LIVE migration:
manual_ai_research_quality_prompt_v2
Recorded database version: 20261111135455

Changes:
- Added public.platform_manual_ai_research_prompt_instructions() as the single quality V2 instruction source.
- Updated platform_owner_create_manual_ai_research_batch(uuid[],text,integer,text) to use the shared helper.
- Updated platform_owner_refresh_manual_ai_research_prompt(uuid) to use the same helper, preserving owner checks and protection of existing drafts/submissions.
- V2 requires three distinct actual product-specific searches per product: exact package, UK new retail and UK used. A fourth targeted same-model alternative-package search is required where useful.
- Added exact manufacturer/model/suffix/revision/mount identity checks.
- Requires opening individual product/listing pages before a finding can be catalogue_evidence. Search snippets, category pages, aggregators, editorial pages and blocked pages remain comparison_only.
- Separates selected catalogue package from actual source package and enforces package_match/evidence_role semantics.
- Separates new/used, refurbished/open-box/opened-never-used/sealed, availability and VAT basis.
- Requires checking existing evidence references and avoiding duplicate source URL + price + evidence_type records.
- Requires all intake fields, including catalogue_package_name, source_kind, page_access, package_match and evidence_role.
- Removes the conflicting “JSON only” vs “readable report plus JSON” instruction: final output must be a readable report followed by exactly one fenced JSON block labelled json.

## Tests and verification
- Ran a transaction preflight using the migration SQL and rolled it back. Dynamic replacement located both existing prompt blocks and confirmed both create/refresh definitions referenced the helper in the test transaction.
- Applied migration to LIVE successfully.
- Read back LIVE migration version 20261111135455.
- Read back helper length 12,427 characters and confirmed it includes catalogue_package_name, source_kind, fenced JSON and three-query requirements.
- Read back create-batch and refresh-prompt function definitions; both reference the V2 helper.
- No UI code changed; no front-end deployment required for this prompt-only change.
- At verification, Manual AI queue totals were 0 pending_review, 0 approved and 0 imported.
- Two current AKASO batches (20 products each, created 13:31 and 13:39 UTC) remained ready/unsubmitted. Their prompt rows were not directly rewritten; the owner-authorised Refresh prompt action now regenerates them with V2.
- The Blackmagic report remains a Library file and was not submitted into the LIVE prompt response table or queue.
- No rows in shared_market_evidence or master catalogue were changed.
- TEST database and main branch were not changed.

## Import boundary
- platform_owner_submit_manual_ai_research_response stages validated structured findings as pending_review queue candidates.
- platform_owner_stage_manual_ai_report stages report-table rows as unverified comparison references.
- platform_owner_review_catalogue_research_item changes queue status only.
- platform_owner_verify_manual_ai_comparison records direct-source verification after a match exists; it does not insert shared evidence.
- No dedicated Manual AI queue-to-shared_market_evidence import RPC was found in the LIVE public function inventory. A separate authorised, idempotent importer with duplicate checks and post-write read-back is required before importing verified candidates.
- Do not treat queue approval as evidence import and do not write directly to shared_market_evidence.

## Files updated
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- docs/TRADEFLOW-HUMAN-USER-MANUAL.md
- docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-CLOUD-AI-RESEARCH-MANAGER.md
- docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-MANUAL-AI-RESEARCH.md (new)

## Next step
Use the owner-authorised Refresh prompt action on one ready prompt, run the new V2 instructions, submit the complete report with its fenced JSON block, then review actual direct pages. Keep the evidence importer as a separate, explicitly tested backend task.
