-- Ensure subscriber staff can read customer-supplied structured buying fields.
-- RLS already restricts access to tenant members / buying permission.
grant select on table public.buying_item_field_values to authenticated;
