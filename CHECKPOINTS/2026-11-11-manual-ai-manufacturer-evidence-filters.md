# Checkpoint — Manual AI Research manufacturer and evidence filters

Date: 11 November 2026
Environment: TRADEFLOW LIVE only

- Added dynamic Manufacturer filter after Category and Branch, scoped to active master products in the selected category/branch.
- Added Evidence required filters: All; No evidence (missing both UK new and UK used); Missing UK new; Missing UK used; Complete (both present).
- Filtering and total counts occur server-side before 500-row pagination.
- Existing checkbox selection, cross-page selection, quick-select controls, 500-product cap, and whole-category/branch queue actions retained.
- Migration: 20261111000300_cloud_ai_catalogue_manufacturer_evidence_filters.
- RPCs: platform_owner_list_cloud_ai_catalogue_manufacturers; platform_owner_list_cloud_ai_catalogue_products_filtered.
- Frontend JS cache reference: v53.
- LIVE test Cameras → Photography Cameras → Nikon: 22 manufacturers in branch; all 205, no evidence 109, missing new 189, missing used 111, complete 14.
- SQL test calls were rolled back. No catalogue/evidence rows or TEST/customer/commercial data changed.
- GitHub Actions Worker deployment must be checked for the HTML/JS commits before the UI is described as live.
