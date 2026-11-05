# Checkpoint — public catalogue category auto-refresh — 5 November 2026

## User request
Make the public Catalogue & AI Research category dropdown and navigation mega-menu stay current as new catalogue categories are added. The user confirmed laptops/computers research has only just started and 3D printers, mobile phones and gaming consoles are being populated.

## Pre-change checks
- Followed the TradeFlow environment map: TEST branch `cloudflare-test`, Worker `tradeflow-test`, Supabase `nnsshnfkjcflucjrftzi`; LIVE branch `production`, Worker `tradeflow`, Supabase `gxsrajtqzdjvmceqcpgv`.
- Read the existing public catalogue checkpoint, project memory, platform public pages roadmap, system handbook and AI operating manual.
- Inspected the existing `catalogue-research.html`, `catalogue-nav.js`, public browser RPC and live/test RPC results.
- The public RPC already derives categories from active categories with at least one active customer-visible product. It returns only public labels/counts and paginated customer-visible product names; no evidence, source URLs, prices, buying rules, tenant/customer/order data.
- Current TEST response includes Laptops (8 customer-visible products); current LIVE response does not yet include Laptops. Both return 3D Printers & Equipment, Mobile Phones and Gaming Consoles & Accessories. No Computers category is currently returned.
- Category lists are independent between TEST and LIVE; no catalogue rows or evidence were copied.

## Change
- Updated only `catalogue-nav.js` on this TEST feature branch.
- Category select and mega-menu are now re-rendered from the latest public RPC response rather than being frozen by a one-time `dataset.loaded` flag.
- Categories refresh on initial page load, browser focus, tab visibility return and every three minutes.
- Current category selection is preserved when still valid; if a category is no longer public/available, the filter safely returns to All categories.
- No database schema/data, RPC permissions, product visibility, pricing, valuation, tenant/customer, payment or Worker configuration changes.

## Verification
- Read-only TEST RPC returns dynamic categories and 28,264 public-visible products at the time of inspection; Laptops appears only in TEST at present.
- Read-only LIVE RPC returns dynamic categories and 28,254 public-visible products at the time of inspection; Laptops is not yet public-visible in LIVE.
- Code change is committed to `feature/catalogue-category-live-refresh-20261105` from `cloudflare-test`.
- Browser/Worker deployment acceptance remains required before merging or promoting to LIVE. Do not call the change deployed until the TEST Worker and browser behaviour are checked.
