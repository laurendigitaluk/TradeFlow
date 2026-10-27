# TradeFlow TEST/LIVE Schema Comparison — 2026-10-27

This note extends `CHECKPOINTS/2026-10-27-test-live-parity-reconciliation.md`.

## Comparison method
Read-only queries compared public table columns (including type/nullability/default), public function signatures and return types, RLS policy names/table/command/roles, indexes, triggers, and table-constraint names/types in TEST and LIVE. This is a structural comparison, not a full semantic comparison of function bodies or policy expressions.

## Results

### Exact matches in the compared metadata
- Public function signatures and return types: **206 TEST / 206 LIVE; no signature-level differences**.
- RLS policy table/name/command/roles: **318 TEST / 318 LIVE; no differences on those fields**.
- Public triggers by table/name/event/timing/action statement: **85 TEST / 85 LIVE; no differences**.

These matches are useful evidence that the core API/security/trigger surface is close, but do not prove that function bodies, policy expressions, grants, data, or runtime behaviour are identical.

### Column-level schema difference
- TEST has 1,446 public columns; LIVE has 1,437.
- The nine extra TEST columns are all in `catalogue_master_category_aliases`:
  `id`, `alias`, `alias_key`, `category_id`, `source_name`, `notes`, `active`, `created_at`, `branch_id`.
- The table itself exists only in TEST. This is a schema feature gap and needs a version-controlled migration if it is intended to be part of the canonical application. Before adding it to LIVE, inspect its use in code/RPCs and verify foreign-key/category compatibility. Do not copy TEST rows into LIVE without duplicate/key review.

### Index differences requiring semantic review
The index metadata comparison found these meaningful-looking differences:
- TEST has `shared_market_evidence_product_active_idx` on `(master_product_id, evidence_type, observed_at DESC) WHERE is_active = true`; LIVE instead has `shared_market_evidence_product_type_date_idx` on the same keys and a similar predicate. Likely naming drift, but compare exact definitions and query usage before deciding whether to normalize.
- TEST has `shared_market_evidence_source_key_unique`; LIVE has `shared_market_evidence_source_name_source_record_key_key`. Both are unique on `(source_name, source_record_key)`; likely equivalent with different names.
- LIVE has `customer_credit_accounts_tenant_customer_uidx`, `payment_records_tenant_idempotency_idx`, and `tenant_domains_one_primary_per_tenant`, which were not present in the TEST index metadata. These must be inspected before changing anything; some protect financial idempotency and domain integrity and should not be removed.
- TEST indexes on `catalogue_master_category_aliases` are absent in LIVE because the table is absent there.

Constraint names on automatically generated NOT NULL checks differ due to different internal table/object identifiers; do not treat those name differences alone as semantic schema drift. Compare actual column nullability and constraint definitions rather than generated names.

## Next safe actions
1. Inspect the actual SQL in repository for category alias resolver usage and the intended migration; create a version-controlled migration for the missing alias table only if confirmed required.
2. Compare full index definitions and function bodies/grants/policy expressions where security or behaviour may differ.
3. Do not drop/recreate LIVE financial idempotency, credit-account uniqueness, or primary-domain indexes merely to force name parity.
4. After structural review, continue with stable-key catalogue/evidence reconciliation; do not sync operational tenant data.

## Writes performed
No Supabase writes were made by this comparison. This is a read-only report.
