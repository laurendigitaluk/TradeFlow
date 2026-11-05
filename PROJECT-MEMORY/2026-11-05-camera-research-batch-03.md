# TradeFlow Cameras — LIVE research batch 03

Date: 5 November 2026
Environment: LIVE Supabase gxsrajtqzdjvmceqcpgv; GitHub production.

## UK price evidence added
- Blackmagic URSA Cine 12K LF Body — £5,999.99, Scan UK; Scan product page identifies the exact body-only EF-mount configuration and marked it in stock at the time checked. Source: https://www.scan.co.uk/products/blackmagic-design-ursa-cine-12k-body-full-frame-camera-body-12k100-cfexpress-16-stops-dynamic-range
- Blackmagic URSA Cine 12K LF 100G Body — £13,868.10 VAT-inclusive equivalent from BPS-TV's £11,556.75 ex-VAT listing; availability not confirmed. Source: https://www.bps-tv.co.uk/product-category/cameras/cinema-cameras/?product_brand=blackmagic-design
- A second, more current observation for URSA Cine 12K LF 100G Body — £8,238.00 VAT-inclusive, RCB Logic; available on backorder, ships in 3–5 days. Source: https://www.rcblogic.co.uk/product/blackmagic-ursa-cine-12k-lf-100g-body

The BPS-TV and RCB Logic observations differ materially. Both are retained as separate source observations; do not collapse or select a valuation from this evidence alone. Used-market evidence was not added.

## Database write verification
Three evidence rows inserted and returned successfully in LIVE, using unique (source_name, source_record_key) keys. Existing product master rows were used. No product, package, lifecycle or valuation fields were changed.

## Scope and caveat
LIVE only; TEST untouched. No schema, RLS, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment.

A fresh category roll-up surfaced a classification discrepancy: main_category=Cameras currently returns 720 active rows, while the earlier camera research baseline was 722. The 722 figure should not be reused as a current total until the camera-category inclusion rule is reconciled across catalogue_category and main_category. This batch therefore does not claim a refreshed total coverage percentage.

## Sources and qualification
Prices are UK GBP. Scan's product page states in stock; the RCB Logic 100G listing states backorder; the BPS-TV listing did not confirm stock. Exact package/mount matching must be preserved.