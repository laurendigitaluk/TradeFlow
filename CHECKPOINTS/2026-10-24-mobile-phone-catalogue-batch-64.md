# Mobile phone catalogue — Batch 64
Date: 24 October 2026

## Evidence added
Added one Google Pixel 9 128GB Obsidian completed-sale observation from eBay UK:
- Listing: https://www.ebay.co.uk/itm/407029495464
- Sold: 29 June 2026
- Displayed price: £272.00; Buyer Protection amount not shown in source result and seller net proceeds not confirmed.
- Listing title describes the device as unlocked and in “Great” condition. Seller based in London; listing showed international postage options, so record as UK eBay seller evidence, not a confirmed UK-destination transaction.
- Evidence type: `uk_used`; condition: `Used`; availability: `sold`; currency: GBP; active: true.
- Stable key: `mobile-used-sold-pixel9-128gb-obsidian-ebay-407029495464-20260629`.
- TEST master: `dcbdbf35-a1b7-468a-8e62-4a52668b2c79`; evidence row: `64d2acde-c73a-4763-b201-a7c675cc373d`.
- LIVE master: `fc040883-912e-4820-9f99-4aa616ddf7b5`; evidence row: `aa7f2090-468e-444f-b83a-f3413d8d692a`.
- Exact URL/key preflight was empty in both environments; insertion and stable-key read-back confirmed one active row in each.

## Current counts (refreshed after insertion)
- TEST: 228 active phone evidence; 134 active `uk_used` + `sold` rows.
- LIVE: 226 active phone evidence; 132 active `uk_used` + `sold` rows.
- The two-row environment difference persists. The `uk_used` + `sold` subtotal includes parts/repair observations and is not working-only.
- Stable-key aggregate audit last returned zero duplicate active non-null source-record keys in both environments.

## Follow-up
Continue UK mobile completed-sale research and exact URL/key preflight. Always write TEST first, LIVE second, and read back both. Keep uncertainty about destination, Buyer Protection, and seller net proceeds explicit.
