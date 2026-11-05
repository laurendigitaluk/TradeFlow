# TradeFlow LIVE camera research — Brinno batch 07

Date: 5 November 2026
Branch: production
Supabase: LIVE gxsrajtqzdjvmceqcpgv

## Added evidence
Five existing active products received UK GBP evidence:
- BCC2000 — £544.99, Timelapse Store, availability unknown. Source https://timelapse.store/collections/brinno.
- BCC2000 Plus — £719.00, BrinnoUK, No Solar Kit configuration, page showed Add to cart. Source https://www.brinnouk.com/products/bcc2000-plus.
- BCC2020 — £432.00 starting price, BrinnoUK homepage, exact variant and availability unknown.
- TLC2020 + ATH1000 — £399.00 starting price, BrinnoUK homepage, availability unknown.
- TLC2020 + ATH2000 — £519.00 starting price, BrinnoUK homepage, availability unknown.

All five insert rows were independently read back and verified active, GBP and source-linked. Existing product master rows only; no master/lifecycle changes. LIVE only; TEST untouched. No valuation, schema, RLS, app, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required.

Camera coverage total remains unpublished while the prior 722 baseline and later 720 main_category=Cameras roll-up are reconciled.