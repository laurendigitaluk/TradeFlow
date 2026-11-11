# Manual AI Research manufacturer and evidence filters — 11 November 2026

## Request
Extend the Owner Dashboard → AI Research Centre product picker beyond Category and Branch to include Manufacturer and evidence-gap filtering. Keep the existing master-catalogue selection and batch workflow intact.

## Inspected LIVE state
- Repository: laurendigitaluk/TradeFlow, release branch production.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv.
- Existing frontend: platform-owner-dashboard.html, platform-owner-dashboard.js; prior category/branch picker used platform_owner_get_cloud_ai_catalogue_tree and platform_owner_list_cloud_ai_catalogue_products.
- Master product records already have category_id, branch_id, manufacturer_id; manufacturer names are in catalogue_master_manufacturers.
- Active evidence records are in shared_market_evidence, linked by master_product_id, with evidence_type values uk_new and uk_used.

## Implemented
- Added dynamic Manufacturer dropdown scoped to the selected category and optional branch.
- Added Evidence required filter: All products; No evidence (neither UK new nor UK used); Missing UK new evidence; Missing UK used evidence; Complete (both evidence types present).
- Added server-side filtered pagination and matching total counts; filters are applied before page slicing.
- Preserved existing product IDs, selection map, cross-page selection, 500-product cap, quick-select controls and whole-category/whole-branch queue actions.
- Added new authenticated owner-checked RPCs; prior RPCs remain intact for compatibility.
- Bumped owner dashboard JS asset reference from v52 to v53.

## Database / deployment
- LIVE migration: 20261111000300_cloud_ai_catalogue_manufacturer_evidence_filters.
- New RPCs: platform_owner_list_cloud_ai_catalogue_manufacturers(uuid,uuid); platform_owner_list_cloud_ai_catalogue_products_filtered(uuid,uuid,uuid,text,integer,integer).
- Both RPCs check platform_cloud_ai_owner_check(), revoke execution from public/anon and grant authenticated execution.
- Test on Cameras → Photography Cameras → Nikon returned 22 manufacturers for the branch. Filtered product totals: all 205; no evidence 109; missing new 189; missing used 111; complete 14.
- Test calls ran inside a transaction and were rolled back; no data was modified by verification.
- GitHub production frontend commits: JS 5fc9624305cc149fd44758f04d97fec271cf78e2; HTML 7c99b06f990bfe84d237b2f6953afca8f61718e5; migration file fc82c297d013c44ae995a75c8ad99983b7faf427.
- Production Worker deployment workflow .github/workflows/deploy-tradeflow-production.yml is configured to deploy on changes to the owner dashboard HTML/JS. Confirm the corresponding Actions run before calling the UI deployed.

## Boundaries
No TEST database, catalogue product records, evidence records, approval/review state, valuation logic, customers, tenants, domains, Stripe or subscriptions changed. Filters only select and display existing catalogue products/evidence state.
