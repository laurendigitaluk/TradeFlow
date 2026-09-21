-- Repair subscriber/customer visibility for buying request details and valuation handoff
grant select on table public.buying_item_field_values to authenticated;
grant select on table public.customers to authenticated;

comment on table public.buying_item_field_values is 'Tenant-scoped customer supplied buying fields. SELECT is protected by tenant RLS policies.';
comment on table public.customers is 'Tenant-scoped customer records. SELECT is protected by tenant RLS policies.';
