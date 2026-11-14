# TradeFlow LIVE — 3D-printer UK Used evidence review 06

- Date: 14 November 2026
- Branch: `production` (LIVE)
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Selection: next 25 active, customer-visible 3D-printer product/package rows with zero active UK Used observations; Pokémon excluded.
- Research: UK eBay and Gumtree; individual listing pages opened where possible.
- Outcome: 2 observations imported and read back; 23 held; 0 duplicate inserts.

## LIVE imports

| Product / package | Stored item price | Source / status | Evidence ID |
|---|---:|---|---|
| Anycubic Kobra 3 Max V2 — Standard Printer | £180.00 GBP | Gumtree active asking listing; Royton, Manchester; Good condition; collection only | `2298f32f-ef9e-4996-8974-85eb245c94b2` |
| Bambu Lab AMS 2 Pro — Single Unit | £230.29 GBP | eBay sold 27 July 2026; Newark, Nottinghamshire; 16 bids | `3ed3e9e3-c457-4b8d-aaac-255fc5ef3ae9` |

### Evidence detail

1. **Anycubic Kobra 3 Max V2 — Standard Printer**
   - Source: https://www.gumtree.com/p/printers-scanners/3d-printer-kobra-3-max-v2/1804857950
   - Listing asks £180. Gumtree shows Good condition, collection only and a separate £9.70 Buyer Protection fee.
   - Location: Royton, Manchester, UK.
   - Seller: Joseph; posting on Gumtree for 3+ years; 2.5/5 from 6 ratings; 43 ads in a year; email verified.
   - The page states “Posted: 3 hours ago” and “Active 4 days ago”; discrepancy preserved in `availability`.
   - Mapped to Standard Printer because the listing names the printer only and does not identify an ACE/4-colour combo. Package contents/accessories not itemised; buyer should confirm no multi-colour module and request a demonstration. No print-hour count or explicit seller confirmation of a successful print test. Current asking price, not a completed sale.
   - Source key: `gumtree:1804857950`.

2. **Bambu Lab AMS 2 Pro — Single Unit**
   - Source: https://www.ebay.co.uk/itm/236951798064
   - Sold auction on 27 July 2026 at 22:30 BST, 16 bids. Displayed total £240.12 included £9.83 Buyer Protection fee; stored item price is £230.29 before that fee.
   - Location: Newark, Nottinghamshire, UK.
   - Listing title specifies AMS 2 Pro with Filament Buffer; buffer is an extra, no other accessories specified.
   - Seller: cupra19852011, private seller, 100% positive feedback, 177 items sold, joined October 2011, usually responds within 24 hours. No returns accepted; postage amount not specified.
   - Completed-sale reference, not a current asking price.
   - Source key: `ebay:236951798064`.

Both inserted rows were read back by evidence ID. Confirmed master product/package, `evidence_type='uk_used'`, source name, full non-null clickable `source_url`, GBP price, condition, channel, status, notes, `is_active=true` and source key. Unique index on (source_name, source_record_key) was checked before insert; no duplicate keys existed.

## 25 candidates — disposition

| # | Product / package | Result |
|---:|---|---|
| 1 | Anycubic Hotend incl. Nozzle, Hardened Steel, Kobra S1 0.4 mm — Single Replacement Hotend with Hardened-Steel Nozzle | Held: no exact UK Used replacement hotend; only new aftermarket parts listings |
| 2 | Anycubic Hotend, Kobra S1 0.4 mm — Single Replacement Hotend | Held: no exact UK Used replacement hotend; only new parts listings |
| 3 | Anycubic Kobra 3 Max V2 — 4-Color Combo | Held: used eBay Kobra 3 Max Combo item specifics identified older Anycubic Kobra Max, not catalogue V2; no exact V2 combo package |
| 4 | Anycubic Kobra 3 Max V2 — Standard Printer | **Imported**: Gumtree £180, Royton; evidence above |
| 5 | Anycubic Kobra 4 — ACE 2 Pro Combo | Held: Kobra 4 combo result was Opened–never used; Used ACE 2 Pro result was Kobra S1, not Kobra 4 |
| 6 | Anycubic Kobra 4 — Standard Printer | Held: found current New offers (£215/£219), not Used |
| 7 | Anycubic Kobra S1 — ACE 2 Pro 4-Color Combo | Held: exact listing was a customer-return, unrepaired, condition unconfirmed, no returns |
| 8 | Anycubic Kobra S1 Max — 16-Color Combo | Held: no exact Used 16-colour combo; available used listing did not establish package |
| 9 | Anycubic Kobra S1 Max — 4-Color Combo | Held: no exact Used 4-colour combo; available used listing did not establish package |
| 10 | Anycubic Kobra S1 Max — 8-Color Combo | Held: no exact Used 8-colour combo; available used listing did not establish package |
| 11 | Anycubic Kobra S1 Max — Standard Printer | Held: listing title said S1 Max but item specifics said Anycubic Kobra Max; no reliable exact match. Seller dpsdirectltd; used £299.99 incl Buyer Protection, £45 postage, Doncaster; sold 17 Oct 2026 |
| 12 | Anycubic Kobra X — 7-Colour Combo | Held: sold Kobra X listing did not specify 7-colour package; 4-colour listing is not an exact match; another result unrepaired |
| 13 | Anycubic Kobra X — Standard Printer | Held: sold listing item specifics said generic Anycubic Kobra rather than Kobra X and did not establish package; another used listing unrepaired/out of stock |
| 14 | Anycubic Photon Mono 4 Ultra — Standard Resin Printer | Held: no exact UK Used listing verified |
| 15 | Anycubic Photon Mono M7 — Standard Resin Printer | Held: only used result explicitly unrepaired/unknown damage, possible missing parts, no warranty and no returns |
| 16 | Anycubic Photon Mono M7 Pro — Standard Resin Printer | Held: unrepaired customer-return listings; condition unconfirmed/no returns |
| 17 | Anycubic Photon P1 — Dual-Color / Dual-Material Platform Bundle | Held for Used: no exact Used listing. Official UK New page £449, but existing UK New evidence already present; no duplicate New row |
| 18 | Anycubic Photon P1 Max — Standard Resin Printer | Held: no exact UK Used listing verified |
| 19 | Artillery M1 Pro — Standard Printer | Held: no exact UK Used listing verified |
| 20 | Artillery M1 Pro S1 — Standard Printer | Held: no exact UK Used listing verified |
| 21 | Bambu Lab A2L — AMS Combo | Held: Gumtree £320 result, Littleborough, seller Jordan, AMS Lite Combo, good condition; detail page returned HTTP 410 |
| 22 | Bambu Lab A2L — Standard Printer | Held: same A2L listing was AMS Lite Combo, not Standard; detail page returned HTTP 410 |
| 23 | Bambu Lab AMS 2 Pro — Single Unit | **Imported**: eBay sold £230.29 before £9.83 fee; evidence above |
| 24 | Bambu Lab H2C — Vortek AMS 2 Pro Combo | Held: sold H2C listing said “AMS 2” but did not confirm Vortek/AMS 2 Pro package |
| 25 | Bambu Lab H2D — 10W Laser Full Combo | Held: used H2D listings were AMS/filament bundles; 10W laser module not confirmed |

