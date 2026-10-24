# Mobile phone catalogue — Batch 66
Date: 24 October 2026

## Evidence added
Added one UK eBay completed-sale observation for Apple iPhone 15 Pro 128GB Blue Titanium.

- Listing: https://www.ebay.co.uk/itm/298501695479
- Sold: 23 July 2026 at 13:42 BST
- Displayed buyer-facing total: £360.72, including £11.41 Buyer Protection
- Listing states factory reset and fully working; original box included but accessories missing; seven bids.
- Seller proceeds are not independently confirmed; treat the displayed total as buyer-facing, not net proceeds.
- Stable key: mobile-used-sold-iphone15pro-128gb-blue-titanium-ebay-298501695479-20260723
- TEST master: 0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe; evidence ID: ec371d07-962a-4a4b-a258-19edeeda551a
- LIVE master: 8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16; evidence ID: 913bd961-7142-45eb-bc5b-c89e4469020d
- Exact URL and stable-key preflight was empty in TEST and LIVE. Inserted TEST-first then LIVE; separate read-back confirmed one active row in each environment.

## Refreshed counts
- TEST: 231 active phone evidence rows; 137 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 229 active phone evidence rows; 135 active rows where evidence_type='uk_used' and availability='sold'.
- Parts/repair rows are included in the used/sold subtotal. Two-row TEST/LIVE difference persists.

## Process
Continue exact source URL/key preflight, match exact model/storage master, insert TEST-first, read-after-write verify, then insert LIVE and verify. Preserve Buyer Protection caveats and condition/accessory notes.
