-- Storage signed-URL policy evaluation references fulfilments and retail_orders.
-- Keep RLS as the row-level boundary while granting authenticated the table privilege
-- required for PostgreSQL to evaluate the storage.objects SELECT policy.
grant select on table public.fulfilments to authenticated;
grant select on table public.retail_orders to authenticated;
