# TradeFlow LIVE — Drone second-pass Batch 19 checkpoint
Date: 13 November 2026 (UTC)
Environment: LIVE only
Category: Drones
Batch: 19
Products reviewed: 20
Verified product masters: 2
Evidence observations inserted: 3 (UK New 3, UK Used 0)
Products held without import: 18

## Scope and reviewed product IDs

| Manufacturer | Model | Package | Master product ID | Result |
|---|---|---|---|---|
| Holy Stone | HS720-4K | Standard | ea10a5f9-2724-4641-b420-4321887fc9f5 | Held |
| Holy Stone | HS790 | Standard | 8c084025-2233-4a12-94da-a353001de247 | Held |
| Holy Stone | HS800 | Standard | d05b4036-32ae-4f85-8e0c-e4273d811451 | Held |
| Holy Stone | HS900PRO | Standard | 99027421-4765-4bc9-8550-cb1ae595f9f6 | Held |
| Holy Stone | T60A | Standard | 9589378b-9571-43c2-864f-fdd0df9b6b8c | Held |
| HOVERAir | X1 PRO Max | Standard Package | 484ea30c-5e41-4935-8a31-5a8dc0a53f43 | 2 UK New |
| Hubsan | ACE 2 | Standard | 2831c24d-bc98-4b2a-a79c-181fecfe9a00 | Held |
| Hubsan | H107C+ | H107C+ | b7b084fd-566a-47d7-ac1d-a0078798321b | 1 UK New |
| Hubsan | H501S X4 Air Black | Black BNF | 532fa928-ff79-485e-bcfa-3d7877ecb5a6 | Held |
| Hubsan | H501S X4 Air White | White BNF | e301d3c8-aefd-4118-88f2-5538f767f482 | Held |
| Hubsan | Zino | Standard | aff56421-9919-4571-b0f5-2d05ad6b7440 | Held |
| Hubsan | Zino 2 | Standard | abba690a-22ff-470c-9f9a-cb2657bf7370 | Held |
| Hubsan | ZINO MINI PRO 2025 | Standard | bffa98e6-4c71-4596-ae7b-dcd6df9e9f33 | Held |
| Hubsan | Zino Mini SE | Standard | 84794596-81f2-4f9b-a917-383d7b34f513 | Held |
| iFlight | BOB57 O4 | BOB57 O4 | 5396357d-8d63-4858-99c3-78aeacfcfd0a | Held |
| iFlight | Chimera7 Pro V2 GPS ANALOG | Standard | 336463c4-a835-43b5-8228-6e4f8a794409 | Held |
| iFlight | Chimera7 Pro V2 O4 | Standard | d8142d5a-bc95-4e81-b499-bac1513cada0 | Held |
| iFlight | Defender 20 Lite O4 | Standard | f21f9292-0856-456a-b04d-cdaec8b71ce7 | Held |
| iFlight | Nazgul DC5 O4 ECO | Standard | 0c034ef2-8cf2-4f4e-b1c0-bce07b9104c6 | Held |
| iFlight | Nazgul Evoque F5 V3 O4 Pro | Standard | e37f624e-6f28-4543-bd64-559b5129a990 | Held |

## Imported evidence

| Product | Source | Price | Evidence ID | Direct source |
|---|---|---:|---|---|
| HOVERAir X1 PRO Max Standard | AO UK | £639.00 GBP | f918cb2d-d50c-4cba-9499-cb57f4654561 | https://ao.com/product/sp06h006-hoverair-x1-promax-drone-black-111519-755.aspx |
| HOVERAir X1 PRO Max Standard | Sync UK | £680.71 GBP | 981cd5f5-89ef-4ecb-9b50-5aa06e991fc7 | https://shop.wearesync.co.uk/sp06h006.html |
| Hubsan H107C+ | Menkind UK | £49.97 GBP | d4c7d8e4-d8cc-46ba-a96d-dcfa9689bcdc | https://www.menkind.co.uk/hubsan-h107c-altitude-mini-quad |

All records are active UK New evidence, condition New, direct source URL, GBP, and stable unique source key. Sync's page displays £680.71 gross and £567.26 ex VAT; the gross price is stored.

