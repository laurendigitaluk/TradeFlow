# Project Memory — QIDI 3D Printer Catalogue Batch 4
Date: 4 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Verified snapshot — both environments
- 3D Printers & Equipment category: 72 master products, 72 active customer-visible.
- Active UK GBP evidence: 85 (74 uk_new / 11 uk_used).
- Seven manufacturers represented.
- Visible products missing evidence: 0.
- Visible products missing branch: 0.
- Active evidence integrity failures: 0.
- TEST and LIVE totals match exactly.

## QIDI manufacturer IDs
- TEST: f8154f03-dd12-426d-b6bc-4ea75f57be43
- LIVE: 9a84f7a7-2a2f-4a52-ba67-cc95a5b93c2d

## QIDI product and evidence mapping
All product/evidence UUIDs shown TEST / LIVE. All evidence is UK-new GBP, availability listed.

| Model/package | TEST product | LIVE product | TEST evidence | LIVE evidence | GBP |
|---|---|---|---|---|---:|
| Q2C standard | 2d7ec04a-b3c2-481b-b919-5462df9bbeb0 | e7e94f05-829b-433a-94dc-00e4236f5936 | 074fe207-52cf-4400-9606-b6350abd3685 | 9a118fff-3f46-44dc-bfca-87e42a9763bb | 299 |
| Q2C QIDI BOX Combo | 3d824f01-3510-41bc-a046-741b78454799 | 95394b15-a464-481b-925c-09842fa23127 | 19ff976d-2aea-4813-b177-9769df1a1c21 | c93dd053-cedf-4950-841a-83110af09dbf | 429 |
| Q2 standard | a88e196b-7b4c-40ea-b8b2-02cbab30946f | 243d9f6f-850f-4732-82d7-48f1b4d27f0f | 6659388d-50b8-4d2e-9194-b2b6ec72bd6f | b8987caa-7400-407d-a292-9ae42012ded3 | 429 |
| Q2 QIDI BOX Combo | 1a09d557-5655-496a-a92a-460a0bd71cc4 | dc794a3d-381c-412f-9024-a3c1da0c9970 | b88a6328-ffd4-43c8-8d0e-1aaf5e346862 | dc224491-4c8a-43b7-a546-2937ee8a4e44 | 559 |
| Plus5 standard | a25704ba-08ce-4339-9513-a022b728bd8f | 03eaf971-c902-4de3-bb53-35d326a524ba | bffc4355-1ba3-41fa-9c39-ad341f7f6dd9 | 7399eb4b-caea-4119-a67f-dac9cb95bf6b | 639 |
| Plus5 QIDI BOX Combo | 21c03a15-bd73-4820-ad3a-9d55a144c72c | 7042046f-9be4-4da7-a23d-c25bd5ab7dba | 16a704dc-45ca-4975-aebb-13245aafb389 | 7bcef365-aa5b-4d07-8fde-95791eb71113 | 769 |
| Max4 standard | c3258d8e-b6e6-4b5d-abc6-5230d1cfd397 | 72dbab60-6561-4cb9-973a-95286f30b407 | 7628e3fd-f625-4577-8572-9ab5300cf5f8 | 08411961-c259-4f25-a676-0d2a845f8040 | 899 |
| Max4 QIDI BOX Combo | bd36933c-296d-4418-a78d-021115c1d3d3 | 53fe9c7a-d3dc-4f9a-84e8-e89d00345f02 | 9d9b1988-dc98-458a-870e-0b08e576a15b | 72472cce-f9f0-4376-90a9-217ab380fe8d | 1,029 |

## Sources and caveats
- Q2C standard: https://uk.qidi3d.com/products/q2c
- Q2C Combo: https://uk.qidi3d.com/pages/halloween-sale
- Q2 standard: https://uk.qidi3d.com/products/qidi-q2
- Q2 Combo: https://hobbysupermarket.com/uk/3d-printing/printers?brand=QIDI+Tech (reports QIDI Tech direct-store price £559, priced 6 Oct 2026; source_name is explicitly HobbySupermarket (QIDI UK price)).
- Plus5 standard: https://uk.qidi3d.com/products/plus5
- Plus5 Combo: https://uk.qidi3d.com/pages/maker-fall-sale
- Max4 standard: https://uk.qidi3d.com/products/max4
- Max4 Combo: https://uk.qidi3d.com/pages/halloween-sale

Combo and standard printer prices remain separate. The Plus5 Combo £769 is the printer plus QIDI BOX; Polar Cooler is separate and not included. Max4 Combo £1,029 is the QIDI BOX package. Q2 Combo price uses the comparison source and is marked accordingly. Do not infer used prices or lifecycle status.

## Scope and next work
No code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Worker deployment changed. Only manufacturer, master product and evidence rows were inserted independently in TEST and LIVE.
Next: verify QIDI legacy models (Plus4, Q1 Pro, X-Max 3) and used-market evidence before adding them. Then proceed to Phrozen, Formlabs, UltiMaker, Snapmaker and Raise3D.
