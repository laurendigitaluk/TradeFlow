# TradeFlow Mobile Phone Catalogue — Batch 74
Date: 25 October 2026

## Added record
Google Pixel 10 Pro 256GB Porcelain, boxed with accessories and described as very good condition. eBay item https://www.ebay.co.uk/itm/336731607825, sold 19 August 2026 at 14:32 BST (13:32 UTC). Displayed buyer-facing total £498.67 includes £13.67 Buyer Protection; seller proceeds not independently confirmed.

- Stable key: `mobile-used-sold-pixel10pro-256gb-porcelain-ebay-336731607825-20260819`
- TEST master: `a20d14bc-aaab-4b82-9e5f-214dfb048547`; evidence: `68ff1138-bf1d-4895-9494-c8a498555cb4`
- LIVE master: `4a2d71c3-0bb2-4633-8c86-56f401ee5a9d`; evidence: `8b3fe4b5-a40f-4171-b4fe-d8558ca5b24c`

Exact URL/key preflight was clear in both environments. TEST insert and full read-back succeeded before LIVE insert; LIVE read-back also verified the row. No existing records were updated.

## Counts verified after Batch 74
Direct Mobile Phones category counts: TEST 242 active evidence / 148 active `uk_used` + sold; LIVE 240 / 146. Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding because the tool blocked it in Batch 73.

## Next
Continue exact active master matching, URL/key preflight, TEST-first insertion and read-back, then LIVE insertion and read-back. Keep Buyer Protection and seller proceeds distinctions explicit. Retry global duplicate-key audit when supported.