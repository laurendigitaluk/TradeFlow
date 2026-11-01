# Checkpoint — Adventure Outpost Complimentary LIVE Testing Account
Date: 1 November 2026

## Owner instruction
Keep Adventure Outpost available indefinitely as a complimentary TradeFlow testing account. No subscription payments are to be taken unless the owner later chooses to close/change the account. Preserve all existing business and test data.

## LIVE identity
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Tenant: `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52` (Adventure Outpost)
- Owner membership remains active.
- Existing TradeFlow plan remains active.

## Stripe cancellation preservation
- Stripe subscription: `sub_1UMXu64O6wrQOcSJuXYDE22L`.
- Stripe Dashboard showed cancellation at period end, 2 November 2026 18:43 UTC, and “No further invoice”.
- Cancellation was not reversed. No new Stripe subscription or Checkout session was created.
- Original Stripe subscription/customer/price IDs and scheduled cancellation details were retained in metadata on the archived local history row.
- The Stripe ID columns were cleared on that historical row so later Stripe webhooks cannot overwrite the new complimentary entitlement.

## Complimentary entitlement
- New LIVE `tenant_subscriptions` row: `a82940c9-1af6-4d69-9366-24a8c8ac4d2e`.
- `billing_provider=manual`, `provider_status=complimentary`, `status=active`.
- No Stripe IDs, no trial end, no current period end, no scheduled cancellation.
- Existing `private.has_tenant_feature` implementation already supports active manual complimentary subscriptions; no function or schema change was needed.
- Verified `module.buying` and `website.editor` both return true.
- The original Stripe-linked row remains as cancelled historical data; the new manual row is the only current entitlement row. The unique one-current-subscription index remains satisfied.

## Dashboard improvement
- Production `subscriber-dashboard.html` now has a visible Subscription & Billing panel and sidebar navigation link.
- It reads the current tenant subscription and displays plan, billing, next payment and access end.
- Complimentary state displays no subscription payments and indefinite access, and hides the cancel action.
- Existing cancelled/trialing/paid states display appropriate cancellation/payment information and keep the cancel action in the main panel rather than at the bottom of the sidebar.
- LIVE commit: `04701b992cf1b6248448ee28a34a0b648043ec87`.

## Documentation
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`

## Verification remaining
- Confirm Cloudflare Production has deployed the dashboard commit.
- Sign into Adventure Outpost and confirm the panel says Complimentary account / No subscription payments / Indefinite.
- Verify existing workflows and website remain available after refresh.
- Check Stripe subscription remains cancelled at period end and no further invoice remains shown.

No TEST environment changes were made.
