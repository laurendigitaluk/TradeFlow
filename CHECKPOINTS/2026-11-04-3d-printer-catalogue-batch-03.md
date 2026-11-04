# 3D Printer Catalogue — Batch 3 Checkpoint
Date: 4 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main
LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Final verification — TEST and LIVE independently
| Metric | TEST | LIVE |
|---|---:|---:|
| Master products | 64 | 64 |
| Active customer-visible products | 63 | 63 |
| Active UK-new evidence | 66 | 66 |
| Active UK-used evidence | 11 | 11 |
| Total active evidence | 77 | 77 |
| Visible products missing active evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active evidence groups | 0 | 0 |

One active Anycubic Kobra S1 ACE 2 Pro 4-colour variant is intentionally customer_visible=false; it has evidence but is not exposed to customers pending package-display review.

## Category and branch IDs
TEST:
- Category cc35aadb-5c1e-439b-8cf9-70ac07e82044
- 3D Printers b716ae40-d711-4a0a-a72c-9cf19fee880a
- Equipment & Accessories 1e45de21-2100-4d1b-8839-319a38a01397

LIVE:
- Category ab8b13b0-b070-4534-838b-3ebd4d7261e5
- 3D Printers 59873baa-da84-461c-a8c3-4b8fd4359bcb
- Equipment & Accessories 8437a905-c72b-4cfb-9d6c-af0dec00f222

## Changes
1. Eleven Creality product/package records added independently to TEST and LIVE: K2 standard/CFS Combo, K2 Pro standard/CFS Combo, K2 Plus standard/CFS Combo, K2 SE standard/CFS Combo, K1 Max, Ender-3 V3 SE, Ender-5 Max. Eleven official UK-new evidence rows per environment.
2. Eight Bambu Lab package variants present in TEST were added independently to LIVE; eight UK-new Additive-X evidence rows were inserted separately in both environments.
3. Fourteen Anycubic UK-new evidence rows were inserted separately in both environments for existing Kobra 3 Max V2, Kobra S1/S1 Max and Photon Mono/P1 models/packages.
4. The £409 Kobra S1 ACE 2 Pro Combo evidence row was reconciled in LIVE.
5. Eleven duplicate Anycubic evidence captures were deactivated in each environment. The canonical rows remain active; duplicates remain in the database with audit notes.

## Source and evidence rules
- Creality UK Store product pages; exact model/package URLs are stored on the evidence rows.
- Anycubic UK product pages; exact model/package URLs are stored on the evidence rows.
- Additive-X UK exact Bambu product pages are stored on the evidence rows.
- UK GBP only. Retailer prices are listed asking prices, not completed sales.
- Some Anycubic pages displayed prices while marked sold out. The evidence notes state this; do not claim stock.
- Keep standard printer and combo prices separate.
- Used evidence is reference-only and must not affect automatic valuations.

## Scope
No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Only category/master product/evidence data was changed separately in TEST and LIVE.

## Next
Expand QIDI, Phrozen, Formlabs, UltiMaker, Snapmaker, Raise3D and specialist/industrial models. Then add actual printer accessories to the existing Equipment & Accessories branch.
