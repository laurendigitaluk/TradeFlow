# Checkpoint — 20-product manual research quick select

Date: 11 November 2026
Repository: laurendigitaluk/TradeFlow
Branch changed: production (LIVE release branch)
Scope: Manual AI Research Centre product-selection controls

## User request
Add a quick-select option for 20 products alongside the existing 1, 2, 3, 5, 10, 100 and 500 options. The selected products are used to generate manual AI research prompts in the configured batch size.

## Pre-change inspection
- Inspected current LIVE production files: `platform-owner-dashboard.html`, `platform-owner-dashboard.js`, both TradeFlow manuals and the previous manual AI research checkpoint.
- Confirmed the current HTML quick-select sequence was 1, 2, 3, 5, 10, 100 and 500.
- Confirmed the JavaScript listener is generic: it reads each button's `data-cloud-ai-select-count` value and passes it to the existing selection function. No JavaScript behaviour change is required.
- The existing research selection is paginated and selection logic remains unchanged.
- The Manual AI Research Centre is present on LIVE production; the corresponding workspace is not present on TEST `main`. Therefore this narrowly scoped UI control was updated on the existing LIVE implementation; TEST branch and TEST database were not altered.

## Changes
- Added a **20** quick-select button between **10** and **100** in `platform-owner-dashboard.html`.
- Advanced the dashboard JavaScript cache reference from v57 to v58 so browsers request the current script asset.
- Updated `docs/TRADEFLOW-SYSTEM-HANDBOOK.md` and `docs/TRADEFLOW-AI-OPERATING-MANUAL.md` to document the 20-product option.
- No JavaScript logic changes were necessary; existing generic click handling supports the new value.

## Commits
- HTML: `892b244d2eb14e0879d9c32ae5fbc3e72f58eafa`
- System Handbook: `d4e96594be1efc9f65da09829d7cdee5aa4c1c74`
- AI Operating Manual: `41136627d95f8d504cd11dfb00628a6345db3ba0`

## Data and safety
- No Supabase schema or data changed.
- No catalogue products, market evidence, research batches, queue rows, tenants, customers, domains, subscriptions or Stripe records changed.
- TEST branch and TEST database were not changed.
- Existing quick-select values, product pagination, cross-page selection and research batch generation logic were not changed.

## Verification
- Source inspection confirmed the new 20 button is inserted in the intended quick-select sequence and uses the existing `data-cloud-ai-select-count` handler.
- Cache reference advanced to v58.
- Production deployment/browser verification remains to be checked from the deployment workflow and a hard-refreshed signed-in dashboard.

## Expected UI
Quick select: **1 | 2 | 3 | 5 | 10 | 20 | 100 | 500 | Clear selection**
