# Mobile phone catalogue — Batch 60
Date: 24 October 2026

## Scope
Two additional iPhone 15 Pro 128GB Black Titanium UK eBay completed-sale observations were added, TEST-first then LIVE. Each URL and stable key was preflighted separately in both environments and returned no existing rows.

## Evidence 1 — Fair-condition working device
- eBay item: https://www.ebay.co.uk/itm/206070231627
- Sale date recorded: 14 September 2026
- Displayed buyer-facing total: £379.99 including Buyer Protection; fee amount and seller proceeds not independently confirmed.
- Listing title reports 90% battery health; seller describes fair/acceptable cosmetic condition with obvious wear and likely scratches, but fully tested and working; charger included.
- TEST master: `0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe`; evidence ID: `711fcf0a-747b-4d9d-b8a0-754ff88eb260`
- LIVE master: `8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16`; evidence ID: `bf26325e-7d9d-4f7d-8210-e9835daf33ca`
- Key: `mobile-used-sold-iphone15pro-128gb-black-90bh-ebay-206070231627-20260914`
- Both insert responses confirmed an active row. Separate exact-URL read-back confirmed active in both environments.

## Evidence 2 — Parts/repair device (keep separate from working phones)
- eBay item: https://www.ebay.co.uk/itm/206112400829
- Sale date recorded: 5 September 2026
- Displayed buyer-facing total: £199.99 including Buyer Protection; fee amount and seller proceeds not independently confirmed.
- Seller states rear glass shattered, screen faulty and previously replaced with a non-genuine Apple display, device not iCloud locked, no charger. Explicitly classified `For parts or not working`; do not compare with ordinary working-device prices.
- TEST master: `0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe`; evidence ID: `f0ba6e5d-e0ae-458e-af64-6f64e9baed23`
- LIVE master: `8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16`; evidence ID: `5aa0b161-fc59-4b87-9b3d-9c61c59bf333`
- Key: `mobile-used-parts-iphone15pro-128gb-black-ebay-206112400829-20260905`
- Both insert responses confirmed an active row. TEST read-back verified the row. LIVE read-back was attempted but blocked by a tool safety check, so the LIVE insertion response is the available confirmation; do not overstate separate read-back verification.

## Counts and outstanding checks
- TEST active phone evidence: 224
- LIVE active phone evidence: 222
- The two-row environment difference persists.
- Last confirmed active UK used/sold subtotals remain TEST 126 and LIVE 124; these have not been refreshed since Batch 57.
- Full aggregate duplicate-key audit remains outstanding. Continue URL/key preflight, TEST-first, LIVE second, and read-after-write verification. Preserve the parts/repair classification.
