# Mobile phone catalogue checkpoint — Batch 54

Date: 24 October 2026
Repository: `laurendigitaluk/TradeFlow`, branch `main`
Scope: UK eBay completed-sale evidence for Google Pixel 9 128GB.

## New evidence inserted

1. **Google Pixel 9 128GB Porcelain, unlocked — Used**
   - eBay item: [287300622924](https://www.ebay.co.uk/itm/287300622924)
   - Sold: 24 May 2026
   - Displayed buyer-facing total: £291.89, including £11.90 Buyer Protection.
   - Listing says Best Offer accepted; £3.94 tracked postage shown separately.
   - Stable key: `mobile-used-sold-pixel9-128gb-porcelain-ebay-287300622924-20260524`
   - Keep buyer-facing total distinct from seller proceeds.

2. **Google Pixel 9 128GB Porcelain, factory unlocked — Opened - never used**
   - eBay item: [287074821925](https://www.ebay.co.uk/itm/287074821925)
   - Sold: 14 August 2026
   - Displayed buyer-facing total: £349.99, including Buyer Protection (fee amount not shown).
   - eBay condition is “Opened – never used”; seller says brand new, open box, not in original box.
   - Stable key: `mobile-used-sold-pixel9-128gb-porcelain-opened-ebay-287074821925-20260814`
   - Keep separate from ordinary used-phone benchmarks.

## Quality checks and environment status

- Globally preflighted both item IDs/source-key patterns in TEST and LIVE; no matching existing evidence rows were returned.
- Confirmed exact Pixel 9 128GB master products in both environments.
- Inserted both rows in TEST, then promoted them to LIVE using the corresponding LIVE master product ID.
- Read-after-write verification confirmed both stable keys active in TEST and LIVE, with matching price, currency, condition and sold status.
- TEST after batch: **208 active phone evidence rows; 114 active UK used sold rows**.
- LIVE after batch: **206 active phone evidence rows; 112 active UK used sold rows**.
- Batch 53 baseline was TEST 206/112 and LIVE 204/110, so each environment increased by two rows.
- The initial search result for item 267795640822 was rejected because it was a phone case, not a phone. It was not inserted.
- Full integrity/duplicate-key audit should be rerun before closing the next batch; this batch’s exact keys and fields were read back successfully.

## Operating rules

Continue large-batch research where quality permits, but keep evidence variant-specific. Check stable source keys globally before inserting; preserve prior observations when displayed totals change. Keep opened-never-used, parts-only/non-working, and ordinary used evidence clearly separated. Insert TEST first, promote promptly to LIVE, and verify both. Do not claim any row was written unless read-after-write confirms it.
