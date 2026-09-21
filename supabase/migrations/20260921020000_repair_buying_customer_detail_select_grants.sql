-- Complete subscriber Buying read access for customer and submitted field details.
-- RLS policies remain the tenant/permission boundary.
grant select on table public.customers to authenticated;
grant select on table public.buying_item_field_values to authenticated;
