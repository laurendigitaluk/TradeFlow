# TradeFlow LIVE — Manual Research Queue Reconciliation and Source Refresh
Date: 12 November 2026
Environment: LIVE only
Scope: Outstanding manual catalogue research queue; Bambu Lab A1, Anycubic Kobra series and Sony PlayStation 5 Digital Edition.

## Summary

A fresh read of LIVE found 10 rows in `platform_catalogue_research_queue` with status `needs_research`. Seven of those candidate source records already have corresponding evidence rows in `shared_market_evidence`; they were not inserted again. The evidence rows were re-read and matched by exact source URL, price, manufacturer/model and catalogue package.

The remaining three queue candidates are retained for follow-up because either the exact package is not represented in the current catalogue or the source does not establish a current price/availability.

## Existing LIVE evidence reconciled (no duplicate inserts)

| Queue candidate | Exact catalogue match | Existing LIVE evidence | Current source status |
|---|---|---|---|
| Bambu Lab A1, 3D Prima £215 | A1 / Standard Printer | 62ea3f7e-34aa-4f5c-9c3e-fd426ffcc95e | UK page shows In Stock (50+), SKU 12558, EAN 6975337039150, price includes VAT. Direct page https://www.3dprima.co.uk/bambu-lab/bambu-lab-a1-12558 |
| Anycubic Kobra 4 £159 | Kobra 4 / Standard Printer | ae7a2f85-ff95-4c22-8bf0-b856ed46142c | Standalone variant selected, distinct from £259 4-colour Combo; ships in 24 hours. https://uk.anycubic3d.com/products/kobra-4-3d-printer |
| Anycubic Kobra 3 Max V2 + ACE 2 Pro £499 | Kobra 3 Max V2 / 4-Color Combo | 24e67af8-e9bf-44ea-b515-c8226a1dec9e | Exact direct UK variant, one ACE 2 Pro, 4-colour package; GB VAT included, Add to Cart, ships in 24 hours. https://uk.anycubic3d.com/products/kobra-3-max-v2-ace-2-pro-combo |
| Anycubic Kobra 3 Max V2 Combo £519 | Kobra 3 Max V2 / 4-Color Combo | 0c749755-ad08-4a78-8d79-c19aca8deb21 | Exact 4-colour Combo variant; GB VAT included, Add to Cart, ships in 24 hours. https://uk.anycubic3d.com/products/kobra-3-max-v2-combo-3d-printer |
| Anycubic Kobra 3 Max V2 £379 | Kobra 3 Max V2 / Standard Printer | f2a40d41-73d3-4c5c-8bd6-e2724c80df39 | Exact standalone without ACE 2 Pro; same page separately lists Combo at £519; Add to Cart, ships in 24 hours. https://uk.anycubic3d.com/products/kobra-3-max-v2-3d-printer |
| Anycubic Kobra S1 + ACE 2 Pro £409 | Kobra S1 / ACE 2 Pro 4-Color Combo | b10534b7-fd71-493f-89f5-cbeab5c7927b | One ACE 2 Pro, base 4-colour package; £409 inc VAT, Add to Cart, ships in 24 hours. https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo |
| Anycubic Kobra S1 ACE 2 Pro £449 | Kobra S1 / ACE 2 Pro 4-Color Combo | 746d8f16-8a0f-48dc-9b07-350d74a787ac | Current 4-colour variant £449 inc VAT; 8-colour option £635; Add to Cart, ships in 24 hours. https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo-3d-printer |

No duplicate rows were created for these seven queue candidates.

## Price/availability refreshes and deduplication

- Bambu Lab A1 / Standard Printer, Additive-X existing row 054e117b-088e-4b16-a72f-0cdf0eaf50ed: refreshed from £209 to £189 inc VAT (displayed £157.50 ex VAT), In Stock / Next Working Day. SKU BAMA1-U1. Direct page https://www.additive-x.com/shop/bambu-lab-a1-3d-printer.html. This is the machine-only printer; AMS Lite is a separate Combo package.
- Kobra 3 Max V2 / 4-Color Combo row 0c749755-ad08-4a78-8d79-c19aca8deb21: availability refreshed from listed to in_stock after direct page showed Add to Cart and shipping within 24 hours.
- Kobra 3 Max V2 / Standard Printer row f2a40d41-73d3-4c5c-8bd6-e2724c80df39: availability refreshed from listed to in_stock after direct page showed standalone £379, Add to Cart and shipping within 24 hours.
- Kobra S1 / ACE 2 Pro 4-Color Combo row 746d8f16-8a0f-48dc-9b07-350d74a787ac: current £449, in stock, Add to Cart and ships within 24 hours.
- Older Kobra S1 row a3cf8ff3-5c32-4064-aa51-ef73b44228e0 was deactivated as a stale duplicate of the same source URL/package. Later £449 observation remains active.
- Sony PlayStation 5 Digital Edition official UK RRP £519.99 remains a price reference, but the current official page explicitly says Out of stock. Active retained row ac2f42ba-b7dc-4fb9-a5ca-1a28b04d5a87 now records `out_of_stock`. Duplicate official row f8d2cd24-966f-40d9-8693-f1266713b26e was deactivated; the same offer remains represented by the retained row. Direct page https://www.playstation.com/en-gb/ps5/digital-edition-825-gb/.

## Three queue items remain unresolved — no forced imports

1. **Anycubic Kobra 3 Max V2 Combo All-in-One Bundle** — direct page now shows £641 inc VAT, Add to Cart, ships in 24 hours. This is not the standard 4-Color Combo: it includes Combo + camera + printhead assembly + two adhesive packs + 4KG PLA High Speed. The current catalogue has no exact all-in-one bundle master. Keep as package comparison only; do not attach £641 to the 4-Color Combo master. Source https://uk.anycubic3d.com/products/kobra-3-max-v2-combo-all-in-one-bundle.
2. **PS5 Digital Edition 825GB / two-controller bundle Amazon ASIN B0HHFXFS8C** — Amazon page has no displayed price. Argos has the exact two-controller bundle at £559.99 with Add to trolley, but postcode is required to confirm local stock. This is a different package from the catalogue's standard 825GB Digital Edition (one controller); do not import its price against the standard package. Argos source https://www.argos.co.uk/product/9618149.
3. **PS5 Digital Edition Amazon ASIN B08H98GVK8** — no current displayed GBP price verified; model generation/package also requires checking against current CFI-2116B01Y Digital Edition. Do not import.

## Queue state

The three unresolved rows remain `needs_research`. Seven have corresponding evidence rows already present in LIVE, but the queue status was not changed through the owner-review workflow in this reconciliation. No fake owner identity or auth context was used.

## Database totals

Batches 01–13 read back as 268 evidence observations: 261 active (142 UK New, 119 UK Used), seven inactive. UK Used remains reference-only and must not affect automatic buying valuation.

## Safety boundaries

- LIVE only. TEST untouched.
- No schema, master catalogue, tenant/customer data, Stripe or valuation logic changed.
- Existing evidence rows updated in place where current source price/availability changed.
- Duplicate rows deactivated rather than deleted.
- No foreign currency converted.
