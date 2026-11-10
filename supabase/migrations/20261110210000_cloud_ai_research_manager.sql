-- Cloud AI Research Manager foundation. Deployed directly to TradeFlow LIVE.
create table if not exists public.platform_cloud_ai_providers (
 id uuid primary key default gen_random_uuid(),
 provider_key text not null unique check (provider_key in ('gemini','groq','openrouter')),
 display_name text not null,
 model_id text not null,
 enabled boolean not null default false,
 free_tier_confirmed boolean not null default false,
 secret_id uuid,
 status text not null default 'not_configured' check(status in ('not_configured','ready','cooldown','disabled','error')),
 cooldown_until timestamptz,
 last_checked_at timestamptz,
 last_error text,
 daily_request_limit integer not null default 0 check(daily_request_limit>=0),
 daily_requests_used integer not null default 0 check(daily_requests_used>=0),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.platform_cloud_ai_research_jobs (
 id uuid primary key default gen_random_uuid(),
 job_key text not null unique,
 category_slug text,
 manufacturer text not null,
 model text not null,
 package_name text,
 task_type text not null default 'price_evidence' check(task_type in ('price_evidence','product_discovery','release_check')),
 status text not null default 'queued' check(status in ('queued','running','submitted','paused','failed','cancelled')),
 assigned_provider text,
 attempts integer not null default 0,
 max_attempts integer not null default 5,
 next_attempt_at timestamptz not null default now(),
 lease_expires_at timestamptz,
 result_report_id uuid,
 last_error text,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists idx_cloud_ai_jobs_ready on public.platform_cloud_ai_research_jobs(status,next_attempt_at,created_at);
alter table public.platform_cloud_ai_providers enable row level security;
alter table public.platform_cloud_ai_research_jobs enable row level security;
revoke all on public.platform_cloud_ai_providers from anon,authenticated;
revoke all on public.platform_cloud_ai_research_jobs from anon,authenticated;

create or replace function public.platform_cloud_ai_owner_check()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.platform_memberships m where m.user_id=auth.uid() and m.status='active'); $$;
revoke all on function public.platform_cloud_ai_owner_check() from public,anon;
grant execute on function public.platform_cloud_ai_owner_check() to authenticated;

create or replace function public.platform_owner_list_cloud_ai_providers()
returns jsonb language plpgsql security definer set search_path=public
as $$
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 return coalesce((select jsonb_agg(jsonb_build_object(
  'provider_key',provider_key,'display_name',display_name,'model_id',model_id,'enabled',enabled,
  'free_tier_confirmed',free_tier_confirmed,'has_key',(secret_id is not null),'status',status,
  'cooldown_until',cooldown_until,'last_checked_at',last_checked_at,'last_error',last_error,
  'daily_request_limit',daily_request_limit,'daily_requests_used',daily_requests_used
 ) order by provider_key) from public.platform_cloud_ai_providers),'[]'::jsonb);
end $$;
revoke all on function public.platform_owner_list_cloud_ai_providers() from public,anon;
grant execute on function public.platform_owner_list_cloud_ai_providers() to authenticated;

create or replace function public.platform_owner_save_cloud_ai_provider(
 p_provider_key text,p_model_id text,p_enabled boolean,p_free_tier_confirmed boolean,
 p_api_key text default null,p_daily_request_limit integer default 0
) returns jsonb language plpgsql security definer set search_path=public,vault
as $$
declare v_secret_id uuid; v_name text; v_display text;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if p_provider_key not in ('gemini','groq','openrouter') then raise exception 'Unsupported provider'; end if;
 if coalesce(length(trim(p_model_id)),0)=0 or length(p_model_id)>180 then raise exception 'A valid model ID is required'; end if;
 if p_enabled and not p_free_tier_confirmed then raise exception 'Free-tier confirmation is required before enabling a provider'; end if;
 if p_daily_request_limit<0 or p_daily_request_limit>10000 then raise exception 'Daily request limit is outside the allowed range'; end if;
 select secret_id into v_secret_id from public.platform_cloud_ai_providers where provider_key=p_provider_key for update;
 if p_api_key is not null and length(trim(p_api_key))>0 then
   if v_secret_id is null then
     v_secret_id:=vault.create_secret(trim(p_api_key),'tradeflow-cloud-ai-'||p_provider_key,'TradeFlow cloud AI provider credential');
   else
     perform vault.update_secret(v_secret_id,trim(p_api_key),'tradeflow-cloud-ai-'||p_provider_key,'TradeFlow cloud AI provider credential');
   end if;
 end if;
 v_display:=case p_provider_key when 'gemini' then 'Google Gemini' when 'groq' then 'Groq' else 'OpenRouter' end;
 insert into public.platform_cloud_ai_providers(provider_key,display_name,model_id,enabled,free_tier_confirmed,secret_id,status,daily_request_limit,last_error,updated_at)
 values(p_provider_key,v_display,p_model_id,p_enabled,p_free_tier_confirmed,v_secret_id,
 case when p_enabled and v_secret_id is not null then 'ready' when p_enabled then 'error' else 'disabled' end,
 p_daily_request_limit,null,now())
 on conflict(provider_key) do update set display_name=excluded.display_name,model_id=excluded.model_id,
 enabled=excluded.enabled,free_tier_confirmed=excluded.free_tier_confirmed,
 secret_id=coalesce(excluded.secret_id,platform_cloud_ai_providers.secret_id),
 status=case when excluded.enabled and coalesce(excluded.secret_id,platform_cloud_ai_providers.secret_id) is not null then 'ready' when excluded.enabled then 'error' else 'disabled' end,
 daily_request_limit=excluded.daily_request_limit,last_error=null,updated_at=now();
 return jsonb_build_object('saved',true,'provider_key',p_provider_key,'has_key',v_secret_id is not null);
end $$;
revoke all on function public.platform_owner_save_cloud_ai_provider(text,text,boolean,boolean,text,integer) from public,anon;
grant execute on function public.platform_owner_save_cloud_ai_provider(text,text,boolean,boolean,text,integer) to authenticated;

create or replace function public.platform_owner_list_cloud_ai_jobs(p_limit integer default 50)
returns jsonb language plpgsql security definer set search_path=public
as $$
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 return coalesce((select jsonb_agg(to_jsonb(j) order by j.created_at desc) from (select id,job_key,category_slug,manufacturer,model,package_name,task_type,status,assigned_provider,attempts,max_attempts,next_attempt_at,last_error,created_at,updated_at from public.platform_cloud_ai_research_jobs order by created_at desc limit greatest(1,least(coalesce(p_limit,50),200))) j),'[]'::jsonb);
end $$;
revoke all on function public.platform_owner_list_cloud_ai_jobs(integer) from public,anon;
grant execute on function public.platform_owner_list_cloud_ai_jobs(integer) to authenticated;

create or replace function public.platform_owner_enqueue_cloud_ai_research(
 p_category_slug text,p_manufacturer text,p_model text,p_package_name text default null,p_task_type text default 'price_evidence'
) returns jsonb language plpgsql security definer set search_path=public
as $$
declare v_key text; v_id uuid;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if length(trim(coalesce(p_manufacturer,'')))=0 or length(trim(coalesce(p_model,'')))=0 then raise exception 'Manufacturer and model are required'; end if;
 if p_task_type not in ('price_evidence','product_discovery','release_check') then raise exception 'Unsupported task type'; end if;
 v_key:=encode(digest(lower(trim(p_manufacturer)||'|'||trim(p_model)||'|'||coalesce(trim(p_package_name),'')||'|'||p_task_type), 'sha256'),'hex');
 insert into public.platform_cloud_ai_research_jobs(job_key,category_slug,manufacturer,model,package_name,task_type)
 values(v_key,p_category_slug,trim(p_manufacturer),trim(p_model),nullif(trim(p_package_name),''),p_task_type)
 on conflict(job_key) do update set status=case when platform_cloud_ai_research_jobs.status in ('failed','paused') then 'queued' else platform_cloud_ai_research_jobs.status end,updated_at=now()
 returning id into v_id;
 return jsonb_build_object('id',v_id,'job_key',v_key);
end $$;
revoke all on function public.platform_owner_enqueue_cloud_ai_research(text,text,text,text,text) from public,anon;
grant execute on function public.platform_owner_enqueue_cloud_ai_research(text,text,text,text,text) to authenticated;
