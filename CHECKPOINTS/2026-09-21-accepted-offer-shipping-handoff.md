# TradeFlow Checkpoint — 21 September 2026 — Accepted Offer → Shipping Label Handoff

## Live state
- Tenant: Camerashack
- Request: BR-744BA41BDC
- Item: BI-1D805A5FD3
- Offer: £100.00, status `accepted`
- Acquisition: ACQ-B11FB7341903, status `accepted`
- Shipping label fields: currently empty
- buying_request.status: `offer_ready`
- buying_item.status: `offer_ready`

## Important finding
The accepted offer and acquisition are authoritative for the post-acceptance handoff. The older request/item status values have not advanced, so the subscriber UI must not interpret `offer_ready` as meaning the customer is still waiting when an accepted offer/acquisition exists.

## Changes
- Buying dashboard now derives `offer_accepted` from the accepted offer or active linked acquisition.
- Subscriber status is **Offer accepted — send customer shipping label**.
- Accepted request detail includes the shipping handoff form using the existing acquisition shipping columns.
- Publishing the shipping handoff moves acquisition `accepted` → `awaiting_item` through `transition_workflow_entity()`.
- Customer Portal accepted-stage wording now says it is awaiting the subscriber's shipping label.
- Existing customer shipping section already displays the label/instructions and lets the customer mark the item posted.
- Cache-busters advanced: Buying v11, Customer Dashboard v29, Acquisition Dashboard v2.
- No database schema/RLS change was made.

## Next browser test
1. Hard refresh Subscriber Buying.
2. Open BR-744BA41BDC.
3. Confirm the old highlighted **Valuation approved — offer not yet sent** message is gone.
4. Confirm status reads **Offer accepted — send customer shipping label**.
5. Confirm £100.00 is shown as the accepted offer.
6. Confirm the shipping handoff form is visible.
7. Do not enter a fake label URL. Use a real test label URL when testing publication.
8. After publication, confirm acquisition changes to `awaiting_item` and Customer Portal shows the label/instructions.
