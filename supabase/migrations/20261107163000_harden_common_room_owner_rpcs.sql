create or replace function public.platform_owner_list_ai_agent_messages(
 p_thread_key text default null,
 p_category_slug text default null,
 p_limit integer default 100,
 p_before timestamptz default null
) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
 if auth.uid() is null or not exists(
  select 1 from public.platform_memberships pm
  where pm.user_id=auth.uid() and pm.status='active'
 ) then
  raise exception 'Platform owner access required';
 end if;
 return coalesce((
  select jsonb_agg(to_jsonb(m) order by m.created_at asc)
  from (
   select *
   from public.platform_ai_agent_messages
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
language plpgsql security definer set search_path = '' as $$
declare v_row public.platform_ai_agent_messages;
begin
 if auth.uid() is null or not exists(
  select 1 from public.platform_memberships pm
  where pm.user_id=auth.uid() and pm.status='active'
 ) then
  raise exception 'Platform owner access required';
 end if;
 if p_message_type not in ('instruction','handover','finding','question','learning_note','status_update') then
  raise exception 'Invalid message type';
 end if;
 if nullif(trim(p_title),'') is null or length(p_title)>180 then
  raise exception 'Enter a title of up to 180 characters';
 end if;
 if nullif(trim(p_body),'') is null or length(p_body)>12000 then
  raise exception 'Enter a message of up to 12000 characters';
 end if;
 if p_thread_key is null or p_thread_key !~ '^[a-z0-9][a-z0-9._:-]{0,79}$' then
  raise exception 'Invalid thread key';
 end if;
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

revoke all on function public.platform_owner_list_ai_agent_messages(text,text,integer,timestamptz) from public,anon;
revoke all on function public.platform_owner_post_ai_agent_message(text,text,text,text,text,text,text,uuid,jsonb) from public,anon;
grant execute on function public.platform_owner_list_ai_agent_messages(text,text,integer,timestamptz) to authenticated;
grant execute on function public.platform_owner_post_ai_agent_message(text,text,text,text,text,text,text,uuid,jsonb) to authenticated;
