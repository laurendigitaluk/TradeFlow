# Checkpoint — 2026-10-03 LIVE Subscriber Cancellation Control

## Scope

Added the subscriber-facing subscription cancellation control after the LIVE Stripe subscription fulfilment was verified for Adventure Outpost.

## LIVE implementation

- Production frontend: `subscriber-dashboard.html`
- New Edge Function: `subscriber-cancel-subscription`
- Function status: ACTIVE
- Function JWT verification: enabled
- Production branch: `production`

## Subscriber experience

- A small **Cancel subscription** text control appears at the bottom of the left navigation.
- The old **Catalogue** placeholder note has been removed.
- Cancellation opens a confirmation dialog.
- The subscriber must re-authenticate with their TradeFlow password before the cancellation request is accepted.
- The password is handled by Supabase Auth and is not stored by TradeFlow.
- Cancellation is scheduled for the end of the current Stripe trial/billing period.
- The subscriber retains access until the scheduled cancellation date.

## Backend safeguards

The cancellation Edge Function verifies:

1. authenticated subscriber identity;
2. active membership of the selected tenant;
3. existence of the connected Stripe subscription;
4. Stripe customer ID matches the TradeFlow subscription record;
5. Stripe subscription metadata user ID matches the authenticated user when present.

The function then sets Stripe `cancel_at_period_end=true` and updates the connected `tenant_subscriptions` row.

## Important

The existing Adventure Outpost Stripe subscription was **not cancelled as part of this implementation**. The new cancellation control is present for future subscriber use and must be tested deliberately before using it on the current trial account.

## Catalogue text cleanup

Removed the obsolete dashboard text:

> Catalogue management will be added when Gemma is ready to maintain the product catalogue.

Existing **What We Buy** and **Products & Categories** navigation remains unchanged.

## Verification state

The LIVE Adventure Outpost subscription remains connected and trialing. No new Stripe subscription was created by this change.

