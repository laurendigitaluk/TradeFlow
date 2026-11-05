# Project memory — Public searchable catalogue browser — 5 November 2026

User approved implementing a dynamic category mega-menu and complete searchable public catalogue browser on the TradeFlow public marketing site.

- Menu appears on index, How It Works, Plans, Examples, Contact Us, Terms, Privacy and Catalogue & AI Research.
- Menu categories/counts load dynamically from environment-specific Supabase public RPC.
- Catalogue & AI Research page has live product search, category filter and 24-row pagination.
- Search supports manufacturer, model, package, product type and catalogue category.
- Product result cards show category, manufacturer, model, product type/branch and package only.
- Only active customer_visible products appear.
- No evidence, source URLs, prices, internal notes, product IDs, tenant/customer/order data, buying settings or valuation rules are exposed.
- RLS direct table deny policies remain. Read-only SECURITY DEFINER RPC with fixed search_path exposes a minimal safe projection and has anon/authenticated execute grants.
- RPC `platform_public_catalogue_browse(text,text,integer,integer)` migration `20261105010000_platform_public_catalogue_browser.sql` applied separately to TEST `nnsshnfkjcflucjrftzi` and LIVE `gxsrajtqzdjvmceqcpgv`.
- TEST and LIVE catalogue data is never copied/synchronised by this feature.
- RPC tested in both environments; DJI + Drones query returned 126 records in each with package variants distinguished.
- Remaining requirement: browser acceptance and Cloudflare Worker deployment verification in TEST, then LIVE. Do not claim browser deployment complete until checked.
- Manuals and `docs/TRADEFLOW-PLATFORM-PUBLIC-PAGES-ROADMAP.md` updated.
