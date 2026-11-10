create or replace function public.verify_cloud_ai_scheduler_token(p_token text)
returns boolean language sql stable security definer set search_path=public,vault
as $$
 select coalesce(exists(select 1 from vault.decrypted_secrets where name='tradeflow-cloud-ai-scheduler' and decrypted_secret=p_token),false);
$$;
revoke all on function public.verify_cloud_ai_scheduler_token(text) from public,anon,authenticated;
grant execute on function public.verify_cloud_ai_scheduler_token(text) to service_role;
do $$
begin
 if not exists(select 1 from vault.decrypted_secrets where name='tradeflow-cloud-ai-scheduler') then
  perform vault.create_secret(encode(gen_random_bytes(32),'hex'),'tradeflow-cloud-ai-scheduler','Private scheduler credential for TradeFlow cloud AI research runner');
 end if;
end $$;
select cron.unschedule(jobid) from cron.job where jobname='tradeflow-cloud-ai-runner';
select cron.schedule('tradeflow-cloud-ai-runner','*/10 * * * *',
 $job$ select net.http_post(url:='https://gxsrajtqzdjvmceqcpgv.supabase.co/functions/v1/tradeflow-cloud-ai-manager',
 headers:=jsonb_build_object('Content-Type','application/json','x-tradeflow-scheduler-token',(select decrypted_secret from vault.decrypted_secrets where name='tradeflow-cloud-ai-scheduler' limit 1)),
 body:='{"action":"process_next_job"}'::jsonb,timeout_milliseconds:=55000); $job$);
