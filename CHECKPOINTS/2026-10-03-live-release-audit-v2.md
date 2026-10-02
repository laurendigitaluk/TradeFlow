# TradeFlow LIVE Release Audit v2 — 2026-10-03

This release supersedes the first production promotion prepared earlier in this chat.

## Why v2
The current subscriber/customer Assistant work lives on `cloudflare-test`, which is the active TEST development line. The first production promotion was based on `main` and therefore did not contain the Assistant/customer-to-subscriber messaging layer.

v2 is based on the current `cloudflare-test` state so the live code reflects the latest tested application, then applies the explicit production exclusions/configuration below.

## Production exclusions
- TEST-only duplicate inventory serial warning migration `20260930232732_allow_duplicate_inventory_serial_numbers_with_warning` is excluded.
- No TEST customer/business data is included.
- Manual shipping remains final; Parcel2Go API is not reintroduced.
- Porkbun production registration remains disabled until the production registrar configuration and acceptance process is explicitly enabled.

## Production Worker
`wrangler.jsonc` is set to:
- Worker name: `tradeflow`
- `TRADEFLOW_ENV=production`
- LIVE Supabase URL/key for production replacement.
- TEST Supabase URL/key remain only as source values for controlled Worker boundary replacement.

The Worker now routes production customer paths:
- `/login`
- `/basket`
- `/assistant`
- `/email-confirmed`
- `/reset-password`

to their customer portal pages.

## Included current functionality
- TEST/LIVE frontend environment separation
- current customer/subscriber authentication repairs
- provider-neutral TradeFlow Assistant
- owner AI provider controls
- Customer Assistant
- customer-to-subscriber messaging
- subscriber Customer Questions queue and replies
- current buying/valuation/offer/shipping/inspection/payment/inventory/selling/order/fulfilment/return work
- domain pricing/payment/registrant-stage implementation
- in-store workflow implementation
- current website/public-site work.

## Database/configuration boundary
The separate LIVE Supabase project exists and was previously bootstrapped from the version-controlled baseline. Direct LIVE project inspection is currently unavailable to the connected Supabase tool, so this release does not claim that the later TEST migrations, Edge Function versions, Auth settings, Stripe configuration, Resend configuration or AI messaging schema are already deployed in LIVE.

Those items must be verified/applied before the first browser acceptance test.

## First LIVE test
After database/configuration parity:
1. Create a fresh subscriber business.
2. Verify subscription/capabilities.
3. Publish its website.
4. Create a fresh customer.
5. Test Customer Assistant.
6. Test customer → subscriber handoff.
7. Test subscriber → customer reply.
8. Run the fresh buying workflow.
9. Verify tenant isolation.
10. Continue to inventory/selling/retail purchase.

**Verification state:** GitHub release prepared. LIVE browser and LIVE database parity are not yet claimed verified.
