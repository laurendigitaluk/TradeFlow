# Developer Diagnostic Roadmap — Customer Payment Providers

## Objective

Give TradeFlow subscribers a simple, tenant-safe way to prepare and connect a customer payment provider without asking them for secret credentials.

## Current verified architecture

- Subscriber settings: `settings.html` / `settings.js`
- Provider records: `payment_provider_connections`
- Stripe method switches: `tenant_payment_methods`
- Retail order lifecycle: `retail_orders` and payment RPCs
- Current live checkout: `supabase/functions/create-stripe-checkout-session/index.ts`
- Payment confirmation: existing Stripe webhook path
- Subscriber AI: `supabase/functions/tradeflow-assistant`

## Phase A — onboarding

Status: implemented.

- Six provider guides.
- Official provider links.
- Provider-specific preparation checklists.
- Non-secret setup fields.
- Tenant-scoped connection records.
- Subscriber chatbot knowledge.

## Phase B — provider integration

For each provider:

1. Inspect the provider's current UK onboarding/API/Connect requirements.
2. Determine whether TradeFlow should use OAuth/Connect, hosted checkout, payment links, or another supported integration.
3. Do not request secret keys from ordinary subscribers unless the provider's architecture genuinely requires a secure server-side credential and the storage/security model has been explicitly designed.
4. Create a provider-specific Edge Function or shared provider adapter only where the contract is verified.
5. Reuse the existing retail order and payment-record lifecycle.
6. Add provider webhook verification and idempotency.
7. Map provider success/failure/refund events into the existing payment records.
8. Test payment → webhook → paid order → My Orders → fulfilment.
9. Test cancellation/failure/retry without creating duplicate orders or payment records.
10. Update the AI knowledge, manuals and checkpoint.

## Phase C — browser verification

For each provider:

- subscriber account setup;
- provider onboarding;
- TradeFlow setup record;
- provider connection state;
- customer basket;
- checkout;
- successful payment;
- failed/cancelled payment;
- webhook;
- order status;
- subscriber order view;
- customer My Orders;
- refund/return path where supported.

## Safety rules

- Never call a provider technically connected when only an onboarding record exists.
- Never expose one tenant's provider connection to another tenant.
- Never store provider passwords or bank login credentials.
- Never bypass the existing retail order/payment lifecycle.
- Never create a second parallel checkout architecture.
- Do not change LIVE data during a repair merely to make a test appear successful.
