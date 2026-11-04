# Project Memory — 3D Printer Catalogue Batch 3
Date: 4 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Verified snapshot in both environments
- Category: 3D Printers & Equipment.
- Master products: 64; active customer-visible: 63.
- Manufacturers: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 3, Flashforge 3, Prusa Research 1.
- Active evidence: 77 (66 UK-new / 11 UK-used).
- Visible products missing evidence: 0.
- Visible products missing branch: 0.
- Evidence integrity failures: 0.
- Duplicate active evidence groups: 0.
- One Anycubic Kobra S1 ACE 2 Pro 4-colour package remains active but customer_visible=false.
- TEST and LIVE have matching totals and package coverage; UUIDs are environment-specific.

## Environment-specific category and branch IDs
| Record | TEST | LIVE |
|---|---|---|
| Category | cc35aadb-5c1e-439b-8cf9-70ac07e82044 | ab8b13b0-b070-4534-838b-3ebd4d7261e5 |
| 3D Printers branch | b716ae40-d711-4a0a-a72c-9cf19fee880a | 59873baa-da84-461c-a8c3-4b8fd4359bcb |
| Equipment & Accessories branch | 1e45de21-2100-4d1b-8839-319a38a01397 | 8437a905-c72b-4cfb-9d6c-af0dec00f222 |

## Batch changes
- Added 11 Creality model/package records independently to TEST and LIVE: K2 standard/CFS Combo, K2 Pro standard/CFS Combo, K2 Plus standard/CFS Combo, K2 SE standard/CFS Combo, K1 Max, Ender-3 V3 SE and Ender-5 Max. Added 11 official UK-new evidence rows in each environment.
- Added eight Bambu Lab package variants to LIVE to bring it into line with TEST: A1 Mini standard/AMS Lite Combo, A1 AMS Lite Combo, P2S standard, P1S AMS Combo, P1S AMS 2 Pro + Upgrade Kit, X2D standard and X2D AMS 2 Pro Combo. Added eight Additive-X UK-new evidence rows independently in each environment.
- Added 14 Anycubic UK-new evidence rows independently to TEST and LIVE for existing products: Kobra 3 Max V2 standard/4-colour Combo; Kobra S1 standard/4-colour Combo/ACE 2 Pro Combo; Kobra S1 Max standard/4/8/16-colour packages; Photon Mono 4, Mono M7, Mono M7 Pro, Mono M7 Max and Photon P1 Max.
- Reconciled the £409 Kobra S1 ACE 2 Pro Combo evidence in LIVE.
- Deactivated 11 exact duplicate Anycubic evidence captures in each environment; canonical active rows remain and duplicate notes are retained.

## Data rules and caveats
- UK GBP only; keep uk_new and uk_used distinct.
- Retail asking prices use availability listed, not sold.
- Printer-only and multi-colour/CFS/AMS packages are distinct.
- Anycubic Mono M7, M7 Max and Photon P1 Max pages showed prices while marked sold out; notes preserve this. Do not claim in-stock.
- Used evidence is reference only and must not alter automatic buying valuations.
- No code, schema, RLS, valuation logic, Edge Function, Stripe, customer/tenant/order/payment data or Cloudflare Worker deployment changed.
- Full IDs and verification details are in CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-03.md.

## Next
Expand QIDI, Phrozen, Formlabs, UltiMaker, Snapmaker, Raise3D and specialist/industrial models. Then populate the existing Equipment & Accessories branch with actual accessories only.
