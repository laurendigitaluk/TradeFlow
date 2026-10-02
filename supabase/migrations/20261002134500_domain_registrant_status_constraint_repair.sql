alter table public.tenant_domain_orders drop constraint if exists tenant_domain_orders_status_chk;
alter table public.tenant_domain_orders drop constraint if exists tenant_domain_orders_status_check;
alter table public.tenant_domain_orders add constraint tenant_domain_orders_status_chk check (status = any (array[
'pending_payment'::text,'payment_failed'::text,'payment_confirmed'::text,'registrant_details_saved'::text,
'submitted'::text,'registering'::text,'registered'::text,'failed'::text,'cancelled'::text,'refunded'::text
]));