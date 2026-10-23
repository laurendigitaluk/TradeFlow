# Mobile Phone Catalogue — Batch 26 Checkpoint
Date: 2026-10-23

## Scope
Resolved the final visible TEST evidence gap for OnePlus 15 256 GB using a current UK price-comparison page that identifies OnePlus as the seller. Added the same evidence to TEST and LIVE and created the missing LIVE product variant.

## Evidence added
- Product: OnePlus 15 5G, 12 GB RAM / 256 GB storage, Black, SIM-free.
- Observed price: £849.00.
- Evidence type: `uk_new`.
- Availability: `listed` (not `in_stock`).
- Source: https://www.mymobiles.com/phones/oneplus/15-deals
- Source notes: MyMobiles page labelled October 2026 lists the exact 256 GB Black SIM-free variant at £849 and identifies OnePlus as the seller. The linked official OnePlus page currently displays a “Notify me” / early-bird page rather than a clear in-stock checkout button, so direct availability is unresolved. Do not promote this record as in-stock until checkout is confirmed.
- Stable source key: `mobile-new-oneplus15-256gb-mymobiles-oneplus-20261023`
- TEST evidence row ID: `491ad359-8ab8-4039-a0c0-a32b8d6bf062`
- LIVE product ID: `476ae104-af53-4e69-8289-bab40e7be39b`
- LIVE evidence row ID: `ec83ec72-3677-4794-b398-3aba7a125ccb`

## Exact-variant safeguards
- A realme GT 7 Pro sold listing at https://www.ebay.co.uk/itm/267681249311 was inspected but rejected for the 512 GB product because its item specifics explicitly say 256 GB / 12 GB RAM. It is not used as 512 GB evidence.
- Another sold realme GT 7 Pro 512 GB listing showed a seller located in Frankfurt, Germany; it remains rejected as UK-local evidence.
- The official OnePlus UK page https://www.oneplus.com/uk/launch/oneplus-15 continues to show Notify me / early-bird material. The £849 price is therefore recorded as a UK new-price reference from MyMobiles identifying OnePlus as seller, but availability is only listed/uncertain.

## Verified database snapshot after Batch 26
- TEST: 123 active customer-visible variants; 124 evidence rows total (121 active, 3 inactive retained for audit); zero active customer-visible variants missing active evidence.
- LIVE: 119 active customer-visible variants; 119 evidence rows, all active. This includes 59 UK used completed-sale rows (`uk_used` + availability `sold`) and 3 UK secondary-market listing rows with availability `listed`.
- LIVE missing-evidence check: 0.
- LIVE integrity check: 0 active evidence rows with missing URL/key, non-positive price, or non-GBP currency.

## Next action
The current active customer-visible phone variants in both TEST and LIVE now all have active evidence. Continue catalogue expansion by researching additional exact UK phone models/variants and validating model identity, storage, price type, stock, and source before insertion. Recheck Xiaomi 17T/17T Pro promotion after 27 Oct 2026.


## Batch 26 follow-up correction — 23 Oct 2026
The live database count was re-run using distinct product IDs rather than joined evidence rows. This is the authoritative current count; it supersedes the older snapshot above.
- TEST: 128 active customer-visible phone variants; 134 evidence rows total, 129 active and 5 inactive; zero visible variants missing active evidence.
- LIVE: 126 active customer-visible phone variants; 129 evidence rows total, 127 active and 2 inactive; zero visible variants missing active evidence.
- LIVE has 59 active UK used completed-sale rows and 3 active UK used/listed rows; 0 active evidence integrity failures.
- Two weaker Xiaomi corroboration rows were added and then marked inactive in both environments because the precise official Xiaomi autumn campaign evidence was already present. These are audit-only and must not be treated as active evidence.
- The Xiaomi autumn campaign price evidence for 17T 12GB/256GB (£549 vs £649) and 17T Pro 12GB/512GB (£699 vs £849) is valid only until 27 Oct 2026 or while stock lasts. Source: https://www.mi.com/uk/support/terms/xiaomi-autumn-sales-campaign-tc
