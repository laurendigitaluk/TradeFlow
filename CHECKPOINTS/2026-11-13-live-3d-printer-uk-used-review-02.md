# TradeFlow LIVE — 3D-printer UK Used evidence review 02

- Date: 13 November 2026
- Repository branch: `production` (LIVE)
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Table: `public.shared_market_evidence`
- Scope: 20 product gaps researched; six exact UK Used observations imported and read back.

## Six new observations

| Product / package | Recorded item price | Source and status | Evidence ID |
|---|---:|---|---|
| Anycubic Kobra S1 — Standard Printer | £220.00 | Gumtree UK; active; Lewisham, London; no combo, single-colour printer | `a8a1127b-4499-4735-9901-f3ffcd91e66a` |
| Elegoo Centauri Carbon 2 — CANVAS Combo | £230.00 | ELEGOO UK Pre-Owned; Good Used; Add to Cart | `2ad00f2c-be15-477b-86bd-24d47a0d275b` |
| Elegoo Neptune 4 Pro — Standard Printer | £138.80 | eBay UK; sold 11 Jul 2026; Lichfield | `6fd22ef7-3ccc-49d4-b296-8d47b9c997ae` |
| Flashforge Creator 5 Pro — Standard Printer | £560.00 | eBay UK; sold 11 Aug 2026; Skipton | `19add863-304c-43b4-b0c0-2e9019ae1055` |
| FLSUN T1-PRO — Standard Printer | £200.00 | eBay UK; sold 26 Oct 2026; Slough; Best Offer accepted | `a7cc0226-91d1-47c5-970f-2904d64b3166` |
| Bambu Lab A1 Mini — AMS Lite Combo | £211.06 | eBay UK auction; sold 16 Sep 2026; Chertsey; 8 bids | `53f03b7c-ed14-4a6c-8d3e-80d07d00a7d2` |

### Price and condition qualifications

- Gumtree Kobra S1 page was re-opened and the current displayed price was £220 (an earlier search preview showed £250). Seller states used only a few times, original packaging, no combo; condition is “As good as new”.
- ELEGOO UK page identifies the Centauri Carbon 2 Combo as Good Used, £230, and available to add to cart. Good Used means inspected, cleaned and repaired to full working order, with possible cosmetic wear. The page states pre-owned machines carry no warranty. Verify CANVAS feeder and accessories on receipt.
- eBay displayed totals include Buyer Protection fees. Recorded item amounts exclude those fees: Neptune 4 Pro £144.14 less £5.34; Creator 5 Pro £578.05 less £18.05; FLSUN T1-Pro £208.77 less £8.77; A1 Mini Combo £218.68 less £7.62.
- FLSUN T1-Pro was sold with Best Offer accepted; actual accepted price may differ from the displayed list amount.
- All sold prices are historical market references, not live asking prices.

## Held candidates

The other 14 candidates were not imported where package or condition was uncertain, listings had ended or become inaccessible, or no exact UK listing was verified. Examples:
- Kobra S1 ACE Pro listing did not prove the ACE 2 Pro package.
- Kobra X listing item specifics used a generic model label; other listings were unrepaired or package-uncertain.
- Creator 5 listing had ended by seller.
- H2S Gumtree listing returned 410; Vector 3D used listing was sold out.
- Kobra 4 auction had ended without a completed sale.

## LIVE coverage read-back

Active + customer-visible 3D-printer scope (main/category labels containing “3D”):

- 199 products
- 176 UK New only
- 22 with both UK New and UK Used
- 1 UK Used only
- 0 with neither
- 176 missing UK Used

This is a current snapshot and may include parallel worker imports. The prior 3D review added four UK Used observations across three products; this review adds six observations across six additional products. Total: 10 observations across 9 unique products.

## Operating rules and change boundary

- UK Used is inspection/reference only and never affects automatic valuation.
- UK New remains the only automatic valuation evidence.
- Use UK GBP and UK sources; exact model/package matching is required.
- Keep seller location, condition, fees, listing status, and uncertainty clear.
- Exclude buyer-protection fees from the underlying item price where separable. Disclose when a Best Offer accepted amount is unknown.
- No master catalogue rows, schema, valuation logic, RLS, RPCs, Edge Functions, TEST, Stripe or deployments were changed.

## Structured memory

LIVE project memory message:
`496501af-bfe4-4a2a-9c2a-6e3b3cfdc7ee` in `platform_ai_agent_messages`, thread `tradeflow-research`.
