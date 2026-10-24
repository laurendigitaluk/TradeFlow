# Mobile phone catalogue — Batch 69
Date: 24 October 2026

## Evidence added
Two UK eBay completed-sale observations for Apple iPhone 15 Pro Max 256GB were added TEST-first then LIVE. Both URLs and stable keys were preflighted as absent in each environment.

### 1. Grey with retail box
- Listing: https://www.ebay.co.uk/itm/298621751352
- Sold: 3 September 2026 at 20:01 BST
- Displayed buyer-facing total: £444.64 including £12.78 Buyer Protection
- Used condition; title says Grey Smartphone with Retail Box; four bids.
- TEST master: 063919bb-3dbc-488b-971a-ad536c413d94; evidence ID: 0d41460e-4c9e-40ad-aec5-b2155cd72c93
- LIVE master: 10002c0a-8717-4bb1-90d2-299b42fc9c7a; evidence ID: 0316bacb-0681-4f65-a611-d6a702ac0aec
- Key: mobile-used-sold-iphone15promax-256gb-grey-box-ebay-298621751352-20260903

### 2. Silver
- Listing: https://www.ebay.co.uk/itm/327278174330
- Sold: 1 August 2026 at 20:46 BST
- Displayed buyer-facing total: £439.66 including £12.70 Buyer Protection
- Used condition; 20 bids. eBay says the seller has relisted this item or one like it, so this observation is not proof of a unique device.
- TEST master: 063919bb-3dbc-488b-971a-ad536c413d94; evidence ID: b72fc8c7-2c95-4783-b960-d150252642bd
- LIVE master: 10002c0a-8717-4bb1-90d2-299b42fc9c7a; evidence ID: 9ea5f767-6d4f-403a-baf1-0f5d989ec7e0
- Key: mobile-used-sold-iphone15promax-256gb-silver-ebay-327278174330-20260801

Seller net proceeds are not independently confirmed for either listing. Both TEST inserts were read-back verified before LIVE inserts; both LIVE inserts were also read-back verified.

## Refreshed counts
- TEST: 235 active phone evidence rows; 141 active rows where evidence_type='uk_used' and availability='sold'.
- LIVE: 233 active phone evidence rows; 139 active rows where evidence_type='uk_used' and availability='sold'.
- The used/sold subtotal includes parts/repair observations and is not a working-only count.
- Two-row TEST/LIVE difference persists.

## Process
Continue exact source URL/key preflight, exact master-product matching, TEST-first insertion and read-back, then LIVE insertion and read-back. Buyer Protection is part of the displayed buyer total, not confirmed seller proceeds.
