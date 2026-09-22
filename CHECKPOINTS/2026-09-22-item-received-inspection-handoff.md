# TradeFlow Checkpoint — 2026-09-22 Item Received & Inspection Handoff Repair

## Live project
- GitHub: laurendigitaluk/TradeFlow
- Supabase: twfbmjwwqzxdxvclxbun
- Tenant: Camerashack
- Tenant ID: 21fca2c5-5da2-4ff6-9f8e-318f9b6277f9
- Test acquisition: ACQ-B11FB7341903
- Acquisition ID: f7486bb6-ff0f-49fb-b5f5-40298ff800d2
- Customer: TEST CS CUST
- Accepted offer: £100
- Offer: OFF-9E44199AB6F3

## What was verified
The live acquisition is currently:
- status: received
- received_at: populated
- shipping_status: received
- customer_sent_at: populated

The workflow log records:
- accepted → awaiting_item
- awaiting_item → received

The existing authoritative receipt RPC is `subscriber_mark_acquisition_received`, and it uses `transition_workflow_entity`.

## Root cause found
The receipt backend transition had succeeded, but the dashboard presentation did not fully understand the resulting `received` state:
- customer portal status rendering did not explicitly display received/inspection;
- subscriber Buying dashboard mapped received/inspection/finalised/paid/completed back to the generic shipping stage;
- the acquisition item remained `accepted` even though the acquisition itself was `received`, creating a secondary workflow synchronisation defect.

## Repair applied
1. Hardened `subscriber_mark_acquisition_received`:
   - remains authenticated and permission-checked;
   - accepts the normal awaiting-item receipt path and is safely idempotent when acquisition is already received;
   - records shipping receipt state;
   - synchronises acquisition-item workflow through authoritative transitions:
     - accepted → awaiting_item → received
     - awaiting_item → received
2. Updated `buying-dashboard.js`:
   - received now renders as `Item received — inspection next`;
   - inspection is rendered as `Item under inspection`;
   - no longer maps these stages back to shipping.
3. Updated `customer-dashboard.js`:
   - received now renders as `Item received by subscriber — inspection next`;
   - inspection has its own customer-facing status/message.
4. Cache-busted:
   - buying-dashboard.js v31
   - customer-dashboard.js v43
5. Both modified JavaScript files passed parse-only syntax checks.
6. Updated:
   - Human User Manual
   - AI Operating Manual
   - Subscriber Dashboard Diagnostic Roadmap

## Important remaining live-test point
The current test acquisition item was already `accepted` when the repair was applied, so its existing row has not yet been synchronised through the newly hardened receipt RPC. The acquisition itself is correctly `received`, and the acquisition-level next action is inspection.

## Next task
Verify the live customer and subscriber dashboards after cache refresh, then move the acquisition:
**Received → Inspection**

After that, inspect and repair the inspection/valuation workflow while keeping these distinct:
- original accepted offer (£100)
- acquisition agreed value
- approved valuation
- inspection findings
- inspection/revaluation
- final valuation/payment/finalisation

Do not redesign shipping again.
