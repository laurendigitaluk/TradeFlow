# TradeFlow Test checkpoint — multi-item customer valuation — 28 October 2026

## Target and safety boundary
- Target deployment branch: `cloudflare-test` (changes are staged in `feature/test-multi-item-valuation-port-20261028` pending review/merge).
- Test Worker: `tradeflow-test.leannelaurenlowe.workers.dev`.
- Test Supabase project: `nnsshnfkjcflucjrftzi`.
- Live project and production branch have not been changed by this work. Do not merge this branch into `production` or deploy to Live before Test acceptance.

## Changes ported while preserving the current Test website
- Ported the multi-item selling page and wizard into the current Test branch's `public-site.js), retaining the surrounding current Test website implementation.
- Added responsive basket CSS to current Test `public-site.css).
- Bumped public-site cache versions to `public-site.css?v=68` and `public-site.js?v=87`.
- Corrected customer auth runtime selection so the current Test hostname uses the current Test Supabase project, while localhost and GitHub Pages keep their legacy test configuration.
- Bumped `customer-auth.js` to v21 in the customer dashboard.
- Added the item-indexed multipart fields: item 0 photos are sent as `files_0`, item 1 as `files_1`, etc. Legacy single-item payloads still send `files`.
- Updated the AI operating manual, human user manual and system handbook to make clear that earlier single-item limitations are historical and that this new flow is not accepted until end-to-end tests pass.

## Verification already performed
- JavaScript parse check passed for the ported `public-site.js).
- JavaScript parse check passed for `customer-auth.js).
- Static checks confirm the basket UI, basket CSS, cache versions and item-indexed photo field names are present.
- Existing Test branch website/template and Worker routing files were not replaced wholesale.

## Not yet verified
- The feature branch has not yet been merged into `cloudflare-test` or confirmed deployed by Cloudflare.
- No real-browser end-to-end submission has been performed.
- Test one-item, two-item, 3+ item and mixed-category requests.
- Verify each item has the correct `buying_product_id`, valuation and offer.
- Verify photos are linked to the correct `buying_item_id`; exercise invalid file and upload failure handling.
- Verify basket edit/remove, reload persistence and tenant isolation.
- Verify customer authentication return journey. The current UI asks the customer to sign in and return to the selling page; automatic round-trip is not confirmed.
- Verify customer portal and staff Buying dashboard show one request with separate item workflows, and no premature acquisition/inventory movement.
- Verify downstream accepted-offer, acquisition, inspection, inventory and sales behaviour.

## Important integration note
The existing Test Worker uses `worker/index.js` to rewrite environment URLs and keys. Keep its environment boundary intact. Do not copy the production worker wholesale into Test. The current Test Edge Function in the remote Test project was previously reported as version 10 active, but the repository copy in `cloudflare-test` is older; verify the deployed function directly before assuming branch code matches remote deployment.

## Next actions
1. Review this branch diff against `cloudflare-test`.
2. Merge only after confirming no unexpected files are included.
3. Confirm the Test Worker deploy and live asset responses.
4. Run the browser/database acceptance tests listed above and record actual results.
5. Only after Test acceptance consider a controlled promotion; Live remains untouched until explicitly approved.
