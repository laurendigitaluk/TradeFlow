# Mobile phone catalogue — Batch 65
Date: 24 October 2026

## Added
Two completed UK eBay parts/repair observations for iPhone 15 128GB were added TEST-first and then LIVE. Both exact URLs and stable keys were preflighted as absent in both environments.

### 1. iPhone 15 128GB Black — parts/repair
- Listing: https://www.ebay.co.uk/itm/267734454669
- Sold: 26 July 2026 at 17:04 BST
- Displayed total: £192.00 including Buyer Protection; fee breakdown and seller proceeds not independently confirmed.
- Seller Clove Technology explicitly classifies the device as parts/not working and warns not to expect normal operation.
- TEST evidence ID: 67fc3405-5706-4636-b0e8-6037d7113d3a; master 5ec2f627-4880-4ff1-bd03-559dde3db510.
- LIVE evidence ID: 052dcd2c-290a-4401-a6c1-a6bfc1debce2; master c9d0c053-8a12-4809-b2c8-69cef071f63b.
- Key: mobile-used-parts-iphone15-128gb-black-ebay-267734454669-20260726.
- TEST and LIVE insert responses and subsequent read-backs confirmed one active row in each.

### 2. iPhone 15 128GB Blue — parts/repair
- Listing: https://www.ebay.co.uk/itm/267749501196
- Sold: 11 August 2026 at 14:06 BST
- Displayed total: £157.00 including Buyer Protection; fee breakdown and seller proceeds not independently confirmed.
- Seller Clove Technology explicitly classifies the device as parts/not working and warns not to expect normal operation.
- TEST evidence ID: f8159e29-0c5f-4e28-aaca-a161728acba1; master 5ec2f627-4880-4ff1-bd03-559dde3db510.
- LIVE evidence ID: 5e0326e0-1462-496d-87ac-4b18de713c23; master c9d0c053-8a12-4809-b2c8-69cef071f63b.
- Key: mobile-used-parts-iphone15-128gb-blue-ebay-267749501196-20260811.
- TEST and LIVE insert responses and subsequent read-backs confirmed one active row in each.

## Candidate screened
Samsung Galaxy S24 128GB Onyx Black, eBay item 257702271643, displayed £237.75 including £8.23 Buyer Protection, was already active in both TEST and LIVE. No duplicate inserted.

## Refreshed counts
- TEST: 230 active phone evidence rows; 136 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 228 active phone evidence rows; 134 active rows where evidence_type='uk_used' and availability='sold'.
The used/sold subtotal includes parts/repair observations and is not a working-only count. Recent-row audit showed the increase since Batch 61 also included three Pixel 9 records inserted during intervening batches, so the +5 increase per environment is reconciled. The two-row TEST/LIVE difference persists.

## Audit
Exact URL and stable-key preflight was clean for both new listings in both environments. No broad aggregate duplicate-key audit was run in this batch. Continue TEST-first, LIVE second, exact source preflight and read-after-write verification.
