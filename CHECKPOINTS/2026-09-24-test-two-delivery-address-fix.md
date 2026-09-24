# Test Two — Customer Delivery Address / Parcel2Go Fix

Date: 24 September 2026

## Issue found
The customer portal showed a Delivery address, but the integrated Parcel2Go shipping handoff reported that no delivery address was available.

Live schema inspection established that `public.customer_addresses.address_type` only permits `primary`, `billing`, `shipping` and `other`. The correct internal value for the customer-facing **Delivery address** is therefore `shipping`. The deployed Parcel2Go Edge Function was stale and was querying `address_type=delivery`.

## Fix
- `customer-dashboard.js` uses `shipping` for the Delivery option and Add delivery address action.
- The Parcel2Go Edge Function was changed to query `customer_addresses.address_type=shipping`.
- Parcel2Go Edge Function `parcel2go-subscriber-shipping` was redeployed as version 3.
- No Supabase schema change was made.
- Test One data was not changed.

## Live verification
The Test Two customer has a saved shipping address:
- Customer: TEST CS CUST
- Address type: `shipping`
- Default: true

The remaining browser test is to refresh the subscriber buying page and request a Parcel2Go quote. The integration should now use that saved shipping address.

## Relevant commits
- Customer portal correction: `144231c001d0bff1158bd217dfe571d92b4d5ebe`
- Parcel2Go source correction: `f32e7c66c9d49eb98b7f12347a6c05449eadfaaa`
- System handbook correction: `ce7c68f535f832c6dd7b91951406a3d7e2bf7209`
- AI manual correction: `33fbcb6bc3952f3c06320c0d457c991e53c1b528`

## Restore points
- checkpoint-test-two-customer-portal-orders-20260924
- checkpoint-test-two-preflight-buying-flow-20260924


## Follow-up — Test Two valuation display

Live data confirms the approved manual trading value is cash £50 and trade-in £55, and the initial trade-in offer for £55 is accepted. The customer dashboard was corrected to display the accepted £55 trade-in amount and retain the underlying £50 cash / £55 trade-in values. The Buying dashboard Parcel2Go explanatory text was clarified so it no longer reads as a current missing-address error.

The customer address itself remains correct: `address_type=shipping`, default=true. Parcel2Go Edge Function version 3 uses the same `shipping` address type. Final quote-flow browser verification remains pending.