# Mobile phone catalogue checkpoint — Batch 58

Date: 24 October 2026
Branch: main
Scope: One verified UK eBay completed sale for iPhone 15 Pro 128GB.

## Added and verified

- Apple iPhone 15 Pro 128GB Natural Titanium, listing describes immaculate condition and original box.
- eBay item: 227530529279
- Sold: 21 September 2026 (listing shows 07:33 BST)
- Displayed total: £402.08, including £12.08 Buyer Protection.
- Stable key: `mobile-used-sold-iphone15pro-128gb-natural-titanium-box-ebay-227530529279-20260921`.
- TEST master product: `0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe`.
- LIVE master product: `8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16`.
- TEST insert returned an active row and a separate exact-URL read-back confirmed it active. LIVE insert returned an active row and a separate exact-URL read-back confirmed it active.

The displayed total is buyer-facing and must not be treated as seller proceeds.

## Candidate not duplicated

The iPhone 15 Plus 128GB Blue listing, eBay item 800655157429 (£300.25, 89% battery health, sold 17 September 2026), was already active in both TEST and LIVE under an existing key. It was not reinserted.

## Post-batch active phone evidence counts

- TEST: 221 active phone evidence rows.
- LIVE: 219 active phone evidence rows.
- The previous Batch 57 UK used/sold counts were TEST 126 and LIVE 124. The UK used/sold recount for Batch 58 was blocked by tool safety checks; do not present these as refreshed counts.
- A full duplicate-key aggregate audit was not completed in this batch. The new record was preflighted by exact URL in both environments before insertion.

## Next steps

Continue with UK sold evidence in larger batches when safe. Verify matching product masters in both environments, preflight exact URL and stable source key globally, insert TEST first and read back, then insert LIVE and read back. Preserve condition/battery notes and separate Buyer Protection from seller proceeds. Do not overwrite historic observations if search snippets later display a different price.
