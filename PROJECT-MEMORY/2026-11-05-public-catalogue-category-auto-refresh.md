# Project memory — public catalogue category auto-refresh — 5 November 2026

The public Catalogue & AI Research category menu and filter are backed by the read-only `platform_public_catalogue_browse` RPC. Categories appear only when active and containing at least one active, customer-visible master product. The RPC exposes only public category/product labels and counts; it does not expose evidence, prices, source URLs, internal notes, valuation settings or tenant/customer/order data.

The front-end `catalogue-nav.js` now refreshes category lists on initial load, browser focus, tab visibility return and every three minutes. It re-renders the category filter and navigation mega-menu, preserves a still-valid selection, and resets to All categories if the selected category is no longer returned.

Environment read-back on 5 November:
- TEST (`nnsshnfkjcflucjrftzi`): Laptops appears with 8 customer-visible products; Computers is not present.
- LIVE (`gxsrajtqzdjvmceqcpgv`): Laptops and Computers are not yet returned.
- Both environments return 3D Printers & Equipment, Mobile Phones, and Gaming Consoles & Accessories. Their product counts can differ; do not sync or merge datasets as part of a UI change.

PR #240 merged to TEST branch `cloudflare-test` at `94b836c4aea294679633519c035bba561d89e858`. Worker deployment and browser acceptance could not be independently verified in this session. LIVE `production` and LIVE database were not changed. Next action: verify TEST Worker route in browser, including category refresh after a category/product becomes customer-visible, then promote only this scoped code change to LIVE after acceptance.
