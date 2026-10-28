# TradeFlow checkpoint — 2026-10-28 — Multi-item customer valuation (staged, not deployed)

## Goal
Allow a customer to add multiple products to one valuation request while preserving the existing per-item valuation, offers, buying workflow and downstream sales/acquisition lifecycle.

## Confirmed baseline
- TEST Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- TEST already has `customer_submit_buying_request(p_tenant_id, p_notes, p_items)`, which creates one `buying_requests` row and a separate `buying_items` row for every JSON item. The function validates tenant/category/product linkage and performs existing per-item automatic valuation and offer processing.
- The current `customer-selling-submit` Edge Function and public wizard were limited to one payload item; the function selected the first buying item and attached all uploaded photos to it.

## Staged changes
Branch: `feature/multi-item-customer-valuation-20261028`, based on `production`.
- `public-site.js`: adds an in-memory basket, Add Another Item, item summary, edit/remove controls, and submits all items together.
- `supabase/functions/customer-selling-submit/index.ts`: maps each payload item into the existing RPC contract and routes photo files by item index, linking photos to each correct `buying_item_id`. Retains legacy single-item payload support.
- `public-site.css`: styles basket and controls.
- `public-site.html`: increments asset cache versions.

## Safety decisions
- No schema/table/RPC duplication and no changes to the valuation engine or downstream acquisition/sales flow.
- The RPC remains the authoritative validation and valuation boundary.
- The feature branch has not been merged or deployed. LIVE remains untouched.
- Public wizard JavaScript passed a syntax compilation check. This is not an end-to-end test.

## Known gaps before acceptance
- Test actual one-item, two-item, 3+ and mixed-category submissions in TEST and verify DB records.
- Verify photographs are attached to their corresponding items and failed upload behaviour is not reported as success.
- Verify customer portal and staff Buying dashboard show grouped request with separate item workflows.
- Verify automatic/manual valuations, offers and downstream acquisition/sales transitions.
- IndexedDB draft persistence has now been added on the feature branch, scoped by tenant ID and hostname, storing the basket, current item and photo File objects across reloads. It has not yet been browser-tested.
- The unauthenticated handoff still requires an end-to-end check: the draft survives, but the login page's return-to-selling-page behaviour has not been verified. Current UI asks the customer to return to the selling page after signing in; do not claim automatic login round-trip is complete.
- Verify edit/remove edge cases and mobile layout.
- Reconcile branch/deployment routing and TEST runtime config before publishing. Do not deploy to LIVE directly.

## Next actions
1. Verify the IndexedDB draft and photos in a real browser, including refresh and tenant separation.
2. Confirm login return routing and the actual TEST hostname/project configuration. Current `public-site.js` maps localhost and `.github.io` to legacy project `twfbmjwwqzxdxvclxbun`, while current TEST project is `nnsshnfkjcflucjrftzi`; do not deploy/test until this is reconciled.
3. Run syntax/static checks on both changed files and inspect final diffs.
4. Deploy only to the confirmed TEST environment.
5. Run end-to-end tests against TEST database records and customer/staff views.
6. Update this checkpoint with results, then promote through the approved process only after passing tests.
