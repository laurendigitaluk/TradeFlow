# TradeFlow Cameras — LIVE research batch 04

Date: 5 November 2026
Environment: LIVE Supabase gxsrajtqzdjvmceqcpgv; GitHub production.

## Products researched and evidence added
- Blackmagic URSA Cine 17K 65 — £18,235 UK GBP, official Blackmagic Design UK product listing; availability unknown. Source: https://www.blackmagicdesign.com/uk/products/blackmagicursacine
- Blackmagic URSA Cine 17K 65 Body — £14,075 UK GBP, official Blackmagic Design UK product listing; availability unknown. Source: https://www.blackmagicdesign.com/uk/products/blackmagicursacine
- Blackmagic URSA Cine Immersive — £20,529 UK GBP, official Blackmagic Design UK products listing; availability unknown. This is the standard Immersive configuration only, not 100G or Body-only. Source: https://www.blackmagicdesign.com/uk/products

## Verification
All three evidence rows inserted into LIVE public.shared_market_evidence and independently read back. Each has GBP currency, a non-empty source URL, and is_active=true. Product master records already existed and were not modified. No duplicate product or lifecycle changes.

## Scope
LIVE only; TEST untouched. No schema, RLS, valuation, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. Used-market evidence was not added.

## Prior count caveat
Do not publish a new camera coverage percentage yet. The prior batch identified a discrepancy between an earlier 722-product research baseline and a fresh main_category Cameras roll-up of 720 active rows. Category inclusion must be reconciled before refreshing totals.