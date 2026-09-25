-- Ensure each customer has one credit account per tenant.
-- Required by subscriber_credit_trade_in's ON CONFLICT (tenant_id, customer_id).
create unique index if not exists customer_credit_accounts_tenant_customer_uidx
  on public.customer_credit_accounts(tenant_id, customer_id);
