# TradeFlow Checkpoint — 2026-09-27 — Selling Listing Gallery and Order Status Clarity

## Changes
- Selling focused product workspace redesigned to behave more like a detailed retail/eBay-style listing preparation page.
- Customer/inspection photographs are promoted to the top of the focused product page.
- First available product photograph is displayed as the main image with additional photographs as thumbnails.
- Source media signed URL handling was repaired so Supabase signed URLs beginning with /storage/v1/ are converted to absolute TradeFlow storage URLs instead of being treated as relative GitHub Pages URLs.
- Selling page visual order is now: photographs, retail listing preparation, purchase information, sales channels, listing details.
- Existing buying, inventory, listing and publication workflow logic was not changed.
- Subscriber dashboard Orders card now distinguishes active paid orders from orders already in fulfilment instead of presenting all active orders generically as action required.

## Live test context
At the time of this checkpoint the subscriber had two active retail orders:
- one paid order awaiting fulfilment progression;
- one order already in fulfilment.

The two recently purchased customer items are separate from these retail-order records and remain in Inventory/ready-for-sale flow.

## Commits
Selling JS: d321a6a60de65856238ffdb330a3b75e4d9fc6e2
Selling HTML: 7256ba816ba6c5cb1e1456dd5ca7e2f4fde46a32
Subscriber dashboard: 649b96ab029f921ac836ce04f92449356f4830a8
