# Batch 03 AKASO / Casio Follow-up — 12 November 2026

## Scope
TradeFlow LIVE only. Continued the existing Batch 03 research after the 18:42 UTC checkpoint. Used existing exact master products and the established direct LIVE evidence insertion path. No schema, master-catalogue, valuation-function, TEST or Stripe changes.

## Verified imports
| Product / package | UK source | Price | Evidence type | Evidence ID |
|---|---|---:|---|---|
| AKASO Brave 6 Plus Standalone | Cash Converters UK, item 048500408933 | £79.99 | UK Used | `60aabc70-c2cf-485d-a548-ad6245b3fb9c` |
| AKASO V50 X Standalone (camera only) | eBay UK, item 189041389978 | £36.75 | UK Used | `343ef1d7-64df-47bf-bb0f-3d920069df9a` |

Both evidence rows were read back from `public.shared_market_evidence`, active, GBP, UK Used, and matched existing master product IDs:
- Brave 6 Plus: `8c0da10d-cd63-4271-a261-ae75e87950a8`
- V50 X: `ac958d8e-cb0f-4936-9a0e-d7e9d0da92c1`

Source links:
- https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/waterproof--action-cameras/action-camera/048500408933
- https://www.ebay.co.uk/itm/189041389978

Condition/package notes preserved. Brave 6 Plus is described by Cash Converters as functions with light cosmetic wear, supplied with two batteries and charger, 12-month warranty. V50 X is camera-only; seller condition detail was not specified in captured listing.

## Casio EX-FR200 follow-up
The Gumtree UK £116 EX-FR200BK lead remains inactive historical reference because the direct listing returned HTTP 410. The two other direct EX-FR200 eBay listings found in the follow-up were Japan-located, so they were excluded from UK evidence. No substitute exact UK domestic listing was verified.

## Reconciliation after import
- Batch 03: 15 observations, 14 active (7 UK New, 7 UK Used), 1 inactive.
- Batches 01–13: 275 observations, 267 active (142 UK New, 125 UK Used), 8 inactive.
- Global LIVE `shared_market_evidence`: 4,820 total, 4,758 active, 62 inactive.

## Rules retained
- UK GBP only; New and Used remain separate.
- Historical UK GBP price references remain retained even when unavailable/ended, with availability recorded. Do not bulk-deactivate these.
- UK Used evidence is reference-only and does not enter automatic valuation.
- No change to valuation logic.
- No TEST data or Stripe changes.

## Dashboard / documentation
LIVE dashboard status message inserted into `tradeflow-research`:
`1c75fbac-5171-453b-8b1c-64cbb465d9e7`.

Updated:
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`

