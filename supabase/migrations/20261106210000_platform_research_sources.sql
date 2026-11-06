-- TradeFlow research source registry, modelled on the proven GearCashOut source registry.
-- Source discovery is read by the local service-role agent; no customer-facing access.
create table if not exists public.platform_research_sources (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  domain text not null,
  homepage_url text,
  source_kind text not null default 'retailer'
    check (source_kind in ('manufacturer','retailer','marketplace','used_dealer','auction','other')),
  country_code text not null default 'GB',
  research_scope text not null default 'all'
    check (research_scope in ('all','new_uk','used_uk','overseas','official')),
  enabled boolean not null default true,
  priority integer not null default 100,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint platform_research_sources_domain_unique unique (domain)
);
create index if not exists platform_research_sources_enabled_priority_idx
  on public.platform_research_sources (enabled, priority, country_code);
alter table public.platform_research_sources enable row level security;
revoke all on table public.platform_research_sources from anon, authenticated;
grant select on table public.platform_research_sources to service_role;
comment on table public.platform_research_sources is
  'Approved product research source registry for the local TradeFlow research agent. Service-role read only at runtime.';
