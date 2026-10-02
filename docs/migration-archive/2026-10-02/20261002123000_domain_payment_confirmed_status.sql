-- Allow a domain order to record confirmed customer payment before registrar submission.
-- Applied to TEST/STAGING on 2026-10-02.
alter table public.tenant_domain_orders drop constraint if exists tenant_domain_orders_status_chk;
alter table public.tenant_domain_orders add constraint tenant_domain_orders_status_chk
  check (status = any (array[
    'pending_payment','payment_failed','payment_confirmed','submitted',
    'registering','registered','failed','cancelled','refunded'
  ]));
