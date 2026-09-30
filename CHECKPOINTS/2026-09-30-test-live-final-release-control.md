# TradeFlow TEST/LIVE Release Control Final Checkpoint — 30 September 2026

## Final state

The permanent environment split is now established in GitHub:

- **TEST:** `main`
- **LIVE:** `production`

Both branches currently point to the same final release commit after the documentation/link updates below.

Final release commit before this checkpoint: `6c5e23a7020a1e842b7bdc10dd6e7a5d31252ccd`.

This checkpoint records the final documentation/control update and must be promoted to both branches before production onboarding continues.

## Documentation

Added authoritative backend manual:

`docs/TRADEFLOW-BACKEND-USER-MANUAL.md`

Updated:

- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-LIVE-LAUNCH-RUNBOOK.md`
- `subscriber-dashboard.html`

The subscriber backend now exposes a **Backend User Manual** link separately from the existing **Website Manual** link.

The Website Manual remains the site-building/public website guide. The Backend User Manual explains the exact business application workflow and operational boundaries.

## Release rule

Future work is built/tested on `main` and its feature/checkpoint branches.

Only a verified release is promoted to `production`.

The production database is separate from TEST and is populated from version-controlled migrations/configuration rather than copied TEST data.

## Required next step

Before production onboarding, verify:

1. TradeFlow Live Supabase organisation is upgraded/ready.
2. A separate LIVE Supabase project exists in eu-west-2.
3. The LIVE project is empty/fresh and is not the TEST project.
4. Version-controlled migrations are applied to LIVE in order.
5. Required Edge Functions and secrets are configured without committing secrets.
6. Production domain/hosting configuration points to LIVE.
7. A clean production smoke test is completed.
8. The production result is recorded in a new checkpoint.

## Safety

- Test One remains frozen.
- Manual shipping remains authoritative.
- Parcel2Go API/checkout/payment-link shipping must not be reintroduced.
- Do not copy TEST customer, bank, payment or transaction data into LIVE.
