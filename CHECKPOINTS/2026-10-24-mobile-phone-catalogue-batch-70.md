# Mobile phone catalogue — Batch 70
Date: 24 October 2026

## Evidence added
Added one UK eBay completed-sale observation for iPhone 15 Pro Max 256GB unlocked.

- Listing: https://www.ebay.co.uk/itm/298539408905
- Sold: 4 August 2026 at 14:01 BST
- Displayed buyer-facing total: £463.08, including £13.08 Buyer Protection
- Two bids; listing says Used and unlocked. No additional condition details were confirmed in the captured listing summary.
- Seller proceeds are not independently confirmed.
- Stable key: mobile-used-sold-iphone15promax-256gb-unlocked-ebay-298539408905-20260804
- TEST master: 063919bb-3dbc-488b-971a-ad536c413d94; evidence ID: 15a6a206-a3c4-4f8c-9de1-942a82148972
- LIVE master: 10002c0a-8717-4bb1-90d2-299b42fc9c7a; evidence ID: e6415500-19f8-4275-ad7f-d0a06e73c731
- Exact URL and stable-key preflight was empty in TEST and LIVE. Inserted TEST-first, read-back verified, then inserted LIVE and read-back verified.

## Refreshed counts
- TEST: 236 active phone evidence rows; 142 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 234 active phone evidence rows; 140 active rows where evidence_type='uk_used' and availability='sold'.
- Used/sold subtotal includes parts/repair observations and is not a working-only count.
- Two-row TEST/LIVE difference persists.

## Process
Continue exact source URL/key preflight, exact model/storage master matching, TEST-first insertion and read-after-write verification, then LIVE insertion and read-after-write verification. Buyer Protection remains part of the displayed buyer total, not confirmed seller proceeds.
