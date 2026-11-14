# TradeFlow LIVE checkpoint — UK Used market-evidence Review 09

- Date: 14 November 2026
- Environment: TRADEFLOW LIVE
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- GitHub repository/branch: `laurendigitaluk/TradeFlow` / `production`

## Preflight

Read current LIVE catalogue/evidence state and schema, recent structured project memory, both production manuals, Review 08 and Review 07 checkpoints, earlier 3D-printer checkpoints, and Review 13 nearest-match checkpoint/commit. Previous fixes retained: exact manufacturer/model/package matching; no suffix/generation substitution; source URL/key idempotency; item price separated from platform fees; disclose status, condition, location, seller, delivery, bundle contents and caveats; no rental listings; no inferred package contents; historical asking price is not a completed sale; UK Used is reference-only; no invented New prices for discontinued products.

Selected the next 25 active/customer-visible products without active UK Used evidence after the prior Review 08 alphabetical boundary (Bambu Lab), excluding Pokémon. All 25 already had UK New evidence.

## Imported and read back

| Product/package | Price | Source/status | Evidence ID |
|---|---:|---|---|
| Benro B4 Triple Action Ball Head | £81.00 | Wex Photo Video, in stock, Very Good (9-) | `ce1e6a08-3f51-47d2-ad55-3eac2aaf9752` |
| Benro GH5CMINI Gimbal Head | £279.99 | London Camera Exchange, Derby, Excellent (five-star) | `87e01205-7c4d-4229-9b33-b7e200ae9323` |

### Source details

1. Wex Photo Video, product code 3371962 / MPN BRB4: https://www.wexphotovideo.com/benro-b4-pu70-magnesium-ball-head-used-3371962/
   - Exact Benro B4 head. Very Good (9-), minor marks. Includes brown box and PU70 Arca quick-release plate; original box and manual absent. PU70 is an extra, not a different head. Wex Certified inspection/testing, 12-month warranty, 30-day returns, free DPD standard delivery in 2–3 days. Wex location shown as Norwich, Norfolk; dispatch warehouse not separately identified. Active in-stock asking price, not a sale; no sale date.
   - Source key: `wex:3371962`.

2. London Camera Exchange item 213980: https://www.lcegroup.co.uk/Used/Benro-Benro-GH5C-Mini-Carbon-Fibre-Gimbal-Head_498972.html
   - Exact Benro GH5CMINI match: listing title GH5C Mini and official model SKU: https://uk.benroeu.com/gh5cmini-gimbal-head-carbon-fibre/
   - Five-star Excellent condition. Carbon gimbal head, approx. 1 kg, 30 kg payload, 3/8-16 base, bubble level and Arca-Swiss compatibility. No case/plate/accessories itemised; none assumed. Derby branch, six-month warranty on main hardware. Next-working-day DPD offered, free for basket value above £100. LCE advises stock confirmation; used items are not reserved until order confirmation. Active asking price, not a sale; no sale date.
   - Source key: `lce:498972`.

Both source URLs and keys were checked globally for duplicates before insert. Both rows were read back by evidence ID and verified for exact master product/package, `uk_used`, source name, non-null URL, GBP price, condition, channel, availability, notes, active flag and source key.

## Review totals

- Candidates researched: 25
- Imported observations: 2
- Distinct products/packages imported: 2
- Held candidates: 23
- Duplicate inserts: 0
- UK New inserts: 0
- Discontinued labels applied: 0 (none verified discontinued)

## Held candidate dispositions

### Bebob
- V150microC — found V150MICRO 143Wh listing without C suffix/USB-C PD3 confirmation; official V150microC is USB-C PD3. Variant not established.
- V98 — found V98MICRO only, not exact V98.

