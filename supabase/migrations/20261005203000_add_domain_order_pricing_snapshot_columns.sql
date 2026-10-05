alter table public.tenant_domain_orders
  add column if not exists registrar_cost_usd numeric(12,4),
  add column if not exists fx_rate_gbp_per_usd numeric(18,8),
  add column if not exists markup_percent numeric(10,3),
  add column if not exists pricing_source text,
  add column if not exists pricing_period_start date,
  add column if not exists pricing_period_end date;

notify pgrst, 'reload schema';
