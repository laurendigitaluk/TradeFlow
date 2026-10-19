# TradeFlow LIVE Stripe Connect checkpoint — 2026-10-19

This checkpoint branch preserves the exact Edge Function source retrieved from the TRADEFLOW LIVE Supabase project after the Stripe Connect onboarding repair.

- Based on production branch commit: 419dc34b42bb60b175b65e9beacb430a195c7a00
- Supabase LIVE project: gxsrajtqzdjvmceqcpgv
- This is a source snapshot only; it does not deploy code or change the production branch.
- Secrets and environment values are not included.
- Stripe subscription billing remains separate and was not modified in this checkpoint.

## Retrieved LIVE functions

- `stripe-connect-onboarding`: version 13, status ACTIVE, verify_jwt=true
- `stripe-connect-webhook`: version 4, status ACTIVE, verify_jwt=false
- `create-stripe-checkout-session`: version 14, status ACTIVE, verify_jwt=true
- `stripe-payment-webhook`: version 15, status ACTIVE, verify_jwt=false

## Known audit state

- Connected-account row reports LIVE mode, active status, charges enabled, payouts enabled, and details submitted.
- Required V2 account configuration: Full Dashboard, Stripe fees collector, Stripe losses collector.
- `stripe-connect-webhook` version 4 corrects the database status constraint mismatch (uses `active`, not unsupported `connected`), takes live mode from the event envelope, and merges existing connection metadata instead of overwriting it.
- Follow-up required: inspect post-deployment Stripe webhook delivery logs to confirm retries succeed. Do not treat payment/webhook end-to-end behavior as fully certified until verified.
- Retail checkout source is preserved for audit; no payment has been made as part of this checkpoint.
