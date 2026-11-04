# Project Memory — 3D Printer Catalogue Batch 5
Date: 4 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: cloudflare-test | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi | LIVE Supabase: gxsrajtqzdjvmceqcpgv

Batch 5 added nine Formlabs printer models and eight UltiMaker product/package records independently to TEST and LIVE. Existing 3D Printers branch reused. One UK-new GBP evidence row per product was added in each environment. TEST and LIVE independently verify 90 products, 90 visible, nine manufacturers, 91 UK-new and 12 UK-used active evidence (103 total), zero missing visible-product evidence/branch and zero active evidence integrity failures.

Product coverage: Formlabs Form 3, Form 3L, Form 3BL, Form 4, Form 4B, Form 4L, Form 4BL, Fuse 1+ 30W, Fuse X1. UltiMaker S3, S5, S6, S7 standard, S7 Pro Bundle, S8 standard, S8 Pro Bundle, Factor 4.

Full product/evidence UUID mapping, GBP prices and clickable UK sources are in CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-05.md.

Evidence caveats: Formlabs UK prices include 20% VAT. 3DGBIRE UltiMaker prices are VAT-inclusive except S6 £4,900, explicitly shown ex VAT and stored unchanged. S8 and S8 Pro Bundle are preorder. Keep Pro Bundle packages distinct. Form 3/3L/3BL are still listed by Formlabs; do not mark discontinued without lifecycle confirmation. No used-market records were fabricated.

No code, schema, valuation logic, RLS, Edge Functions, tenant/customer/order/payment/Stripe/subscription/domain data or Worker deployment changed. Only manufacturer/product/evidence rows changed independently in TEST and LIVE. Next: Phrozen and Raise3D, then Snapmaker and remaining QIDI legacy models; keep used evidence reference-only.
