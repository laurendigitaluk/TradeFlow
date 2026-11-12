# TradeFlow LIVE — Scheduled Market Evidence Project Memory, Batch 07

**Date:** 2026-11-12  
**Branch:** production  
**Environment:** LIVE only  
**Detailed checkpoint:** CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-07.md  
**Checkpoint commit:** 824a9d51fd0bcce30eea2ef43011a8579d09004c

## Current state

Batch 07 researched 20 new active LIVE catalogue master products with no active shared_market_evidence. Product UUIDs, source URLs, observed price/currency, condition, availability, package contents, uncertainties and RED VERIFY instructions are recorded in the detailed checkpoint.

Products researched:

1. Shure — MV88+ Video Kit — 3711e70b-84a6-4300-827f-4fd8d3af8f58
2. Skydio — Skydio 2+ / Sports Kit — 384cb481-e8fd-47b1-9d12-befdf5a4a3f1
3. Sony — SRG-XB25 — 3bca1bc7-000e-4c7c-98ac-bdd212a36617
4. Hubsan — H501S / H501S X4 Air — 3ec6cf28-d691-4e70-a15a-b90f8c5ebf3d
5. Nikon — AF-S DX Nikkor 18-55mm f/3.5-5.6G VR — 3f8caa8b-3436-4124-badb-63fb16b3b272
6. Nikon — F2 Photomic SB — 42ab017d-69c0-4401-b7dc-9eea35d84722
7. Skydio — X10 / Ready Case Kit — 43025083-45ca-41ba-9997-acd9fc1135f5
8. Z CAM — E2-M5G — 445e129d-8513-46ca-87d6-62988841b4fa
9. Sony — HXC-D70 — 44ac30d9-9985-4ebb-8548-3caced8ee039
10. Manfrotto — Video Alu Tripod with 500X Fluid Head — 4534d392-cfcf-4ac3-a017-4dad979267bd
11. Walkera — DEVO-10 Radio + RX1002 receiver — 494b619b-5354-4cc4-aee9-d9ac3c0930b8
12. Sony — DSR-400 — 4a0496fd-d9ce-4dc2-8b47-4759e76b5fe6
13. Z CAM — ZBlade 4TB — 4d423c23-4ff3-4a9a-beb5-039ff4def019
14. Sony — PMW-F55 — 4ecf0857-2b22-49bd-8755-9845a5c24dd4
15. Nikon — S3M — 4f7e69c9-9638-4edd-bdff-9be4772a5a50
16. Z CAM — IPMAN Gemini Pro — 4fd9b673-e12f-4087-9f10-312ac85ef170
17. Sony — HDCU-3500 — 4fedfd46-1dc5-4b63-a27b-15e0bf0cf108
18. Leica — M11 Monochrom — 511f350a-d1c9-4aca-9f6d-b04fe5a5a3d0
19. Sony — HDC-5500RV — 5138a9c6-5f19-41c4-8347-64014bfc8c21
20. Parrot — Jumping Race Max — 52023314-a46b-4652-b6e9-eba5c72a9ed0

## Selection and exclusion controls

Before selection, the run read scheduled checkpoint files 02–06 and all available matching project-memory files (02, 04, 05 and 06). The batch-03 checkpoint exists but its matching project-memory file is absent from production. The scheduled checkpoint directory contained batches 02–06 at selection time.

The dynamic selection query:
- Excluded all UUIDs present in scheduled checkpoints 02–06 (142 unique UUIDs extracted).
- Excluded the 20 product IDs in the single outstanding manual AI research prompt (status ready).
- Excluded all 10 current LIVE needs_research queue candidates by manufacturer/model or linked master product ID.
- Excluded products with active shared_market_evidence.
- Used no fixed SQL OFFSET.

The manual AI research prompt table contained one completed prompt and one ready prompt. Every selected product was outside the ready prompt's 20 product IDs.

Immediately before research, every selected product had 0 active shared_market_evidence, 0 matching outstanding queue candidates and 0 outstanding manual prompt matches. The same recheck after research returned zero for all 20.

## Owner authentication and staging

Checked LIVE owner-auth context before any queue write and again after research:
- current_user = postgres
- auth.uid() = null
- auth.role() = null
- public.platform_cloud_ai_owner_check() = false

No queue staging was attempted. No direct table write, impersonated claim, RLS bypass or alternate write path was used. The 20 researched candidates remain in the detailed checkpoint, not in the dashboard queue.

Queue status snapshot after research:
- imported: 28
- needs_research: 10
- rejected: 43
- pending_review: 0

## Research rules and findings to preserve

