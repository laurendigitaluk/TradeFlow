# TradeFlow Checkpoint — 22 September 2026 — Customer Shipping Handoff Correction

## Problem found
The customer shipping stage had become split across two areas of the Customer Portal. The main selling-request status showed the handoff, while a second lower “Send your item” section duplicated label/QR controls. The subscriber Buying dashboard also used wording that could imply the customer was responsible for paying shipping, and its post-handoff text could incorrectly appear to confirm the item had already been sent.

## Business rule
The subscriber arranges and pays the shipping service. The customer does not pay TradeFlow or the subscriber for shipping. The customer receives the shipping handoff, uses the supplied label/QR/instructions, sends the item, then explicitly confirms “Item sent”.

## Changes made
- customer_get_acquisition_shipping() now returns source_offer_id so the Customer Portal can reliably match the shipping handoff to the accepted offer.
- Customer Portal shipping handoff is consolidated into the main selling-request status card.
- Removed the duplicate lower “Send your item” shipping section.
- Customer handoff now clearly separates shipping service/carrier, tracking number, provider tracking link, physical shipping label, physical QR code, and customer shipping instructions.
- Physical label actions: Download your label; Print your label.
- Physical QR actions: Download your QR code; Print your QR code.
- Provider tracking links are kept separate from the physical label/QR files.
- “Item sent” is now a prominent full-width action and only appears before the customer confirms dispatch.
- Clicking “Item sent” calls customer_mark_acquisition_posted(), sets acquisition status to shipping, records posted_at, and sets shipping_status=in_transit.
- After confirmation the Customer Portal shows “Item sent — on its way to the subscriber”.
- Subscriber Buying/Acquisition dashboards distinguish shipping handoff sent / awaiting customer item from item on its way / awaiting receipt.
- Removed customer-facing wording that told the customer to arrange/pay shipping.
- Cache busters updated: customer dashboard v44; buying dashboard v29; acquisition dashboard v13.

## Current test acquisition
The existing test acquisition remains awaiting_item until the customer deliberately clicks Item sent. Current manual handoff data includes a label URL, QR URL, carrier/service and tracking number. The URLs shown in the current test are test placeholder/provider URLs, not stored physical label/QR files.

## Integrated shipping note
Provider tracking/label automation remains provider-adapter work. The current customer handoff UI will display provider tracking information when TradeFlow has it, but it does not falsely claim that a provider webhook has populated tracking unless the data exists.

## Verification
- customer-dashboard.js syntax OK
- buying-dashboard.js syntax OK
- acquisition-dashboard.js syntax OK
- Live database function updated successfully.