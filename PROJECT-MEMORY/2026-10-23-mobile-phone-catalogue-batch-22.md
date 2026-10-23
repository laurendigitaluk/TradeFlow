# Project Memory — Mobile Phone Catalogue Batch 22
Date: 2026-10-23

Added and promoted one additional exact-variant UK listing price:
- Samsung Galaxy S25+ 256 GB — £770.00, sealed/boxed new eBay UK business-seller listing, seller location Kent, more than 10 available at observation.
- Source: https://www.ebay.co.uk/itm/168750596099
- Stable key: `mobile-new-galaxys25plus-256gb-ebay-168750596099-20261023`
- Treat as an asking/listing price, not a completed sale or guaranteed acquisition offer.

Current database snapshot:
- TEST: 126 active customer-visible phone variants; 113 evidence rows total (110 active, 3 inactive for audit); 14 active visible variants without active evidence.
- LIVE: 108 active customer-visible variants; 108 active evidence rows, all active; 58 completed-sale rows where evidence type is `uk_used` and availability is `sold`, plus one `uk_used` listing row with availability `listed` and condition “Opened – never used”.
- LIVE integrity failures: 0. Active visible variants missing active evidence: 0.

Quality correction:
- Samsung Galaxy A27 5G 256 GB eBay listing explicitly shows “Opened – never used”, so the evidence was corrected in TEST and LIVE from `uk_new`/New to `uk_used`/Opened – never used, availability listed. It is not sealed-new or a completed sale.
- Purported OPPO Reno13 5G 256 GB sold listing https://www.ebay.co.uk/itm/318450438601 redirected to an OPPO Reno4 Pro 5G product page with incompatible identifiers and was rejected.
- Official OnePlus UK page shows OnePlus 15 as “Coming soon”; do not use the misleading eBay listing whose item specifics identify OnePlus 10 Pro.

Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-22.md`.
Next: resolve the 14 remaining TEST gaps with exact-variant UK evidence, promote promptly, and recheck the temporary Xiaomi campaign prices after 27 Oct 2026.
