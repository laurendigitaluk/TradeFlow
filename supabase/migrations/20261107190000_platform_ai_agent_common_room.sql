-- TradeFlow AI Agent Common Room — persistent LIVE collaboration and instruction feed.
-- Messages are separate from catalogue research candidates and financial/customer data.
create table if not exists public.platform_ai_agent_messages (
  id uuid primary key default gen_random_uuid(),
  thread_key text not null default 'general',
  message_type text not null check (message_type in ('instruction','handover','finding','question','learning_note','status_update')),
  sender_kind text not null check (sender_kind in ('platform_owner','chatgpt_supervisor','gemma_agent','system')),
  sender_key text not null,
  sender_name text not null,
  recipient_key text,
  category_slug text,
  task_key text,
  title text not null,
  body text not null,
  metadata jsonb not null default '{}'::jsonb,
  parent_message_id uuid references public.platform_ai_agent_messages(id) on delete set null,
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  archived_at timestamptz
);
create index if not exists platform_ai_agent_messages_created_idx on public.platform_ai_agent_messages(created_at desc);
create index if not exists platform_ai_agent_messages_thread_idx on public.platform_ai_agent_messages(thread_key,created_at desc);
create index if not exists platform_ai_agent_messages_recipient_idx on public.platform_ai_agent_messages(recipient_key,created_at desc);
alter table public.platform_ai_agent_messages enable row level security;
revoke all on public.platform_ai_agent_messages from public, anon, authenticated;
grant select, insert, update on public.platform_ai_agent_messages to service_role;

create or replace function public.platform_owner_list_ai_agent_messages(
 p_thread_key text default null,
 p_category_slug text default null,
 p_limit integer default 100,
 p_before timestamptz default null
) returns jsonb
language plpgsql security definer set search_path=public,private as $$
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then
  raise exception 'Platform owner access required';
 end if;
 return coalesce((
  select jsonb_agg(to_jsonb(m) order by m.created_at asc)
  from (
   select * from public.platform_ai_agent_messages
   where archived_at is null
     and (p_thread_key is null or thread_key=p_thread_key)
     and (p_category_slug is null or category_slug=p_category_slug)
     and (p_before is null or created_at<p_before)
   order by created_at desc
   limit greatest(1,least(coalesce(p_limit,100),250))
  ) m
 ),'[]'::jsonb);
end; $$;

create or replace function public.platform_owner_post_ai_agent_message(
 p_message_type text,
 p_thread_key text,
 p_recipient_key text,
 p_category_slug text,
 p_task_key text,
 p_title text,
 p_body text,
 p_parent_message_id uuid default null,
 p_metadata jsonb default '{}'::jsonb
) returns jsonb
language plpgsql security definer set search_path=public,private as $$
declare v_row public.platform_ai_agent_messages;
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then
  raise exception 'Platform owner access required';
 end if;
 if p_message_type not in ('instruction','handover','finding','question','learning_note','status_update') then raise exception 'Invalid message type'; end if;
 if nullif(trim(p_title),'') is null or length(p_title)>180 then raise exception 'Enter a title of up to 180 characters'; end if;
 if nullif(trim(p_body),'') is null or length(p_body)>12000 then raise exception 'Enter a message of up to 12000 characters'; end if;
 if p_thread_key is null or p_thread_key !~ '^[a-z0-9][a-z0-9._:-]{0,79}$' then raise exception 'Invalid thread key'; end if;
 insert into public.platform_ai_agent_messages(
  message_type,sender_kind,sender_key,sender_name,recipient_key,category_slug,task_key,
  thread_key,title,body,parent_message_id,metadata
 ) values (
  p_message_type,'platform_owner',auth.uid()::text,'Platform Owner',
  nullif(trim(p_recipient_key),''),nullif(trim(p_category_slug),''),nullif(trim(p_task_key),''),
  p_thread_key,trim(p_title),trim(p_body),p_parent_message_id,coalesce(p_metadata,'{}'::jsonb)
 ) returning * into v_row;
 return to_jsonb(v_row);
end; $$;

