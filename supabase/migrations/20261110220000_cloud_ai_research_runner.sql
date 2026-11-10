create or replace function public.platform_cloud_ai_claim_next_job()
returns jsonb language plpgsql security definer set search_path=public
as $$
declare v_job public.platform_cloud_ai_research_jobs;
begin
 update public.platform_cloud_ai_research_jobs set status='queued',lease_expires_at=null,updated_at=now()
 where status='running' and lease_expires_at<now();
 select * into v_job from public.platform_cloud_ai_research_jobs
 where status='queued' and next_attempt_at<=now() and attempts<max_attempts
 order by created_at asc for update skip locked limit 1;
 if not found then return null; end if;
 update public.platform_cloud_ai_research_jobs set status='running',attempts=attempts+1,
 lease_expires_at=now()+interval '5 minutes',updated_at=now()
 where id=v_job.id returning * into v_job;
 return to_jsonb(v_job);
end $$;
revoke all on function public.platform_cloud_ai_claim_next_job() from public,anon,authenticated;
grant execute on function public.platform_cloud_ai_claim_next_job() to service_role;
create or replace function public.platform_cloud_ai_finish_job(p_job_id uuid,p_status text,p_error text default null)
returns void language plpgsql security definer set search_path=public
as $$
begin
 if p_status not in ('submitted','queued','paused','failed') then raise exception 'Invalid job status'; end if;
 update public.platform_cloud_ai_research_jobs set status=p_status,last_error=left(p_error,1000),
 lease_expires_at=null,next_attempt_at=case when p_status='queued' then now()+interval '15 minutes' else next_attempt_at end,
 updated_at=now() where id=p_job_id;
end $$;
revoke all on function public.platform_cloud_ai_finish_job(uuid,text,text) from public,anon,authenticated;
grant execute on function public.platform_cloud_ai_finish_job(uuid,text,text) to service_role;
create or replace function public.platform_cloud_ai_pause_provider(p_provider_key text,p_status text,p_error text,p_cooldown_minutes integer default 60)
returns void language plpgsql security definer set search_path=public
as $$
begin
 if p_status not in ('cooldown','error') then raise exception 'Invalid provider status'; end if;
 update public.platform_cloud_ai_providers set status=p_status,
 cooldown_until=case when p_status='cooldown' then now()+make_interval(mins=>greatest(5,least(p_cooldown_minutes,1440))) else null end,
 last_error=left(p_error,500),last_checked_at=now(),updated_at=now()
 where provider_key=p_provider_key;
end $$;
revoke all on function public.platform_cloud_ai_pause_provider(text,text,text,integer) from public,anon,authenticated;
grant execute on function public.platform_cloud_ai_pause_provider(text,text,text,integer) to service_role;
