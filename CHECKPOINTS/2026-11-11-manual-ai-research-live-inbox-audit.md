# Checkpoint — Manual AI Research LIVE inbox and import-path audit

Date: 11 November 2026, 20:30 UTC
Repository: laurendigitaluk/TradeFlow
Branch: production
Target: TradeFlow LIVE Supabase project gxsrajtqzdjvmceqcpgv
Scope: Retrieve all outstanding Manual AI Research submissions and verify authorised evidence import route. LIVE only.

## Current LIVE retrieval
- No rows remain in platform_catalogue_research_queue with agent_name beginning 'Manual AI Research ·'.
- A broader check for any agent_name containing 'Manual AI Research' or raw_payload.research_method of manual_ai_chat/manual_ai_report_table also returned zero.
- LIVE queue contains 75 non-manual rows, all Gemma lanes: 28 imported, 10 needs_research, 37 rejected.
- platform_research_reports contains zero rows. The Bionic Research Inbox is a separate workflow.
- Two ChatGPT batches remain in LIVE, each with a 20-product prompt:
  - Batch cb0e7020-c4b0-4bc7-ae68-03dea4752263; prompt 4e9d16d5-baae-4fb7-8617-2e3a0a829cb5; ready; response_text=null; response_draft=null; response_submitted_at=null.
  - Batch 3b8febea-ef87-4158-b2b6-0beab943edf0; prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8; ready; response_text=null; response_draft=null; response_submitted_at=null.
- Original prompt_text and products_snapshot remain saved for both prompts. First snapshot covers 20 AKASO products including AKASO 360 packages and Brave/EK7000 models; second snapshot covers 20 AKASO Brave/EK7000 package variants. Neither is a submitted response.
- Historical AKASO batch 1b46e2ba-75ae-499f-83c5-05a07695edba and prompt 3e633e82-d5c1-4804-b6e3-2b37f1ec83fc from the 10 November checkpoint no longer exist in current LIVE batches/prompts. Its 13 candidate rows are absent from current queue. Selective prompt/queue deletion RPCs were introduced on 11 November; the current DB has no deletion audit trail that identifies which cleanup removed those old rows.
- platform_research_reports inbox is empty.
- Existing active shared_market_evidence: 4,490 total (2,157 uk_new; 2,333 uk_used). No rows were inserted during this audit.

## Import path and security rechecked
- platform_owner_submit_manual_ai_research_response validates and stages candidate rows in platform_catalogue_research_queue with pending_review status; it does not insert shared_market_evidence.
- platform_owner_stage_manual_ai_report stages parsed table references as unverified comparison_only rows; it does not import.
- platform_owner_match_manual_ai_comparison only assigns a same-manufacturer/model/category catalogue product/package.
- platform_owner_verify_manual_ai_comparison sets source_verified metadata after owner checks; it does not insert evidence.
- platform_owner_review_catalogue_research_item changes status/reviewer metadata only. Approval is not import.
- Public-function inventory across schemas found no function inserting into shared_market_evidence for this workflow. No triggers exist on platform_catalogue_research_queue or shared_market_evidence.
- shared_market_evidence grants: authenticated SELECT only; INSERT is granted to service_role/postgres. RLS policy exposes active rows to authenticated; no authenticated INSERT policy.
- Constraints include evidence_type in uk_new/uk_used/overseas, FK to catalogue_master_products, and unique (source_name, source_record_key).
- tradeflow-research-mcp is a separate Bionic inbox. Its report submission stores report Markdown/JSON and explicitly does not create products or shared evidence. tradeflow-cloud-ai-manager stages Cloud AI findings in the research queue, not shared_market_evidence.
- No authorised Manual AI queue-to-shared-evidence importer exists in current LIVE code/database.

## Results for this run
- Candidates reviewed: 0 (no current pending_review Manual AI candidates).
- Source pages opened: 0.
- Source pages verified: 0.
- Evidence records imported: 0.
- Duplicates skipped: 0.
- Rejected candidates: 0.
- Items needing further research from current candidate queue: 0.
- Two saved 20-product prompts (40 selected products) remain ready/unsubmitted, with no saved response. Do not treat them as submissions or initiate research without the user submitting a report.
- No code/database changes or deployment occurred. No TEST, catalogue, evidence, customer, tenant, Stripe, subscription or published website data changed.

## Exact remaining blocker
Build and test a narrow owner-authorised, idempotent importer before any deployment. It should require an approved queue candidate and source_verified=true, supported direct source type/URL, exact matched LIVE master product/package, GBP price, evidence type, condition, availability, observed date and supporting excerpt. It must deduplicate by existing source_name/source_record_key uniqueness and product/source/price/type, atomically insert shared_market_evidence and update queue live_evidence_id/imported_at. Used-market evidence must remain reference-only and excluded from automatic buying valuation. Do not write directly to shared_market_evidence or expose service-role credentials to the browser.

## Documentation
- Updated docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-MANUAL-AI-RESEARCH.md with this audit and the current state.
- No code or database change was required; no deployment was performed.
