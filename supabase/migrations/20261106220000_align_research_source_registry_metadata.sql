-- Align the TradeFlow approved-source registry with the established GearCashOut source metadata.
alter table public.platform_research_sources
  add column if not exists search_url_template text,
  add column if not exists last_verified_at timestamptz,
  add column if not exists discovery_status text,
  add column if not exists site_status text,
  add column if not exists monitor_for_opening boolean not null default false,
  add column if not exists opening_soon_detected_at timestamptz,
  add column if not exists opened_at timestamptz,
  add column if not exists last_status_checked_at timestamptz,
  add column if not exists status_note text,
  add column if not exists discovery_count integer not null default 0;
alter table public.platform_research_sources
  drop constraint if exists platform_research_sources_research_scope_check;
alter table public.platform_research_sources
  add constraint platform_research_sources_research_scope_check
  check (research_scope in ('all','new_uk','used_uk','overseas','official','discovered','manufacturer'));
