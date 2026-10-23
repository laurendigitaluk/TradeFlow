# Project Memory — Mobile Phone Catalogue (updated 2026-10-23)

## Current state after batches 01 and 02
- TEST Mobile Phones category ID: `f10be666-dd02-43f6-ba38-fac09b4008f2`; branch ID: `a622bd9f-da55-437a-b4c0-a4dbd448a7d6`.
- LIVE Mobile Phones category ID: `90fda02e-ec5e-4e2c-bc30-11dab560781d`; branch ID: `0369d691-4950-4dfc-9f8e-9d8cd5f80ab0`.
- TEST has 106 phone variants and 28 linked evidence rows.
- LIVE has 12 phone variants and 12 linked evidence rows. LIVE counts represent the verified batches only; do not assume all TEST seed rows have been promoted.
- Batch 01: Galaxy A37 5G 128/256 GB and Galaxy A57 5G 128/256/512 GB.
- Batch 02: Galaxy S26 FE 128/256/512 GB, Galaxy Z Fold8 256/512 GB/1 TB, Galaxy Z Flip8 256 GB.
- Official Samsung UK / Samsung Business UK pages supply all 12 LIVE new-price evidence rows. LIVE integrity query returned zero missing URLs, keys, product links, non-positive prices or non-GBP prices.

## Required process
1. Validate exact model and storage identity, current UK new price, source URL, availability, currency, observation timestamp and stable source key in TEST.
2. Keep UK list price, promo price, used asking price and completed/sold price distinct.
3. Promote only verified products/evidence in each batch. LIVE taxonomy IDs differ from TEST; map category/branch by slug and name and manufacturer by exact name, never by assuming matching IDs.
4. Verify LIVE rows and evidence integrity after each promotion; avoid a growing backlog.
5. Research UK used-market evidence separately; new-price evidence is not a valuation recommendation.
6. Retain discontinued phones for used valuation but clearly distinguish discontinued lifecycle from current new-price availability.

See `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-01.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-02.md`.
