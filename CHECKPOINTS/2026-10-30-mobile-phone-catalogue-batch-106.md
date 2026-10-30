# Mobile Phone Catalogue — Batch 105/106 Research Checkpoint
Date: 30 October 2026

## Environment and scope
- Repository: `laurendigitaluk/TradeFlow`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- Retired TEST project `twfbmjwwqzxdxvclxbun` remains prohibited.
- Research only in this batch. No database writes or product-master changes.

## Acceptance rules retained
Accept only a live, direct UK listing for the exact manufacturer/model/storage variant, with explicit Used/Pre-owned or a genuine refurbished grade, GBP price, and verifiable UK seller/item location. Exclude new, sealed, opened-never-used, wrong model/storage, overseas, buyback/trade-in and search-snippet-only leads. Asking prices are `uk_used` / `listed`; sold prices require a confirmed completed sale.

## Remaining gaps
TEST: 5
- Motorola Edge 70 Plus 256 GB
- OPPO Find X10 256 GB (customer hidden)
- OPPO Find X10 Pro Max 512 GB
- Apple iPhone 18 256 GB (customer hidden)
- OPPO Reno16 F 5G 256 GB

LIVE: 4
- Motorola Edge 70 Plus 256 GB
- OPPO Find X10 256 GB (customer hidden)
- OPPO Find X10 Pro Max 512 GB
- OPPO Reno16 F 5G 256 GB

The five unique products represent nine environment-specific evidence gaps. The iPhone 18 target exists only in TEST.

## Batch 105/106 research findings
- eBay UK still indexes the exact OPPO Find X10 Pro Max 512 GB Luna White listing from seller `nanovault` as Pre-owned at £1,244.82 plus £13 postage; seller feedback is shown as 100% positive (254). The search result/category page does not expose a usable direct item URL/item number or the location for this specific listing. A different completed nanovault OPPO Find X9 Ultra listing shows Leicester, but seller location on a separate item cannot be used to infer location for the target listing. Keep as a lead only; do not insert.
- OPPO Find X10 256 GB offers found were new, including a direct eBay item located in India; exclude.
- OPPO Find X10 Pro Max other exact offers were new/sealed or opened-never-used; exclude.
- Motorola Edge 70 Plus 256 GB exact listing £430 was brand new/sealed. MoneySavingExpert showed £529.99 new and no refurbished grade available; exclude.
- OPPO Reno16 F 5G 256 GB eBay offer £439.99 was new/sealed. Comparison pages show new retail/contract pricing only; exclude.
- iPhone 18 search results were wrong Pro/Pro Max variants; no base iPhone 18 256 GB used evidence found.
- No qualifying new evidence was found. No inserts or deactivations were performed.

## Fresh database snapshot after Batch 106 research
| Measure | TEST | LIVE |
|---|---:|---:|
| Mobile master rows | 160 | 156 |
| Active masters | 159 | 156 |
| Customer-visible active masters | 156 | 154 |
| Active mobile evidence rows | 541 | 535 |
| Active UK-used evidence rows | 274 | 272 |
| Active listed UK-used rows | 79 | 79 |
| Active products with any active UK-used evidence | 154/159 | 152/156 |
| Active-product evidence gaps | 5 | 4 |

Counts are unchanged from Batch 104. No writes were made.

## Next action
Continue targeted exact-variant UK used/refurbished searches, prioritising a direct eBay item URL and verified item location for nanovault's OPPO Find X10 Pro Max listing. Do not relax the evidence rules or create placeholder evidence. Re-run the two-environment gap/count query before any insert. If evidence qualifies, resolve the correct local product ID separately in TEST and LIVE, preflight the unique source key, insert separately, and read back both environments.
