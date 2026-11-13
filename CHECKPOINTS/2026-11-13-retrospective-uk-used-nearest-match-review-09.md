# TradeFlow LIVE checkpoint — 13 November 2026

## Retrospective UK Used nearest-match review 09

Three verified UK Used GBP observations were inserted and read back in `public.shared_market_evidence`:

| Product | Price | Source/location | Evidence ID | Caveat |
|---|---:|---|---|---|
| DJI Mini 4 Pro Fly More Combo (DJI RC 2) | £550 | Gumtree, Hazel Grove, Manchester | `274da652-b805-41f7-9221-5b0500895368` | Three batteries listed; charging hub not explicitly listed |
| DJI Mini 4 Pro Fly More Combo (DJI RC 2) | £550 | Gumtree, Mirfield, West Yorkshire | `e694de4e-1992-4afc-bc73-23310c8503ee` | Three batteries and charging hub listed; about 27 minutes flight, battery cycles 2/2/1 |
| Potensic ATOM 2 PTD 1 Fly More Combo | £186.58 | eBay UK, seller located London | `ff504ae1-3d7f-4fe8-9ab6-de625a209685` | Listing title says Fly More; package contents not itemised in retrieved details; postage separate |

All three are current asking prices, not sold prices. Individual source URLs and notes are stored on each evidence row. No duplicate observations were added. No catalogue master/package rows, valuation logic, schema, RLS or Edge Functions changed.

## Coverage after review 09

541 active customer-visible drone products: 173 neither, 143 UK New only, 118 UK Used only, 107 both; 291 missing UK New and 316 missing UK Used. Counts are unchanged because all three observations deepen Used evidence on products already covered.

## Operating rules retained

- UK Used evidence is inspection/click-through only; automatic valuation remains UK New-only.
- UK GBP only. Preserve individual source URLs, seller location, condition, package differences, current/sold status and fee/postage caveats.
- Closest sensible model/package match is acceptable when differences are explicitly disclosed; never claim unverified accessory equivalence.
- LIVE is authoritative; do not sync TEST data into LIVE.
