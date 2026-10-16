# Stripe Connect Settings Integration Checkpoint — 16 October 2026

Repository: `laurendigitaluk/TradeFlow`
Integration branch: `integration/stripe-connect-reconcile-20261016`
Base: current `production` head `419dc34b42bb60b175b65e9beacb430a195c7a00`
Source branch retained unchanged: `feature/live-stripe-connect-onboarding-20261015`

## Work completed

A separate integration branch was created from current production. The two production-only settings changes were reconciled there without merging or modifying production or the original feature branch.

- `settings.html` retains the production Stripe Connect panel and wording. The settings script cache key was bumped to `v=20`.
- `settings.js` uses the feature branch's Stripe-only settings logic rather than retaining the legacy PayPal/SumUp/Square/Mollie/Revolut provider editor.
- Stripe Connect status and connect controls remain wired to `stripe-connect-onboarding`.
- Stripe refresh return handling starts a fresh onboarding link, as required for a refresh URL.
- Stripe payment-method rows continue to load from `tenant_payment_methods` and display only the methods represented by the settings code.

Latest integration commits:
- `affc357f453c06a02ac97e7c0044047473e768c0` — reconcile settings JavaScript.
- `5ab27dcda969800d811add00aee594c576c18ba8` — bump settings script cache key.
- `3703b9f5e095019601ea94cc3092002609b267db` — integration checkpoint documentation.

## Static source checks

The repository fetch checks confirmed:
- legacy multi-provider renderer/list removed from the integrated settings JavaScript;
- Stripe status/connect functions present;
- refresh return calls the connect flow to obtain a fresh link;
- payment-method query remains present;
- all five Stripe UI element IDs used by the JavaScript exist in the production HTML;
- HTML references `settings.js?v=20`.

These are source-string consistency checks only. They are not a JavaScript parser/typecheck, browser test, Supabase test, Stripe onboarding test, or end-to-end checkout test.

## Runtime-write review

The current `load()` path POSTs four default rows to `tenant_payment_methods` on every settings-page load, using `on_conflict=tenant_id,method_code` and `Prefer: resolution=ignore-duplicates,return=minimal`. It then reads the rows back for display.

This is an actual database write at runtime, even though the insert is intended to be idempotent. It has not been executed during this source review. Before browser testing, verify:
- the unique constraint matches `(tenant_id, method_code)`;
- the subscriber's authenticated request is permitted by the table's RLS policies;
- inserting defaults on page load is an intentional product decision rather than a hidden settings mutation;
- existing rows are not overwritten by defaults (the current ignore-duplicates preference means existing enabled/disabled choices should remain unchanged);
- defaulting Link, Klarna and Amazon Pay to enabled is appropriate for the intended UI, while the checkout function still validates the connected account and Stripe's support for each requested method.

A safer long-term approach may be to seed defaults during tenant setup or through an explicit, narrowly scoped initialization operation, instead of performing a write every time settings loads. Do not change this behavior without checking the tenant onboarding flow and schema constraints.

## Remaining review items

1. Check the integration diff against production and review the complete `settings.js` flow, including its startup calls and database writes to the tenant payment-method settings.
2. Run a JavaScript syntax check and available project CI/tests.
3. Validate the Stripe method allow-list and actual checkout session creation agree. UI enablement alone must not imply Stripe supports a method for every connected account or transaction.
4. Continue the unresolved checkout-attempt-aware webhook lifecycle work in issue #152 before release. In the current feature webhook, Checkout Session IDs and PaymentIntent IDs are treated as interchangeable provider-payment IDs; expired sessions can cancel the payment record; and checkout attempts are not updated atomically with webhook processing. These are release blockers, not just UI concerns.

## Safeguards

No merge, deployment, LIVE database change, Edge Function deployment, connected-account creation, or Stripe charge was performed. Production and the original feature branch were not changed by this reconciliation. Preserve the DJI Osmo Action 6 Adventure Combo transaction (sale £125, acquisition cost £70, seller payment marked paid by bank transfer).
