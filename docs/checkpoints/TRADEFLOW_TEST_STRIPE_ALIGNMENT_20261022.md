# TradeFlow TEST Site Readiness Checkpoint — 22 October 2026

## Decision
- TEST website is accepted as the current test site for normal application changes and validation.
- Stripe checkout testing on TEST is explicitly **PENDING / DEFERRED**. It is not a blocker for using the TEST website for other work.
- Revisit TEST Stripe setup and end-to-end acceptance only when payment functionality needs to be tested or changed.

## Environment boundaries
- TEST branch: `test/stripe-connect-test-mode-repair-20261020`.
- TEST Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- LIVE website and Stripe configuration must remain untouched during this deferral.
- Product/category/shared-evidence database work remains outside this workstream.

## TEST Stripe change already applied
- Added an explicit Stripe mode guard to `subscriber-create-checkout-session` on TEST.
- TEST defaults `TRADEFLOW_STRIPE_MODE` to `test` and checks the configured `STRIPE_SECRET_KEY` prefix against the expected mode before creating a subscription Checkout Session.
- A mismatch or missing/invalid key fails closed with HTTP 503.
- Source commit: `44183f0d4284e558a1aad64b1cc82bb541319c1a`.
- Deployed to TEST only; Supabase reported the function ACTIVE at version 11 with JWT verification enabled.
- No LIVE function was deployed or modified.

## Pending — TEST Stripe (not a current readiness blocker)
When Stripe checkout testing is next required:
1. Confirm TEST has its own Stripe test-mode secret key and `TRADEFLOW_STRIPE_MODE=test`.
2. Confirm the TEST webhook endpoint and signing secret.
3. Run a controlled test subscriber checkout and verify webhook completion.
4. Record the result before treating TEST Stripe acceptance as complete.

No end-to-end TEST Stripe checkout or webhook acceptance has been run in this workstream. LIVE Stripe was reported by the user as previously tested and working; it was not re-tested here.

## Readiness limits
- This checkpoint records the decision to defer TEST Stripe and accept TEST for normal application changes.
- It does not claim every feature has been exhaustively re-tested or that full TEST/LIVE feature parity has been proven.
- Branch commit-count differences alone are not evidence of broken functionality.
