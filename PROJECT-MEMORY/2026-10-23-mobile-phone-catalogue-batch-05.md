# Project Memory — Mobile Phone Catalogue Batch 05
Updated: 2026-10-23

## Current verified position
- TEST Mobile Phones: 116 product variants; 47 evidence rows total, 46 active.
- LIVE Mobile Phones: 30 product variants and 31 active evidence rows.
- Batch 05 promoted: iPhone 17 256 GB (£899), iPhone 17 512 GB (£1,099), and Pixel 10a 256 GB (£599).
- LIVE-wide active evidence integrity: zero missing URLs, keys, product links, non-positive prices, non-GBP values, or inactive evidence rows.
- No used-market evidence added in batch 05.

## Quality correction
The old TEST evidence row for iPhone 17 256 GB had a generic giffgaff catalogue error URL and an unsupported £959 price. It is now inactive and retained for audit history. The active replacement is product-specific Apple UK evidence at £899. Do not use the inactive row for pricing or valuation.

## Evidence details
- Apple UK lists iPhone 17 256 GB at £899 and 512 GB at £1,099 (observed 23 Oct 2026).
- Argos lists Google Pixel 10a 256 GB at £599 (observed 23 Oct 2026). Stock/delivery requires postcode check.
- Source URLs: https://www.apple.com/uk/shop/buy-iphone/iphone-17/6.3-inch-display-256gb-white and https://www.argos.co.uk/product/7939318.

## Operating rules
1. TEST first; promote only verified product/evidence rows.
2. Match evidence to exact model and storage variant.
3. Retire bad evidence by marking it inactive and retaining an audit note; do not silently delete it.
4. Distinguish UK new, promotional, used asking, and completed/sold prices.
5. Use stable unique source keys, real source URLs, GBP, observation timestamps, positive prices and conservative availability.
6. Promote checked batches promptly and verify LIVE independently.
7. Preserve discontinued devices for used valuation; never treat old launch prices as current new prices.
