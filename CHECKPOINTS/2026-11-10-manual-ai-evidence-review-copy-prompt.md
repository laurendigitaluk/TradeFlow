# Checkpoint — Manual AI evidence-review prompt copy control

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Branch changed: production (LIVE release branch)
Scope: Platform Owner AI Research Centre UI only

## User requirement
Place the reusable ChatGPT evidence-review prompt inside each active Manual AI Research response panel, directly below the complete AI response textarea and before the save/validate controls. Keep completed prompt history compact.

## Changes committed
- Initially added a global copy panel, then replaced it with a per-response-panel **Copy ChatGPT evidence-review prompt** button directly below the complete AI response textarea and before Save/Validate.
- Removed the global copy panel from the bottom of the AI Research Centre.
- Active research prompts keep their generated prompt, response box and controls. After successful submission, the generated prompt box and active controls disappear from the main list; completed reports remain preserved in a collapsed **Completed research** history section.
- Added clipboard copy handling to the per-response button and advanced the dashboard JavaScript cache reference to v52.
- Updated both manuals with the new layout and preservation behavior.

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
- HTML and JS changes are committed to production.
- GitHub Actions LIVE deployment run **42924871267** for commit `1a31e01d167d94cd6c4dd6fdfe4cee33a12ad9f3` completed successfully. The `Deploy TradeFlow Worker and static assets` step also completed successfully.
- Source verification confirms the button is at the bottom of the AI Research Centre, the dashboard JavaScript cache reference is v51, and the prompt text and click handler are present.
- A real signed-in browser click/copy test has not yet been performed. Hard-refresh the Owner Dashboard and click **Copy ChatGPT evidence review prompt** to confirm clipboard access in the browser.

## Required next work
1. Verify the production Worker deployment and browser copy action.
2. Inspect shared_market_evidence schema, constraints, RLS, triggers and any existing trusted insert paths.
3. If no supported importer exists, create a narrow owner-authorised, idempotent import RPC via a versioned migration, test in TEST first, then release to LIVE.
4. Ensure the import preserves source URL/name, exact master product/package, GBP price, evidence type, condition, availability, observed date and excerpt; used evidence remains reference-only for automatic valuations.
5. Update both manuals and this checkpoint after the importer is implemented and verified.

## Stop point
The reusable prompt copy control is committed. The requested review-and-add workflow is not yet end-to-end complete because the current LIVE review action approves queue rows but does not import them into shared catalogue evidence.


## Follow-up layout correction — 10 November 2026

- User feedback on the deployed layout showed the global copy button was too far down the page and repeated completed research prompts made the workspace unnecessarily long.
- Updated `platform-owner-dashboard.html` and `platform-owner-dashboard.js` on `production`: removed the global bottom-of-section copy panel; placed **Copy ChatGPT evidence-review prompt** in each active response panel immediately after the complete AI response textarea and before the save/validate buttons; advanced the script cache to v52.
- The renderer now displays only active prompts in the main batch view. Submitted prompts are moved into a collapsed **Completed research** history section. Their complete AI reports and metadata remain stored and viewable; nothing is deleted from Supabase.
- No database migration or Supabase write was performed. TEST and all catalogue/evidence/research/tenant/customer/Stripe data remain unchanged.
- Commits: HTML `e6600a347c70c234a37755d2213d3e667a3a4a1e`; JavaScript `500f4ee0dda3e8743160eac79c2cb09957490f60`. The documentation updates are committed in the corresponding manual commits. Await the production Worker deployment and verify the signed-in browser layout and clipboard action before marking accepted.
