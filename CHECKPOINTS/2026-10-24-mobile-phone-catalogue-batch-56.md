# Mobile phone catalogue checkpoint — Batch 56

Date: 24 October 2026
Branch: main
Scope: UK eBay completed-sale evidence for iPhone 14 128GB and Google Pixel 8 128GB; reconcile an earlier LIVE verification gap.

## Records confirmed

1. Apple iPhone 14 128GB unlocked, eBay item 366661027705, sold 13 September 2026, displayed £188.66 including £6.65 Buyer Protection. Stable key: `mobile-used-sold-iphone14-128gb-ebay-366661027705-20260913`. This record was previously inserted into TEST and submitted to LIVE, but LIVE read-back had been blocked. On this checkpoint run, the LIVE row was successfully read back and confirmed active at £188.66.
2. Google Pixel 8 128GB Obsidian unlocked, eBay item 267790609007, sold 21 September 2026, displayed £159.95 including Buyer Protection (fee breakdown not captured). Stable key: `mobile-used-sold-pixel8-128gb-obsidian-ebay-267790609007-20260921`.
3. Google Pixel 8 128GB Obsidian/Black unlocked, eBay item 188937928681, sold 17 September 2026, displayed £179.99; listing states Good cosmetic condition and no accessories, and no fee breakdown was captured. Stable key: `mobile-used-sold-pixel8-128gb-black-good-ebay-188937928681-20260917`.

The two Pixel 8 rows were inserted TEST-first, read-after-write verified active in TEST, then inserted into LIVE and read-after-write verified active there. All three keys above are confirmed active in both environments. Displayed eBay totals are buyer-facing values and must not be treated as seller proceeds.

## Duplicate and rejected candidates

- iPhone 16 128GB items 366694404412 (£386.83) and 318875321713 (£381.75) were already active in both TEST and LIVE under existing source keys; neither was duplicated.
- Other candidates were identified but not inserted in this batch because a multi-row TEST write was blocked by tool safety checks and read-back was unavailable for those candidates at the time. Do not assume they were inserted.

## Post-batch integrity

- TEST: 218 active phone evidence rows; 124 active UK used/sold rows; 3 active phone rows classified `For parts or not working`.
- LIVE: 216 active phone evidence rows; 122 active UK used/sold rows; 3 active phone rows classified `For parts or not working`.
- Duplicate active source-record-key groups: 0 in TEST and 0 in LIVE.
- Counts are from separate successful SQL queries against the phone category in each environment. The count difference between TEST and LIVE remains 2 rows; do not claim the catalogues are fully identical.

## Next steps

Continue in larger evidence batches. For every candidate, validate the exact sold item, model/storage variant, date, displayed price, fee/condition caveats, and global source-key/item URL uniqueness. Insert TEST first, read back, then insert LIVE and read back. Keep defective/parts, opened-never-used, low-battery, and custom-OS evidence distinct from ordinary working-device sales. Check the matching master product exists in both environments before inserting. Do not mark any future batch complete until all inserted records are verified in both environments.
