# Manual AI Research simple evidence checkboxes — 11 November 2026

## User request
Replace the evidence dropdown with a very simple checkbox system:
- Products with no used evidence
- Products with no new evidence
- Products with no evidence at all

## Implemented in LIVE
- Replaced the Evidence required dropdown with three plain checkbox controls and a short explanatory note.
- No checkboxes selected = all products.
- Multiple checkboxes selected = show products matching ANY selected condition (OR).
- No used evidence means active UK used evidence count is zero, regardless of new evidence.
- No new evidence means active UK new evidence count is zero, regardless of used evidence.
- No evidence at all means both active UK new and used evidence counts are zero.
- Both missing-new and missing-used selected maps to missing_any; no-evidence remains a distinct both-zero condition.
- Updated dashboard JS and HTML; JS asset cache reference is v55.
- Existing category, branch, manufacturer, product selection and batch workflow remain.

## Database
- Migration: 20261111000301_simplify_manual_research_evidence_checkbox_filters.
- Updated RPC: platform_owner_list_cloud_ai_catalogue_products_filtered.
- Accepted filters: all, no_evidence, missing_new, missing_used, missing_any.
- Existing evidence counts remain sourced from active shared_market_evidence rows, evidence_type uk_new / uk_used.

## Verification
Cameras → Photography Cameras → Nikon:
- All: 205
- No evidence at all: 109
- No new evidence: 189
- No used evidence: 111
- Missing either new or used: 191
Verification ran in a transaction and was rolled back. No catalogue products or evidence records were changed.

## GitHub commits
- JS: 586699546619529d639cba90ed780ff0340d5fa3
- HTML checkbox replacement: 2778be40500d2918fc39d35135baf66fb6fa863a
- HTML cache version v55: 6766c7a4cde67bf157b8dcd73d083b8b04db17e1

## Boundaries
No TEST data, customer/tenant data, evidence records, approval status, valuation rules, Stripe or subscription state changed. Production Worker deployment should be confirmed in Actions before calling the UI deployed.
