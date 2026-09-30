# TradeFlow TEST → LIVE Release Architecture — 30 September 2026

## Purpose

TradeFlow now has a permanent separation between development/testing and the live production release.

## GitHub

Repository: `laurendigitaluk/TradeFlow`

- `main` = TEST/STAGING branch.
- `production` = LIVE release branch.
- Feature/fix/checkpoint branches are created from the TEST development line and merge/promote into `main` first.
- A tested `main` commit is promoted to `production` for LIVE release.
- Production is never the place for experimental development.

## Supabase

- TEST: `twfbmjwwqzxdxvclxbun`, eu-west-2.
- LIVE: separate production project under the TradeFlow Live production organisation.

TEST contains deliberate test data. LIVE must be built from version-controlled migrations and must not receive copied TEST customer/transaction data.

## Release sequence

1. Build/fix in a feature or checkpoint branch.
2. Merge/update `main`.
3. Deploy/test against TEST.
4. Verify browser behaviour, tenant isolation, permissions, database state and relevant workflow.
5. Record a release checkpoint.
6. Promote the approved commit to `production`.
7. Apply the same version-controlled migrations, Edge Functions and configuration to LIVE.
8. Run a clean LIVE smoke test.
9. Record the LIVE verification result.

A commit is not the same thing as LIVE verification.

## Current release

The latest promoted release commit is:

`927e63d7a0c64c5ca7684e38a42bc1e4d60736a3`

This includes:

- automatic customer-product valuation linkage and UK New valuation rules;
- valuation/offer refusal workflow repairs;
- buying-item return workflow and customer return tracking;
- selling return-status presentation;
- production security release-candidate hardening;
- AI operating manual environment rules;
- backend user manual;
- live launch runbook alignment;
- backend user manual link in the subscriber dashboard.

## Backend documentation

- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md` — authoritative operational backend manual.
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md` — AI continuity/change-control manual.
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md` — human operational history/manual.
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md` — developer/system architecture handbook.
- `docs/TRADEFLOW-LIVE-LAUNCH-RUNBOOK.md` — release and production runbook.
- `subscriber-website-manual.html` — separate public/site-building manual.

## Shipping

Manual shipping remains authoritative. Parcel2Go API, checkout, quote creation and payment-link shipping flows are retired and must not be reintroduced.

## Safety

Test One remains the frozen historical known-good baseline. It is not overwritten by the TEST/LIVE release process.

## Verification

After this checkpoint, verify that `main` and `production` point to the same approved release commit before starting production database onboarding.
