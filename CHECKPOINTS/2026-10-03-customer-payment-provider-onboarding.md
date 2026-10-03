# TradeFlow Checkpoint — 2026-10-03 — Customer Payment Provider Onboarding

## Scope

Add a simple subscriber-facing customer payment provider onboarding workspace to LIVE Settings, with six provider guides and approved chatbot knowledge.

## LIVE architecture verified before change

- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- Production repository: `laurendigitaluk/TradeFlow`
- Production branch: `production`
- Existing `payment_provider_connections` table already exists and is tenant-scoped.
- Existing `tenant_payment_methods` remains the separate Stripe Checkout method-control table.
- Existing retail customer checkout uses `create-stripe-checkout-session`.
- No existing provider-specific checkout connection implementation was found for PayPal, SumUp, Square, Mollie or Revolut.
- No existing LIVE payment-provider connection rows were present.

## Changes

### Subscriber Settings

Updated:
- `settings.html`
- `settings.js`

Settings now provides **Checkout & payments → Customer payment provider** with six onboarding guides:

1. Stripe
2. PayPal Business
3. SumUp
4. Square
5. Mollie
6. Revolut Business

Each guide provides:
- official signup link;
- official instructions link;
- provider-specific preparation checklist;
- provider-specific setup sequence;
- provider account email field;
- non-secret provider/merchant ID field;
- optional payment-link field;
- business postcode carried from Business Settings;
- primary-provider choice;
- setup-complete checkbox.

The UI explicitly states that provider passwords, secret API keys and bank logins must not be entered into TradeFlow.

### Backend record

The existing `payment_provider_connections` table is reused with:
- `connection_type = customer_payments`
- `status = onboarding`
- `provider_account_id` for non-secret account/merchant IDs
- `metadata` for non-secret setup details

A saved onboarding record is deliberately not treated as proof of a technical checkout integration.

### Assistant knowledge

Updated:
- `supabase/functions/tradeflow-assistant/knowledge.ts`

Added approved knowledge for:
- customer payment provider setup;
- the six provider guides and official URLs;
- subscriber chatbot usage;
- Customer Questions handling;
- secret-credential prohibition;
- distinction between provider onboarding and technical TradeFlow integration.

Deployed updated `tradeflow-assistant` Edge Function to LIVE.

### Documentation

Updated:
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `subscriber-website-manual.html`

## Final implementation references

- Settings UI commit: `9edc8838c2427c8e962383b0c9240c46faa958b7`
- Settings provider logic commit: `adbc3ffd7d55d57169e36c01509e592487f0717e`
- Assistant knowledge commit: `558c341a77c7319e27d3224036dfe3c2f4c04f9e`
- Subscriber manual commit: `4c9a06dff762c990176bc99b229806cb290ad150`
- Developer roadmap: `docs/DEVELOPER-DIAGNOSTIC-ROADMAP-CUSTOMER-PAYMENTS.md`
- LIVE `tradeflow-assistant` Edge Function version: 6

## Verification state

Code/database structure verified. `settings.js` syntax check passed.

Not yet browser-verified:
1. Subscriber opens Settings → Checkout & payments.
2. Six provider cards render.
3. Official links open correctly.
4. Provider setup form opens for each provider.
5. Existing business postcode is carried into the form.
6. Saving a provider creates/updates the tenant-scoped onboarding row.
7. Primary-provider selection behaves correctly.
8. Subscriber Assistant can answer the payment-provider setup questions from the new approved knowledge.

Do not claim those browser tests have passed until observed.

## Important payment boundary

Stripe is currently the live TradeFlow retail customer Checkout provider.

The five other providers are currently documented/onboarding choices, not completed TradeFlow checkout integrations. Do not describe them as technically connected merely because a subscriber has completed the onboarding form.

## Next development stage

Implement and verify actual provider-specific customer checkout integrations one provider at a time, beginning with the existing Stripe architecture. Do not replace the working retail order/payment lifecycle or introduce a second checkout architecture.