- Keep sold-out, ended, backorder, stale, unverified and no-price source links.
- Never invent a price or convert non-GBP currencies into GBP. Leave GBP price blank and record source-displayed currency/amount in notes.
- Record exact package and condition. Do not assign a bundle price to a body-only product or a standalone component.
- Prefix uncertain notes with RED VERIFY and state what Gary should check.
- Shure MV88+ Video Kit has several exact UK retail offers (£233–£259); verify current checkout and stock.
- Skydio 2+ Sports Kit is discontinued for consumer sale. The $550 USD Sports Upgrade is an accessory upgrade, not the complete kit; the Skydio shop says it sells only in the US and Canada, so there is no verified UK offer. The X10 Ready Case guide confirms contents but no price; Maverick's $17,900 USD Starter Kit is a different package and its direct page fetch returned 404.
- Sony SRG-XB25 has conflicting UK leads (£1,452 inc VAT on a Converge result whose page is now 410 Gone; £2,799.98 at SCAN awaiting ETA).
- Hubsan H501S has current/ended/new used-market leads with materially different condition and package; distinguish single unit, range extender and two-drone lot. OnBuy's search result showed £543.15 plus delivery for a new BNF package but the direct page returned 404 and its July delivery estimate is stale.
- Nikon AF-S DX 18-55mm f/3.5-5.6G VR has exact used UK stock from MPB and LCE; do not mix VR, VR II or AF-P variants.
- Nikon F2 Photomic SB exact DP-3 listings are mostly Japan-based; UK £660 listing ended with zero bids and is not a completed sale.
- Skydio X10 Ready Case official contents are documented, but no exact UK price was found; Maverick's $17,900 Starter Kit is a different package.
- Z CAM E2-M5G Voosestore page is Sweden-facing and displays SEK 58,995; no GBP conversion. Current Z CAM About page lists E2 Mark II products but not E2-M5G; do not infer discontinued status solely from that omission.
- Sony HXC-D70 £4,000 listing is a complete used camera channel, not the camera head alone.
- Manfrotto MVK500XAM exact kit is £369 inc VAT at CVP, but stock is in the EU warehouse.
- Walkera DEVO-10 page includes RX1002 and displays £149.95 inc VAT, but current stock is unclear.
- Sony DSR-400K manufacturer page is discontinued and priced in JPY; DSR-400K 17x lens kit is not the same as a standard DSR-400 body.
- ZBlade 4TB exact SKU EXP4M6G004TB is €2,049 incl VAT at Syntex, on request; CVP's default £665.99 is not proven to be the 4TB selector price.
- Sony PMW-F55 £1,099 body-only eBay and £9,750 ex VAT ES Broadcast leads have package/availability gaps; ES Broadcast page returned 503.
- Nikon S3M global auction index shows raw EUR sales; do not use its GBP-normalised estimate as a direct UK GBP listing.
- Z CAM IPMAN Gemini Pro is £47.99 inc VAT at ProAV, backorder around seven working days. Official Z CAM page gives historical USD $49.90 MSRP and scheduled ship date in September 2021; not a current price.
- Sony HDCU-3500 is €14,400 ex VAT at Axis-One; UK £31,000 + VAT KitPlus listing is a complete HDC-3500 channel including the CCU.
- Leica M11 Monochrom UK leads are £8,100–£8,500; The Classic Camera's stock/pre-order messaging conflicts, and Clifton's estimated stock date is stale.
- Sony HDC-5500RV has no visible price; Teltec says price on request. Visuals' £60,036 inc VAT HDC-5500 is not the RV model.
- Parrot Jumping Race Max exact MediaMarkt Spain lead is €159 but unavailable. Zavvi's £39.99 lead is a different Jumping Race EVO Jett model and the retailer is in administration.
- Direct Google Shopping search URLs were inaccessible and indexed shopping.google.com searches returned generic guides, not product-specific offer cards. Merchant pages found through product-shopping and general web searches were opened where accessible. Do not claim full Google Shopping card click-through.

## Next run

Read Batch 07 checkpoint and this project-memory file first. Exclude all 20 Batch 07 product UUIDs, every UUID in scheduled checkpoints 02–07, all outstanding LIVE queue candidates and all outstanding manual AI research prompt IDs. Recheck evidence/queue/prompt status immediately before research. Select the next 20 eligible active LIVE catalogue products dynamically without SQL OFFSET.

Continue opening actual manufacturer, retailer and marketplace pages; retain every useful URL even when sold out, seller unverified, price missing or model/package uncertain. Do not invent or convert prices. Prefix uncertainty with RED VERIFY. Stage candidates only through the supported authenticated platform-owner RPC if a real owner-auth context is present. If auth.uid is null or owner check fails, do not write directly; create the next detailed checkpoint and project-memory files instead.

Do not modify master products, schema, valuation logic, TEST or Stripe.
