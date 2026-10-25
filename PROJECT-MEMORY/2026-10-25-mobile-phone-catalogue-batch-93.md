# Mobile Phone Catalogue — Batch 93 Project Memory
Date: 25 October 2026

## Work completed
Reviewed 20 exact phone model/storage variants, prioritising UK new-condition completed-sale evidence. One eligible observation was inserted into the existing Galaxy S26 Ultra 512GB master, TEST-first with read-back, then LIVE with independent read-back. No master rows, valuation logic, or schema were changed.

### Verified observation
- Product: Samsung Galaxy S26 Ultra 512GB Silver/Silver Shadow, factory-unlocked UK version, 12GB RAM, new.
- Source: https://www.ebay.co.uk/itm/127914642940
- Sale: 14 July 2026 at 13:43 BST.
- Displayed buyer-facing price: £989.00; Buyer Protection indicated, separate fee not shown.
- Seller: MrPhonesLtd, UK business seller, 99.7% positive feedback, 2,380 feedback at capture. Original page showed new condition, 512GB storage, unlocked UK version, out of stock and 10 sold.
- TEST master: abeb9f3f-... is LIVE master; TEST master is d3b3798d-a06a-408f-ac26-fc29d91a67e4.
- TEST evidence: 65eb70b3-5d85-4f88-b9dd-54f936618c09.
- LIVE master: abeb9f3f-b716-44d6-b711-e2b92f234c1f.
- LIVE evidence: d813d211-b43e-4995-a38e-3a4f33b1e06a.
- Stable key: `mobile-new-sold-galaxys26ultra-512gb-silver-ebay-127914642940-20260714`.

### Exclusions and duplicate controls
- iPhone 16 128GB item 257344900565: sold new, but India country-of-origin and Global Shipping Programme made UK-market variant suitability uncertain.
- iPhone 16 256GB item 167987075949: original page redirected to current product page.
- iPhone 16 Plus 128GB item 156427029735: multi-variant/out-of-stock page; no reliable individual completed-sale capture.
- iPhone 16e 128GB item 178318053825: 73.9% seller feedback and conflicting price captures (£258.92 vs £260.61).
- iPhone 17 Pro 512GB item 298717513949: seller had only 39 feedback; item 168558423665 has unresolved historic capture conflicts.
- Pixel 10 128GB item 287392332597: original page failed to open.
- Pixel 10 256GB item 157437867418: multi-quantity/out-of-stock page; sale timing not confidently reconciled.
- Pixel 10 Pro 256GB item 287449530690: accepted Best Offer amount hidden.
- Pixel 9 128GB item 157602233625: search result and original page price conflict (£356.17 vs £370.11 including £13.94 Buyer Protection).
- Pixel 8 128GB item 356984495160: active multi-quantity listing, not a clean completed-sale capture; item 157724761377 was China-based, not UK-local.
- Galaxy S25 128GB item 158092312889: source page date discrepancy; URL already existed in TEST and LIVE under an existing stable key, so no duplicate was inserted.
- Galaxy S25 Ultra 256GB item 286955204031: original page returned 404.
- OPPO Find X9 512GB item 128011295855: search capture £595.25 including £15.25 Buyer Protection conflicted with original page £598.45 including £18.45.
- Galaxy S26 Ultra 512GB item 147576942570 and item 128128322824 redirected to generic product pages; item 377337959960 had a Best Offer accepted with hidden price.
- iPhone 13 128GB item 188929213094 was already present in both databases, so it was excluded as a duplicate.
- Other reviewed variants were left unchanged where clean exact evidence was not found.

### Current verified coverage
- TEST: 134 total phone masters / 133 active; 78 masters with active uk_new evidence; 68 with active uk_used evidence; 273 active phone evidence rows; 19 uk_new+sold and 160 uk_used+sold.
- LIVE: 130 total/active phone masters; 78 masters with active uk_new evidence; 66 with active uk_used evidence; 271 active phone evidence rows; 19 uk_new+sold and 158 uk_used+sold.
- TEST/LIVE coverage differences remain open. Global active duplicate-key audit remains outstanding.
- Historic iPhone 15 Pink item 307244687330 discrepancy remains open: stored £292 including £12 Buyer Protection versus fresh capture £289.92 including £9.92. Never overwrite the historic row.
