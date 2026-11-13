# TradeFlow LIVE checkpoint — 13 November 2026

## Retrospective UK Used nearest-match review 13

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- Added and read back one active UK Used GBP observation for DJI Mini 3 Pro generic Standard Package: £380, Gumtree, West End, Glasgow.
- Evidence ID: `1edb4a59-375c-42ff-964d-f731e931e770`.
- Source: https://www.gumtree.com/p/drones/dji-mini-3-pro-drone-/1804815846
- Seller says Good condition, never crashed/dropped, original box; lens hood absent. Controller, batteries and package extras not specified; closest generic Standard Package match only. Current asking price, not sold.
- Idempotency key: `gumtree:1804815846`.
- Review coverage baseline before import: 541 active customer-visible drone products; 316 missing UK Used, 291 missing UK New. Re-read aggregate coverage before subsequent batch because this import should reduce missing UK Used by one.
- UK Used is inspection-only; UK New remains the only automatic valuation evidence.
- No schema, RLS, RPC, Edge Function, catalogue master/package, valuation or Stripe changes.
- Both TradeFlow manuals appended with Review 13.

## Research quality notes

- Do not infer controller variant or Fly More package from the model name. Keep the generic Standard Package nearest-match caveat visible.
- Other Mini 3 Pro listings were held where controller/package contents were unclear. Drone Atlas recent-sales aggregate was context only, not imported as a listing observation.
