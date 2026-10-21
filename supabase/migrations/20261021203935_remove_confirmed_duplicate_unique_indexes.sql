-- Remove exact duplicate unique indexes after verifying definitions and dependencies.
-- Keep the constraint-backed customer credit unique index and one copy of each partial unique index.
DROP INDEX IF EXISTS public.customer_credit_accounts_tenant_customer_uidx;
DROP INDEX IF EXISTS public.payment_records_tenant_idempotency_idx;
DROP INDEX IF EXISTS public.tenant_domains_one_primary_per_tenant;
