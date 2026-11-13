# TradeFlow LIVE — 3D-printer UK Used evidence review 04

- Date: 13 November 2026
- Branch: `production` (LIVE)
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Candidate review: next 25 active/customer-visible 3D-printer product/package gaps; two qualifying observations imported and read back.

## Imports

| Product / package | Item price | Source / status | Evidence ID |
|---|---:|---|---|
| Bambu Lab P1S — AMS Combo | £400.00 | Gumtree UK active; Snettisham, Norfolk; seller says barely used and excellent condition | `3d9945b0-7a84-464b-ac58-c55163c0616a` |
| Flashforge AD5X — Standard Printer | £300.00 | Gumtree UK active; Leicester; over 900 operating hours; good condition | `da99d21c-2831-4f18-b8dd-7d818b3e6851` |

### Source details and qualifications

- P1S listing: https://www.gumtree.com/p/printers-scanners/bambu-lab-p1s-with-ams/1804851357 — seller says standard AMS unit included, barely used, works perfectly; no print-hour count or detailed box contents. £400 is an asking price, not a completed sale; seller open to offers.
- AD5X listing: https://www.gumtree.com/p/printers/flashforge-ad5x-3d-printer-multi-color-enclosure-led-light-camera/1803371377 — seller reports 900+ hours. Includes enclosure, LED, camera, cool plate, textured plate (one side scratched), extra nozzle, rear poop bin and original box. These are extras outside the standard package and are not separately valued. £300 is an asking price, not a completed sale; seller open to offers.

## Held findings

- Bambu H2D search results included AMS 2 Pro / multiple-AMS bundles, not the Standard Printer package. H2D AMS 2 Pro Combo and H2D Pro + AMS HT already have used evidence.
- Bambu P2S listing was AMS 2 Pro package, not the catalogue Standard Printer.
- Creality Ender-3 V3 SE Gumtree detail pages returned HTTP 410 when opened; no record inserted.
- Dremel 3D45 and Sovol SV07 had active UK listings but no exact active/customer-visible master product row in the current 3D scope. No catalogue rows were created.
- Creality K2 Max and other model/package candidates were held where catalogue match or listing details were not established.
- ELEGOO Mars 4 Ultra result was explicitly brand new, so not classified as UK Used.

## LIVE coverage snapshot

Active + customer-visible products in 3D scope:

- 199 products
- 198 with UK New
- 30 with UK Used
- 169 UK New only
- 1 UK Used only
- 0 with neither
- 169 missing UK Used

Counts may include parallel worker activity.

## Rules and change boundary

UK Used remains inspection/reference only and never affects automatic valuation; UK New remains the only automatic valuation evidence. UK GBP and UK sources only. Match exact model/package and disclose condition, location, print hours, extras, listing status, asking-versus-sold uncertainty. Evidence URLs stored in `source_url`. No catalogue master rows, schema, valuation logic, RLS, RPCs, Edge Functions, TEST, LIVE Stripe or deployments changed.

## Structured memory

LIVE project-memory message: `1469764a-808e-4f68-bcad-d097e03614d6`, thread `tradeflow-research`.
