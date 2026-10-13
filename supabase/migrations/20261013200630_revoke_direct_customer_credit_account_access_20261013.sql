-- Customer credit accounts are accessed through tenant- and identity-checked RPCs only.
-- RLS is enabled with no direct-client policies, so direct table grants are unnecessary.
REVOKE ALL PRIVILEGES ON TABLE public.customer_credit_accounts FROM anon, authenticated;
