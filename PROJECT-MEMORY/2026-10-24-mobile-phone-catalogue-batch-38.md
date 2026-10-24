# Project Memory — Mobile Phone Catalogue Batch 38
Date: 2026-10-24

Three additional UK completed-sale records were inserted in TEST, promoted to LIVE, and independently verified in both environments:
- Samsung Galaxy S24 128GB Onyx Black, excellent/boxed, £243.31 displayed total including £8.41 Buyer Protection, sold 14 Oct 2026: https://www.ebay.co.uk/itm/147622053576. Key: `mobile-used-sold-galaxy-s24-128gb-ebay-147622053576-20261014`.
- Google Pixel 9 128GB Obsidian unlocked, £279.58 displayed total including £9.58 Buyer Protection, sold 29 Sep 2026: https://www.ebay.co.uk/itm/820179580133. Key: `mobile-used-sold-pixel9-128gb-ebay-820179580133-20260929`.
- Apple iPhone 16 128GB Teal unlocked, 88% battery, great condition, £386.83 displayed total including £11.83 Buyer Protection, sold 29 Sep 2026: https://www.ebay.co.uk/itm/366694404412. Key: `mobile-used-sold-iphone16-128gb-ebay-366694404412-20260929`.

Each source key was checked absent before insertion. Exact 128GB variants and active status were verified by querying the inserted rows joined to the product catalogue in both TEST and LIVE.

Verified phone-category snapshot after Batch 38:
- TEST: 130 active customer-visible variants; 175 evidence rows (164 active, 11 inactive); 70 active UK used completed-sale rows.
- LIVE: 128 active customer-visible variants; 170 evidence rows (162 active, 8 inactive); 68 active UK used completed-sale rows.
- Both environments: zero visible active variants missing active evidence; zero active evidence rows missing URL/key, non-positive price, or non-GBP currency; zero duplicate active source keys.

Database tool note: the earlier safety-check blocks were intermittent tool-layer blocks rather than returned database errors. A separate use of `ON CONFLICT (source_record_key)` failed because no unique/exclusion constraint exists on that column; this was not retried with ON CONFLICT. After verifying the key absent, a plain INSERT succeeded and the rows were independently read back.

Batch 37 historical displayed totals for eBay item 377500378163 (Galaxy S24) and 800749991087 (iPhone 16) differ from what those pages currently display. Do not silently overwrite old observations; investigate revisions/relisting and preserve historical evidence.

Checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-38.md`.
Continue TEST-first, promote promptly, keep UK used sales distinct from asking prices and Buyer Protection totals. Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden pending exact-capacity evidence. Recheck Xiaomi 17T/17T Pro after 27 Oct and OPPO Find X10 after 28 Oct 2026.
