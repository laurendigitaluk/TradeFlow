create table if not exists public.platform_domain_pricing_settings (
  id integer primary key default 1 check (id = 1),
  markup_percent numeric not null default 25.000,
  usd_to_gbp_rate numeric not null default 0.74549089,
  fx_source text not null default 'Bank of England',
  fx_series text not null default 'XUMAUSS',
  fx_basis text not null default '12-month average of monthly USD into Sterling spot rates',
  fx_period_start date not null default date '2025-10-01',
  fx_period_end date not null default date '2026-09-30',
  fx_review_threshold_percent numeric not null default 5.000,
  fx_last_reviewed date not null default date '2026-10-02',
  fx_source_url text not null default 'https://www.bankofengland.co.uk/boeapps/database/index.asp?EC=XUMAUSS&From=Template&G0Xtop.x=1&G0Xtop.y=1&Travel=NIxSUx',
  updated_at timestamptz not null default now()
);

insert into public.platform_domain_pricing_settings
(id, markup_percent, usd_to_gbp_rate, fx_source, fx_series, fx_basis, fx_period_start, fx_period_end, fx_review_threshold_percent, fx_last_reviewed, fx_source_url)
values
(1,25.000,0.74549089,'Bank of England','XUMAUSS','12-month average of monthly USD into Sterling spot rates',date '2025-10-01',date '2026-09-30',5.000,date '2026-10-02','https://www.bankofengland.co.uk/boeapps/database/index.asp?EC=XUMAUSS&From=Template&G0Xtop.x=1&G0Xtop.y=1&Travel=NIxSUx')
on conflict (id) do update set
  markup_percent=excluded.markup_percent,
  usd_to_gbp_rate=excluded.usd_to_gbp_rate,
  fx_source=excluded.fx_source,
  fx_series=excluded.fx_series,
  fx_basis=excluded.fx_basis,
  fx_period_start=excluded.fx_period_start,
  fx_period_end=excluded.fx_period_end,
  fx_review_threshold_percent=excluded.fx_review_threshold_percent,
  fx_last_reviewed=excluded.fx_last_reviewed,
  fx_source_url=excluded.fx_source_url,
  updated_at=now();

alter table public.platform_domain_pricing_settings enable row level security;

drop policy if exists platform_domain_pricing_owner_all on public.platform_domain_pricing_settings;
create policy platform_domain_pricing_owner_all
on public.platform_domain_pricing_settings
as permissive for all to authenticated
using ((select private.is_platform_owner(auth.uid())))
with check ((select private.is_platform_owner(auth.uid())));

create or replace function public.platform_owner_get_domain_pricing()
returns public.platform_domain_pricing_settings
language sql stable security definer
set search_path to pg_catalog, public, private
as $$
  select *
  from public.platform_domain_pricing_settings
  where id = 1
    and private.is_platform_owner(auth.uid());
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
set search_path to pg_catalog, public, private
as $$
declare v_row public.platform_domain_pricing_settings;
begin
  if not private.is_platform_owner(auth.uid()) then raise exception 'Platform owner access required'; end if;
  if p_markup_percent is null or p_markup_percent < 0 or p_markup_percent > 1000 then raise exception 'Markup must be between 0 and 1000 percent'; end if;
  if p_usd_to_gbp_rate is null or p_usd_to_gbp_rate <= 0 or p_usd_to_gbp_rate >= 10 then raise exception 'USD to GBP rate must be greater than 0 and less than 10'; end if;
  if p_fx_period_start is null or p_fx_period_end is null or p_fx_period_start > p_fx_period_end then raise exception 'FX period is invalid'; end if;
  if p_fx_review_threshold_percent is null or p_fx_review_threshold_percent <= 0 or p_fx_review_threshold_percent > 100 then raise exception 'Review threshold must be greater than 0 and no more than 100 percent'; end if;
  update public.platform_domain_pricing_settings
  set markup_percent=round(p_markup_percent,3),
      usd_to_gbp_rate=round(p_usd_to_gbp_rate,8),
      fx_period_start=p_fx_period_start,
      fx_period_end=p_fx_period_end,
      fx_review_threshold_percent=round(p_fx_review_threshold_percent,3),
      fx_last_reviewed=coalesce(p_fx_last_reviewed,current_date),
      updated_at=now()
  where id=1
  returning * into v_row;
  return v_row;
end;
$$;

grant execute on function public.platform_owner_get_domain_pricing() to authenticated;
grant execute on function public.platform_owner_update_domain_pricing(numeric,numeric,date,date,numeric,date) to authenticated;
