-- LIVE Gemma control plane and owner review queue.
-- TEST retains its existing queue for regression only; no TEST rows are copied or removed.
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
 created_by text not null default 'platform_owner',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists platform_ai_agent_tasks_claim_idx on public.platform_ai_agent_tasks(status,priority,created_at);
create index if not exists platform_ai_agent_tasks_lease_idx on public.platform_ai_agent_tasks(status,lease_expires_at);
alter table public.platform_ai_agent_tasks enable row level security;
revoke all on public.platform_ai_agent_tasks from public,anon,authenticated;
grant select,insert,update on public.platform_ai_agent_tasks to service_role;

create or replace function public.platform_ai_agent_claim_task(p_worker_id text,p_lease_seconds integer default 600)
returns setof public.platform_ai_agent_tasks language plpgsql security definer set search_path=public,private as $$
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 if nullif(trim(p_worker_id),'') is null then raise exception 'Worker identity required'; end if;
 return query with candidate as (
  select id from public.platform_ai_agent_tasks where attempts < max_attempts and
  (status='queued' or (status='running' and lease_expires_at < now()))
  order by priority asc,created_at asc for update skip locked limit 1
 ) update public.platform_ai_agent_tasks t
 set status='running',worker_id=p_worker_id,attempts=t.attempts+1,
 lease_expires_at=now()+make_interval(secs=>greatest(120,least(coalesce(p_lease_seconds,600),1800))),
 started_at=coalesce(t.started_at,now()),updated_at=now(),last_error=null
 from candidate c where t.id=c.id returning t.*;
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

create table if not exists public.platform_catalogue_research_queue (
 id uuid primary key default gen_random_uuid(),
 record_type text not null check(record_type in('product_candidate','release_candidate','evidence_candidate')),
 status text not null default 'pending_review' check(status in('pending_review','needs_research','approved','rejected','imported')),
 dedupe_key text not null unique,
 agent_name text not null, task_key text, category_slug text, branch_slug text,
 manufacturer text not null, model text not null, package_key text, package_name text,
 release_status text check(release_status is null or release_status in('rumoured','announced','preorder','released','available','discontinued','replaced','update')),
 release_date date,
 evidence_type text check(evidence_type is null or evidence_type in('uk_new','uk_used')),
 source_name text, source_url text, observed_price numeric check(observed_price is null or observed_price>0),
 price_currency text check(price_currency is null or price_currency='GBP'),
 item_condition text, sales_channel text, availability text, source_record_key text,
 source_excerpt text, research_notes text, raw_payload jsonb not null default '{}'::jsonb,
 review_notes text, reviewed_by uuid references auth.users(id), reviewed_at timestamptz,
 approved_at timestamptz, imported_at timestamptz,
 test_master_product_id uuid, live_master_product_id uuid, test_evidence_id uuid, live_evidence_id uuid,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists platform_catalogue_research_queue_status_idx on public.platform_catalogue_research_queue(status,created_at desc);
alter table public.platform_catalogue_research_queue enable row level security;
revoke all on public.platform_catalogue_research_queue from public,anon,authenticated;
grant select,insert,update on public.platform_catalogue_research_queue to service_role;

create or replace function public.platform_owner_enqueue_ai_agent_task(p_task_key text,p_payload jsonb,p_priority integer default 100)
returns jsonb language plpgsql security definer set search_path=public,private as $$
declare v_task public.platform_ai_agent_tasks;
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 if nullif(trim(p_task_key),'') is null or p_payload is null or jsonb_typeof(p_payload)<>'object' then raise exception 'Valid task key and object payload required'; end if;
 insert into public.platform_ai_agent_tasks(task_key,payload,priority,created_by)
 values(trim(p_task_key),p_payload,greatest(1,least(coalesce(p_priority,100),1000)),auth.uid()::text)
 on conflict(task_key) do nothing returning * into v_task;
 if v_task.id is null then select * into v_task from public.platform_ai_agent_tasks where task_key=trim(p_task_key); end if;
 return jsonb_build_object('id',v_task.id,'task_key',v_task.task_key,'status',v_task.status,'created_at',v_task.created_at);
end; $$;

create or replace function public.platform_owner_list_ai_agent_tasks(p_limit integer default 50)
returns jsonb language plpgsql security definer set search_path=public,private as $$
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 return coalesce((select jsonb_agg(to_jsonb(t) order by t.created_at desc) from (select * from public.platform_ai_agent_tasks order by created_at desc limit greatest(1,least(coalesce(p_limit,50),200))) t),'[]'::jsonb);
end; $$;

create or replace function public.platform_owner_list_catalogue_research_queue(p_status text default 'pending_review',p_limit integer default 100)
returns jsonb language plpgsql security definer set search_path=public,private as $$
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 if p_status is not null and p_status not in('pending_review','needs_research','approved','rejected','imported','all') then raise exception 'Invalid queue status'; end if;
 return coalesce((select jsonb_agg(to_jsonb(q) order by q.created_at desc) from (select * from public.platform_catalogue_research_queue where p_status is null or p_status='all' or status=p_status order by created_at desc limit greatest(1,least(coalesce(p_limit,100),200))) q),'[]'::jsonb);
end; $$;

create or replace function public.platform_owner_review_catalogue_research_item(p_id uuid,p_decision text,p_notes text default null)
returns jsonb language plpgsql security definer set search_path=public,private as $$
declare v_row public.platform_catalogue_research_queue;
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 if p_decision not in('approved','rejected','needs_research') then raise exception 'Invalid review decision'; end if;
 update public.platform_catalogue_research_queue set status=p_decision,review_notes=nullif(trim(p_notes),''),reviewed_by=auth.uid(),reviewed_at=now(),approved_at=case when p_decision='approved' then now() else null end,updated_at=now()
 where id=p_id and status in('pending_review','needs_research') returning * into v_row;
 if not found then raise exception 'Queue item not found or no longer reviewable'; end if;
 return to_jsonb(v_row);
end; $$;

revoke all on function public.platform_owner_enqueue_ai_agent_task(text,jsonb,integer) from public,anon;
revoke all on function public.platform_owner_list_ai_agent_tasks(integer) from public,anon;
revoke all on function public.platform_owner_list_catalogue_research_queue(text,integer) from public,anon;
revoke all on function public.platform_owner_review_catalogue_research_item(uuid,text,text) from public,anon;
grant execute on function public.platform_owner_enqueue_ai_agent_task(text,jsonb,integer) to authenticated;
grant execute on function public.platform_owner_list_ai_agent_tasks(integer) to authenticated;
grant execute on function public.platform_owner_list_catalogue_research_queue(text,integer) to authenticated;
grant execute on function public.platform_owner_review_catalogue_research_item(uuid,text,text) to authenticated;
