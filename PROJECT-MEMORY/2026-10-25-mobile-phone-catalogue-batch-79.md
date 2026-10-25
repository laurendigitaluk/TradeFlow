# Project Memory — Mobile Phone Catalogue Batch 79
Date: 25 October 2026

Batch 79 added one UK eBay used-sale observation for Google Pixel 10 Pro XL 256GB unlocked, item 227413880546. Sold 8 Jul 2026 at 19:00 BST; displayed £507.44 including £13.81 Buyer Protection fee; seller proceeds not independently confirmed. Listing states no charger included; 12-bid auction, no Best Offer ambiguity visible.

- Stable key: `mobile-used-sold-pixel10proxl-256gb-unlocked-ebay-227413880546-20260708`
- TEST master `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`, evidence `753183e6-5091-4186-90ca-a85e3c188488`.
- LIVE master `8755fe3c-dd5a-4282-bcef-5775f4200c3a`, evidence `53d8d266-7ce4-40d4-ab8a-7be66131a644`.

Counts: TEST 251 active phone evidence / 155 used-sold / 2 new-sold; LIVE 249 / 153 / 2. Two-row difference and global duplicate-key aggregation audit remain outstanding.

Important audit flag: Batch 78 item 128026023099 is recorded at £399.99, but a later eBay search result currently shows £479.99 including Buyer Protection. Do not overwrite the historical row; investigate whether this is relisting/current-price drift or a capture discrepancy. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-79.md`.
