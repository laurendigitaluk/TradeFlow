# Mobile phone catalogue — Batch 68
Date: 24 October 2026

## Evidence added
Added one UK eBay completed-sale observation for Apple iPhone 15 Pro Max 256GB Natural Titanium (unlocked).

- Listing: https://www.ebay.co.uk/itm/128012606222
- Sold: 8 August 2026 at 19:40 BST
- Displayed buyer-facing total: £399.88, including £14.29 Buyer Protection
- Three bids; listing title says Excellent condition, while eBay condition field is Used. Preserve this distinction.
- Seller proceeds are not independently confirmed.
- Stable key: mobile-used-sold-iphone15promax-256gb-natural-titanium-ebay-128012606222-20260808
- TEST master: 063919bb-3dbc-488b-971a-ad536c413d94; evidence ID: 4132ab52-5258-4947-8648-171079051bc5
- LIVE master: 10002c0a-8717-4bb1-90d2-299b42fc9c7a; evidence ID: 8c79bcfb-a2da-4f64-8ca1-2bd860f3998b
- Exact URL and stable-key preflight was empty in TEST and LIVE. Inserted TEST-first and read-back verified, then inserted LIVE and read-back verified.

## Refreshed counts
- TEST: 233 active phone evidence rows; 139 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 231 active phone evidence rows; 137 active rows where evidence_type='uk_used' and availability='sold'.
- The used/sold subtotal includes parts/repair observations and is not a working-only count.
- Two-row TEST/LIVE difference persists.

## Process
Continue exact URL/key preflight, exact master-product mapping, TEST-first insertion and read-back, then LIVE insertion and read-back. Buyer Protection remains part of the displayed buyer total, not confirmed seller proceeds.
