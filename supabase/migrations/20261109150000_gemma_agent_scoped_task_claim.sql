-- Desktop Research Control Centre: claim only tasks whose every subtask belongs
-- to an enabled specialist agent. Existing unscoped claim RPC is retained for
-- backwards compatibility; the desktop worker never falls back to it.
create or replace function public.platform_ai_agent_claim_task_for_agents(
 p_worker_id text,
 p_agent_keys text[],
 p_lease_seconds integer default 600
)
returns setof public.platform_ai_agent_tasks
language plpgsql
security definer
set search_path=public,private
as $$
declare
 v_allowed text[] := coalesce(p_agent_keys,'{}'::text[]);
begin
 if coalesce(auth.role(),'') <> 'service_role' then
  raise exception 'Service role required';
 end if;
 if nullif(trim(p_worker_id),'') is null then
  raise exception 'Worker identity required';
 end if;
 if cardinality(v_allowed)=0 then
  return;
 end if;
 if exists (
  select 1 from unnest(v_allowed) k
  where k is null or k not in (
   '3d-printers-equipment','3d-printers',
   'gaming-consoles-accessories','gaming-consoles',
   'drones','metal-detectors','mobile-phones','laptops','cameras'
  )
 ) then
  raise exception 'Unknown or unsupported research agent key';
 end if;

 return query
 with candidate as (
  select t.id
  from public.platform_ai_agent_tasks t
  where t.attempts < t.max_attempts
   and t.task_type='catalogue_research'
   and (t.status='queued' or (t.status='running' and t.lease_expires_at < now()))
   and jsonb_array_length(case when jsonb_typeof(t.payload->'tasks')='array' then t.payload->'tasks' else '[]'::jsonb end) > 0
   and exists (
    select 1
    from jsonb_array_elements(case when jsonb_typeof(t.payload->'tasks')='array' then t.payload->'tasks' else '[]'::jsonb end) as item(value)
    cross join lateral (
     select case
      when lower(trim(coalesce(item.value->>'agent_key','')))='3d-printers-equipment'
       and nullif(trim(item.value->>'category_slug'),'') is not null
       and lower(trim(item.value->>'category_slug')) <> '3d-printers-equipment'
      then regexp_replace(lower(trim(item.value->>'category_slug')),'[^a-z0-9]+','-','g')
      else coalesce(
       nullif(regexp_replace(lower(trim(item.value->>'agent_key')),'[^a-z0-9]+','-','g'),''),
       nullif(regexp_replace(lower(trim(item.value->>'category_slug')),'[^a-z0-9]+','-','g'),'')
      )
     end as resolved_agent_key
    ) identity
    where identity.resolved_agent_key = any(v_allowed)
   )
   and not exists (
    select 1
    from jsonb_array_elements(case when jsonb_typeof(t.payload->'tasks')='array' then t.payload->'tasks' else '[]'::jsonb end) as item(value)
    cross join lateral (
     select case
      when lower(trim(coalesce(item.value->>'agent_key','')))='3d-printers-equipment'
       and nullif(trim(item.value->>'category_slug'),'') is not null
       and lower(trim(item.value->>'category_slug')) <> '3d-printers-equipment'
      then regexp_replace(lower(trim(item.value->>'category_slug')),'[^a-z0-9]+','-','g')
      else coalesce(
       nullif(regexp_replace(lower(trim(item.value->>'agent_key')),'[^a-z0-9]+','-','g'),''),
       nullif(regexp_replace(lower(trim(item.value->>'category_slug')),'[^a-z0-9]+','-','g'),'')
      )
     end as resolved_agent_key
    ) identity
    where identity.resolved_agent_key is null
       or not (identity.resolved_agent_key = any(v_allowed))
   )
  order by t.priority asc,t.created_at asc
  for update skip locked
  limit 1
 )
 update public.platform_ai_agent_tasks t
 set status='running',
  worker_id=p_worker_id,
  attempts=t.attempts+1,
  lease_expires_at=now()+make_interval(secs=>greatest(120,least(coalesce(p_lease_seconds,600),1800))),
  started_at=coalesce(t.started_at,now()),
  updated_at=now(),
  last_error=null
 from candidate c
 where t.id=c.id
 returning t.*;
end;
$$;

comment on function public.platform_ai_agent_claim_task_for_agents(text,text[],integer)
 is 'Service-role-only queue claim restricted to enabled research agent keys. Mixed-agent tasks remain queued until every subtask agent is enabled.';

revoke all on function public.platform_ai_agent_claim_task_for_agents(text,text[],integer) from public,anon,authenticated;
grant execute on function public.platform_ai_agent_claim_task_for_agents(text,text[],integer) to service_role;
