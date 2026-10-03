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


## UI refinement — 3 October 2026

The subscriber payment settings UI was refined after browser review:
- provider call-to-action buttons are now consistently coloured and aligned;
- provider cards use a cleaner two-column card layout with actions aligned at the bottom;
- the separate Stripe payment-methods panel was removed;
- Stripe payment methods and the Apple Pay explanation are now rendered inside the Stripe provider card;
- Stripe remains one provider choice rather than appearing twice.

Implementation commits:
- `c8fe7aa2407dfdd3eb1014d9d6871f64c1d73b2c` — Stripe options integrated into provider card.
- `65fa5c9be511a6b12bbd0dcce8e518587d3bb8d6` — UI polish and removal of duplicate Stripe section.

`settings.js` syntax check passed. Browser verification of the refreshed deployed page remains required.

## UI refinement — provider dropdowns

After browser review, the six payment providers were changed from large side-by-side blocks to compact expandable dropdowns. Each provider row shows its name, description, status and expand control. Setup instructions, provider links, setup fields and Stripe payment-method controls are revealed only when that provider is opened. Stripe remains a single provider and its checkout options remain inside the Stripe dropdown.

Implementation commits:
- 8ef1fa78ab572e2703054c6974d856f256cde952 — provider dropdown rendering.
- 60d56e23278d9f54fc8cf1c2c7fad14e41c57c3a — dropdown styling and cache-buster update.

settings.js had previously passed syntax validation; the dropdown change preserves the same data/save functions. Browser verification of the refreshed deployed page remains required.

## UI refinement — bordered provider cards and setup buttons

The provider dropdowns were refined again after browser review. Each provider is now a clearly bordered card with a coloured **View setup** button. Clicking the provider/card control reveals the full provider setup details. The button changes to **Hide setup** when open. Stripe's full payment-method controls remain inside the Stripe provider details and are loaded into the Stripe card when the settings page loads.

Implementation commits:
- 529cb11522d6fcc94d7e8c0ad70cb22b5c36178b — clear provider setup button.
- 761496055fa3fbfff3a0c2c9088c611f9c6baa93 — bordered card styling and cache-buster.

settings.js syntax validation passed after the change.

## Shipping Settings restoration — 3 October 2026

Browser review showed the dedicated Shipping Settings page had no selectable services. The underlying LIVE database tables and RPCs already existed, but shipping_service_catalog contained zero rows, so the UI correctly rendered an empty catalogue.

Restored the researched manual shipping catalogue with 26 active entries:
- Royal Mail
- Parcelforce Worldwide
- Evri
- InPost
- DPD
- DHL eCommerce UK
- UPS
- FedEx
- Yodel
- Parcel2Go
- Packlink
- Sendcloud
- Shippo
- Shiptheory
- Scurri
- Metapack
- Linnworks
- Shiply
- CitySprint
- Stuart
- Palletforce
- Tuffnells
- DX
- APC Overnight
- Whistl
- Amazon Shipping

The dedicated Shipping Settings page now also has a searchable catalogue and preserves unsaved selections while filtering. The existing subscriber_get_shipping_service_settings and subscriber_save_shipping_services RPCs remain the authoritative selection workflow. The Business Settings shipping card is a navigation shortcut to the dedicated Shipping Settings workspace, not a second shipping catalogue.

LIVE shipping-settings.js fallback Supabase URL was corrected to the LIVE project URL and cache-busted.

Relevant commits:
- b58a3db8ab2266d9a1bd816a2482369a82d4a6ce — LIVE Supabase fallback fix.
- 088eac7ae2b1b7174b7ccbbb1dc27115bc200bad — shipping settings cache refresh.
- ee0a2ac4aa7675b7e9ff34109aaac0e2e186311c — searchable catalogue UI.
- d19c4050db31bb44d3d9c59538226ed9649368a8 — search filtering.
- 9fcc460562a933c4d9a875bca7c6d8f360d430ec — preserve unsaved selections while searching.
- d59a16a78e2360198e44125336d35c0b20d5ec44 — shipping catalogue added to Assistant knowledge.
- LIVE tradeflow-assistant redeployed as version 7.

The catalogue population has been verified directly in LIVE. Browser verification of the subscriber's selectable list and save action remains required.
