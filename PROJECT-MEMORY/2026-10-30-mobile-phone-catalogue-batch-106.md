# Project Memory — Mobile Phone Catalogue Batch 105/106
Date: 30 October 2026

Mobile phone catalogue evidence research continued through Batch 106. No qualifying new UK used/refurbished listing was verified for the five remaining unique exact product variants (four shared between environments, plus TEST-only base iPhone 18 256 GB). No Supabase writes were made.

Fresh counts remain stable:
- TEST: 160 mobile masters, 159 active, 156 customer-visible active; 541 active evidence rows, 274 active uk_used, 79 listed uk_used; 154/159 active products have uk_used evidence; 5 gaps.
- LIVE: 156 mobile masters, all active, 154 customer-visible; 535 active evidence rows, 272 active uk_used, 79 listed uk_used; 152/156 active products have uk_used evidence; 4 gaps.

Strongest remaining lead: eBay UK search indexes nanovault's OPPO Find X10 Pro Max 512 GB Luna White as Pre-owned at £1,244.82 + £13 postage, seller feedback 100% (254). The target listing's direct item URL/item number and its own seller/item UK location remain unverified. A separate sold item from this seller shows Leicester, but that does not prove the location of this target item. Do not insert until the exact listing is directly accessible and its own location is verified.

Other exact-variant offers were new/sealed, opened-never-used, wrong model/storage, overseas, or Pro/Pro Max instead of the base iPhone 18. Exclude them.

Evidence acceptance remains strict: exact variant, active direct UK listing, explicit Used/Pre-owned or genuine refurb grade, GBP price and verified UK location. Do not use trade-in/buyback quotes, new/sealed/opened-never-used or overseas listings. Do not alter master visibility, valuation, lifecycle, tenant/customer data or schema during this evidence task.

Next: continue direct-link/location verification for the nanovault listing and fresh targeted searches for the remaining four models. Re-run TEST and LIVE counts before any write. Resolve each environment's own product ID and source-key uniqueness independently before separate inserts.
