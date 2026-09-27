# TradeFlow checkpoint — 2026-09-27 — Orders workspace tenant-context repair

## Issue
The subscriber Orders page opened from the main Business Dashboard without a `tenant_id` query parameter and remained on “Loading orders…”. The page also contained an obsolete hard-coded test-tenant map, so it could not reliably operate against the live Camerashack subscriber tenant.

## Root cause
`orders-dashboard.js` read `tenant_id` directly from the URL and required it to match a legacy hard-coded `TENANTS` object. Main subscriber navigation does not need to carry the tenant in every URL because `subscriber-auth.js` / `subscriber-tenant-context.js` already provide the authenticated subscriber tenant.

## Repair
- `orders-dashboard.html` now loads `subscriber-auth.js?v=8` and `subscriber-tenant-context.js?v=5` before the Orders application.
- `orders-dashboard.js` now obtains the authenticated subscriber key, session and tenant from `window.tradeflowSubscriberAuthReady`.
- Removed the legacy hard-coded Test Business A/B tenant restriction.
- Orders continue to query `retail_orders` for the authenticated tenant with the existing status filter. The default All filter therefore includes completed orders as well as active orders.
- Orders sign-out now uses the subscriber authentication sign-out handler.
- Orders page cache/version bumped to v2.

## Files
- `orders-dashboard.html`
- `orders-dashboard.js`

## Live data safety
No database schema, order records, order statuses, payments or completed orders were changed by this repair.

## Verification required
Open Orders from the Business Dashboard after a hard refresh. The page should load the authenticated subscriber tenant and display all retail orders, including completed orders, when Status = All. Then test the status filter and order details.
