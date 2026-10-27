# TradeFlow TEST/LIVE Parity Continuation — 2026-10-27

## Goal
Align the deployable application, schema/migrations, master catalogue, shared market evidence and customer-facing behaviour between TEST and LIVE. TEST remains the designated test environment after parity is established.

## Non-negotiable separation
Do not copy TEST operational data into LIVE or LIVE operational data into TEST. Tenant/customer identities, memberships, subscriptions, orders, payments, Stripe configuration, domain ownership/registration, website content, inventory and workflow history remain environment-specific. Never sync secrets or provider credentials.

## Read-only comparison performed 2026-10-27
Supabase project refs:
- TEST: `nnsshnfkjcflucjrftzi`
- LIVE: `gxsrajtqzdjvmceqcpgv`

Recorded migration counts: TEST 125; LIVE 93.
Public table counts: TEST 106; LIVE 105.
Only TEST table in the compact listing: `catalogue_master_category_aliases`. No table appeared only in LIVE.
Repository `supabase/migrations` currently contains only 28 migration files and its latest file is `20261026130000_separate_internal_catalogue_from_customer_visibility.sql`. It does not contain the later operational data/evidence batch migrations listed in the Supabase migration histories. Therefore migration history cannot be made consistent merely by replaying the current repository directory; first reconcile which schema changes are represented in version control and which were applied ad hoc.

Selected table counts:
| Table | TEST | LIVE |
|---|---:|---:|
| catalogue_master_products | 46,590 | 46,953 |
| catalogue_master_categories | 38 | 36 |
| catalogue_master_branches | 192 | 188 |
| catalogue_master_manufacturers | 106 | 96 |
| catalogue_master_product_identifiers | 108 | 419 |
| tenant_catalogue_selections | 52 | 213 |
| tenant_buying_products | 52 | 213 |
| shared_market_evidence | 4,225 | 3,807 |
| pokemon_tcg_cards | 42,395 | 42,453 |
| pokemon_tcg_sets | 569 | 574 |
| pokemon_tcg_card_variants | 1,071 | 1,895 |

Operational table counts intentionally differ and must not be treated as catalogue parity failures: LIVE contains customer, acquisition, inventory, order, payment, domain, shipping, published-site and workflow records; TEST has a different tenant/member/subscription shape. Keep these records isolated.

Migration histories are divergent in both directions: many TEST-only recorded migrations and a set of LIVE-only recorded migrations. Some similarly named changes have different timestamped names. Compare actual SQL/function definitions and outcomes before making migration changes; do not mark migrations as applied or replay them blindly.

## Current blocking issue: Pokémon source classification
Previous checkpoint records that LIVE English Pokémon source categories are misclassified, and the canonical reconciliation script exists but has not been run in this environment. Do not expose Pokémon to customer valuation as ready until source categories and corresponding master-product branches are verified. No name-only category heuristics.

## Controlled parity sequence
1. Freeze destructive sync operations; take/export backups or restore points using the platform's supported mechanisms before any writes.
2. Compare repository migrations against actual TEST and LIVE schema/function/policy/index definitions. Add missing durable migration files to version control where their SQL is known; author corrective migrations for genuine drift. Apply schema changes to TEST first, verify, then LIVE.
3. Build a stable-key reconciliation for master catalogue categories, branches, manufacturers, products and identifiers. Use normalized stable keys and exact identifiers; report duplicates/unmatched rows before writes.
4. Reconcile shared market evidence by stable product key + source URL/ID + condition + price type/currency; retain provenance and avoid duplicates. UK GBP only where this is the product rule. Do not copy tenant-private research.
5. Reconcile Pokémon sets/cards/variants using canonical source keys; repair category classification and master branch mapping before customer enablement.
6. Compare tenant catalogue selection defaults separately. Only copy platform-wide product catalogue settings that are explicitly shared; do not copy tenant-owned configuration blindly.
7. Run automated schema/function checks, catalogue/evidence counts, duplicate checks, and a signed-in customer valuation smoke test in TEST. Confirm offer calculation uses the existing valuation path.
8. Promote verified code/migrations and shared catalogue/evidence changes to LIVE, keeping all LIVE operational records and provider configuration untouched. Verify LIVE with read-only checks and a controlled customer-facing smoke test.
9. Record a parity manifest/checkpoint with commit SHA, migration versions, counts and explicit remaining exceptions. Once stable, use TEST for ongoing testing and promote through the same controlled process.

## Current status
This pass performed read-only comparison only. No database rows, schema, migration history, tenant configuration, Stripe settings or customer data were changed. Do not claim TEST/LIVE parity until the sequence above has been executed and verified.