create or replace function public.platform_ai_agent_post_message(
 p_worker_id text,
 p_agent_key text,
 p_agent_name text,
 p_message_type text,
 p_thread_key text,
 p_recipient_key text,
 p_category_slug text,
 p_task_key text,
 p_title text,
 p_body text,
 p_parent_message_id uuid default null,
 p_metadata jsonb default '{}'::jsonb
) returns jsonb
language plpgsql security definer set search_path=public,private as $$
declare v_row public.platform_ai_agent_messages;
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 if nullif(trim(p_worker_id),'') is null or nullif(trim(p_agent_key),'') is null then raise exception 'Worker and agent identity are required'; end if;
 if p_message_type not in ('handover','finding','question','learning_note','status_update') then raise exception 'Agent message type is not allowed'; end if;
 if nullif(trim(p_title),'') is null or length(p_title)>180 then raise exception 'Enter a title of up to 180 characters'; end if;
 if nullif(trim(p_body),'') is null or length(p_body)>12000 then raise exception 'Enter a message of up to 12000 characters'; end if;
 if p_thread_key is null or p_thread_key !~ '^[a-z0-9][a-z0-9._:-]{0,79}$' then raise exception 'Invalid thread key'; end if;
 insert into public.platform_ai_agent_messages(
  message_type,sender_kind,sender_key,sender_name,recipient_key,category_slug,task_key,
  thread_key,title,body,parent_message_id,metadata
 ) values (
  p_message_type,'gemma_agent',trim(p_agent_key),coalesce(nullif(trim(p_agent_name),''),trim(p_agent_key)),
  nullif(trim(p_recipient_key),''),nullif(trim(p_category_slug),''),nullif(trim(p_task_key),''),
  p_thread_key,trim(p_title),trim(p_body),p_parent_message_id,coalesce(p_metadata,'{}'::jsonb)
 ) returning * into v_row;
 return to_jsonb(v_row);
end; $$;

create or replace function public.platform_ai_agent_list_messages(
 p_worker_id text,
 p_agent_key text,
 p_thread_key text default null,
 p_category_slug text default null,
 p_limit integer default 100,
 p_since timestamptz default null
) returns jsonb
language plpgsql security definer set search_path=public,private as $$
begin
 if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
 if nullif(trim(p_worker_id),'') is null or nullif(trim(p_agent_key),'') is null then raise exception 'Worker and agent identity are required'; end if;
 return coalesce((
  select jsonb_agg(to_jsonb(m) order by m.created_at asc)
  from (
   select * from public.platform_ai_agent_messages
   where archived_at is null
     and (p_thread_key is null or thread_key=p_thread_key)
     and (p_category_slug is null or category_slug=p_category_slug)
     and (p_since is null or created_at>p_since)
     and (recipient_key is null or recipient_key in ('all','*',trim(p_agent_key),trim(p_worker_id)))
   order by created_at desc
   limit greatest(1,least(coalesce(p_limit,100),250))
  ) m
 ),'[]'::jsonb);
end; $$;

revoke all on function public.platform_owner_list_ai_agent_messages(text,text,integer,timestamptz) from public,anon;
revoke all on function public.platform_owner_post_ai_agent_message(text,text,text,text,text,text,text,uuid,jsonb) from public,anon;
revoke all on function public.platform_ai_agent_post_message(text,text,text,text,text,text,text,text,text,text,uuid,jsonb) from public,anon,authenticated;
revoke all on function public.platform_ai_agent_list_messages(text,text,text,text,integer,timestamptz) from public,anon,authenticated;
grant execute on function public.platform_owner_list_ai_agent_messages(text,text,integer,timestamptz) to authenticated;
grant execute on function public.platform_owner_post_ai_agent_message(text,text,text,text,text,text,text,uuid,jsonb) to authenticated;
grant execute on function public.platform_ai_agent_post_message(text,text,text,text,text,text,text,text,text,text,uuid,jsonb) to service_role;
grant execute on function public.platform_ai_agent_list_messages(text,text,text,text,integer,timestamptz) to service_role;
