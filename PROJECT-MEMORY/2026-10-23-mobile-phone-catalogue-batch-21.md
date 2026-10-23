# Project Memory — Mobile Phone Catalogue Batch 21
Date: 2026-10-23

Batch 21 added seven UK new-price/listing evidence records to TEST and promoted the validated records to LIVE:
- HONOR 600 256 GB — £599.99 HONOR UK online-store list price; not the lowest UK market price.
- HONOR 600 Smart 128 GB — £249.99 Argos listing.
- Xiaomi 17T 256 GB — £549 promotional price (original £649), Xiaomi UK campaign through 27 Oct 2026 or while stock lasts.
- Xiaomi 17T Pro 512 GB — £699 promotional price (original £849), same campaign expiry.
- HONOR Magic8 Lite 256 GB — £349.99 after-coupon HONOR UK shop offer; standard price listed as £399.99.
- Samsung Galaxy S26+ 256 GB — £1,179 Samsung UK listing, shown in stock.
- Samsung Galaxy A27 5G 256 GB — £209.99 current eBay UK business-seller listing, condition Opened – never used, 19 available at direct-page verification; recorded as secondary-market listing evidence, not completed-sale evidence.

Evidence sources and caveats are recorded in CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-21.md.

Verified database snapshot:
- TEST: 126 active customer-visible phone variants; 112 evidence rows total (109 active, 3 inactive for audit); 15 active visible variants lack active evidence.
- LIVE: 107 active customer-visible variants; 107 active evidence rows (58 used completed-sale rows); zero visible variants missing evidence and zero evidence integrity failures.
- TEST product count has changed from 123 active variants reported in Batch 20 to 126 in the current query; current query is authoritative and the new rows should be identified during remaining-gap review.
- Do not mix new listing/promo prices with completed-sale evidence. Recheck Xiaomi promo evidence after 27 Oct 2026.
- The Samsung Galaxy A27 direct page was checked after insertion and its condition corrected from “New” to “Opened – never used”; evidence type is now `uk_used`, availability `listed`. OnePlus 15 false-identity listing (actually OnePlus 10 Pro) and a Nothing Phone (4b) search result that resolved to earbud content were rejected.
- Next: work through the remaining 15 TEST gaps in large batches, exact model/storage, source verification, prompt LIVE promotion and post-promotion integrity checks.
