# Submit valuation action restored — 26 September 2026

## Issue
In the subscriber Buying detail view, items at the initial `submitted` or `under_review` stage displayed a generic review message but provided no valuation action.

## Repair
Updated `buying-dashboard.js` so these stages now display:
- **Valuation required**
- **Submit valuation** action
- Automatic valuation result handling
- Manual valuation inputs when no automatic catalogue valuation is available
- **Approve valuation & send offer** for the manual path

The existing valuation RPC and offer-transition logic were retained. No database records were changed.

## Verification basis
The live Buying workflow was inspected before the change. The existing controller already contained the valuation action handler (`value`) and manual valuation logic, but the corresponding initial-stage UI button was missing from `renderActions()`.

## Commit
`e3fd4fbce1b2aec65bc646ae0e12a6f4c459bb75`
