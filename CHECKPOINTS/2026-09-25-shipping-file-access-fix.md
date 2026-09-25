# TradeFlow Shipping File Access Fix — 25 September 2026

## Scope
Test Two only: Camerashack tenant. Test One remains frozen.

## Problem
Customer Portal "Open shipping label" returned a Supabase Storage "Object not found" error.

## Root cause
The shipping label object did exist in the private `tradeflow-media` bucket:
`{tenant}/buying-items/{buying_item_id}/shipping-label-*.png`.

The Customer Portal was correctly requesting the Storage signed-object endpoint, but the Storage SELECT policy `tradeflow_customer_shipping_files` queried `customers`, `buying_requests` and `buying_items` directly. Those tables are protected by RLS, so the policy's subquery could not see the customer's rows when evaluated as the authenticated customer. Supabase therefore treated the private object as inaccessible and returned the Storage "object not found" response.

## Repair
- Added security-definer helper: `private.customer_can_access_buying_item_shipping(uuid, uuid, uuid)`.
- Replaced `tradeflow_customer_shipping_files` with a policy that:
  - only applies to `tradeflow-media`;
  - only exposes `buying-items` shipping label/QR objects;
  - checks the tenant, buying item and authenticated customer through the security-definer helper.
- Verified with the Test Two customer's auth user ID that the exact shipping label object is now visible through Storage RLS.

## Frontend
- Updated `customer-dashboard.js` signed URL handling defensively.
- Updated `buying-dashboard.js` signed URL handling defensively.
- Bumped `customer-dashboard.html` controller cache version from v103 to v104.

## Relevant commits
- Customer dashboard: `3c5a460852e9f9c95035c91e94ca103261be749f`
- Buying dashboard: `6343b89704ef2de6d70102d6104cc96be6cb042c`
- Customer dashboard cache refresh: `d18e60e0e8aba5a51d087c73df7d6e743ca4bd38`

## Verification
- Exact Test Two shipping label object confirmed in `storage.objects`.
- Authenticated RLS simulation for the Test Two customer now returns `visible=true`.
- Supabase signed URL endpoint requests were previously returning HTTP 400 because the object was inaccessible under the customer RLS policy.
- Live browser click verification remains required after GitHub Pages publishes the new frontend commit. Do not mark the end-to-end shipping handoff complete until the customer can open the label successfully.

## Next test
1. Refresh Customer Portal with the new v104 script.
2. Click **Open shipping label**.
3. Confirm the label opens rather than showing "Object not found".
4. Then test the same path for the QR code once a QR file is uploaded.
