-- Persistent ChatGPT-to-Research-PC task queue. TEST is the control plane; LIVE catalogue remains separate.
create table if not exists public.platform_ai_agent_tasks (
 id uuid primary key default gen_random_uuid(),
 task_key text not null unique,
 task_type text not null default 'catalogue_research' check(task_type in('catalogue_research')),
 payload jsonb not null,
 status text not null default 'queued' check(status in('queued','running','completed','failed','cancelled')),
 priority integer not null default 100,
 attempts integer not null default 0,
 max_attempts integer not null default 3,
 worker_id text,
 lease_expires_at timestamptz,
 started_at timestamptz,
 completed_at timestamptz,
 result jsonb not null default '{}'::jsonb,
 last_error text,
 created_by text not null default 'chatgpt',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists platform_ai_agent_tasks_claim_idx on public.platform_ai_agent_tasks(status,priority,created_at);
create index if not exists platform_ai_agent_tasks_lease_idx on public.platform_ai_agent_tasks(status,lease_expires_at);
alter table public.platform_ai_agent_tasks enable row level security;
revoke all on public.platform_ai_agent_tasks from public,anon,authenticated;
grant select,insert,update on public.platform_ai_agent_tasks to service_role;

create or replace function public.platform_ai_agent_claim_task(p_worker_id text,p_lease_seconds integer default 600)
returns setof public.platform_ai_agent_tasks
language plpgsql security definer set search_path=public,private as $$
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 if nullif(trim(p_worker_id),'') is null then raise exception 'Worker identity required'; end if;
 return query
 with candidate as (
  select id from public.platform_ai_agent_tasks
  where attempts < max_attempts and (
   (status='queued') or (status='running' and lease_expires_at < now())
  )
  order by priority asc,created_at asc
  for update skip locked limit 1
 )
 update public.platform_ai_agent_tasks t
 set status='running',worker_id=p_worker_id,attempts=t.attempts+1,
     lease_expires_at=now()+make_interval(secs=>greatest(120,least(coalesce(p_lease_seconds,600),1800))),
     started_at=coalesce(t.started_at,now()),updated_at=now(),last_error=null
 from candidate c where t.id=c.id
 returning t.*;
end; $$;

create or replace function public.platform_ai_agent_heartbeat_task(p_task_id uuid,p_worker_id text,p_lease_seconds integer default 600)
returns boolean language plpgsql security definer set search_path=public,private as $$
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 update public.platform_ai_agent_tasks set lease_expires_at=now()+make_interval(secs=>greatest(120,least(coalesce(p_lease_seconds,600),1800))),updated_at=now()
 where id=p_task_id and status='running' and worker_id=p_worker_id;
 return found;
end; $$;

create or replace function public.platform_ai_agent_complete_task(p_task_id uuid,p_worker_id text,p_result jsonb)
returns boolean language plpgsql security definer set search_path=public,private as $$
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 update public.platform_ai_agent_tasks set status='completed',result=coalesce(p_result,'{}'::jsonb),completed_at=now(),lease_expires_at=null,updated_at=now(),last_error=null
 where id=p_task_id and status='running' and worker_id=p_worker_id;
 return found;
end; $$;

create or replace function public.platform_ai_agent_fail_task(p_task_id uuid,p_worker_id text,p_error text)
returns boolean language plpgsql security definer set search_path=public,private as $$
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 update public.platform_ai_agent_tasks set status='failed',last_error=left(coalesce(p_error,'Unknown worker error'),4000),lease_expires_at=null,updated_at=now()
 where id=p_task_id and status='running' and worker_id=p_worker_id;
 return found;
end; $$;

revoke all on function public.platform_ai_agent_claim_task(text,integer) from public,anon,authenticated;
revoke all on function public.platform_ai_agent_heartbeat_task(uuid,text,integer) from public,anon,authenticated;
revoke all on function public.platform_ai_agent_complete_task(uuid,text,jsonb) from public,anon,authenticated;
revoke all on function public.platform_ai_agent_fail_task(uuid,text,text) from public,anon,authenticated;
grant execute on function public.platform_ai_agent_claim_task(text,integer) to service_role;
grant execute on function public.platform_ai_agent_heartbeat_task(uuid,text,integer) to service_role;
grant execute on function public.platform_ai_agent_complete_task(uuid,text,jsonb) to service_role;
grant execute on function public.platform_ai_agent_fail_task(uuid,text,text) to service_role;
