create table if not exists public.platform_ai_settings (
  id boolean primary key default true check (id = true),
  active_provider text not null default 'none' check (active_provider in ('none','gemma','openai','anthropic','google','subscriber')),
  allowed_providers jsonb not null default '["none"]'::jsonb,
  subscriber_provider_enabled boolean not null default false,
  gemma_enabled boolean not null default false,
  openai_enabled boolean not null default false,
  anthropic_enabled boolean not null default false,
  google_enabled boolean not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

insert into public.platform_ai_settings (id)
values (true)
on conflict (id) do nothing;

alter table public.platform_ai_settings enable row level security;
revoke all on public.platform_ai_settings from anon, authenticated;

create or replace function public.platform_owner_get_ai_settings()
returns jsonb
language plpgsql
security definer
set search_path=public,private
as $$
declare r public.platform_ai_settings;
begin
  if not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Platform owner access required';
  end if;
  select * into r from public.platform_ai_settings where id = true;
  return jsonb_build_object(
    'active_provider', r.active_provider,
    'allowed_providers', r.allowed_providers,
    'subscriber_provider_enabled', r.subscriber_provider_enabled,
    'gemma_enabled', r.gemma_enabled,
    'openai_enabled', r.openai_enabled,
    'anthropic_enabled', r.anthropic_enabled,
    'google_enabled', r.google_enabled,
    'updated_at', r.updated_at
  );
end;
$$;

create or replace function public.platform_owner_update_ai_settings(
  p_active_provider text,
  p_subscriber_provider_enabled boolean,
  p_gemma_enabled boolean,
  p_openai_enabled boolean,
  p_anthropic_enabled boolean,
  p_google_enabled boolean
)
returns jsonb
language plpgsql
security definer
set search_path=public,private
as $$
declare allowed jsonb := '["none"]'::jsonb;
declare v_active text := coalesce(nullif(trim(p_active_provider), ''), 'none');
begin
  if not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Platform owner access required';
  end if;

  if p_gemma_enabled then allowed := allowed || '"gemma"'::jsonb; end if;
  if p_openai_enabled then allowed := allowed || '"openai"'::jsonb; end if;
  if p_anthropic_enabled then allowed := allowed || '"anthropic"'::jsonb; end if;
  if p_google_enabled then allowed := allowed || '"google"'::jsonb; end if;
  if p_subscriber_provider_enabled then allowed := allowed || '"subscriber"'::jsonb; end if;

  if not (v_active = 'none' or allowed ? v_active) then
    raise exception 'Active provider must be enabled first';
  end if;

  update public.platform_ai_settings
  set active_provider = v_active,
      allowed_providers = allowed,
      subscriber_provider_enabled = coalesce(p_subscriber_provider_enabled,false),
      gemma_enabled = coalesce(p_gemma_enabled,false),
      openai_enabled = coalesce(p_openai_enabled,false),
      anthropic_enabled = coalesce(p_anthropic_enabled,false),
      google_enabled = coalesce(p_google_enabled,false),
      updated_at = now(),
      updated_by = auth.uid()
  where id = true;

  return public.platform_owner_get_ai_settings();
end;
$$;

revoke all on function public.platform_owner_get_ai_settings() from public,anon;
revoke all on function public.platform_owner_update_ai_settings(text,boolean,boolean,boolean,boolean,boolean) from public,anon;
grant execute on function public.platform_owner_get_ai_settings() to authenticated;
grant execute on function public.platform_owner_update_ai_settings(text,boolean,boolean,boolean,boolean,boolean) to authenticated;
