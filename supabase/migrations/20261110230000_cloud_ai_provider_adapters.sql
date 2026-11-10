alter table public.platform_cloud_ai_providers drop constraint if exists platform_cloud_ai_providers_provider_key_check;
alter table public.platform_cloud_ai_providers add constraint platform_cloud_ai_provider_key_format check(provider_key ~ '^[a-z][a-z0-9_]{1,39}$');
alter table public.platform_cloud_ai_providers add column if not exists api_base_url text;
alter table public.platform_cloud_ai_providers add column if not exists api_protocol text not null default 'openai_compatible' check(api_protocol in ('openai_compatible','gemini'));
alter table public.platform_cloud_ai_providers add column if not exists daily_usage_date date not null default current_date;

create or replace function public.platform_owner_save_cloud_ai_provider(
 p_provider_key text,p_model_id text,p_enabled boolean,p_free_tier_confirmed boolean,
 p_api_key text default null,p_daily_request_limit integer default 20
) returns jsonb language plpgsql security definer set search_path=public,vault
as $$
declare v_secret_id uuid; v_display text; v_base text; v_protocol text;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if p_provider_key not in ('gemini','groq','openrouter','cerebras','sambanova','nvidia_nim','mistral','huggingface','github_models') then raise exception 'Unsupported provider adapter'; end if;
 if coalesce(length(trim(p_model_id)),0)=0 or length(p_model_id)>180 then raise exception 'A valid model ID is required'; end if;
 if p_enabled and not p_free_tier_confirmed then raise exception 'Free-tier confirmation is required before enabling a provider'; end if;
 if p_enabled and p_provider_key='openrouter' and right(trim(p_model_id),5)<>':free' then raise exception 'OpenRouter model IDs must end in :free'; end if;
 if p_enabled and (p_daily_request_limit<1 or p_daily_request_limit>10000) then raise exception 'Enabled providers require a daily request cap from 1 to 10000'; end if;
 if p_daily_request_limit<0 or p_daily_request_limit>10000 then raise exception 'Daily request limit is outside the allowed range'; end if;
 v_base:=case p_provider_key when 'groq' then 'https://api.groq.com/openai/v1' when 'openrouter' then 'https://openrouter.ai/api/v1' when 'cerebras' then 'https://api.cerebras.ai/v1' when 'sambanova' then 'https://api.sambanova.ai/v1' when 'nvidia_nim' then 'https://integrate.api.nvidia.com/v1' when 'mistral' then 'https://api.mistral.ai/v1' when 'huggingface' then 'https://router.huggingface.co/v1' when 'github_models' then 'https://models.inference.ai.azure.com' when 'gemini' then 'https://generativelanguage.googleapis.com/v1beta' end;
 v_protocol:=case when p_provider_key='gemini' then 'gemini' else 'openai_compatible' end;
 v_display:=case p_provider_key when 'gemini' then 'Google Gemini' when 'groq' then 'Groq' when 'openrouter' then 'OpenRouter' when 'cerebras' then 'Cerebras' when 'sambanova' then 'SambaNova' when 'nvidia_nim' then 'NVIDIA NIM' when 'mistral' then 'Mistral' when 'huggingface' then 'Hugging Face' else 'GitHub Models' end;
 select secret_id into v_secret_id from public.platform_cloud_ai_providers where provider_key=p_provider_key for update;
 if p_api_key is not null and length(trim(p_api_key))>0 then
  if v_secret_id is null then v_secret_id:=vault.create_secret(trim(p_api_key),'tradeflow-cloud-ai-'||p_provider_key,'TradeFlow cloud AI provider credential');
  else perform vault.update_secret(v_secret_id,trim(p_api_key),'tradeflow-cloud-ai-'||p_provider_key,'TradeFlow cloud AI provider credential'); end if;
 end if;
 insert into public.platform_cloud_ai_providers(provider_key,display_name,model_id,api_base_url,api_protocol,enabled,free_tier_confirmed,secret_id,status,daily_request_limit,daily_requests_used,daily_usage_date,last_error,updated_at)
 values(p_provider_key,v_display,trim(p_model_id),v_base,v_protocol,p_enabled,p_free_tier_confirmed,v_secret_id,
 case when p_enabled and v_secret_id is not null then 'ready' when p_enabled then 'error' else 'disabled' end,p_daily_request_limit,0,current_date,null,now())
 on conflict(provider_key) do update set display_name=excluded.display_name,model_id=excluded.model_id,api_base_url=excluded.api_base_url,api_protocol=excluded.api_protocol,enabled=excluded.enabled,free_tier_confirmed=excluded.free_tier_confirmed,secret_id=coalesce(excluded.secret_id,platform_cloud_ai_providers.secret_id),status=case when excluded.enabled and coalesce(excluded.secret_id,platform_cloud_ai_providers.secret_id) is not null then 'ready' when excluded.enabled then 'error' else 'disabled' end,daily_request_limit=excluded.daily_request_limit,daily_requests_used=0,daily_usage_date=current_date,last_error=null,updated_at=now();
 return jsonb_build_object('saved',true,'provider_key',p_provider_key,'has_key',v_secret_id is not null);
end $$;
revoke all on function public.platform_owner_save_cloud_ai_provider(text,text,boolean,boolean,text,integer) from public,anon;
grant execute on function public.platform_owner_save_cloud_ai_provider(text,text,boolean,boolean,text,integer) to authenticated;
