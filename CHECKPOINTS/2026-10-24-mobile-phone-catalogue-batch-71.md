# Mobile phone catalogue — Batch 71
Date: 24 October 2026

## Evidence added
Added one verified UK eBay completed-sale observation, TEST-first then LIVE.

- Product: Apple iPhone 16 Pro 256GB Desert Titanium, unlocked.
- Listing: https://www.ebay.co.uk/itm/820212891404
- Sold: 8 October 2026 at 14:37 BST.
- Displayed buyer-facing total: £567.85 including £17.85 Buyer Protection.
- Condition: Used. Listing offered Best Offer; the accepted seller proceeds are not independently confirmed, so preserve the displayed total as the buyer-facing observation and do not treat it as seller net proceeds.
- TEST master:  a4e9fd6f-fa28-4e31-9a8e-78079d44c6f8; evidence ID: 35d17e45-0a47-43d1-b6ed-ce13ed58579a.
- LIVE master: 24ff7595-f1e0-4d81-9d5c-01a6dcc33eaf; evidence ID: c0249903-0bdb-493d-a989-207fa2a6be57.
- Stable key: mobile-used-sold-iphone16pro-256gb-desert-titanium-ebay-820212891404-20261008.
- Exact URL/key preflight returned no row in either environment. TEST insert and exact read-back succeeded; LIVE insert and independent exact read-back succeeded.

## Duplicate-prevention notes
- iPhone 16 128GB listings 366694404412 and 800749991087 were already recorded in both environments; no duplicates were added.
- iPhone 16 Pro 256GB Black listing 137835281735 was also already recorded in both environments under an existing key, with a historical observed price of £447.44. The currently opened page displayed a different buyer-facing total (£450.13). The existing observation was preserved; no duplicate or overwrite was made.

## Refreshed counts after Batch 71
- TEST: 237 active phone evidence rows; 143 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 235 active phone evidence rows; 141 active rows where evidence_type='uk_used' and availability='sold'.
- Used/sold subtotal includes parts/repair observations and is not a working-only count.
- Two-row TEST/LIVE difference persists.
- Active duplicate non-null stable-key groups: TEST 0; LIVE 0.

## Process and next steps
Continue exact source URL/key preflight, exact model/storage master matching, TEST-first insertion and read-after-write verification, then LIVE insertion and read-after-write verification. Preserve historical observations; do not overwrite a previous observation simply because a listing page now shows a different buyer-facing amount. Continue to distinguish Buyer Protection totals from seller proceeds and keep parts/repair records separate.
