# Mobile Phone Catalogue — Batch 08
Date: 2026-10-23
Status: Completed-sale evidence added to TEST and LIVE; integrity checked

## Evidence added
- Apple iPhone 15 256 GB — £238.35, sold 7 Oct 2026, [eBay UK](https://www.ebay.co.uk/itm/377548449194)
- Samsung Galaxy S23 256 GB — £197.61, sold 8 Sep 2026, [eBay UK](https://www.ebay.co.uk/itm/298615747269)
- Apple iPhone 14 256 GB — £344.99, sold 1 Oct 2026, [eBay UK](https://www.ebay.co.uk/itm/178542006119)
- Apple iPhone 15 Pro 256 GB — £386.83, sold 4 Oct 2026, [eBay UK](https://www.ebay.co.uk/itm/366701964664)
- Samsung Galaxy S24 256 GB — £268.15, sold 4 Aug 2026, [eBay UK](https://www.ebay.co.uk/itm/128000546242)
- Google Pixel 9 256 GB — £292.20, sold 20 Jul 2026, [eBay UK](https://www.ebay.co.uk/itm/298511562847)

All records use `evidence_type=uk_used`, `availability=sold`, exact storage variant links, stable source keys, GBP currency, and the observed sale date. Several eBay totals include buyer protection fees; notes identify these as buyer-facing totals, not seller proceeds. The iPhone 14 item condition was “Opened – never used”, so do not treat it as a normal used-condition comparable.

## Verification snapshot
- TEST: 124 phone product rows, 123 active; 64 evidence rows total, 61 active.
- LIVE latest query during this pass: 58 active phone products, 59 active evidence rows, including 17 sold rows.
- LIVE was changing concurrently during this work window. Additional legacy model rows/evidence appeared alongside this batch; inspect timestamps and re-query before attributing them or doing the next promotion.
- Integrity: zero missing URLs/keys, non-positive prices, non-GBP values, or broken product links.
- Keep used sold evidence separate from current new prices, promotional prices, and RRP.

## Next steps
1. Re-query both environments to establish a fresh product/evidence inventory because LIVE changed during this session.
2. Continue adding completed/sold evidence for existing older phone variants in large batches.
3. Audit remaining current models without UK new-price evidence.
4. Keep the TEST → LIVE cadence and never promote unverified seeds.
