# Mobile Phone Catalogue Research — Batch 93
Date: 25 October 2026

## Scope and handling
Reviewed 20 exact model/storage variants, prioritising current UK new-condition completed-sale evidence. Where clean new evidence was not available, used completed-sale evidence and existing database coverage were checked. One observation was eligible and inserted into existing masters. TEST insertion/read-back preceded LIVE insertion/read-back. No master products, valuation logic, or schema were changed.

## Added observation
**Samsung Galaxy S26 Ultra 512GB Silver/Silver Shadow, factory-unlocked UK version, 12GB RAM, new**
- Original source: https://www.ebay.co.uk/itm/127914642940
- Sold: 14 July 2026 at 13:43 BST.
- Displayed buyer-facing price: £989.00; Buyer Protection indicated, separate fee not shown.
- Seller: MrPhonesLtd, UK business seller; 99.7% positive feedback; 2,380 feedback at capture. Original page confirms new condition, 512GB storage, unlocked UK version and page status out of stock/10 sold.
- TEST master: d3b3798d-a06a-408f-ac26-fc29d91a67e4
- TEST evidence: 65eb70b3-5d85-4f88-b9dd-54f936618c09
- LIVE master: abeb9f3f-b716-44d6-b711-e2b92f234c1f
- LIVE evidence: d813d211-b43e-4995-a38e-3a4f33b1e06a
- Stable key: `mobile-new-sold-galaxys26ultra-512gb-silver-ebay-127914642940-20260714`
- Buyer-facing total, not seller proceeds or a guaranteed TradeFlow offer.

## Twenty exact variants reviewed
1. Samsung Galaxy S26 Ultra 512GB — item 127914642940 eligible and inserted.
2. Samsung Galaxy S25 128GB — item 158092312889 sold used, but source page shows a date inconsistency; URL already exists in both databases under another stable key. No duplicate inserted.
3. Samsung Galaxy S25 Ultra 256GB — item 286955204031 original page returned 404; no reliable original sale capture.
4. Samsung Galaxy S23 256GB — item 257582311450 was opened/never-used, with accepted Best Offer price hidden; excluded.
5. Apple iPhone 16 128GB — item 257344900565 sold new at £629.99, but country of origin India and Global Shipping Programme make UK-market variant suitability uncertain; excluded.
6. Apple iPhone 16 256GB — item 167987075949 redirected to a current product page; excluded.
7. Apple iPhone 16 Plus 128GB — item 156427029735 is a multi-variant/out-of-stock page without a reliable individual completed-sale capture; excluded.
8. Apple iPhone 16e 128GB — item 178318053825 seller feedback 73.9% and price capture conflict (£258.92 vs £260.61); excluded.
9. Apple iPhone 17 Pro 512GB — item 298717513949 seller feedback only 39; excluded. Item 168558423665 has unresolved historical capture conflict.
10. Google Pixel 10 128GB — item 287392332597 original page failed to open; excluded.
11. Google Pixel 10 256GB — item 157437867418 page currently shows a multi-quantity out-of-stock listing and sale timing cannot be reconciled; excluded.
12. Google Pixel 10 Pro 256GB — item 287449530690 explicitly indicates Best Offer accepted but hides accepted price; excluded.
13. Google Pixel 9 128GB — item 157602233625 search capture £356.17 conflicts with original page £370.11 including £13.94 Buyer Protection; excluded.
14. Google Pixel 8 128GB — item 356984495160 is an active multi-quantity listing, not a completed-sale observation; excluded.
15. Google Pixel 8 128GB alternate source — item 157724761377 is an active multi-variant listing from Shenzhen, China; not UK-local evidence.
16. Apple iPhone 13 128GB — item 188929213094 already exists in both TEST and LIVE; duplicate preflight blocked a second observation.
17. Apple iPhone 13 256GB — no clean new-condition source selected in this pass; existing evidence retained and no master change.
18. Samsung Galaxy S24 128GB — no clean current new-condition source selected; prior lifecycle notes do not prove manufacturing cessation. No master change.
19. Samsung Galaxy S24 256GB — no clean current new-condition source selected; existing used evidence retained. No master change.
20. OPPO Find X9 512GB — item 128011295855 search capture £595.25 including £15.25 Buyer Protection conflicts with original page £598.45 including £18.45; excluded.

Additional screening: Galaxy S26 Ultra 512GB item 147576942570 and item 128128322824 redirected to generic product pages; item 377337959960 had an accepted Best Offer with hidden price. Pixel 10 Pro 256GB item 800258416614 had hidden accepted Best Offer amount. Apple iPhone 16e 128GB item 135810841943 was a current out-of-stock multi-quantity listing, not a clean individual completed-sale record.

## Verified coverage after Batch 93
| Metric | TEST | LIVE |
|---|---:|---:|
| Total phone masters | 134 | 130 |
| Active phone masters | 133 | 130 |
| Masters with active uk_new evidence | 78 | 78 |
| Masters with active uk_used evidence | 68 | 66 |
| Active phone evidence rows | 273 | 271 |
| Active uk_new + sold rows | 19 | 19 |
| Active uk_used + sold rows | 160 | 158 |

Counts are from fresh queries after Batch 93, filtered to phone-category masters and linked evidence. TEST/LIVE master-count and evidence-count differences remain unresolved. Global active duplicate-key audit remains outstanding.

## Existing unresolved issues
- iPhone 15 128GB Pink item 307244687330: stored £292 including £12 Buyer Protection versus later capture £289.92 including £9.92. Preserve historical observation; do not overwrite.
- TEST/LIVE master-count and evidence-count differences.
- Global active duplicate-key audit.
- Continue current UK new-price evidence first. If no clean current new evidence is found and official sources indicate the model is no longer in the current range, prioritise UK second-hand completed-sale evidence. Do not infer that manufacture has stopped without evidence.
