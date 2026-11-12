# TradeFlow LIVE — Scheduled Market Evidence Progress

**Updated:** 12 November 2026  
**Automation:** TradeFlow 20-Product Evidence Research (hourly)  
**Project:** `laurendigitaluk/TradeFlow` production / LIVE Supabase only

## Gary's evidence-capture rule

Retain useful source links even when listings are sold out, sellers are unverified, exact bundle matches are uncertain, or prices are missing. Never invent a price or convert a non-GBP price into a GBP observation. Keep the URL, state exactly what is uncertain, explain what Gary should check, and prefix the visible note with `RED VERIFY`. Use the closest catalogue product only where defensible and document any mismatch. Do not discard an evidence candidate merely because it is imperfect.

## Research progress

- **Batch 01:** preceding scheduled run covered the first 20 no-evidence products (plus the Sony 70-200 lens-only variant was included in the ID exclusion set because it has since gained active evidence). Findings are in the preceding run history. Product IDs are listed in `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md`.
- **Batch 02:** 20 products researched on 12 November 2026. Product IDs, source URLs, prices, stock states, package mismatches and verification notes are in `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md`.
- At the end of Batch 02, all 20 Batch 02 product IDs still had zero active shared-market evidence and zero outstanding LIVE catalogue queue candidates.

## Queue staging limitation

The scheduled Supabase connection reports `current_user=postgres`, `auth.uid()=null`, `auth.role()=null`, and `platform_cloud_ai_owner_check()=false`. `platform_catalogue_research_queue` has RLS enabled and no direct insert policy. Supported staging functions `platform_owner_stage_manual_ai_report` and `platform_owner_submit_manual_ai_research_response` require authenticated platform-owner context. Do not write directly to the table or simulate/impersonate owner claims. No candidates from Batch 02 were inserted.

Queue snapshot before Batch 02: 43 rejected, 10 needs_research, 28 imported, 0 pending_review.

The production owner dashboard recognizes `evidence_role=comparison_only` (“Unverified comparison — match to catalogue and verify”) and `evidence_role=catalogue_match_assigned` (“Matched to catalogue — source still needs verification”). It does not currently render a dedicated red-marker field. Until candidates can be staged through the owner RPC, keep `RED VERIFY` notes in the checkpoint. If a user-authenticated staging path becomes available, submit uncertain references as pending review/comparison-only and leave uncertain GBP prices blank.

## Next-run selection rule

Read the latest scheduled evidence checkpoint before selecting products. Exclude all product IDs listed in every prior scheduled research checkpoint and all products already covered by outstanding research-queue candidates/prompts. Do not use fixed SQL OFFSET. Recheck active evidence and outstanding candidates immediately before each batch. Continue in batches of 20, using manufacturer sites, UK retailers, marketplaces and Google Shopping; open product pages and inspect variants/package contents, price, condition and availability. Keep uncertain links with explicit verification notes. Do not touch TEST, Stripe, master products, schema or valuation logic.


## 12 November 2026 — CVP/MPB used-market follow-up

Four further UK Used GBP rows were verified from direct pages and read from LIVE: CVP Open Box URSA Cine 12K LF Body £4,989.40 ex VAT / £5,987.28 inc (Like New, immediate delivery, 90-day warranty); CVP Studio Camera 6K Pro £1,580.40 ex VAT (Excellent, immediate delivery, 90-day warranty); CVP URSA Cine 17K 65 + EVF £16,199.10 ex VAT (Excellent, immediate delivery, 90-day warranty, full EVF/8TB package); MPB URSA Cine 12K LF PL Fit £5,509 (Excellent, one available, 12-month warranty, PL fit with EF mount included). Exact master IDs, row IDs, package notes and direct URLs are in the Batch 02 checkpoint. All are UK Used reference-only, not automatic valuation inputs.

Batch 02 now four active UK Used observations. Current Batches 01–13 LIVE: 261 observations, 257 active (140 UK New, 117 UK Used), four inactive. TEST, Stripe, schema and valuation logic untouched.
