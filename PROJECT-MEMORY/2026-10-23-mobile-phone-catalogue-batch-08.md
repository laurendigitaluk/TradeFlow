# Project Memory — Mobile Phone Catalogue Batch 08
Date: 2026-10-23

## Scope
Add UK completed/sold evidence to storage-specific phone variants, separate from UK new-price/RRP evidence.

## Verified evidence
- iPhone 15 256 GB: £238.35, eBay UK item 377548449194, sold 7 Oct 2026.
- Galaxy S23 256 GB: £197.61, eBay UK item 298615747269, sold 8 Sep 2026.
- iPhone 14 256 GB: £344.99, eBay UK item 178542006119, sold 1 Oct 2026; condition “Opened – never used”.
- iPhone 15 Pro 256 GB: £386.83, eBay UK item 366701964664, sold 4 Oct 2026.
- Galaxy S24 256 GB: £268.15, eBay UK item 128000546242, sold 4 Aug 2026.
- Pixel 9 256 GB: £292.20, eBay UK item 298511562847, sold 20 Jul 2026.

## Data-quality notes
All records are UK used, sold status, exact storage match, GBP, meaningful listing URL, and stable source key. Several displayed totals include buyer protection fees; they are buyer-facing totals, not seller proceeds or guaranteed trade-in/buy-in values. Keep the iPhone 14 “Opened – never used” condition distinct from ordinary used condition.

## Snapshot and concurrent activity
- TEST at final check: 124 total phone products, 123 active; 64 evidence rows, 61 active.
- LIVE changed concurrently during this pass. Latest query: 58 active phone products, 59 active evidence rows, 17 sold evidence rows. Only six sold evidence records are explicitly part of this batch; other newly visible legacy records should be attributed only after reviewing their timestamps and sources.
- Integrity query returned zero missing source URLs/keys, non-positive prices, non-GBP values, or broken product links.

## Next
Freshly inventory TEST and LIVE before the next batch. Continue legacy-phone sold evidence in large batches; then fill current new-price evidence gaps. Promote verified batches to LIVE promptly, while keeping price types separate.
