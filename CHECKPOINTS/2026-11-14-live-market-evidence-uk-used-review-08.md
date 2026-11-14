# TradeFlow LIVE — UK Used market-evidence research Review 08

- Date: 14 November 2026
- Environment: TRADEFLOW LIVE
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Production branch: `production`
- Selection: next 25 active, customer-visible catalogue product/package records with active UK New and no active UK Used evidence; Pokémon excluded; previous Review 06 and Review 07 candidate sets excluded.
- Outcome: 25 researched, 3 UK Used observations imported and read back, 23 product/package candidates held, 0 duplicate source observations, 0 UK New inserts.
- Imported observations cover two distinct master product/package records: two AT2020 listings and one AVerMedia AM310 historical listing.

## Preflight

Read current LIVE Supabase state, structured project-memory thread `tradeflow-research`, production branch, both manuals, Review 07 checkpoint, Review 06 and Review 05 checkpoints, and recent project-memory/fix history. Retained exact model/package matching, source-key idempotency, item price separate from buyer fees, clear active/ended/sold status, no inferred bundle contents, no unrepaired/unknown-condition returns as working Used benchmarks, and no invented current New prices for discontinued products.

All 25 selected products already had active UK New evidence. No new-price research or UK New insert was needed.

## Imported observations

| Product / package | Item price | Source / status | Evidence ID |
|---|---:|---|---|
| Audio-Technica AT2020 — AT2020 Condenser Microphone | £50.00 | Gumtree UK active asking listing; East Finchley, London; as good as new | `a042b88c-9c7f-46ee-bd22-8c3a93481050` |
| Audio-Technica AT2020 — AT2020 Condenser Microphone | £60.00 | Reverb UK active asking listing; Farnham, Surrey; Very Good; free shipping | `cada3ff9-6f29-4569-b6b8-e2cdacdd5a46` |
| AVerMedia AM310 — AVerMedia AM310 USB Microphone | £9.99 | eBay UK ended 26 Oct 2026; 0 bids; historical asking reference, not a sale | `851506c1-5686-46c0-ba63-4f38b14b1ffd` |

### AT2020 — Gumtree

Source: https://www.gumtree.com/p/other-studio-equipment/audio-technica-at2020.-xlr/1509376545

- Exact AT2020 XLR version; listing explicitly says not USB.
- £50 asking price; seller says used a few times for voice-over and mint/as-good-as-new.
- Box, pouch, mic stand clamp and thread adapter included.
- East Finchley, London, UK. Seller Joe: 5/5 from 3 ratings, posting for 1+ years, 22 ads in a year, email verified.
- Active yesterday at capture; posted 1 day earlier; offers accepted. AnyVan delivery quote requires postcode, or seller can meet in London West End. No delivery amount shown. Not a completed sale.
- Source key: `gumtree:1509376545`.

### AT2020 — Reverb

Source: https://reverb.com/uk/item/102478601-audio-technica-at2020-large-diaphragm-cardioid-condenser-microphone-2010s-black

- Exact black, wired Audio-Technica AT2020 large-diaphragm cardioid condenser microphone.
- £60 asking price after an 8% reduction from £65; free UK shipping.
- Used–Very Good; seller says it has been used in a bedroom studio. No accessories itemised.
- Farnham, Surrey, UK. Seller Jairo's Gear Depot, joined Reverb in 2025, 8 seller reviews, marked Quick Shipper.
- Listed 16 days before 14 November 2026. Sold As-Described; returns restricted to materially different condition/description. Asking price, not a completed sale.
- Source key: `reverb:102478601`.

### AVerMedia AM310 — eBay

Source: https://www.ebay.co.uk/itm/860062992857

- Exact AVerMedia AM310 USB condenser microphone; item specifics show AVerMedia brand, MPN AM310, USB connectivity and condenser form factor.
- £9.99 item price; displayed £10.66 total included £0.67 Buyer Protection fee (fee excluded from stored item price).
- Bodmin, Cornwall, UK. Seller cornishchaos, private seller, 99.4% positive feedback, 215 items sold, joined November 2025.
- Listing ended 26 October 2026 at 21:27 BST with zero bids; no completed sale. This was the latest of repeated relistings by the same seller, so only one observation is retained.
- No accessories/bundle contents specified; no returns accepted; postage amount not shown and buyer must contact seller for options.
- Stored only as historical asking-price reference, not a completed sale or current offer.
- Source key: `ebay:860062992857`.

All three inserted records were read back by evidence ID. Confirmed master product/package, `uk_used`, source name, full non-null source URL, GBP price, condition, sales channel, listing status, detailed notes, active flag and source key.

## 23 held candidates

