# Original Nintendo Switch controller catalogue — Batch 11

Date: 2026-11-05
Repository: laurendigitaluk/TradeFlow (main)

## Scope and source evidence
Added three distinct original Switch-compatible products independently in LIVE and TEST, each with active UK-new GBP Argos evidence.

| Product | UK new price | Argos source |
|---|---:|---|
| Konix Hello Kitty Nintendo Switch Wired Controller | £15.99 | https://www.argos.co.uk/product/7294606 |
| CRKD NEO S Wireless Controller — Fortnite Festival Edition (Purple Wave) | £44.99 promotional price (was £59.99) | https://www.argos.co.uk/product/7183638 |
| CRKD NEO S Wireless Controller — Peely Fortnite Edition | £59.99 | https://www.argos.co.uk/product/7188846 |

Konix Hello Kitty has a 3m wired connection, vibration and screenshot button; Argos confirms Switch, OLED and PC compatibility and its supplier says Switch 1 only. The Fortnite Festival NEO S has a detachable five-fret attachment, Hall Effect thumbsticks and remappable rear buttons. The Peely NEO S has Hall Effect thumbsticks, remappable rear buttons and a charging dock. Both NEO S models are wireless and support original Switch/OLED plus PC/mobile/TV platforms.

## Manufacturer handling
- Konix was absent from both manufacturer tables before this batch. A separate Konix manufacturer row was created in LIVE and TEST.
- Existing CRKD manufacturer rows were reused.
- Duplicate preflight found no matching Konix or NEO S product in the Nintendo Controllers branch.

## LIVE records
| Product | Product UUID | Evidence UUID |
|---|---|---|
| Konix Hello Kitty | 0f0efd88-5c28-48f2-b35b-7d659ffba154 | 66c57120-c62f-4c44-9600-124a95215bf9 |
| CRKD NEO S Fortnite Festival | 0ce9b9ea-2eb2-4030-b6ce-63f087e8894b | a1994d8c-0dd0-4b88-8ab7-ff5b2e1a4ba0 |
| CRKD NEO S Peely Fortnite | 5a1164ee-32ab-4ae7-954f-bef4c31c3c84 | 4dcf6ddd-1235-4051-b1ed-28a2285b1d64 |

Konix manufacturer UUID: `4cc909b7-9696-4cad-a5ac-8602806d1d3b`.

## TEST records
| Product | Product UUID | Evidence UUID |
|---|---|---|
| Konix Hello Kitty | 98105bfe-d49c-49ed-b7a3-0fe352dd3bdb | acd3843e-45b8-4cfd-b881-1b2dd4ebff0d |
| CRKD NEO S Fortnite Festival | 9fa609ab-ef64-4244-bfba-29308cff6033 | 30d834da-8499-4b74-a418-7831c2405a68 |
| CRKD NEO S Peely Fortnite | b9e657a9-7ee1-43c3-90a1-bf1cca23e7b4 | 6191e58d-0e74-4fb7-af7b-f3784291594f |

Konix manufacturer UUID: `1de7688e-68ac-4c28-973e-f50cf8954bce`.

## Evidence and verification
Each evidence row is active UK-new GBP, item_condition New, source Argos, availability listed, with exact product URL, positive observed price and stable source_record_key.

Independent post-insert SQL verification in both environments:
- Active customer-visible Nintendo Controllers products: **72**
- Active evidence rows: **75**
- Visible active products missing active evidence: **0**
- Active evidence integrity exceptions: **0**
- LIVE and TEST totals match; environment-specific UUIDs remain separate.

Batch 11 increased Batch 10's verified 69 products / 72 evidence rows to 72 / 75 in both environments. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment or custom-domain data changed. No Cloudflare Worker deployment required. Used evidence remains reference-only and does not affect automatic valuation.
