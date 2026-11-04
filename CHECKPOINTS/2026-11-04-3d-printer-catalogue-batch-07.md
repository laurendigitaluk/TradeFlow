# 3D Printer Catalogue — Batch 7 Checkpoint
Date: 4 November 2026

## Scope
Added three Snapmaker models and two QIDI legacy models independently to TEST and LIVE. Existing 3D Printers branch reused. Three UK-new retail evidence rows (incl VAT) and two UK-used marketplace listing evidence rows. Used listings are asking prices, not completed sales.

## Product and evidence mapping
| Product | Evidence price | Source | TEST product | LIVE product | TEST evidence | LIVE evidence |
|---|---:|---|---|---|---|---|
| Snapmaker U1 | £827.62 incl VAT | [Source](https://www.3djake.uk/snapmaker/u1?sai=40878) | 5aa1436f-9eaf-48a5-a482-797dcf91ee12 | 38055193-8785-494c-88c0-613b20270ba7 | aa35f672-c309-4dc3-b214-a2b75bd8777b | 512e3488-69ee-48c5-9175-c969cd892ab5 |
| Snapmaker Artisan | £1,932.33 incl VAT | [Source](https://www.3djake.uk/snapmaker/artisan?sai=16681) | d282b66a-2ff2-4e9a-b446-35a75230a833 | 7f7e52bb-4e89-4c33-b861-c85d6a87feee | 029d6428-19dc-4b10-9ead-ae4223e4b5a6 | 95ac31f7-1999-4a1b-b264-af6c4a824d9f |
| Snapmaker Artisan Premium | £2,300.58 incl VAT | [Source](https://www.3djake.uk/snapmaker/artisan-premium?sai=18699) | de5259bb-6314-43b0-94e3-0ffbf4cb0e37 | 521b3f4f-edfa-4d5f-b87b-4eea1f3d5ac4 | 174a268b-b9d6-4d96-aaa2-a0a4f2052bad | 2e652ebc-6477-4665-b86f-1f4ed44063ce |
| QIDI Q1 Pro | £190 used asking price | [Source](https://www.gumtree.com/p/printers-scanners/qidi-q1-pro-3d-printer-open-to-offers-/1801842959) | 0dca028d-cf35-412c-8d47-9d7c6b9c54c2 | 575d21fd-a9a1-4ed7-92d2-14d7fcd9a5e4 | 9e6716a5-00f5-465a-8a6b-5045a1a5141c | 030fab3e-7298-4d19-a1a8-465926fcb50d |
| QIDI X-Plus 3 | £257.66 used asking price | [Source](https://www.ebay.co.uk/itm/158103519611) | 37892466-91c0-4200-90e1-b3155891b7f2 | 9cd4b110-bae2-45cc-8731-616d369b3e9a | 80d6241c-2ab8-4e6a-b3dd-d851bdc2bee5 | 79acda44-aecb-4c92-8cbb-3606016823cd |

## Model notes
- Snapmaker U1 is the four-toolhead multicolour FDM printer.
- Snapmaker Artisan is the standard 3-in-1 model; Artisan Premium is a separate premium 40W laser/200W CNC package.
- QIDI Q1 Pro is explicitly discontinued by QIDI and replaced by Q2. Retain as legacy product for used matching.
- QIDI X-Plus 3 is distinct from X-Plus 2 and X-Max 3. It is retained as a legacy model; do not label formally discontinued without stronger manufacturer evidence.
- Q1 Pro Gumtree listing £190: seller states great condition/fully working and includes a filament dryer and filament. X-Plus 3 eBay listing £257.66: used, described as fully operational, seller located London. Both prices are asking prices only.
- Snapmaker 3DJake UK prices include VAT: U1 £827.62, Artisan £1,932.33, Artisan Premium £2,300.58.

## Verification (independent TEST and LIVE)
| Metric | TEST | LIVE |
|---|---:|---:|
| Active products | 118 | 118 |
| Customer-visible products | 118 | 118 |
| Manufacturers | 12 | 12 |
| UK-new evidence | 117 | 117 |
| UK-used evidence | 14 | 14 |
| Total active evidence | 131 | 131 |
| Visible products missing evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Active evidence integrity failures | 0 | 0 |

All active evidence has HTTP(S) source URLs, positive GBP prices and source record keys. Environment UUIDs differ. Used evidence remains reference-only and must not feed automatic valuations.

No code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe/subscription/domain changes or Worker deployment. Database-only catalogue changes do not require Worker deployment.
