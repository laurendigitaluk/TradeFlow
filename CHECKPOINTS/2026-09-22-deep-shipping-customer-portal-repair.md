# Checkpoint — Deep shipping/customer portal repair

Date: 22 September 2026

## Confirmed live facts

The test acquisition `f7486bb6-ff0f-49fb-b5f5-40298ff800d2` did successfully receive the manual shipping handoff at 19:37 UTC:
- status: awaiting_item
- shipping_method: subscriber_override
- shipping_label_url: populated
- shipping_qr_url: populated
- carrier/service/tracking: populated
- shipping_status: ready_for_customer
- posted_at: populated

Therefore the latest subscriber click was reaching the database. The remaining subscriber problem was stale detail rendering after the successful publish, not a failed database write.

The customer auth user remains confirmed and has multiple valid auth sessions in Supabase. No new auth session was created by the later visible Sign in clicks, proving those clicks were not reaching the current authentication handler.

## Root causes found

### Buying Dashboard
1. After successful shipping publish, `load()` refreshed request data but did not re-render the open request detail. The old button and old form therefore stayed on screen.
2. PR #103 introduced a `published` reference in the shipping handoff renderer without declaring `published`, creating a latent runtime error in the current source.

### Customer Portal
The portal had been split between `customer-auth.js` and `customer-dashboard.js`. The visible state could show a stale/authenticated header while the body remained on the login panel. To remove this entire race, authentication/session restoration is returned to one owner: `customer-dashboard.js`.

## Repair
- Buying Dashboard re-renders the currently open request after publishing shipping.
- The `published` shipping state is explicitly calculated from acquisition status, shipping status, posted_at, label/QR and instructions.
- Customer Portal no longer loads `customer-auth.js`.
- `customer-dashboard.js` owns sign in, sign up, sign out, session restoration and portal initialization.
- Session restoration attempts a refresh-token exchange before treating a stored session as invalid.
- Cache versions: Buying v26; Customer v38.

## Business/workflow boundary
No offer/acquisition financial values were changed by this repair. Customer-paid shipping remains unchanged.