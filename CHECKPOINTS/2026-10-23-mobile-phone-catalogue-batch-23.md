# Mobile Phone Catalogue — Batch 23 Checkpoint
Date: 2026-10-23

## Scope
Added two official Xiaomi UK launch/list prices with availability explicitly recorded as coming soon, then tightened visibility and identity notes for unverified product seeds. No records were deleted and no product was marked discontinued solely because pricing evidence was unavailable.

## Evidence added
| Product variant | Listed price | Source | Availability |
|---|---:|---|---|
| Xiaomi REDMI Note 15 6 GB / 128 GB | £179.00 | Xiaomi UK REDMI Note 15 Series | Coming soon |
| Xiaomi REDMI Note 15 Pro 5G 8 GB / 256 GB | £349.00 | Xiaomi UK REDMI Note 15 Series | Coming soon |

Source: https://www.mi.com/uk/event/redmi-note-15-series/

The official Xiaomi page confirms the named configurations and starting/current prices but labels both models “Coming soon”. Do not present these as in-stock or guaranteed checkout prices. Source keys:
- `mobile-new-redmi-note15-128gb-xiaomi-uk-20261023`
- `mobile-new-redminote15pro5g-256gb-xiaomi-uk-20261023`

## Product identity / visibility corrections in TEST
- Apple iPhone 18 256 GB: set `customer_visible=false` pending official model/release/storage confirmation. No official Apple UK listing for a standard iPhone 18 256 GB was verified in this pass. It remains active in the catalogue and is not marked discontinued.
- Nothing Phone (4b) 128 GB: set `customer_visible=false` pending exact product identity and UK availability confirmation. A search result for this name resolved to earbud content. It remains active and is not marked discontinued.
- HMD Skyline 256 GB: note now records that exact UK SKU/availability remain unconfirmed; ended listings were not accepted as completed-sale evidence.
- Motorola Edge 70 256 GB and Edge 70 Pro 256 GB: note now records that UK retailer evidence found in this pass was for 512 GB variants only. Do not reuse those prices for 256 GB.
- Motorola moto g37 128 GB: UK retail SKU/availability remains unverified; no reliable UK retailer price found.
- OnePlus 15 256 GB: official OnePlus UK page labels the model “Coming soon”; global specs confirm 256 GB configuration but no verified UK price was captured. Do not use the misleading eBay listing whose item specifics identify OnePlus 10 Pro.
- realme 14 Pro+ 512 GB and GT 7 Pro 512 GB: UK sales channel/exact SKU remain unverified; the GT 7 Pro sale from a Germany-based seller was rejected as UK-local evidence.
- Redmi Note 15 and Redmi Note 15 Pro notes now record the official UK configuration and “Coming soon” status.

## Rejected source
The purported OPPO Reno13 5G 256 GB sold listing https://www.ebay.co.uk/itm/318450438601 redirected to an OPPO Reno4 Pro 5G product page with incompatible model identifiers. It was not entered.

## Verified snapshot after Batch 23
- TEST: 124 active customer-visible phone variants; 115 evidence rows total (112 active, 3 inactive retained for audit); 10 active visible variants remain without active evidence.
- LIVE: 110 active customer-visible phone variants; 110 evidence rows, all active. This includes 58 UK completed-sale rows (`uk_used` + availability `sold`) and one secondary-market listing (`uk_used`, availability `listed`, condition “Opened – never used”).
- LIVE missing-evidence check: 0.
- LIVE evidence integrity failures: 0.

The active visible count dropped from 126 to 124 because two unverified seeds were hidden from customers pending confirmation; neither was deleted or marked discontinued. Current database queries take precedence over earlier batch snapshots.

## Next action
Continue the 10 remaining visible TEST variants without active evidence. Keep upcoming prices tagged `coming_soon`; do not claim stock until verified. Recheck Xiaomi 17T/17T Pro promotion after 27 Oct 2026. Promote each verified batch to LIVE promptly and run the same integrity checks.
