# TradeFlow Checkpoint — Initial Cash / Trade-in Offer Workflow — 24 September 2026

## Scope
Clean up the initial offer workflow so manual offers are represented by one Offer stage with separate Cash and Trade-in values, while automatic catalogue pricing remains authoritative.

## Implemented
- Added `public.offers.offer_mode` with values `cash` and `trade_in`.
- Added `customer_get_offers_v2` so the customer portal can distinguish cash and trade-in offers.
- Customer acceptance now accepts one initial/revised option and supersedes the other published initial/revised options.
- Initial acceptance moves the buying item to `awaiting_item`.
- Existing inspection workflow remains authoritative: after receipt and a passed inspection, the item moves to `final_offer_required`.
- Final post-inspection offer remains a separate final offer workflow.
- Buying dashboard now has one manual Offer box containing:
  - Manual offer — Cash
  - Manual offer — Trade-in
  - Send manual offer to customer
- Automatic catalogue pricing creates the authoritative automatic valuation and corresponding cash/trade-in initial offer option(s), and manual initial offer controls are disabled while an automatic valuation is active.
- Automatic/manual replacement logic supersedes previously published initial/revised offers and approved valuations before creating the new initial offer set.
- Customer portal now displays the available cash/trade-in initial options and lets the customer choose which one to accept.
- Buying dashboard and customer portal cache versions were bumped to pick up the changes.
- JavaScript syntax was checked for both modified dashboard files.

## Current test data
The tenant currently has one submitted Nikon test request remaining:
- Request: `BR-E46C8F392E`
- Item: `BI-C6D4E98548`
- Customer: `CUS-E82930637A58`
- Item status: `under_review`
- Purchase stage: `none`
- Trading values: 0
- Offers: 0
- Acquisitions: 0

This record was not deleted as part of this workflow change.

## Database migrations applied
- `20260924212116_manual_cash_trade_in_offer_modes`
- `20260924212130_customer_offer_modes_and_acceptance`
- `20260924212452_fix_initial_offer_acceptance_and_restore_final_offer`

## Next test path
1. Complete the Nikon review/valuation.
2. Test manual Cash and Trade-in initial offers.
3. Verify the customer sees both options.
4. Accept one option as the customer.
5. Verify the other initial option becomes superseded and the item moves to shipping.
6. Complete receipt.
7. Complete and pass inspection.
8. Verify the item enters Final offer required.
9. Create/send the final post-inspection offer.
10. Accept the final offer and continue to payment.

Do not bypass the authoritative workflow transition functions when changing offer or purchase stages.
