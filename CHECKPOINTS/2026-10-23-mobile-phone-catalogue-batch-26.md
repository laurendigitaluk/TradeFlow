# Mobile Phone Catalogue — Batch 26 Checkpoint
Date: 2026-10-23

## Scope
Resolved OnePlus 15 256GB UK price-reference gap and added current exact-variant UK evidence for Nothing Phone (4b) and Motorola Edge 70 256GB. TEST and LIVE were updated promptly.

## Evidence added
- OnePlus 15 5G 256GB: £849 MyMobiles page identifying OnePlus as seller; source https://www.mymobiles.com/phones/oneplus/15-deals. Recorded as UK new-price reference, availability listed rather than in_stock because direct official checkout availability remains unclear. Key: mobile-new-oneplus15-256gb-mymobiles-oneplus-20261023.
- Nothing Phone (4b), 8GB RAM / 128GB: £299, official Nothing UK checkout https://checkout.nothing.tech/products/phone-4b, with Add to bag. TEST product d31d491b-a5ab-440f-880a-fc84a185000c; LIVE product 9ea16e96-f9da-49fc-baa6-8c498af007f9. Key: mobile-new-nothing-phone4b-128gb-nothinguk-20261023.
- Motorola Edge 70 256GB: £359.99 on MoneySavingExpert UK SIM-free comparison https://www.moneysavingexpert.com/cheap-mobile-finder/sim-free/motorola/edge-70/. TEST product cb1d3ee8-3cd2-4cbc-afdc-55a4762b1a09; LIVE product 69b5eb58-17ef-40ac-ad67-0ced87edfb9a. Key: mobile-new-motorola-edge70-256gb-mse-20261023. Secondary comparison evidence; recheck final checkout and stock before treating as confirmed purchase offer.
- Both Nothing Phone (4b) and Motorola Edge 70 were made customer-visible in TEST after exact-variant evidence was added. LIVE product rows were created customer-visible with active evidence.

## Xiaomi campaign record handling
- Xiaomi 17T 12GB/256GB: official UK autumn campaign £549 (was £649).
- Xiaomi 17T Pro 12GB/512GB: official UK autumn campaign £699 (was £849).
- Both campaign prices run 11–27 October 2026 or while stock lasts. Redundant/less precise Which? and secondary Xiaomi listing evidence rows were marked inactive in both TEST and LIVE; official campaign evidence remains active.
- Recheck and deactivate expired promotional evidence after 27 October if no longer valid.

## Current database snapshot after latest additions
- TEST: 130 active customer-visible variants; 142 evidence rows total; 137 active; zero visible variants missing active evidence.
- LIVE: 128 active customer-visible variants; 137 evidence rows total; 135 active; 62 active UK used completed-sale rows; 3 active UK used listing rows; zero visible variants missing active evidence.
- Last completed LIVE evidence integrity check before the most recent writes returned zero failures. Rerun at the next verification.

## Operating rules
Continue adding phones in large evidence-led batches. Add to TEST first, validate exact model/storage/condition/price type/source, then promote to LIVE without accumulating a backlog. Keep new prices, promotional prices, used asking prices, completed sales and refurbished listings distinct. Never infer exact storage, stock, price or lifecycle from a nearby variant.
