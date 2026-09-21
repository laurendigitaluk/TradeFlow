# TradeFlow Checkpoint — 21 September 2026 — Live Buying Workflow Dashboard Repair

## Scope
Continued from the live TradeFlow state. No architecture recreation and no reset of the Camerashack test data.

## Live project
- GitHub: laurendigitaluk/TradeFlow
- Supabase: twfbmjwwqzxdxvclxbun
- Tenant: Camerashack (21fca2c5-5da2-4ff6-9f8e-318f9b6277f9)

## Failure found
The Business Dashboard workflow controller successfully loaded buying requests, items, approved valuations, offers and acquisitions, but then wrote the acquisition count to count-received. The HTML contains count-acquisitions. The null DOM access threw an exception and the catch block displayed the misleading message Workflow status could not be loaded. Open Buying for the full record.

## Repair
- subscriber-dashboard.html: corrected count-received to count-acquisitions.
- Active acquisition count now uses existing acquisition statuses: accepted, awaiting_item, received, processing.
- buying-dashboard.html: cache-busted buying-dashboard.js from v9 to v10.
- No Supabase schema, RLS or tenant-security change was required.

## Buying/customer workflow
The current Buying controller already renders customer name/reference/email/phone, request notes, item details, structured customer fields, valuation and offer state. Structured fields use category_fields.label; category_fields.name does not exist.

## Live test record
- Customer: TEST CS CUST
- Request: BR-744BA41BDC
- Item: BI-1D805A5FD3
- Approved valuation: £100.00, manual, approved.
- Current live offer: £100.00, accepted by the customer. This is the current database state and was not reset.

## Next verification
1. Hard refresh Subscriber Dashboard.
2. Confirm Transactions in progress loads without the generic workflow error.
3. Open Buying → BR-744BA41BDC.
4. Confirm customer details and supplied information render.
5. Confirm £100.00 / Manual / Approved valuation is visible.
6. Confirm current accepted offer is reflected as accepted/acquisition progressing.
7. For a fresh published-offer test, use a separate test item rather than altering this existing accepted record.
