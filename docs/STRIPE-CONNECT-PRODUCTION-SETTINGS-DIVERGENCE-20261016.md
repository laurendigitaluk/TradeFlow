# Production-only Stripe Settings Changes — Review Note — 16 October 2026

Repository: `laurendigitaluk/TradeFlow`
Production head inspected: `419dc34b42bb60b175b65e9beacb430a195c7a00`
Feature branch: `feature/live-stripe-connect-onboarding-20261015`

## What the comparison confirms

Comparing the common ancestor `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1` to `production` identifies two production-only commits affecting only:

- `settings.html`
- `settings.js`

The latest production commit is titled **“Simplify LIVE subscriber payment settings to Stripe Connect”**. It replaces the multi-provider subscriber-payment panel in `settings.html` with a dedicated Stripe Connect panel, status/continue controls, and Stripe-managed customer payment methods. It also bumps the settings script version to `19`.

This overlaps files changed by the feature branch. It is not a harmless documentation-only divergence.

## Specific integration risk

The production `settings.js` retrieved during this review still contains the legacy `PAYMENT_PROVIDERS` list (Stripe, PayPal, SumUp, Square, Mollie, Revolut) and the old `renderPaymentProviders` / `savePaymentProvider` code, while also defining the new Stripe Connect status/onboarding functions. The production HTML no longer contains the old `payment-providers` host, so the old renderer exits early when it cannot find that element. This may be intentional transition scaffolding, but the code path needs review and tests before further cleanup.

The feature branch's settings files must be compared against this production version before integration. Do not overwrite production's Stripe Connect UI with an older feature copy, and do not blindly take the production files either: the feature branch contains additional onboarding-return behavior that may need preserving.

## Safe next action

Create a separate integration branch from current `production`, then reconcile `settings.html` and `settings.js` deliberately while preserving the original feature branch. Before considering merge:

1. Ensure the Stripe Connect status and onboarding controls still work.
2. Ensure the `stripe_connect` return/refresh behavior survives.
3. Ensure legacy provider setup cannot create non-Stripe connections that the checkout path no longer supports.
4. Check the customer payment-method UI and checkout allow-list against each other.
5. Run JavaScript/static checks and an end-to-end non-live-money onboarding/status test.

## Release status and safeguards

This is a source review only. No integration branch was created, no files were merged, no database or LIVE configuration was changed, and no Stripe accounts or charges were created. The branch still requires reconciliation and the checkout/webhook lifecycle work documented in issue #152. Preserve the existing DJI Osmo Action 6 Adventure Combo transaction.
