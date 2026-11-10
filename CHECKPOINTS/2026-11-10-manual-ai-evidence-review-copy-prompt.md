# Checkpoint — Manual AI evidence-review prompt copy control

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Branch changed: production (LIVE release branch)
Scope: Platform Owner AI Research Centre UI only

## User requirement
Place a reusable ChatGPT evidence-review prompt at the very bottom of the Manual AI Research Centre so the owner can copy it and paste it into ChatGPT whenever a manual research batch needs review.

## Changes committed
- Added a dedicated "Copy ChatGPT evidence review prompt" panel after Evidence Awaiting Review and the collapsed optional API research settings.
- Added the reusable prompt text and clipboard copy handler to platform-owner-dashboard.js.
- Advanced the dashboard JavaScript cache reference to v51 in platform-owner-dashboard.html.
- Updated docs/TRADEFLOW-AI-OPERATING-MANUAL.md and docs/TRADEFLOW-SYSTEM-HANDBOOK.md with the new control and the verified import boundary.

## Verified implementation boundary
- The current UI lists Manual AI Research submissions in Evidence Awaiting Review.
- Same-manufacturer/model catalogue matching is available through platform_owner_list_manual_ai_comparison_matches and platform_owner_match_manual_ai_comparison.
- Direct source verification is available through platform_owner_verify_manual_ai_comparison.
- platform_owner_review_catalogue_research_item changes the queue status to approved/rejected/needs_research; it does not insert a row into shared_market_evidence.
- Inspection of LIVE pg_proc definitions found no function referencing shared_market_evidence for this import route, and no trigger on platform_catalogue_research_queue was found to perform the import.
- Therefore queue approval must never be described as catalogue evidence import. The copied prompt explicitly checks the current import path and reports the missing importer instead of pretending that evidence was added.

## Data and environment safety
- No Supabase schema or data was changed.
- No research batches, queue rows, master catalogue products or existing evidence were changed.
- No TEST data, tenant/customer data, subscription or Stripe data was changed.
- No secrets were read or modified.
- LIVE project memory/checkpoint table-name scan returned no matching tables. This repository checkpoint is the durable record.

## Deployment / verification status
- HTML and JS changes are committed to production and the production workflow is configured to deploy on pushes affecting these assets.
- GitHub combined commit status did not expose a deployment status for the JS commit at the time of this checkpoint; verify the relevant GitHub Actions deployment run and then hard-refresh the Owner Dashboard to confirm the button is visible and copies the prompt.
- No browser interaction test has yet been performed.

## Required next work
1. Verify the production Worker deployment and browser copy action.
2. Inspect shared_market_evidence schema, constraints, RLS, triggers and any existing trusted insert paths.
3. If no supported importer exists, create a narrow owner-authorised, idempotent import RPC via a versioned migration, test in TEST first, then release to LIVE.
4. Ensure the import preserves source URL/name, exact master product/package, GBP price, evidence type, condition, availability, observed date and excerpt; used evidence remains reference-only for automatic valuations.
5. Update both manuals and this checkpoint after the importer is implemented and verified.

## Stop point
The reusable prompt copy control is committed. The requested review-and-add workflow is not yet end-to-end complete because the current LIVE review action approves queue rows but does not import them into shared catalogue evidence.
