# Mobile phone catalogue checkpoint — Batch 55

Date: 24 October 2026
Repository: `laurendigitaluk/TradeFlow`, branch `main`
Scope: UK eBay completed-sale evidence for iPhone 14 128GB and Google Pixel 8 128GB.

## New evidence inserted

### Apple iPhone 14 128GB
1. [Item 377487102296](https://www.ebay.co.uk/itm/377487102296) — Midnight, original packaging, sold 11 Sep 2026, £176.25 including £6.25 Buyer Protection; Best Offer accepted. Key: `mobile-used-sold-iphone14-128gb-midnight-ebay-377487102296-20260911`.
2. [Item 168648162659](https://www.ebay.co.uk/itm/168648162659) — sold 11 Sep 2026, £199.99 including Buyer Protection (fee amount not captured); no battery health or cosmetic grade recorded in captured excerpt. Key: `mobile-used-sold-iphone14-128gb-ebay-168648162659-20260911`.
3. [Item 278191750824](https://www.ebay.co.uk/itm/278191750824) — Black, unlocked, good condition, 77% battery health, sold 8 Sep 2026, £207.25 including £7.25 Buyer Protection. Low battery health is a material valuation caveat. Key: `mobile-used-sold-iphone14-128gb-black-77bh-ebay-278191750824-20260908`.
4. [Item 198725402177](https://www.ebay.co.uk/itm/198725402177) — White, unlocked, boxed, 78% battery capacity, sold 19 Oct 2026, £181.42 including £6.42 Buyer Protection; Best Offer option shown but acceptance not confirmed. Key: `mobile-used-sold-iphone14-128gb-white-78bh-ebay-198725402177-20261019`.

### Google Pixel 8 128GB
5. [Item 128030154438](https://www.ebay.co.uk/itm/128030154438) — Obsidian Black, excellent condition, accessories included, sold 17 Aug 2026, £165.92 including £5.92 Buyer Protection; Best Offer acceptance not confirmed. Key: `mobile-used-sold-pixel8-128gb-obsidian-ebay-128030154438-20260817`.
6. [Item 307086986254](https://www.ebay.co.uk/itm/307086986254) — Hazel, unlocked, near-mint condition per seller, sold 27 Jul 2026, £196.92 including £6.92 Buyer Protection. Key: `mobile-used-sold-pixel8-128gb-hazel-ebay-307086986254-20260727`.
7. [Item 267679227990](https://www.ebay.co.uk/itm/267679227990) — Black, unlocked, running GrapheneOS (custom/de-Googled OS), sold 25 Jun 2026, £218.48 including £7.61 Buyer Protection. Keep custom OS caveat; not a stock-software comparable. Key: `mobile-used-sold-pixel8-128gb-grapheneos-ebay-267679227990-20260625`.

## Reconciliation and quality

- Preflight checked candidate IDs/source-key patterns in both TEST and LIVE. Six candidate items were new; item 800739946361 (iPhone 14 128GB, £171.08) was already present in both and was not duplicated.
- Confirmed exact 128GB master products in TEST and LIVE before insertion.
- Inserted seven new rows into TEST, then LIVE, mapped to the corresponding environment's master IDs.
- Read-after-write confirmed all seven stable keys active in both environments.
- TEST: **215 active phone evidence rows; 121 active UK used sold rows**.
- LIVE: **213 active phone evidence rows; 119 active UK used sold rows**.
- Basic integrity failures: **0 in both**. Duplicate active source-key groups: **0 in both**.
- Galaxy A15/A16 search candidates were deferred because there are no corresponding master product rows in the current catalogue; do not create orphan evidence. Catalogue expansion should be a separate deliberate step.

## Operating rules

Continue global stable-key preflight, exact variant mapping, TEST-first insertion, prompt LIVE promotion, and read-after-write verification. Preserve battery-health and custom-OS caveats. Buyer-facing totals including Buyer Protection are not seller proceeds.
