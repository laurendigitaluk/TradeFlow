-- TradeFlow domain pricing controls
-- Applied to TEST/STAGING on 2026-10-02.
--
-- Registrar availability/pricing is supplied by Porkbun in USD.
-- TradeFlow customer pricing is calculated in GBP using the stored 12-month
-- Bank of England USD/GBP rate plus the owner-controlled markup.

create table if not exists public.platform_domain_pricing_settings (
  id integer primary key default 1,
  markup_percent numeric(6,3) not null default 25.000,
  usd_to_gbp_rate numeric(12,8) not null default 0.74549089,
  fx_source text not null default 'Bank of England',
  fx_series text not null default 'XUMAUSS',
  fx_basis text not null default '12-month average of monthly USD into Sterling spot rates',
  fx_period_start date not null default date '2025-10-01',
  fx_period_end date not null default date '2026-09-30',
  fx_review_threshold_percent numeric(6,3) not null default 5.000,
  fx_last_reviewed date not null default date '2026-10-02',
  fx_source_url text not null default 'https://www.bankofengland.co.uk/boeapps/database/index.asp?EC=XUMAUSS&From=Template&G0Xtop.x=1&G0Xtop.y=1&Travel=NIxSUx',
  updated_at timestamptz not null default now(),
  constraint platform_domain_pricing_settings_singleton_chk check (id = 1),
  constraint platform_domain_pricing_settings_markup_chk check (markup_percent >= 0 and markup_percent <= 1000),
  constraint platform_domain_pricing_settings_rate_chk check (usd_to_gbp_rate > 0 and usd_to_gbp_rate < 10),
  constraint platform_domain_pricing_settings_threshold_chk check (fx_review_threshold_percent > 0 and fx_review_threshold_percent <= 100)
);

insert into public.platform_domain_pricing_settings (
  id, markup_percent, usd_to_gbp_rate, fx_source, fx_series, fx_basis,
  fx_period_start, fx_period_end, fx_review_threshold_percent,
  fx_last_reviewed, fx_source_url
)
values (
  1, 25.000, 0.74549089, 'Bank of England', 'XUMAUSS',
  '12-month average of monthly USD into Sterling spot rates',
  date '2025-10-01', date '2026-09-30', 5.000,
  date '2026-10-02',
  'https://www.bankofengland.co.uk/boeapps/database/index.asp?EC=XUMAUSS&From=Template&G0Xtop.x=1&G0Xtop.y=1&Travel=NIxSUx'
)
on conflict (id) do nothing;

alter table public.platform_domain_pricing_settings enable row level security;
revoke all on public.platform_domain_pricing_settings from anon, authenticated;

drop policy if exists platform_domain_pricing_owner_read on public.platform_domain_pricing_settings;
create policy platform_domain_pricing_owner_read on public.platform_domain_pricing_settings
  for select to authenticated using (private.is_platform_owner(auth.uid()));

drop policy if exists platform_domain_pricing_owner_write on public.platform_domain_pricing_settings;
create policy platform_domain_pricing_owner_write on public.platform_domain_pricing_settings
  for all to authenticated
  using (private.is_platform_owner(auth.uid()))
  with check (private.is_platform_owner(auth.uid()));

grant select, insert, update on public.platform_domain_pricing_settings to authenticated;

create or replace function public.platform_owner_get_domain_pricing()
returns public.platform_domain_pricing_settings
language sql stable security definer
set search_path = pg_catalog, public, private
as $$
  select * from public.platform_domain_pricing_settings
  where id = 1 and private.is_platform_owner(auth.uid());
$$;

create or replace function public.platform_owner_update_domain_pricing(
  p_markup_percent numeric,
  p_usd_to_gbp_rate numeric,
  p_fx_period_start date,
  p_fx_period_end date,
  p_fx_review_threshold_percent numeric,
  p_fx_last_reviewed date
)
returns public.platform_domain_pricing_settings
language plpgsql security definer
set search_path = pg_catalog, public, private
as $$
declare
  v_row public.platform_domain_pricing_settings;
begin
  if not private.is_platform_owner(auth.uid()) then
    raise exception 'Platform owner access required';
  end if;
  if p_markup_percent is null or p_markup_percent < 0 or p_markup_percent > 1000 then
    raise exception 'Markup must be between 0 and 1000 percent';
  end if;
  if p_usd_to_gbp_rate is null or p_usd_to_gbp_rate <= 0 or p_usd_to_gbp_rate >= 10 then
    raise exception 'USD to GBP rate must be greater than 0 and less than 10';
  end if;
  if p_fx_period_start is null or p_fx_period_end is null or p_fx_period_start > p_fx_period_end then
    raise exception 'FX period is invalid';
  end if;
  if p_fx_review_threshold_percent is null or p_fx_review_threshold_percent <= 0 or p_fx_review_threshold_percent > 100 then
    raise exception 'Review threshold must be greater than 0 and no more than 100 percent';
  end if;
  update public.platform_domain_pricing_settings
     set markup_percent = round(p_markup_percent, 3),
         usd_to_gbp_rate = round(p_usd_to_gbp_rate, 8),
         fx_period_start = p_fx_period_start,
         fx_period_end = p_fx_period_end,
         fx_review_threshold_percent = round(p_fx_review_threshold_percent, 3),
         fx_last_reviewed = coalesce(p_fx_last_reviewed, current_date),
         updated_at = now()
   where id = 1
   returning * into v_row;
  return v_row;
end;
$$;

revoke all on function public.platform_owner_get_domain_pricing() from public, anon;
revoke all on function public.platform_owner_update_domain_pricing(numeric,numeric,date,date,numeric,date) from public, anon;
grant execute on function public.platform_owner_get_domain_pricing() to authenticated;
grant execute on function public.platform_owner_update_domain_pricing(numeric,numeric,date,date,numeric,date) to authenticated;

alter table public.tenant_domain_orders
  add column if not exists registrar_cost_usd numeric(12,4),
  add column if not exists fx_rate_gbp_per_usd numeric(12,8),
  add column if not exists markup_percent numeric(6,3),
  add column if not exists pricing_source text,
  add column if not exists pricing_period_start date,
  add column if not exists pricing_period_end date;

comment on table public.platform_domain_pricing_settings is 'Platform-owner controls for converting registrar USD domain costs into customer GBP prices.';
comment on column public.platform_domain_pricing_settings.usd_to_gbp_rate is 'Fixed GBP received per 1 USD for domain customer pricing; snapshot basis is recorded with each paid domain order.';
comment on column public.platform_domain_pricing_settings.fx_review_threshold_percent is 'Owner monitoring threshold for reviewing the stored FX rate against the current market rate.';
comment on column public.tenant_domain_orders.registrar_cost_usd is 'Registrar quoted cost in USD captured when the domain order is priced.';
comment on column public.tenant_domain_orders.fx_rate_gbp_per_usd is 'GBP per USD rate captured for this domain order.';
comment on column public.tenant_domain_orders.markup_percent is 'Domain retail markup captured for this order so later settings changes do not alter historical pricing.';
