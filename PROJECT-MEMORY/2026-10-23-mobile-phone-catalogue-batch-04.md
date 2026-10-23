# Project Memory — Mobile Phone Catalogue Batch 04
Updated: 2026-10-23

## Current verified position
- TEST Mobile Phones: 116 product variants and 44 linked evidence rows.
- LIVE Mobile Phones: 27 product variants and 28 linked evidence rows.
- Batch 04 promoted: iPhone 17e 256 GB (£699), iPhone 17e 512 GB (£899), and Pixel 10a 128 GB (£599), each with current UK new-price evidence.
- LIVE-wide integrity check: zero missing URLs, keys, product links, non-positive prices, non-GBP values, or inactive evidence rows.
- Pixel 10a 256 GB is in TEST only, without evidence. Confirm exact variant price before promotion.
- No used-market evidence added in batch 04.

## Evidence details
Apple UK purchase page listed £699 for iPhone 17e 256 GB and £899 for 512 GB on 23 Oct 2026. Do not use the March 2026 launch starting price (£599) as current price. Google Store UK displayed “From £599” and confirms 128 GB and 256 GB options; the retrieved page did not provide a variant-specific 256 GB price. A Pixel Buds 2a bundle ending 3 Nov is separate from handset price.

## Operating rules
1. TEST first; promote only verified product/evidence rows.
2. Match evidence to exact model and storage variant.
3. Store UK new, promotional, used asking, and completed/sold evidence as distinct price contexts; add explanatory notes when the schema uses the shared `uk_new` evidence type.
4. Use stable unique source keys, real source URLs, GBP, observation timestamps, positive prices, and conservative availability.
5. Promote checked batches promptly and verify LIVE independently.
6. Preserve discontinued devices for used valuation; never treat old launch prices as current new prices.
7. Do not promote Pixel 10a 256 GB until its exact UK new price is sourced.
