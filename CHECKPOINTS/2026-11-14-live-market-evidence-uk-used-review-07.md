# TradeFlow LIVE — UK Used market-evidence research Review 07

- Date: 14 November 2026
- Environment: TRADEFLOW LIVE
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Production branch before documentation update: `c70c8022135146fd1982b874ce94ef3e6644b1b3`
- Selection: next 25 active, customer-visible catalogue product/package records with no active UK Used evidence; Pokémon excluded; global catalogue, all categories.
- Outcome: 25 researched, 1 imported and read back, 24 held, 0 duplicate inserts, 0 UK New inserts.

## Preflight completed

Read current LIVE catalogue/evidence state and current project-memory thread `tradeflow-research`; inspected the production branch, both manuals, Review 05 and Review 06 checkpoints, latest structured project-memory entry, and recent production commit history. Retained prior fixes/rules: exact model/package match, idempotent source keys, separate item price and Buyer Protection fee, no package inference, no unrepaired/unknown-condition returns as working Used evidence, and clear out-of-stock/sold status. No master data or application behaviour changed.

## Imported observation

| Product / package | Price | Status | Evidence ID |
|---|---:|---|---|
| Ansmann NP-FW50 — Ansmann Sony NP-FW50 Camera Battery | £15.00 GBP | CameraWorld UK used listing; out of stock at capture; historical page-price reference only | `55771227-11ef-42a5-8cfd-04b22655db12` |

