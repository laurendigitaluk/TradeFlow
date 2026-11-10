create or replace function public.platform_owner_save_cloud_ai_provider(
 p_provider_key text,p_model_id text,p_enabled boolean,p_free_tier_confirmed boolean,
 p_api_key text default null,p_daily_request_limit integer default 0
) returns jsonb language plpgsql security definer set search_path=public,vault
as $$
declare v_secret_id uuid; v_display text;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if p_provider_key not in ('gemini','groq','openrouter') then raise exception 'Unsupported provider'; end if;
 if coalesce(length(trim(p_model_id)),0)=0 or length(p_model_id)>180 then raise exception 'A valid model ID is required'; end if;
 if p_enabled and not p_free_tier_confirmed then raise exception 'Free-tier confirmation is required before enabling a provider'; end if;
 if p_enabled and p_provider_key='openrouter' and right(trim(p_model_id),5)<>':free' then raise exception 'OpenRouter model IDs must end in :free'; end if;
 if p_daily_request_limit<0 or p_daily_request_limit>10000 then raise exception 'Daily request limit is outside the allowed range'; end if;
 select secret_id into v_secret_id from public.platform_cloud_ai_providers where provider_key=p_provider_key for update;
 if p_api_key is not null and length(trim(p_api_key))>0 then
   if v_secret_id is null then v_secret_id:=vault.create_secret(trim(p_api_key),'tradeflow-cloud-ai-'||p_provider_key,'TradeFlow cloud AI provider credential');
   else perform vault.update_secret(v_secret_id,trim(p_api_key),'tradeflow-cloud-ai-'||p_provider_key,'TradeFlow cloud AI provider credential'); end if;
 end if;
 v_display:=case p_provider_key when 'gemini' then 'Google Gemini' when 'groq' then 'Groq' else 'OpenRouter' end;
 insert into public.platform_cloud_ai_providers(provider_key,display_name,model_id,enabled,free_tier_confirmed,secret_id,status,daily_request_limit,last_error,updated_at)
 values(p_provider_key,v_display,trim(p_model_id),p_enabled,p_free_tier_confirmed,v_secret_id,
 case when p_enabled and v_secret_id is not null then 'ready' when p_enabled then 'error' else 'disabled' end,
 p_daily_request_limit,null,now())
 on conflict(provider_key) do update set display_name=excluded.display_name,model_id=excluded.model_id,
 enabled=excluded.enabled,free_tier_confirmed=excluded.free_tier_confirmed,
 secret_id=coalesce(excluded.secret_id,platform_cloud_ai_providers.secret_id),
 status=case when excluded.enabled and coalesce(excluded.secret_id,platform_cloud_ai_providers.secret_id) is not null then 'ready' when excluded.enabled then 'error' else 'disabled' end,
 daily_request_limit=excluded.daily_request_limit,last_error=null,updated_at=now();
 return jsonb_build_object('saved',true,'provider_key',p_provider_key,'has_key',v_secret_id is not null);
end $$;
