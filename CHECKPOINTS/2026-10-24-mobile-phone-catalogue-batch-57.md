# Mobile phone catalogue checkpoint — Batch 57

Date: 24 October 2026
Branch: main
Scope: UK eBay sold evidence for iPhone 15 128GB and Samsung Galaxy S22 128GB.

## Added and verified

Both records were preflighted by exact item URL and stable source key in TEST and LIVE; no existing rows were found. Each was inserted into TEST first, then read back by exact URL as active before the LIVE insert. LIVE insert results and separate LIVE read-backs confirm both active.

1. Apple iPhone 15 128GB Black, title says fully functional, battery health 82%; eBay item 407192517582, sold 14 September 2026 at 16:52 BST; displayed £238.25 including £8.25 Buyer Protection. Stable key: `mobile-used-sold-iphone15-128gb-black-82bh-ebay-407192517582-20260914`. Keep the 82% battery note and treat the displayed price as buyer-facing, not seller proceeds.
2. Samsung Galaxy S22 128GB; eBay item 398437617494, sold 28 September 2026 at 10:03 BST; displayed £80.00 including Buyer Protection, Best Offer accepted. Stable key: `mobile-used-sold-galaxys22-128gb-ebay-398437617494-20260928`. Accepted seller proceeds are not independently confirmed; retain as a low-price/outlier candidate rather than treating it as a typical working-device benchmark without further detail.

## Rejected as duplicates

A broader candidate review found that several iPhone 15 listings already exist in both databases, including items 168659039520, 178513141590, 188991253809, 278364248917, 800710234384, and others. They were not reinserted. Existing evidence sometimes has a stored displayed price that differs from a later search snippet; do not overwrite historic observations.

## Post-batch counts

- TEST: 220 active phone evidence rows; 126 active UK used/sold rows.
- LIVE: 218 active phone evidence rows; 124 active UK used/sold rows.
- Both new rows were confirmed active in both environments.
- A full duplicate-key aggregate query was blocked by tool safety checks in this run. The two new URLs and keys were preflighted empty in both environments and both inserts returned active rows; do not claim a new full duplicate audit was completed.
- The two-row difference between TEST and LIVE remains.

## Next steps

Continue in larger batches where each row has reliable item identity, model/storage match, sold date, price, condition, and explicit fee caveat. Preflight source URL and stable key globally in both environments; TEST insert and exact read-back first, then LIVE insert and exact read-back. Keep low-battery, faulty, parts-only, opened-never-used, and custom-OS items separate from ordinary working-phone evidence. Do not overwrite old observations when search snippets later show a different price.
