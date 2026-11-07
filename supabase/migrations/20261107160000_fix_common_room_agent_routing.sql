create or replace function public.platform_ai_agent_list_messages(
 p_worker_id text,
 p_agent_key text,
 p_thread_key text default null,
 p_category_slug text default null,
 p_limit integer default 100,
 p_since timestamptz default null
) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
 if coalesce(auth.jwt()->>'role','') <> 'service_role' then
  raise exception 'Service role required';
 end if;
 if nullif(trim(p_worker_id),'') is null or nullif(trim(p_agent_key),'') is null then
  raise exception 'Worker and agent identity are required';
 end if;
 return coalesce((
  select jsonb_agg(to_jsonb(m) order by m.created_at asc)
  from (
   select *
   from public.platform_ai_agent_messages
   where archived_at is null
     and (p_thread_key is null or thread_key=p_thread_key)
     and (p_category_slug is null or category_slug is null or category_slug=p_category_slug)
     and (p_since is null or created_at>p_since)
     and (
       recipient_key is null
       or recipient_key in ('all','*',trim(p_agent_key),trim(p_worker_id),'gemma-task-worker')
       or (recipient_key='research-agents' and sender_kind='gemma_agent')
     )
   order by created_at desc
   limit greatest(1,least(coalesce(p_limit,100),250))
  ) m
 ),'[]'::jsonb);
end; $$;

revoke all on function public.platform_ai_agent_list_messages(text,text,text,text,integer,timestamptz) from public,anon,authenticated;
grant execute on function public.platform_ai_agent_list_messages(text,text,text,text,integer,timestamptz) to service_role;
