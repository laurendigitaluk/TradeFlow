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
language plpgsql security definer set search_path = '' as $$
declare v_row public.platform_ai_agent_messages;
begin
 if coalesce(auth.jwt()->>'role','') <> 'service_role' then
  raise exception 'Service role required';
 end if;
 if nullif(trim(p_worker_id),'') is null or nullif(trim(p_agent_key),'') is null then
  raise exception 'Worker and agent identity are required';
 end if;
 if p_message_type not in ('handover','finding','question','learning_note','status_update') then
  raise exception 'Agent message type is not allowed';
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
  p_message_type,'gemma_agent',trim(p_agent_key),coalesce(nullif(trim(p_agent_name),''),trim(p_agent_key)),
  nullif(trim(p_recipient_key),''),nullif(trim(p_category_slug),''),nullif(trim(p_task_key),''),
  p_thread_key,trim(p_title),trim(p_body),p_parent_message_id,coalesce(p_metadata,'{}'::jsonb)
 ) returning * into v_row;
 return to_jsonb(v_row);
end; $$;

revoke all on function public.platform_ai_agent_post_message(text,text,text,text,text,text,text,text,text,text,uuid,jsonb) from public,anon,authenticated;
grant execute on function public.platform_ai_agent_post_message(text,text,text,text,text,text,text,text,text,text,uuid,jsonb) to service_role;