## Exclusions / quality decisions

- HS720-4K: the eBay lead surfaced as a relisted/current page rather than a clean original completed-sale capture; not imported.
- HS790, HS800, HS900PRO, T60A: no exact, qualifying UK GBP source found in this pass.
- Hubsan ACE 2: surfaced UK listing was an active for-parts/repair item; not treated as completed-sale evidence.
- H501S X4 Air: sold listing did not establish exact BNF package and colour variant; not mapped to Black or White masters.
- Zino family: GBP-selector results from the manufacturer's EUR-market page were not treated as UK seller evidence.
- iFlight: UK-localised GBP storefront results disclosed Austrian dispatch. No evidence was imported from that seller in this pass; do not silently classify an EU-dispatched price as a UK domestic retailer observation.
- Other active marketplace listings and unverified used offers were not counted as UK Used completed-sale evidence.

## Post-write LIVE verification

- Active customer-visible Drone products: 541
- No active evidence: 184
- Missing UK New: 306
- Missing UK Used: 351
- Products with both UK New and UK Used: 68
- Active Drone evidence integrity failures: 0

Three new evidence rows were read back by ID and source key. The reduction from the preceding checkpoint is two products for no-evidence and missing-UK-New; missing-UK-Used remains unchanged. No duplicate active source keys were introduced by these three writes.

## Boundaries

LIVE shared market evidence only. TEST, Stripe, valuation logic, catalogue masters/packages, tenant/customer/order/payment data, schema, RLS, RPCs, Edge Functions and deployment were untouched. UK Used evidence remains reference-only and is excluded from automatic valuation. Pokémon cards remain excluded.

## Next work — Batch 20

The next 20-product candidate selection was read from LIVE after excluding second-pass Batches 16–18 and the 20 IDs above:

1. iFlight Nazgul Evoque F7 O4 GPS — 71b239e2-53bb-415b-beef-f3f48d7d76a7
2. iFlight Nazgul XL5 ECO V1.1 6S ANALOG — b85ab562-f1cd-4b91-a0ad-6375e66d0dfd
3. iFlight Specter 7 O4 6S HD — b9b0149f-6164-437f-99c4-f877b10be5ba
4. iFlight Taurus X8 Pro Max V2 8S HD Cinelifter — 9346922d-ad8e-468f-837d-9a4d7ac56741
5. Parrot ANAFI FPV — ec489c09-8529-4509-90c7-9c32914e5876
6. Parrot ANAFI UKR — affa5761-586c-4e06-aec2-adbc06ff9729
7. Parrot ANAFI UKR GOV — 9f42ccf2-1e12-4d5c-b9cb-05d78b23a0cf
8. Parrot ANAFI UKR XLR — b74bee20-f13b-4308-bf31-6970b0fc7c27
9. Parrot ANAFI USA GOV — 47154869-e35a-4a21-82ab-f95e9c658fd4
10. Parrot ANAFI USA MIL — 5bb6b909-d2e9-435a-8726-6b6f5420cf95
11. Parrot Bebop-Pro Thermal — 68ba2643-f829-426a-a882-e21cabb681a2
12. Parrot Jumping Night Marshall — dd41eaf7-a565-4cc9-877b-e82a4d586459
13. Parrot Jumping Race Max — 52023314-a46b-4652-b6e9-eba5c72a9ed0
14. Parrot Mambo Fly — bcadaeac-e010-4378-bad5-285cce68b121
15. Parrot Bebop Pro 3D Modeling — a07aebb8-da70-4678-8da8-d4b6389049c8
16. Parrot Hydrofoil New Z — 97e045f2-73f9-4779-bce6-05171ff901b4
17. Parrot Jumping Night Buzz — 41599469-23dd-4121-8888-030ccd137c5d
18. Potensic A20 — 1fcfbaf6-3a76-4bc7-851a-1655ab50e7f6
19. Potensic A20 Mini — 8f5c264b-c176-41f9-94f2-d54ad2f25bfe
20. Potensic A30 — 834f07c4-176b-4f43-a890-ed01cfab0171

This is a candidate selection, not a completed research result. Recheck active evidence and exact package identity before any Batch 20 write.