**Source:** [CameraWorld — Used Ansmann NP-FW50 Battery](https://www.cameraworld.co.uk/used-ansmann-np-fw50-battery-447.html) — SKU B002022399; source key `cameraworld:B002022399`.

- Exact Ansmann NP-FW50 manufacturer/model/package match.
- Retailer identifies it as secondhand, Excellent+ condition and full working order; page says used equipment is checked.
- Page explicitly says Out of Stock. £15 is the displayed retailer page price, not a completed sale; no sale date shown. Not currently purchasable.
- Single battery; no accessory bundle contents specified.
- Stock location not disclosed; CameraWorld lists click-and-collect at London and Stevenage.
- No item-specific delivery charge shown; site free UK delivery threshold is £150.
- Used returns policy: 14 days. Six-month used guarantee applies only to items over £50, so not this £15 battery.
- Stored as historical/out-of-stock reference only, not current available stock.

The insert returned the record. Separate read-back verified evidence ID, exact master product, `uk_used`, source name, full non-null source URL, GBP price, condition, channel, availability, notes, active status and source key.

## 24 held candidates

| # | Product / package | Reason held |
|---:|---|---|
| 1 | 8BitDo Pro 3 Wireless Controller for Nintendo Switch 2 — Purple | Only listing found was ended by seller due to listing error; generic grey Pro 3 with Nintendo Switch compatibility, not purple Switch 2 variant |
| 2 | AKASO Brave 4 — With SD Bundle | Two sold Brave 4 listings checked; neither confirms an SD card, so package does not match. One also has a missing lens bubble cover |
| 3 | AKASO Brave 4 Elite — Standalone | No exact Used listing; generic Brave 4 is not Elite |
| 4 | AKASO Brave 4 Pro — Standalone | Results were new/damaged-box or generic, not exact Used |
| 5 | AKASO Brave 7 — Motorcycle Bundle | No exact motorcycle bundle contents; Brave 7 LE listings are not this model/package |
| 6 | AKASO Brave 7 — Standalone | Results were Brave 7 LE or item-specific model-ambiguous |
| 7 | AKASO Brave 7 — Super Bundle | No exact Used bundle listing |
| 8 | AKASO Brave 7 LE — Motorcycle Bundle | Sold Brave 7 LE listing specified charger only, not motorcycle kit; Best Offer accepted so actual accepted price unknown |
| 9 | AKASO Brave 8 Lite — Standalone | No exact UK Used listing |
| 10 | AKASO Keychain 2 — Standard | No exact UK Used listing |
| 11 | AKASO Keychain 3 — Standalone | No exact UK Used listing |
| 12 | AKASO V50 X — With SD Bundle | No exact listing with SD contents confirmed |
| 13 | AKASO V50 X Cube — Standalone | No exact UK Used listing |
| 14 | amaran 150c — Standard | No exact UK Used listing |
| 15 | amaran 300c — Standard | Gumtree page says Good working order in description but shows FREE and condition New; eBay sold result returned HTTP 404 |
| 16 | Angelbird AV PRO CFexpress Type B SE MK2 1TB | Sold 1TB AV PRO SE listing lacked MK2 identifier and showed CFexpress 2.0; generation mismatch |
| 17 | Angelbird AV PRO CFexpress Type B SE MK2 2TB | No exact UK Used listing |
| 18 | Ansmann NP-F970 | Sony/Neewer-compatible battery results are not exact Ansmann-branded product |
| 19 | Ansmann NP-FM500H | Found Sony-branded Used battery, not Ansmann |
| 20 | Ansmann NP-FZ100 | Found Sony-branded Used stock, not Ansmann |
| 21 | Anycubic Kobra S1 hardened-steel 0.4 mm replacement hotend | Only new aftermarket parts found |
| 22 | Anycubic Kobra S1 0.4 mm replacement hotend | Only new replacement parts found |
| 23 | Anycubic Kobra 3 Max V2 — 4-Color Combo | ACE Pro-only accessory and older Kobra Max listings do not establish a complete V2 4-colour combo |
| 24 | Anycubic Kobra 4 — ACE 2 Pro Combo | Kobra S1 combo listing is a different printer; ACE Pro-only accessory is not a Kobra 4 combo |

### Listing references checked

- 8BitDo generic Pro 3 ended listing, £36.83, London, grey and Nintendo Switch compatibility, ended by seller due to error: https://www.ebay.co.uk/itm/206500949515
- AKASO Brave 4 sold 20 Aug 2026, displayed £32.96 including £1.96 Buyer Protection, Liverpool, seller tinyuser13; Excellent condition but lens bubble cover missing; SD card not confirmed: https://www.ebay.co.uk/itm/287516236807
- AKASO Brave 4 sold 16 Aug 2026, £29.95 plus Buyer Protection not itemised, Harrogate, seller Thriftyness; Good condition, two batteries and assorted accessories; SD card not confirmed: https://www.ebay.co.uk/itm/158188432347
- AKASO Brave 7 LE sold 11 Oct 2026, displayed £96.04 including £3.79 Buyer Protection, Bristol, seller aglon_r; Best Offer accepted, actual accepted price unknown; charger specified, motorcycle kit not specified: https://www.ebay.co.uk/itm/278445005105
- AKASO Brave 7 LE business listing showed £215.99, seller I L0VE TECH, London, tested/fully working, but no motorcycle bundle contents: https://www.ebay.co.uk/itm/127390133881
- Angelbird 1TB AV PRO SE sold listing, £314.39, Malvern, seller memorywolf, Like New/100% Health; item specifics CFexpress 2.0 and no MK2 identifier: https://www.ebay.co.uk/itm/406979732382
- amaran 300c Gumtree listing description and page metadata conflict on price/condition: https://www.gumtree.com/p/lighting-studio/amaran-300c-studio-light-with-stand-good-condition/1803544855
- Ansmann NP-FW50 imported exact listing, out of stock, £15 displayed, Excellent+, full working order: https://www.cameraworld.co.uk/used-ansmann-np-fw50-battery-447.html

No rows were created for held candidates. No UK New observation was necessary; all 25 selected products already had UK New evidence. No product in this batch was verified as discontinued, so no discontinued label was applied and no current New price was invented.

## Current LIVE coverage snapshot

Active + customer-visible master products excluding Pokémon:
- 28,370 total products
- 1,863 with active UK New evidence
- 1,739 with active UK Used evidence
- 604 with both
- 1,259 UK New only
- 1,135 UK Used only
- 25,372 with neither
- 26,631 missing UK Used

Reviewed batch after import: 25 candidates; 1 now has UK Used; 24 still missing UK Used. Snapshot may change with parallel workers.

## Operating rules and change boundary

- UK New is the only evidence type used for automatic valuation; UK Used remains reference/inspection only.
- UK GBP and UK sources only. Match exact model, manufacturer and package/variant. Disclose listing status, sale date where relevant, seller, location, condition, fees, accessories/bundle contents and uncertainty.
- An out-of-stock page may be retained only as clearly labelled historical/out-of-stock reference; never present it as available stock or a completed sale.
- Do not substitute compatible-brand products for exact manufacturer-branded master products, infer missing bundle contents, or treat New/Opened–never used as Used.
- Do not invent a current New price for discontinued products; label Discontinued only when verified.
- No catalogue master data, valuation logic, schema, RLS, RPCs, Edge Functions, TEST data, LIVE Stripe or deployments changed.

## Structured project memory

Supabase message: `d8cb7e54-1dcd-4ff0-874a-903a872b524f`, thread `tradeflow-research`.
