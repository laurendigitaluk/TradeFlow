# Mobile Phone Catalogue — Batch 22 Checkpoint
Date: 2026-10-23

## Scope
Added one additional exact-variant UK listing-price record for Samsung Galaxy S25+ 256 GB to TEST and LIVE.

## Evidence added
- Samsung Galaxy S25+ 256 GB — £770.00 current sealed/boxed eBay UK business-seller listing.
- Source: https://www.ebay.co.uk/itm/168750596099
- Source key: `mobile-new-galaxys25plus-256gb-ebay-168750596099-20261023`
- Listing showed more than 10 available; seller location shown as Kent, England.
- This is a current new asking/listing price, not a completed-sale price or guaranteed acquisition offer.

## Current verified database snapshot
- TEST: 126 active customer-visible phone variants; 113 evidence rows total (110 active, 3 inactive retained for audit); 14 active customer-visible variants remain without active evidence.
- LIVE: 108 active customer-visible phone variants; 108 active evidence rows (all active); 58 active UK completed-sale rows with availability=sold, plus 1 secondary-market listing row with availability=listed and condition “Opened – never used”.
- LIVE missing-evidence check: 0 active visible variants missing active evidence.
- LIVE integrity check: 0 active evidence integrity failures.

## Evidence quality correction
The direct page for Samsung Galaxy A27 5G 256 GB, https://www.ebay.co.uk/itm/287456740841, explicitly displays condition “Opened – never used”, not “New”. The record was corrected in both TEST and LIVE to evidence type `uk_used`, condition “Opened – never used”, availability `listed`, and notes stating the listing price is not a completed-sale price. Do not treat this as sealed-new or an ordinary-used comparable.

## Rejected source
The purported OPPO Reno13 5G 256 GB sold listing https://www.ebay.co.uk/itm/318450438601 was opened and redirected to an OPPO Reno4 Pro 5G product page with incompatible model identifiers. It was rejected and not entered as Reno13 evidence.

## Next action
Continue the 14 remaining active TEST variants without active evidence. The official OnePlus UK launch page currently labels OnePlus 15 as “Coming soon”; its 256 GB variant is real, but no verified UK price was captured in this batch. Do not use the misleading eBay listing whose item specifics identify OnePlus 10 Pro. Continue verifying model identity, exact storage and UK source before insertion; promote each validated batch promptly and rerun LIVE integrity checks.
