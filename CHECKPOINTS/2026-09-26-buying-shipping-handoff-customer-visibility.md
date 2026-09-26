# 2026-09-26 — Buying shipping handoff customer visibility fix

## Problem
The Buying subscriber workflow can upload a shipping label/QR and publish a shipping handoff, but the customer portal only rendered the shipping controls when the status message field was populated. This meant a valid saved handoff could exist without the customer seeing the label/QR controls.

The subscriber Buying screen also described `awaiting_item` as “Label sent — awaiting item” even before a shipping handoff had actually been saved.

## Fix
- Customer portal now checks the actual `customer_get_pre_acquisition_shipping` row for the item.
- When a shipping handoff exists, the customer sees:
  - shipping instructions;
  - carrier/service;
  - tracking number and tracking link when available;
  - Open / print shipping label;
  - Open / print QR code when supplied;
  - I have sent my item.
- When no handoff exists, the customer sees a clear waiting message instead of a false label-ready state.
- Subscriber Buying status wording changed from “Label sent — awaiting item” to “Awaiting shipping handoff”.
- Cache-busting versions were incremented for the Buying and Customer Portal JavaScript.

## Retail protection
No retail fulfilment code or retail tracking-only rule was changed.

## Storage
The previously added subscriber INSERT policy for Buying shipping files remains scoped to the private `tradeflow-media` bucket and the tenant's `buying-items` path.

## Current Test 3 item
BI-6DE411A0BE remains `awaiting_item` in live Supabase and currently has no saved shipping handoff/file. After the subscriber successfully uploads the label and sends the handoff, the customer portal should display the controls above.
