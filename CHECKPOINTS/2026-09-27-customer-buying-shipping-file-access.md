# 2026-09-27 — Customer Buying shipping label / QR access

## Problem
Customer Portal shipping label and QR viewer returned `permission denied for table fulfilments`. The error came from Storage RLS evaluation: an existing retail fulfilment customer SELECT policy directly referenced `fulfilments`, which the customer role could not access. This policy was unrelated to the Buying item, but Storage evaluated it while serving the shared bucket.

## Repair
- Added a dedicated Storage SELECT policy for `tradeflow-media/{tenant}/buying-items/{buying_item}/...` using `private.customer_can_access_buying_item_shipping`.
- Added Edge Function `customer-buying-shipping-media`, JWT protected, which verifies the authenticated customer owns the buying request and securely downloads the saved Buying shipping label/QR from the private `tradeflow-media` bucket.
- Updated `customer-dashboard.js` to retrieve Buying shipping files through that authenticated function instead of directly hitting Storage.
- The retail fulfilment shipping workflow was not changed.

## Current UI
Customer Portal retains Open / print shipping label and Open / print QR code controls, with Print 6×4, Print on A4, and Close.

## Cache
The HTML cache version update could not be written by the GitHub connector after the JavaScript change. A hard refresh (Ctrl+F5) is therefore required to ensure the browser loads the current `customer-dashboard.js` content.

## Test
Re-test the Canon C70 Buying item from the customer portal after Ctrl+F5. Expected result: shipping label and QR open without the previous fulfilments permission error.
