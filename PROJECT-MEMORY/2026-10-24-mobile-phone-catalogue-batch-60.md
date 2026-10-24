# Mobile phone catalogue — Batch 60 memory
Date: 24 October 2026

Added two iPhone 15 Pro 128GB Black Titanium UK eBay sale observations to TEST then LIVE after URL and stable-key preflight in both.

1. Item 206070231627, sold 14 Sep 2026, displayed £379.99 incl Buyer Protection, 90% battery health, fair/acceptable cosmetic condition with obvious wear/scratches, seller says fully tested/working, charger included. TEST row `711fcf0a-747b-4d9d-b8a0-754ff88eb260`; LIVE row `bf26325e-7d9d-4f7d-8210-e9835daf33ca`. Key `mobile-used-sold-iphone15pro-128gb-black-90bh-ebay-206070231627-20260914`. Separate read-back confirmed active in both.
2. Item 206112400829, sold 5 Sep 2026, displayed £199.99 incl Buyer Protection; rear glass shattered, faulty non-genuine replacement screen, not iCloud locked, no charger. Explicitly `For parts or not working`, not comparable to working phones. TEST row `f0ba6e5d-e0ae-458e-af64-6f64e9baed23`; LIVE row `5aa0b161-fc59-4b87-9b3d-9c61c59bf333`. Key `mobile-used-parts-iphone15pro-128gb-black-ebay-206112400829-20260905`. Insert responses confirmed both rows active; TEST read-back succeeded, LIVE read-back was blocked by a tool safety check.

Counts after Batch 60: TEST 224 active phone evidence, LIVE 222. Last confirmed UK used/sold subtotals remain TEST 126 / LIVE 124; not refreshed. Full duplicate-key aggregate audit remains outstanding; two-row environment difference persists. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-60.md`.

Count refresh on 24 October 2026: TEST 224 active phone evidence / 130 active rows where evidence_type is `uk_used` and availability is `sold`; LIVE 222 / 128. The used/sold filter includes the separate parts/repair record, so it is not a working-only subtotal. Two-row difference persists; full duplicate-key aggregate audit remains outstanding.
