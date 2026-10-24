# Mobile phone catalogue — Batch 67
Date: 24 October 2026

## Evidence added
Added one UK eBay completed-sale observation for Apple iPhone 15 Pro 128GB White Titanium.

- Listing: https://www.ebay.co.uk/itm/188829349517
- Sold: 29 August 2026 at 12:28 BST
- Displayed buyer-facing total: £377.66, including £11.68 Buyer Protection
- Four bids; used condition. Captured listing summary confirms model, 128GB, White Titanium, and sale details; no further condition/accessory claims have been inferred.
- Seller proceeds are not independently confirmed.
- Stable key: mobile-used-sold-iphone15pro-128gb-white-titanium-ebay-188829349517-20260829
- TEST master: 0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe; evidence ID: 85894977-1303-463f-a8ea-42e1749f1d09
- LIVE master: 8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16; evidence ID: 0ffba6f2-0bd8-4955-ba6e-5b83b3083137
- Exact URL and stable-key preflight was empty in TEST and LIVE. Inserted TEST-first, verified read-back, then inserted LIVE and verified read-back.

## Refreshed counts
- TEST: 232 active phone evidence rows; 138 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 230 active phone evidence rows; 136 active rows where evidence_type='uk_used' and availability='sold'.
- Used/sold subtotal includes parts/repair observations and is not a working-only count.
- Two-row TEST/LIVE difference persists.

## Process
Continue exact source URL/key preflight, exact model/storage master matching, TEST-first insertion and read-after-write verification, then LIVE insertion and read-after-write verification. Preserve Buyer Protection caveats.
