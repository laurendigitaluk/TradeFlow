# Mobile Phone Catalogue Research — Batch 94
Date: 25 October 2026

## Scope and result
Reviewed the next 20 exact catalogue variants, checking existing evidence coverage first, then UK new-condition evidence, and second-hand evidence where new evidence was not established. One clean new-condition UK completed-sale observation was added to an existing master. TEST insert and read-back preceded LIVE insert and read-back. No master products, valuation logic or schema were changed.

## Added observation
**HONOR 600 Pro 5G, 512GB, 12GB RAM, Black UK model, unlocked, new**
- Source: https://www.ebay.co.uk/itm/267769398258
- Sold: 11 September 2026 at 11:57 BST.
- Displayed price: £589.99. Original page does not show a separate Buyer Protection fee.
- Original page confirms new condition, 512GB storage, 12GB RAM, model VKP-NX9, black, unlocked, UK model and sold status.
- Seller: gadgetheroukltd, UK business seller located in Luton, 100% positive feedback; 1,498 seller feedback entries shown at capture.
- TEST master: 3ff0ba4c-18ee-4c2f-b1e8-5cc8b7717cdc.
- TEST evidence: 8ffd75f3-e38f-4284-b129-1fe781f22d15.
- LIVE master: 7e297046-6655-47c3-b5da-39a7111b8f32.
- LIVE evidence: 7ccead9c-95b9-4da0-9ddc-f82afb7d668e.
- Stable key: `mobile-new-sold-honor600pro-512gb-black-ebay-267769398258-20260911`.
- Record represents the displayed buyer-facing listing price, not seller proceeds or a guaranteed TradeFlow offer.

## Twenty variants reviewed
1. OnePlus 12 256GB — no fresh exact UK new-condition evidence accepted in this pass; existing evidence retained.
2. OnePlus 13 256GB — no fresh exact UK new-condition evidence accepted in this pass; existing evidence retained.
3. realme 14 Pro+ 5G 512GB — UK sales channel and exact 512GB SKU remain unverified; do not use non-UK-local listings.
4. Xiaomi 14T 256GB — available search result was a multi-variant listing mixing 14T/14T Pro and 4G/5G variants; no exact individual sale price could be assigned.
5. Xiaomi 14T Pro 512GB — same multi-variant source excluded; official Xiaomi result was an older/out-of-stock page, not proof of current availability or discontinuation.
6. OnePlus 15 256GB — catalogue note says official UK launch page is Coming soon and no verified UK price captured; keep status unchanged until UK price evidence is clear.
7. OnePlus 15R 256GB — current UK new/used evidence not established in this pass; no lifecycle status change.
8. Xiaomi 17T 256GB — new price references found, but the master already has active new evidence; no duplicate or refresh inserted.
9. Xiaomi 17T Pro 512GB — Xiaomi UK currently displayed £699.00 on its official product page; the master already has active new evidence. No duplicate inserted.
10. HONOR 200 256GB — candidate completed-sale item 377200513894 returned 404 on direct open; not ingested. Other surfaced pages were ended, open-box or out of stock and were not treated as completed new sales.
11. HONOR 400 256GB — candidate item 336575555446 had only 73 seller feedback entries; not accepted as robust evidence. Other surfaced listings were active, out of stock, import/GSP, or used/damaged.
12. HONOR 600 256GB — existing active new and used evidence found; no duplicate inserted. Current search-index promo terms had expired dates, so not reused.
13. HONOR 600 Pro 512GB — item 267769398258 passed exact SKU, new condition, UK seller and completed-sale checks; inserted as detailed above.
14. HONOR 600 Smart 128GB — current Currys listing at £249.99 found; master already has active new evidence. No duplicate inserted.
15. realme A6 Pro 5G 256GB — no fresh exact UK new-condition source accepted; no lifecycle status change.
16. Motorola Edge 50 Neo 256GB — a UK retailer showed new stock as out of stock; this is not evidence that the model is discontinued. No new record or status change.
17. Motorola Edge 70 256GB — master already has active new evidence; no duplicate inserted.
18. Motorola Edge 70 Plus 256GB — current UK retailer pricing found and master already has active new evidence; no duplicate inserted.
19. Motorola Edge 70 Pro 256GB — master already has active new evidence; no duplicate inserted.
20. OPPO Find X10 256GB — EE page showed pre-order with launch expected 28 October 2026; master already has active new evidence. No duplicate inserted.

## Excluded source checks
- Xiaomi 14T/14T Pro eBay item 395808973921 mixes several different storage/network variants and is out of stock; the £319.99 displayed amount cannot be assigned safely to a single master.
- HONOR 400 item 336575555446 had only 73 seller feedback entries; excluded under the reliability threshold used for these batches.
- HONOR 200 item 377200513894 was not retrievable from the original URL at direct verification.
- HONOR 600 Pro item 267713321179 returned 404; the separate valid item 267769398258 was used instead.
- HONOR 600 Pro item 147588481544 had an accepted Best Offer with the accepted price hidden.
- HONOR 200 listing item 405311761581 was out of stock and displayed an asking price rather than a verified completed sale.
- Xiaomi 17T Pro 512GB official Xiaomi UK page showed £699.00, but the master already had active new evidence, so this was not duplicated.
- Do not infer discontinuation solely from an out-of-stock page, an expired promotion, a missing retailer listing, or an unopenable URL.

## Coverage after Batch 94
One new active evidence row was added in each environment. Relative to the verified post-Batch 93 snapshot:
- TEST: 134 total phone masters / 133 active; 79 masters with active uk_new evidence; 68 with active uk_used evidence; 274 active phone evidence rows; 20 uk_new+sold and 160 uk_used+sold.
- LIVE: 130 total/active phone masters; 79 masters with active uk_new evidence; 66 with active uk_used evidence; 272 active phone evidence rows; 20 uk_new+sold and 158 uk_used+sold.
These counts are the prior verified Batch 93 snapshot plus one successful active evidence insert per environment; a fresh aggregate SQL snapshot could not be run after insertion because the query tool blocked that combined query. The new rows themselves were returned by both inserts. Re-query aggregate counts in the next batch.

## Open issues
- TEST/LIVE master-count and evidence-count differences.
- Global active duplicate-key audit.
- Historic iPhone 15 Pink item 307244687330 price discrepancy; preserve the original row.
- Establish official lifecycle status before marking a model discontinued; when new evidence is absent, research second-hand completed sales only after status is grounded.
