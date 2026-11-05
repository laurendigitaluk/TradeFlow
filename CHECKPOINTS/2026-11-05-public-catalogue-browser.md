# Checkpoint — Public searchable catalogue browser and mega-menu — 5 November 2026

## User request
Implement the proposed public category mega-menu and a complete searchable catalogue browser so the user can inspect it.

## Pre-change checks
- Reviewed current production page `catalogue-research.html`, `catalogue-research.css`, shared public navigation and `buying-catalogue.js`.
- Reviewed `docs/TRADEFLOW-PLATFORM-PUBLIC-PAGES-ROADMAP.md`, AI operating manual, prior public-page checkpoint and project memory.
- Checked LIVE and TEST schema for master categories, branches, manufacturers, products and shared evidence.
- Confirmed direct client access to master catalogue tables remains denied by RLS in both environments.
- Existing catalogue master is large (tens of thousands of public-visible records); pagination is mandatory.

## Implementation
- Add dynamic **Catalogue & AI Research** mega-menu on all eight public pages: index, how-it-works, plans, examples, contact-us, terms, privacy, catalogue-research.
- Add category menu that loads current active categories and counts dynamically from the environment's own public RPC.
- Add searchable public product browser to `catalogue-research.html`, category filter, 24 records/page and Previous/Next controls.
- Product search matches manufacturer, model, package, product type and catalogue category.
- Query-string category links preselect the requested category before the first results request.
- New assets: `catalogue-nav.js`, `catalogue-nav.css`, `catalogue-browser.css`.
- Existing static category examples and AI research explanation remain in place.

## Database and security
- New read-only RPC: `public.platform_public_catalogue_browse(text,text,integer,integer)`.
- Migration: `supabase/migrations/20261105010000_platform_public_catalogue_browser.sql`.
- Applied independently to TEST `nnsshnfkjcflucjrftzi` and LIVE `gxsrajtqzdjvmceqcpgv`.
- RPC returns only active category labels/counts and active `customer_visible` product category/manufacturer/model/package/product-type/branch labels. No IDs, evidence, source URLs, prices, notes, tenant/customer/order data, buying rules or valuation settings.
- SECURITY DEFINER with fixed search_path, read-only, no tenant argument, page size capped at 48, EXECUTE granted to anon/authenticated.
- Direct table RLS deny policies remain unchanged.
- TEST and LIVE product data remains independent. No product/evidence rows were copied.

## Verification
- RPC executed in both environments.
- Both return the expected category list and paginated product records.
- DJI + Drones filter returned 126 matches and correctly separated package variants in TEST and LIVE.
- RPC execute privileges confirmed for anon and authenticated.
- Remaining acceptance: verify browser network/rendering, search, category filters, pagination, keyboard/mobile mega-menu, and Worker deployment commit in TEST first, then LIVE. GitHub merge is not proof of deployment.

## Branches
- TEST: `feature/public-catalogue-browser-test-20261105` based on `cloudflare-test`.
- LIVE: `feature/public-catalogue-browser-live-20261105` based on `production`.

## Documentation
- Human User Manual, AI Operating Manual and Public Pages Diagnostic Roadmap updated.

## Merge status — 5 November 2026
- TEST PR #238 merged into `cloudflare-test` at `8ccd334b46a2627a26766e6faa0d1b7fa505115b`.
- LIVE PR #239 merged into `production` at `b40944bd6d4617d73923401d198c7b399e23dce7`.
- Supabase RPC migration applied and function execution tested separately in TEST and LIVE. DJI + Drones search returned 126 matching products in each environment; package variants remain separate.
- GitHub reports no workflow runs or commit statuses for either merge commit, and the available public-page URL check could not access either Worker. Cloudflare deployment/runtime is therefore not independently confirmed. Browser acceptance is still required.
