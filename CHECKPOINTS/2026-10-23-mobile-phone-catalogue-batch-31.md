# TradeFlow Mobile Phone Catalogue — Batch 31
Date: 23 October 2026

## Changes promoted to TEST and LIVE

### Nothing Phone (4b), 8GB RAM / 128GB storage
- Current UK official new price: £299.
- Source: Nothing UK official product page, https://nothing.tech/products/phone-4b
- The page displays the 8+128GB configuration and an “Add to bag” control.
- Evidence type: `uk_new`; availability recorded as `listed`.
- Stable source key: `mobile-new-nothing-phone4b-128gb-299-official-20261023`.
- The exact product variant is now supported in both TEST and LIVE.

### OnePlus 15, 12GB / 256GB
- UK new-price reference: £849 from MyMobiles’ October 2026 page, which identifies OnePlus as the seller.
- Source: https://www.mymobiles.com/phones/oneplus/15-deals
- Official linked OnePlus page still shows notify-me/early-bird material; availability remains `listed`, not `in_stock`.
- Stable source key: `mobile-new-oneplus15-256gb-mymobiles-oneplus-20261023`.
- This is a price reference, not a confirmed live checkout or guaranteed buying offer.

## Evidence cleanup / audit notes
- The Xiaomi 17T 256GB £549 and Xiaomi 17T Pro 512GB £699 primary evidence remains the official Xiaomi UK autumn campaign record, with the campaign due to end 27 October 2026 or earlier if stock runs out. These are promotional prices, not evergreen RRPs.
- We added secondary Xiaomi corroboration rows but deactivated them because the storage variant was not explicit in the comparison summary or the dynamic official page did not independently expose the selected variant and final cart. They remain for audit and must not be treated as active price evidence.
- Apple iPhone Duo 256GB/512GB/1TB/2TB official UK prices were already recorded in Batch 27. Duplicate evidence rows added during this pass were immediately marked inactive and retained for audit; the original Batch 27 evidence remains active.
- Do not use the eBay OnePlus 15 listing at https://www.ebay.co.uk/itm/257792354372 as evidence: its item specifics identify a OnePlus 10 Pro.

## Verified database snapshot after Batch 31
Counts were re-queried after writes; they differ from earlier checkpoint snapshots, so this query is the current position.

- TEST: 130 active customer-visible phone variants; 147 evidence rows total, 138 active and 9 inactive retained for audit. Zero active visible variants are missing active evidence.
- LIVE: 128 active customer-visible phone variants; 142 evidence rows total, 136 active and 6 inactive retained for audit. 62 active UK used completed-sale rows (`uk_used` + `sold`) and 3 active UK used/listed rows.
- LIVE evidence integrity failures: 0.
- LIVE active visible variants missing active evidence: 0.

## Next actions
1. Continue expanding the phone catalogue in larger verified batches, adding to TEST first and promoting each validated batch promptly to LIVE.
2. Recheck Xiaomi 17T / 17T Pro promotional pricing after 27 October 2026.
3. Keep exact storage, price type, availability, condition, buyer-protection and Best Offer caveats explicit.
4. Do not infer a product’s UK variant price from another storage size or treat a listed/pre-order item as in stock.
