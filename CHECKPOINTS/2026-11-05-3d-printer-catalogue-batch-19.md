# Checkpoint — TradeFlow 3D Printer Catalogue Batch 19

Date: 5 November 2026
Status: Complete; database-only catalogue update verified in both environments.

## Changes
Added Sovol SV06 ACE Standard (£210), SV06 ACE + SH02 Filament Box Combo (£269), and Sovol Zero Standard (£249) to both LIVE and TEST, with active UK-new GBP evidence linked to official UK product pages. Availability is unconfirmed for all three because page stock indicators conflict or show sold-out/notify states.

## LIVE IDs
- SV06 ACE Standard: product 8453c386-45e0-413b-9f70-43fb428ae919; evidence 418a0008-2c75-4c2b-a3c8-2c82442794c4.
- SV06 ACE SH02 combo: product 49872fc8-73c9-43be-8784-c2e5fae98e36; evidence 48c985f9-531a-4f88-b478-2712a47e26f4.
- Zero Standard: product 479484f0-eb4b-40cb-ae86-3e0f16f3968c; evidence a9794fb9-f81c-440f-89fe-72d607d7860c.

## TEST IDs
- SV06 ACE Standard: product 5c823ba8-8707-4fe4-af76-d69f1d58eaab; evidence 935a6d29-281a-4c16-b0aa-999cef5bb404.
- SV06 ACE SH02 combo: product 366983ef-d69b-4466-9941-e776934485da; evidence c19f0335-a97a-4bb0-90bd-547a295eafae.
- Zero Standard: product 2f6670e9-aa1f-4cbf-b6e1-e49d6165724b; evidence 476a0073-7b7f-46ea-a120-861c96ea4e4d.

## Read-back verification
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 174 | 167 | 7 | 193 | 178 | 15 |
| TEST | 175 | 167 | 8 | 193 | 178 | 15 |

Both environments have zero missing active visible evidence, zero duplicate active product keys, zero duplicate active evidence source keys, zero invalid/missing evidence and zero invalid UK-new evidence. TEST's additional hidden product row remains untouched. UK-used is reference-only and excluded from automatic valuation.

No Worker deployment. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data changed.

## Next
Continue verifying remaining Sovol UK configurations, then research ENTINA/WEEFUN brand identity and UK price evidence. Do not add duplicate brand/model records or use USD-only evidence. Research BRESSER and Voxelab only after checking current catalogue records and confirming reliable UK availability/brand status.
