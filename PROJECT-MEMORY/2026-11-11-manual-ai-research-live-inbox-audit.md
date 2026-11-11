# TradeFlow Manual AI Research current LIVE audit — 11 November 2026

At 20:30 UTC, LIVE has zero Manual AI Research candidate rows in platform_catalogue_research_queue, including broader searches for the Manual AI Research agent name and manual_ai_chat/manual_ai_report_table provenance. platform_research_reports is empty. There are 75 queue rows total, all Gemma lanes: 28 imported, 10 needs_research, 37 rejected.

Two current ChatGPT batches remain ready/unsubmitted, each with one 20-product prompt:
- Batch cb0e7020-c4b0-4bc7-ae68-03dea4752263 / prompt 4e9d16d5-baae-4fb7-8617-2e3a0a829cb5.
- Batch 3b8febea-ef87-4158-b2b6-0beab943edf0 / prompt cc5e8462-feda-45f0-b4ba-6f6ae33bbce8.
Both retain original prompt_text and products_snapshot; response_text, response_draft and response_submitted_at are null. They are not submissions and have no queue candidates.

Historical AKASO batch 1b46e2ba-75ae-499f-83c5-05a07695edba / prompt 3e633e82-d5c1-4804-b6e3-2b37f1ec83fc and its 13 historical candidates documented in the 10 November checkpoint are absent from current LIVE batch/prompt/queue tables. Selective deletion RPCs exist; current DB has no deletion audit trail to identify which cleanup removed them.

Import-path recheck:
- Submit response stages pending_review candidates only.
- Stage report stages unverified comparison references only.
- Match assigns a same-manufacturer/model/category package only.
- Verify stamps source_verified metadata only.
- Review changes queue status only.
- No public DB function or trigger imports Manual AI queue rows into shared_market_evidence.
- Authenticated has SELECT only on shared_market_evidence; INSERT is service_role/postgres only.
- tradeflow-research-mcp is a separate Bionic inbox and explicitly does not write catalogue evidence; tradeflow-cloud-ai-manager stages Cloud AI candidates in the queue only.
- shared_market_evidence has unique (source_name, source_record_key), FK to catalogue_master_products and evidence_type check uk_new/uk_used/overseas.

Counts: active shared evidence 4,490 (2,157 uk_new; 2,333 uk_used). This audit imported 0 records, opened 0 candidate pages, verified 0 candidate pages, skipped 0 duplicates, rejected 0 candidates. No code/DB changes or deployment. No TEST or commercial/customer data changed.

Exact blocker: a narrow owner-authorised, idempotent importer is still required. It must require approved queue status, source_verified=true, supported direct page, exact LIVE product/package match, GBP price, condition, availability, observed date and excerpt; deduplicate and atomically write evidence plus queue live_evidence_id/imported_at. Keep used evidence reference-only and out of automatic valuations. Test before deployment; never use direct table writes or browser service-role credentials.
