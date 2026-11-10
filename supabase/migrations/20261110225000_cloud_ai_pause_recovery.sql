create or replace function public.platform_cloud_ai_claim_next_job()
returns jsonb language plpgsql security definer set search_path=public
as $$
declare v_job public.platform_cloud_ai_research_jobs;
begin
 update public.platform_cloud_ai_providers set status='ready',cooldown_until=null,last_error=null,updated_at=now()
 where enabled=true and free_tier_confirmed=true and status='cooldown' and cooldown_until<=now();
 update public.platform_cloud_ai_providers set daily_requests_used=0,daily_usage_date=current_date,updated_at=now()
 where daily_usage_date<current_date;
 update public.platform_cloud_ai_research_jobs j set status='queued',next_attempt_at=now(),last_error=null,updated_at=now()
 where j.status='paused' and exists(
  select 1 from public.platform_cloud_ai_providers p
  where p.enabled=true and p.free_tier_confirmed=true and p.status='ready'
   and p.secret_id is not null and p.daily_request_limit>0
   and (p.daily_usage_date<current_date or p.daily_requests_used<p.daily_request_limit)
 );
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
