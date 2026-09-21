-- Repair missing PostgREST SELECT grants for subscriber Buying workflow tables.
-- RLS remains the tenant/subscription/permission boundary.
grant select on table public.buying_requests to authenticated;
grant select on table public.buying_items to authenticated;
grant select on table public.trading_values to authenticated;
grant select on table public.offers to authenticated;