### Additional listing references checked

- Kobra 3 Max (unrepaired): https://www.ebay.co.uk/itm/396757973405 — seller says unrepaired, possible missing parts, no returns; excluded.
- Kobra 3 Max Combo: https://www.ebay.co.uk/itm/287474323251 — item specifics say Anycubic Kobra Max, not Kobra 3 Max V2; excluded.
- Kobra 4 combo (Opened–never used): https://www.ebay.co.uk/itm/278316144295 — not Used; excluded.
- Kobra S1 ACE 2 Pro Combo unrepaired return: https://www.ebay.co.uk/itm/920056753001 — condition unconfirmed, unrepaired, no returns; excluded.
- Kobra S1 Max listing: https://www.ebay.co.uk/itm/880010462485 — item specifics contradict title (Anycubic Kobra Max); package unclear; excluded.
- Kobra X generic/unrepaired examples: https://www.ebay.co.uk/itm/236887036030 and https://www.ebay.co.uk/itm/800357158511 — item specifics/model or repair condition unsuitable; excluded.
- Photon Mono M7 unrepaired: https://www.ebay.co.uk/itm/396639694476 — unknown damage/parts; excluded.
- Photon Mono M7 Pro unrepaired returns: https://www.ebay.co.uk/itm/398155847648 and https://www.ebay.co.uk/itm/800431136840 — condition unconfirmed, unrepaired; excluded.
- H2C with AMS 2: https://www.ebay.co.uk/itm/278304922535 — AMS 2 Pro/Vortek not confirmed; excluded.
- H2D AMS/filament bundle: https://www.ebay.co.uk/itm/188831640361 — no 10W laser module confirmed; excluded.
- Photon P1 official UK New page: https://uk.anycubic3d.com/collections/3d-printers/products/photon-p1-dual-color-and-dual-material-printing — £449 promotion, ships in 24h; existing UK New observation meant no duplicate row.

## LIVE coverage after import

Active + customer-visible 3D-printer scope (main_category/catalogue_category containing 3D):
- 199 products
- 198 with UK New
- 33 with UK Used
- 166 UK New only
- 1 UK Used only
- 0 neither
- 166 missing UK Used

Reviewed candidate set was rechecked: 25 reviewed; 23 still missing UK Used. Counts are a LIVE snapshot and may change with parallel worker imports.

## Operating rules and change boundary

- UK Used remains inspection/reference only and never affects automatic valuation; UK New remains the only automatic valuation evidence.
- UK GBP and UK sources only; exact product/package match; disclose condition, location, print hours, bundle contents, extras, missing accessories, fees, seller details, listing status and asking-versus-sold status.
- Do not treat unrepaired/unknown-condition customer returns as working-product Used benchmarks. Do not infer package contents from model name or substitute New/never-used listings for Used.
- Discontinued models must be labelled Discontinued where supported; never invent a current New price.
- No catalogue master data, valuation logic, schema, RLS, RPCs, Edge Functions, TEST data, LIVE Stripe or deployments changed.

## Structured project memory

Supabase message: `96622c16-5fa2-4ec4-8db3-02ea03bfcb83`, thread `tradeflow-research`.
