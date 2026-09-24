# Test Two — Customer Delivery Address Type Fix

Date: 24 September 2026

## Issue found
The customer portal displayed a Delivery address form but submitted the value shipping to customer_upsert_address. The live Parcel2Go subscriber-shipping Edge Function expects customer_addresses.address_type = delivery, so the delivery address could not be used for shipping.

## Fix
Updated customer-dashboard.js so:
- the visible Delivery option submits delivery;
- Add delivery address opens the form with delivery selected;
- existing billing/payment behaviour is unchanged.

## Verification
- GitHub code inspected before change: Yes
- Live Supabase RPC inspected: Yes
- Live shipping Edge Function inspected: Yes
- Supabase schema changed: No
- Test One data changed: No
- Browser verified after fix: Pending

## Restore points
- checkpoint-test-two-customer-portal-orders-20260924
- checkpoint-test-two-preflight-buying-flow-20260924
- Test One remains frozen.