### Benro
- A373FBS8PRO — matching eBay item was US-located/USD; CVP alternative was A373FBS6PRO (S6PRO head), not S8PRO.
- A573TBS6PRO — no exact UK Used listing.
- C373FBS8PRO — no exact UK Used listing.
- GH2N — found GH2 (different model); GH2N price tracker only had historical Wex data without direct listing.
- HD1A — CameraWorld page was New.
- HD2A — price aggregator had historic Wex used values (£38/£50, 27 February 2026) but no original listing URL/current listing.
- MCT28AFS2PRO — MCT28AF listing did not confirm S2PRO head.
- Polaris Astro Module — no exact UK Used listing.
- Polaris Timelapse 2-Axis Head — current UK results were New.
- S6PRO Video Head — MPB used page was out of stock and no price/offer shown.
- B4 and GH5CMINI imported above.

### BetaFPV
- Air65 — Air65 II used result was a different generation.
- Air75 — only Used result was an entire FPV bundle with RadioMaster Pocket, Fatshark Scout goggles/module, three batteries, charger, spare motors, frames, canopies, antennas and props. £269.25 + £7 shipping, Yeovil. Bundle price cannot be allocated to standalone Air75.
- Air75 II — New frame/accessory and New starter-kit results only.
- Aquila16 — only relevant UK eBay listing was New and China-located.
- Aquila16 FPV Kit — New overseas listings only.
- Aquila20 HD — no exact UK Used listing.
- Cetus — result was Cetus Pro, wrong model.
- Cetus X — no exact UK Used listing.
- Cetus X HD — no exact UK Used listing.
- Meteor65 Pro II O4 — New overseas listings/accessories only.
- Meteor65 Pro O4 — no exact UK Used listing.

## Useful held listing references

- Bebob V150MICRO: https://www.ebay.co.uk/itm/236703420254
- Bebob V98MICRO: https://www.ebay.co.uk/itm/127746605873
- Benro A373FBS8PRO US listing: https://www.ebay.co.uk/itm/115024179101
- Benro HD1A New: https://www.cameraworld.co.uk/benro-hd1a-3-way-head.html
- Benro GH2N historic price tracker: https://www.camerapricebuster.co.uk/Benro/Benro-Heads/Benro-GH2N-Gimbal-Head
- Benro HD2A historic price tracker: https://www.camerapricebuster.co.uk/Benro/Benro-Heads/Benro-HD2A-3-Way-Head
- Benro MCT28AF without S2PRO confirmation: https://www.ebay.co.uk/itm/365694253484
- BetaFPV Air75 complete bundle: https://www.ebay.co.uk/itm/198607616518
- BetaFPV Cetus Pro (wrong model): https://www.ebay.co.uk/itm/137540813225
- BetaFPV Aquila16 New/China: https://www.ebay.co.uk/itm/389385296789
- BetaFPV Meteor65 Pro II O4 New/China: https://www.ebay.co.uk/itm/298506604085
- BetaFPV Air65 II sold listing (wrong generation): https://www.ebay.co.uk/itm/206498703346

## LIVE coverage snapshot after imports

Active + customer-visible master products excluding Pokémon:
- 28,370 total
- 1,863 with active UK New
- 1,743 with active UK Used
- 608 with both
- 1,255 UK New only
- 1,135 UK Used only
- 2 with neither
- 1,257 missing UK Used

Snapshot may change with parallel workers.

## Rules and change boundary

- UK New alone affects automatic valuation; UK Used is reference/inspection only.
- UK GBP and UK sources only. Exact manufacturer/model/package matching. Disclose item price separately from fees, seller, location, condition, status, sale date, shipping, bundle contents and caveats.
- Do not infer model suffixes, generations or package contents. No rental, overseas, New, accessory-only or aggregator-only observations as exact UK Used listings.
- Ended listings are historical asking-price references only, never completed sales. Verify discontinued status before labelling Discontinued; never invent current New prices.
- No catalogue master data, valuation logic, schema, RLS, RPCs, Edge Functions, TEST data, LIVE Stripe or deployments changed.

## Structured project memory

Supabase message: `aa8a49a5-0785-480c-86eb-55cdca783e4b`, thread `tradeflow-research`.

## Documentation

Both `docs/TRADEFLOW-SYSTEM-HANDBOOK.md` and `docs/TRADEFLOW-AI-OPERATING-MANUAL.md` appended with Review 09.
