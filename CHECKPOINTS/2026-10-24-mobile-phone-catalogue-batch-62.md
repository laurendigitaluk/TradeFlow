# Mobile phone catalogue — Batch 62
Date: 24 October 2026

## Added evidence
- Product: Google Pixel 9 128GB Obsidian
- Source: https://www.ebay.co.uk/itm/147349812276
- Sale date: 28 June 2026
- Displayed buyer-facing total: £243.42 including £8.42 Buyer Protection
- Listing title describes acceptable condition, 99% battery health, and warranty through 27 November 2027. Seller proceeds are not independently confirmed.
- Stable key: `mobile-used-sold-pixel9-128gb-99bh-acceptable-ebay-147349812276-20260628`
- TEST master: `dcbdbf35-a1b7-468a-8e62-4a52668b2c79`; evidence ID: `ee84c859-6e55-4144-b1be-02972f52f0e9`
- LIVE master: `fc040883-912e-4820-9f99-4aa616ddf7b5`; evidence ID: `5f0b03eb-e840-49e3-a60a-166b415f0704`
- Exact URL and stable-key preflights were empty in both environments. Inserted TEST-first then LIVE; separate read-back confirmed one active row in each.

## Counts
- TEST active phone evidence: 226
- LIVE active phone evidence: 224
- Two-row environment difference persists.
- Last refreshed active `uk_used` + `sold` counts before this batch: TEST 130, LIVE 128. Not refreshed in Batch 62.
- Existing Pixel 9 128GB Obsidian item 820179580133 was already present in both environments and not duplicated.

## Process
Continue global URL/key preflight, exact model/storage master matching, TEST-first, LIVE second, and read-after-write verification. Buyer Protection is part of the buyer-facing total, not confirmed seller net proceeds.
