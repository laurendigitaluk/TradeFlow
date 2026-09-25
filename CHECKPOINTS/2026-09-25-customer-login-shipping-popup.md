# TradeFlow Customer Portal + Shipping Popup — 25 September 2026

## Test Two scope
Camerashack tenant: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`.

## Customer login context
Customer Login from the subscriber public site now stores the active tenant context in localStorage under `tradeflow_customer_tenant_id` and opens `customer-dashboard.html` without exposing the tenant UUID in the customer-facing URL.

Customer authentication/dashboard code restores the tenant context from that value when no `tenant_id` query parameter is present.

This preserves the intended journey:
Camerashack website → Customer Login → Customer Account
without requiring the customer to type or know a tenant ID.

## Shipping file popup
Customer Portal shipping label and QR buttons now:
- open a separate browser popup/window immediately from the customer click;
- request the secure shipping file URL;
- display the file in a print-friendly viewer;
- provide Print and Close controls;
- support image files directly and other shipping files through an iframe;
- report popup-blocking clearly if the browser prevents the new window.

## Frontend commits
- `ab51d826a445b5cb93baa2765439dc49891c8bcd` — customer tenant context from public site
- `d0a83f0148267850032d695db3cf3bc95189bfa2` — customer auth tenant restoration
- `c6213b41745c6e4db9d5b72e0f02bcf66855e959` — dashboard tenant restoration + printable shipping popup
- `9b60893d540c361e6f1e6af66f0952c8f6f3f29a` — dashboard cache version v105

## Required live verification
After GitHub Pages publishes:
1. Open Camerashack public website.
2. Click Customer Login.
3. Confirm Customer Portal opens without a tenant ID in the visible URL.
4. Sign in as Test Two customer.
5. Open Shipping → Open shipping label.
6. Confirm a separate printable popup opens.
7. Confirm Print and Close controls work.
8. Repeat for QR code after a QR file is uploaded.
