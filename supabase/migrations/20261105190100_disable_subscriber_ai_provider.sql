-- Disable subscriber-supplied AI providers. The TradeFlow Assistant remains
-- available as a platform-managed service; this removes subscriber-owned provider
-- selection without affecting subscriber accounts, tenants or conversations.
update public.platform_ai_settings
   set active_provider=case when active_provider='subscriber' then 'none' else active_provider end,
       subscriber_provider_enabled=false,
       allowed_providers=coalesce((
         select jsonb_agg(value)
         from jsonb_array_elements(allowed_providers) as p(value)
         where value <> '"subscriber"'::jsonb
       ), '["none"]'::jsonb),
       updated_at=now()
 where id=true;

create or replace function public.platform_owner_update_ai_settings(
  p_active_provider text,
  p_subscriber_provider_enabled boolean,
  p_gemma_enabled boolean,
  p_openai_enabled boolean,
  p_anthropic_enabled boolean,
  p_google_enabled boolean
) returns jsonb
language plpgsql security definer
set search_path=public,private
as $$
declare allowed jsonb := '["none"]'::jsonb;
declare v_active text := coalesce(nullif(trim(p_active_provider), ''), 'none');
begin
  if not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then raise exception 'Platform owner access required'; end if;

  if coalesce(p_subscriber_provider_enabled,false) or v_active='subscriber' then
    raise exception 'Subscriber-supplied AI providers are disabled; use platform-managed providers';
  end if;

  if p_gemma_enabled then allowed := allowed || '"gemma"'::jsonb; end if;
  if p_openai_enabled then allowed := allowed || '"openai"'::jsonb; end if;
  if p_anthropic_enabled then allowed := allowed || '"anthropic"'::jsonb; end if;
  if p_google_enabled then allowed := allowed || '"google"'::jsonb; end if;
  if not (v_active = 'none' or allowed ? v_active) then
    raise exception 'Active provider must be enabled first';
  end if;

  update public.platform_ai_settings
     set active_provider=v_active,
         allowed_providers=allowed,
         subscriber_provider_enabled=false,
         gemma_enabled=coalesce(p_gemma_enabled,false),
         openai_enabled=coalesce(p_openai_enabled,false),
         anthropic_enabled=coalesce(p_anthropic_enabled,false),
         google_enabled=coalesce(p_google_enabled,false),
         updated_at=now(),
         updated_by=auth.uid()
   where id=true;
  return public.platform_owner_get_ai_settings();
end;
$$;

revoke all on function public.platform_owner_update_ai_settings(text,boolean,boolean,boolean,boolean,boolean) from public,anon;
grant execute on function public.platform_owner_update_ai_settings(text,boolean,boolean,boolean,boolean,boolean) to authenticated;
