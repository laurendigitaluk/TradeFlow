# Project Memory — Mobile Phone Catalogue Batch 26
Date: 2026-10-23

Resolved the final active visible TEST gap: OnePlus 15 5G 12GB/256GB Black SIM-free, £849 new-price reference from MyMobiles' October 2026 deal page, which identifies OnePlus as seller. Source https://www.mymobiles.com/phones/oneplus/15-deals. The official linked page still shows Notify me / early-bird material rather than an explicit in-stock checkout button, so evidence availability is `listed`, not `in_stock`. Stable key `mobile-new-oneplus15-256gb-mymobiles-oneplus-20261023`.

Created the missing LIVE product variant and added the evidence row in both TEST and LIVE.

Exact-variant safeguards:
- Rejected https://www.ebay.co.uk/itm/267681249311 for realme GT 7 Pro 512GB because its item specifics identify the phone as 256GB/12GB RAM.
- Rejected another 512GB GT 7 Pro sale from a Frankfurt, Germany seller as not UK-local evidence.
- Official OnePlus UK page remains Notify me / early-bird, so do not describe the £849 record as confirmed in stock.

Current verified counts:
- TEST: 123 active visible variants; 124 evidence rows (121 active, 3 inactive); zero active visible variants missing evidence.
- LIVE: 119 active visible variants; 119 active evidence rows; 59 UK completed-sale rows and 3 secondary-market listed rows. Zero missing active evidence; zero integrity failures.

Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-26.md`.
Next: expand with additional exact-variant UK phone models, not just patch evidence gaps. Recheck Xiaomi 17T/17T Pro campaign after 27 Oct 2026.


## Batch 26 follow-up correction — 23 Oct 2026
A fresh distinct-product count supersedes the initial snapshot in this file:
- TEST: 128 active customer-visible variants; 134 evidence rows (129 active, 5 inactive); zero visible variants missing active evidence.
- LIVE: 126 active customer-visible variants; 129 evidence rows (127 active, 2 inactive); zero visible variants missing active evidence.
- LIVE has 59 active UK used completed-sale rows, 3 active UK used/listed rows, and 0 active evidence integrity failures.
- Two lower-quality Xiaomi corroboration rows are inactive in both environments; exact-variant official campaign evidence remains active. Xiaomi 17T £549 and 17T Pro 512GB £699 promotional prices expire 27 Oct 2026 or while stocks last; recheck before retaining as current price evidence.


## Batch 26 continued — 23 Oct 2026
Added in both TEST and LIVE:
- iPhone 18 Pro 256GB: £1,199 EE SIM-free, in stock; https://ee.co.uk/products/iphone-18-pro-sim-free. Stable key `mobile-new-iphone18pro-256gb-ee-simfree-20261023`.
- Google Pixel 11 256GB / 12GB RAM: £879 EE SIM-free, in stock; https://ee.co.uk/products/google-pixel-11-sim-free. The EE tech voucher offer runs through 31 Oct 2026; recorded price excludes voucher value. Stable key `mobile-new-pixel11-256gb-ee-simfree-20261023`.

Rejected eBay listing https://www.ebay.co.uk/itm/257792354372 as OnePlus 15 evidence: the title is misleading and item specifics identify OnePlus 10 Pro (Snapdragon 8 Gen 1; MPN 5011101954).

Authoritative distinct-product snapshot after this batch:
- TEST: 128 active visible variants; 139 evidence rows total, 134 active.
- LIVE: 126 active visible variants; 134 evidence rows total, 132 active.
- LIVE visible variants missing evidence: 0.
- LIVE active evidence integrity failures: 0.
- LIVE active UK used completed-sale rows: 59; active UK used/listed rows: 3.
