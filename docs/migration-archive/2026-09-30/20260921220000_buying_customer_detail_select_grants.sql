-- Repair subscriber visibility of customer supplied buying details and customer contact records.
grant select on table public.buying_item_field_values to authenticated;
grant select on table public.customers to authenticated;
