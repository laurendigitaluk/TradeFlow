# Checkpoint — 2026-09-29 — Subscriber Customer Addresses and Protected Bank Details

## Scope
Subscriber Customers page only. Existing customer portal, Camerashack/Test Five retail data, shipping and buying workflow remain unchanged.

## Finding
Customer payment/billing and delivery/shipping addresses were already persisted correctly in public.customer_addresses, but the subscriber Customers page only displayed the customer's core profile fields. Bank details were stored in public.customer_bank_details and were intentionally protected from direct table access, but the general customer record had no controlled bank-details display.

## Repair
Added tenant-scoped subscriber RPCs:
- subscriber_get_customer_addresses(p_tenant_id,p_customer_id) — authenticated tenant-member access.
- subscriber_get_customer_bank_details_for_customer(p_tenant_id,p_customer_id) — authenticated tenant-member access plus finance.view permission.

Updated customers.js so opening a customer loads:
- Payment/billing address.
- Delivery/shipping address.
- Bank-details availability.

Bank details are hidden behind a hover/focus interaction. The UI is not treated as the security boundary: the RPC requires tenant membership and finance.view, and the bank table remains inaccessible directly to authenticated users.

Updated customers.html with the address panels and protected bank-details hover card, and bumped the script cache version to v3.

## Live database
The two new RPCs were applied to live Supabase before the repository migration was committed.

## Verification
Existing customer address persistence was already verified in Test Sub 2 after refresh. Existing bank-detail persistence was also verified after refresh using test data.

## Commits
- 987b2a269ec75fc96055a6fdf1bdda648d2eb0b0 — subscriber customer detail loading.
- 71c032b4185f61d033730c3dde5a94bfa4d18b5a — customer detail UI and cache bump.
- ffbbb7ae21d622548495ed73a67b863318ad7aec — reproducible Supabase migration.

## Test
After GitHub Pages publishes:
1. Open Subscriber → Customers.
2. Open Test Sub 2 customer.
3. Confirm payment/billing address appears.
4. Confirm delivery/shipping address appears when present.
5. Confirm bank details show as protected/hidden until hover or keyboard focus.
6. Confirm the actual bank values appear only to a subscriber with finance.view.
7. Test Camerashack separately and confirm no cross-tenant customer/address/bank data is visible.

Do not alter Test One or existing Test Five retail purchase data.
