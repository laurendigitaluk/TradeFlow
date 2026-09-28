# TradeFlow checkpoint — 2026-09-28 — Customer valuation handoff repair

## Problem
During a new customer valuation submission, the public selling journey was redirecting to the Customer Account instead of directly submitting the signed-in customer's valuation to the subscriber workflow.

## Root cause
The public website valuation wizard's `getStoredCustomerSession()` still read and refreshed the legacy shared `localStorage` key `tradeflow_customer_session`.

The current customer authentication architecture is tenant-scoped `sessionStorage`, using:
`tradeflow_customer_session:<tenant_id>`

This mismatch meant the public valuation wizard could fail to recognise the customer session even though the customer was signed in.

## Repair
- `public-site.js` now reads the active tenant's customer session from tenant-scoped `sessionStorage`.
- Token validation still calls Supabase `/auth/v1/user`.
- Refresh-token results are written back to the same tenant-scoped `sessionStorage` key.
- Invalid sessions are removed only from that tenant-scoped key.
- No shared customer `localStorage` session is recreated.
- `public-site.html` script cache version was bumped.

## Commits
- Public valuation/session repair: `2604761360f223c21059ce5e1312e30ace2dc2aa`
- Public-site cache refresh: `193dddfa1290d947a39a020bb98afa87453b3099`

## Verification
Before this repair, the latest Camerashack buying requests remained the previously completed test requests; no new request from the current test had appeared in `buying_requests`. The repair therefore targets the handoff boundary rather than fabricating a new transaction.

## Expected behaviour
1. Customer is signed into the customer portal in the same browser tab.
2. Customer starts a new valuation on the public website.
3. At submission, the valuation wizard recognises the tenant-scoped customer session.
4. `customer-selling-submit` receives the authenticated request and uploads any selected photographs.
5. The request is created in the subscriber's Buying workflow.
6. Customer is then taken to Customer Account to track the submitted request — but only after successful submission.
7. Subscriber Buying dashboard receives the new request as an active customer request.

## Next test
Use Ctrl+F5 on the public website, repeat the valuation, and submit it. Then check both the customer account and subscriber Buying dashboard. The key distinction is that Customer Account navigation should now occur after a successful submission, not because the wizard failed to find the signed-in customer session.
