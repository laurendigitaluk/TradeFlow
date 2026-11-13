# TradeFlow LIVE evidence checkpoint — 13 November 2026

- Repository: `laurendigitaluk/TradeFlow`
- Branch: `production` (LIVE)
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Evidence table: `public.shared_market_evidence`
- Research scope: UK GBP only; no TEST or Stripe writes.

## Verified UK Used imports — 3D printers

Four active UK Used observations were inserted and read back across three exact master products:

| Product / package | Price | Source / status | Evidence ID |
|---|---:|---|---|
| Bambu Lab A1 Mini — Standard Printer | £124.58 | eBay UK; sold 7 Nov 2026; Rowley Regis | `dedf7fee-2ebe-4a5e-b22a-0b5899cfbcff` |
| Flashforge Adventurer 5M — Standard Printer | £233.08 | eBay UK; active Buy It Now; Chelmsford | `b3fc4f42-62b6-46cc-a276-bd9799dbe40d` |
| Flashforge Adventurer 5M — Standard Printer | £103.92 | eBay UK; sold 2 Nov 2026; Coddington/Newark | `cdd2bc87-40a6-4477-8188-e091d169a27b` |
| Elegoo Centauri Carbon 2 — Standard Printer | £291.80 | eBay UK; active Buy It Now; Honiton; seller reports 444 operating hours | `1845c944-9171-4591-b65c-a32904f6224e` |

eBay displayed prices on the sold A1 Mini and Adventurer 5M listings include Buyer Protection fees; accepted Best Offer amounts may differ. Active listings are asking prices, not completed-sale prices. The Centauri Carbon 2 listing did not establish the CANVAS combo, so it was mapped to Standard Printer only. All UK Used observations remain inspection/reference-only.

## Drone second-pass Batch 39 — UK New

Three UK New observations were inserted and read back:

| Product / package | Price | Source / availability | Evidence ID |
|---|---:|---|---|
| DJI Mavic 3 Classic — Drone Only | £1,049.00 | Clifton Cameras; Now Available / add to basket | `8f2b43a6-9e3f-4bc2-b074-89c1e6e751de` |
| DJI Mavic 3 Classic — Standard Package (DJI RC-N1) | £1,119.00 | Clifton Cameras; awaiting stock, orders accepted, usually 5–7 days | `3165710b-5d3f-41f5-bd17-cc09f2351bfb` |
| DJI Mavic 3 Thermal — Standard Package | £4,839.00 | Drone Safe Store; explicitly marked DISCONTINUED; historical price only | `6a55af88-32ef-4647-92dd-c0e83037797f` |

The Mavic 3 Thermal observation is not current purchasable stock. The retailer page retains the historic VAT-inclusive UK price but labels the product discontinued. This follows the rule to mark confirmed discontinued variants as Discontinued rather than present an old price as current.

### Duplicate prevention and held research

- DJI Mavic 3 Enterprise Standard Package and DJI Mavic 3 Pro Fly More Combo (DJI RC Pro) already had UK New observations from the preceding drone batch; no duplicate insert.
- Mavic 3 Pro Cine UK listings found were for the Cine Premium Combo, while the master candidate was Standard Package; held as a package mismatch.
- Skydio confirms consumer Skydio 2+ Starter Kit sales are discontinued while the Enterprise kit remains in production. No verified UK GBP Starter Kit price was found; no numeric row was invented.
- SCAN UK marks DJI Mavic 2 Pro, Mavic 2 Zoom, original Mavic Mini, Yuneec Q500 4K and Yuneec Typhoon H End of Life/no longer purchasable. No suitable exact UK new price was available from those pages.
- Holy Stone HS175D manufacturer UK page displayed £130 but was Sold Out; no current stock price imported.
- Mini 2 sources were body/accessory pages or sold-out stock, not an exact complete Fly More Combo / RC-N1 package price. Remaining candidates were held where exact UK package price/availability was not verified.

## LIVE read-back

Current active + customer-visible Drone catalogue snapshot, including main_category values `Drones` and `Drone`:

- 541 products
- 173 with neither UK New nor UK Used
- 142 UK New only
- 115 UK Used only
- 111 with both
- 288 missing UK New
- 315 missing UK Used

This snapshot includes parallel research imports by other workers. Do not attribute all movement from the prior checkpoint to Batch 39 alone.

## Operating rules preserved

- UK New is the only evidence type used for automatic valuation.
- UK Used is inspection/comparison/source-click-through only and never affects automatic valuation.
- UK GBP and UK sources only; exact model/package match preferred.
- Notes disclose package differences, seller location, condition, extras, sold/current status and limitations.
- Confirmed discontinued product variants must be labelled Discontinued in UK New evidence. Retain a historical price only when a reliable UK listed price is available. Never invent a price or use £0 to force a discontinued status.
- No catalogue master/package rows, schema, valuation functions, RLS, RPCs, Edge Functions, tenant/customer/transaction data, TEST, Stripe or deployments were changed.

## Structured memory

LIVE structured project memory was updated in `platform_ai_agent_messages`, thread `tradeflow-research`, message:
`4725b94f-adb5-449b-b23a-b0577823e376`.
