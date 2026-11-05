-- Platform Owner Agent Control Centre and worker telemetry.
create table if not exists public.platform_ai_agent_status (
 agent_key text primary key,agent_name text not null,category text,
 status text not null default 'idle' check(status in('idle','running','paused','error')),
 current_task text,tasks_completed bigint not null default 0,candidates_found bigint not null default 0,evidence_queued bigint not null default 0,
 last_heartbeat timestamptz,last_started_at timestamptz,last_completed_at timestamptz,last_error text,
 metadata jsonb not null default '{}'::jsonb,updated_at timestamptz not null default now()
);
create table if not exists public.platform_ai_agent_activity (
 id bigint generated always as identity primary key,agent_key text not null,agent_name text not null,
 event_type text not null,message text not null,task_key text,details jsonb not null default '{}'::jsonb,created_at timestamptz not null default now()
);
create index if not exists platform_ai_agent_activity_created_idx on public.platform_ai_agent_activity(created_at desc);
create index if not exists platform_ai_agent_activity_agent_created_idx on public.platform_ai_agent_activity(agent_key,created_at desc);
alter table public.platform_ai_agent_status enable row level security;
alter table public.platform_ai_agent_activity enable row level security;
revoke all on public.platform_ai_agent_status,public.platform_ai_agent_activity from public,anon,authenticated;
grant select,insert,update on public.platform_ai_agent_status to service_role;
grant select,insert on public.platform_ai_agent_activity to service_role;
grant usage,select on sequence public.platform_ai_agent_activity_id_seq to service_role;
create or replace function public.platform_owner_get_ai_agent_control_centre(p_activity_limit integer default 60)
returns jsonb language plpgsql security definer set search_path=public,private as $$
declare result jsonb;
begin
 if not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 select jsonb_build_object('agents',(select coalesce(jsonb_agg(to_jsonb(a) order by a.category nulls last,a.agent_name),'[]'::jsonb) from public.platform_ai_agent_status a),
 'activity',(select coalesce(jsonb_agg(to_jsonb(e) order by e.created_at desc),'[]'::jsonb) from(select * from public.platform_ai_agent_activity order by created_at desc limit greatest(1,least(coalesce(p_activity_limit,60),200))) e)) into result;return result;
end; $$;
revoke all on function public.platform_owner_get_ai_agent_control_centre(integer) from public,anon;
grant execute on function public.platform_owner_get_ai_agent_control_centre(integer) to authenticated;
create or replace function public.platform_ai_agent_report_event(
 p_agent_key text,p_agent_name text,p_category text,p_status text,p_current_task text,
 p_event_type text,p_message text,p_task_key text default null,p_tasks_completed_delta integer default 0,
 p_candidates_found_delta integer default 0,p_evidence_queued_delta integer default 0,p_last_error text default null,p_details jsonb default '{}'::jsonb
) returns jsonb language plpgsql security definer set search_path=public,private as $$
declare v_id bigint;
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 if p_status not in('idle','running','paused','error') then raise exception 'Invalid agent status'; end if;
 if nullif(trim(p_agent_key),'') is null or nullif(trim(p_agent_name),'') is null then raise exception 'Agent identity required'; end if;
 insert into public.platform_ai_agent_status(agent_key,agent_name,category,status,current_task,tasks_completed,candidates_found,evidence_queued,last_heartbeat,last_started_at,last_completed_at,last_error,metadata,updated_at)
 values(p_agent_key,p_agent_name,p_category,p_status,p_current_task,greatest(0,p_tasks_completed_delta),greatest(0,p_candidates_found_delta),greatest(0,p_evidence_queued_delta),now(),case when p_status='running' then now() end,case when p_event_type='task_completed' then now() end,p_last_error,coalesce(p_details,'{}'::jsonb),now())
 on conflict(agent_key) do update set agent_name=excluded.agent_name,category=coalesce(excluded.category,platform_ai_agent_status.category),status=excluded.status,current_task=excluded.current_task,
 tasks_completed=platform_ai_agent_status.tasks_completed+greatest(0,p_tasks_completed_delta),candidates_found=platform_ai_agent_status.candidates_found+greatest(0,p_candidates_found_delta),evidence_queued=platform_ai_agent_status.evidence_queued+greatest(0,p_evidence_queued_delta),
 last_heartbeat=now(),last_started_at=case when p_status='running' then now() else platform_ai_agent_status.last_started_at end,last_completed_at=case when p_event_type='task_completed' then now() else platform_ai_agent_status.last_completed_at end,
 last_error=case when p_last_error is not null then p_last_error when p_status='error' then platform_ai_agent_status.last_error else null end,metadata=coalesce(platform_ai_agent_status.metadata,'{}'::jsonb)||coalesce(p_details,'{}'::jsonb),updated_at=now();
 insert into public.platform_ai_agent_activity(agent_key,agent_name,event_type,message,task_key,details) values(p_agent_key,p_agent_name,p_event_type,p_message,p_task_key,coalesce(p_details,'{}'::jsonb)) returning id into v_id;
 return jsonb_build_object('ok',true,'activity_id',v_id);
end; $$;
revoke all on function public.platform_ai_agent_report_event(text,text,text,text,text,text,text,text,integer,integer,integer,text,jsonb) from public,anon,authenticated;
grant execute on function public.platform_ai_agent_report_event(text,text,text,text,text,text,text,text,integer,integer,integer,text,jsonb) to service_role;
insert into public.platform_ai_agent_status(agent_key,agent_name,category,status,metadata,updated_at) values
('mobile-phones','Gemma — Mobile Phones','Mobile phones','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('gaming-consoles','Gemma — Gaming Consoles','Gaming consoles and accessories','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('3d-printers','Gemma — 3D Printers','3D printers and accessories','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('drones','Gemma — Drones','Drones and accessories','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('cameras','Gemma — Cameras','Cameras and lenses','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('metal-detectors','Gemma — Metal Detectors','Metal detectors and accessories','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('laptops','Gemma — Laptops','Laptops and computers','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('release-monitor','Gemma — Release Monitor','Official manufacturer release monitoring','idle','{"stage":"registered_not_started"}'::jsonb,now()),
('catalogue-importer','TradeFlow — Catalogue Importer','Owner-approved catalogue imports','idle','{"stage":"registered_not_started"}'::jsonb,now())
on conflict(agent_key) do nothing;
