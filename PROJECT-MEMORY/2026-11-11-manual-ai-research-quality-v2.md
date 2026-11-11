# Project Memory — Manual AI Research quality V2

Date: 11 November 2026
Project: TradeFlow
Environment: LIVE only
Repository branch: production
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Current truth
The second Blackmagic Design camera research test returned 38 candidate findings across ten selected catalogue products. All 38 were comparison_only. Thirty-two were snippet_only; the six marked opened came from a multi-product manufacturer list page, not individual product pages. Thirty-five findings had one search query and three had two. No direct retailer/listing page was opened, so the test produced zero verified catalogue evidence.

The report was a Library file (Pasted text (2).txt), not a submitted LIVE manual research response. The LIVE Manual AI queue had zero pending, zero approved and zero imported candidates. Two current AKASO batches (20 products each, created 13:31 and 13:39 UTC) remained ready/unsubmitted and unchanged.

## Prompt V2
LIVE migration manual_ai_research_quality_prompt_v2, database version 20261111135455, committed on production as supabase/migrations/20261111000400_manual_ai_research_quality_prompt_v2.sql.

The shared helper public.platform_manual_ai_research_prompt_instructions() is 12,427 characters. Both platform_owner_create_manual_ai_research_batch and platform_owner_refresh_manual_ai_research_prompt call it.

V2 requires three distinct actual product-specific searches per product (exact package, UK new retail, UK used), optional fourth alternative-package search, exact model/suffix/revision/mount verification, direct product/listing page inspection, truthful source_kind/page_access, explicit package/evidence-role labels, separate new/used/condition/availability/VAT, duplicate checks and a readable report followed by one fenced JSON block matching the LIVE intake validator.

## Import boundary
Manual AI response submission stages candidates in platform_catalogue_research_queue. Report-table staging creates unverified comparison references. Queue approval only changes status. Source verification marks a candidate as checked but does not import it. No dedicated Manual AI importer into shared_market_evidence was found. Do not write directly to the evidence table or claim an approval is an import.

## Verification
Migration applied to LIVE and read back. Transaction preflight passed. Helper text and both function references verified. No evidence, catalogue, customer, tenant, subscription, Stripe or TEST records changed. Existing ready prompts must be regenerated through the authorised Refresh prompt action to use V2.

## Durable references
- Checkpoint: CHECKPOINTS/2026-11-11-manual-ai-research-quality-v2.md
- Developer roadmap: docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-MANUAL-AI-RESEARCH.md
- Human/Developer System Handbook: docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- AI Operating Manual: docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- Human User Manual: docs/TRADEFLOW-HUMAN-USER-MANUAL.md


## Independent page spot-check
The current Blackmagic Cinema Camera 6K product page displays £2,069 and states MSRP excludes VAT, versus £1,219 ex VAT in the report. Production Gear's Micro Studio Camera 4K G2 page displays £744 ex VAT / £892.80 inc VAT, versus £870 inc VAT in the report snippet. Wex and MPB sample URLs returned cache misses. This validates the V2 rule: snippet-only prices remain comparisons until a direct page is opened and checked. No evidence was imported.