| # | Product / package | Reason held |
|---:|---|---|
| 1 | Aputure STORM 700x — Standard | UK Hygglo results were rental offers, not sale listings; no exact UK Used sale listing verified |
| 2 | Arca Swiss Monoball Z1 SP with Quickset Classic Device | Used Teamwork Photo result was Monoball Z Classic (different model); Z1+ SP with Quickset Fliplock result was New and not the exact Used package |
| 3 | Atomos A-Eye 4K-12X | No exact UK Used listing; UK retailer result was New |
| 4 | Atomos A-Eye HD-20X | No exact UK Used listing; results were New product pages |
| 5 | Atomos StudioSonic AIR | Recent product launch; no UK Used listing found |
| 6 | Audient EVO 4 | eBay Used listing ended 27 July; item specifics gave MPN EVO8 and 4 mic inputs despite title/model EVO 4. Reverb result was New; aggregator's used listing was no longer listed and direct link could not be resolved |
| 7 | Audio-Technica AT2020 — Standard | **Imported two independent exact UK Used observations** |
| 8 | Autel EVO II Dual 640T — Enterprise Bundle V3 | Results were US-located/New seller listings, not UK Used |
| 9 | Autel EVO II Dual 640T — RTK Rugged Bundle V3 | No exact UK Used package; results were New/international or accessories |
| 10 | Autel EVO II Dual 640T — Rugged Bundle V3 | UK SCAN page was New/awaiting ETA, not Used |
| 11 | Autel EVO II Dual 640T Enterprise — Enterprise Bundle V3 | Found US seller New listing, not UK Used |
| 12 | Autel EVO II Dual 640T RTK — RTK Rugged Bundle V3 | No exact UK Used listing verified |
| 13 | Autel EVO II Pro Enterprise — 6K Enterprise Bundle V3 | No exact UK Used package verified |
| 14 | Autel EVO II Pro RTK — 6K RTK Rugged Bundle V3 | UK Scan result was New/pre-order information, not Used |
| 15 | Autel EVO II Pro V3 — 6K RTK Rugged Bundle V3 | No exact UK Used package verified |
| 16 | Autel EVO Lite — Premium Bundle | No exact UK Used bundle verified |
| 17 | Autel EVO Lite — Standard Bundle | No exact UK Used bundle verified |
| 18 | Autel EVO Lite 640T Enterprise — Basic Combo | Results were current New retail, not Used |
| 19 | Autel EVO Lite 640T Enterprise — Plus Combo | Results were current New retail, not Used |
| 20 | Autel EVO Max 4T V2 — Standard | Used listing located in Bulgaria, not UK; held under UK-only rule |
| 21 | AVerMedia AM310 — Standard USB Microphone | **Imported one historical ended listing**; repeated relistings by the same seller not duplicated |
| 22 | AVerMedia AM350 — Standard USB Microphone | Only UK New retailer pages found; no exact UK Used listing |
| 23 | AVerMedia Live Gamer ULTRA 2.1 — Standard Capture Card | UK retailer result was New/in stock, not Used |
| 24 | Bambu Lab H2D — 40W Laser Full Combo | Used H2D listings did not establish the 40W laser module; AMS/filament bundles are not this package |
| 25 | Bambu Lab H2D — Engineering Bundle | Exact H2D + AMS 2 Pro + AMS HT Gumtree listing was already recorded under related H2D Pro master product/package `H2D Pro — AMS 2 Pro + AMS HT`; existing evidence ID `682c1d26-9e23-450b-b473-e7ca4fa348b1`, source key `gumtree:1804119344`. No duplicate row was inserted and no master data was changed; candidate remains for later package reconciliation |

## Current LIVE coverage snapshot

Active + customer-visible master products excluding Pokémon:

- 28,370 total products
- 1,863 with active UK New
- 1,741 with active UK Used
- 606 with both
- 1,257 UK New only
- 1,135 UK Used only
- 25,372 with neither
- 26,629 missing UK Used

Coverage may change with parallel workers.

## Operating rules and change boundary

- UK New remains the only evidence used for automatic valuation; UK Used remains reference/inspection only.
- UK GBP and UK sources only. Exact manufacturer/model/package match. Keep item price separate from platform fees; disclose condition, location, seller, listing/sale date, status, bundle contents, missing accessories, delivery and caveats.
- Ended/zero-bid listings may be stored only as clearly labelled historical asking-price references, never as completed sales.
- Do not infer bundle contents, substitute another model/package, or import rental listings as Used sale evidence.
- Do not mark products Discontinued unless verified; never invent a current New price.
- No catalogue master data, valuation logic, schema, RLS, RPCs, Edge Functions, TEST data, LIVE Stripe or deployments changed.

## Structured project memory

Supabase message: `b028ff53-25ed-43d8-abf4-a3b4b817ebb0`, thread `tradeflow-research`.
