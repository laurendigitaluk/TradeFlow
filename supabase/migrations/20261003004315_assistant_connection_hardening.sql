-- Customer/subscriber assistant connection hardening.
-- Do not create an empty customer conversation merely by opening the Assistant.
-- Keep closed conversations out of the subscriber's open Customer Questions queue.

create or replace function public.customer_get_assistant_conversation(p_tenant_id uuid)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
declare v_customer_id uuid; v_conversation_id uuid; v_messages jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and c.status='active'
  limit 1;

  if v_customer_id is null then raise exception 'Customer account not found'; end if;

  select ac.id into v_conversation_id
  from public.assistant_conversations ac
  where ac.tenant_id=p_tenant_id
    and ac.customer_id=v_customer_id
    and ac.status='open'
  order by ac.last_message_at desc
  limit 1;

  if v_conversation_id is null then
    return jsonb_build_object('conversation_id',null,'messages','[]'::jsonb);
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id',m.id,
        'sender_type',m.sender_type,
        'body',m.body,
        'created_at',m.created_at
      ) order by m.created_at
    ),
    '[]'::jsonb
  )
  into v_messages
  from public.assistant_messages m
  where m.conversation_id=v_conversation_id;

  return jsonb_build_object(
    'conversation_id',v_conversation_id,
    'messages',v_messages
  );
end $$;

create or replace function public.subscriber_get_assistant_conversations(p_tenant_id uuid)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
begin
  if auth.uid() is null
     or not exists(
       select 1
       from public.tenant_memberships tm
       where tm.tenant_id=p_tenant_id
         and tm.user_id=auth.uid()
         and tm.status='active'
         and tm.role_code in ('owner','admin','staff')
     )
  then
    raise exception 'Subscriber access required';
  end if;

  return coalesce(
    (
      select jsonb_agg(x order by (x->>'last_message_at') desc)
      from (
        select jsonb_build_object(
          'conversation_id',ac.id,
          'customer_id',c.id,
          'customer_name',trim(concat(c.first_name,' ',c.last_name)),
          'customer_email',c.email,
          'status',ac.status,
          'last_message_at',ac.last_message_at,
          'message_count',(
            select count(*)
            from public.assistant_messages am
            where am.conversation_id=ac.id
          )
        ) x
        from public.assistant_conversations ac
        join public.customers c on c.id=ac.customer_id
        where ac.tenant_id=p_tenant_id
          and ac.status='open'
          and exists(
            select 1
            from public.assistant_messages am
            where am.conversation_id=ac.id
          )
      ) x
    ),
    '[]'::jsonb
  );
end $$;

revoke all on function public.customer_get_assistant_conversation(uuid) from public,anon;
revoke all on function public.subscriber_get_assistant_conversations(uuid) from public,anon;
grant execute on function public.customer_get_assistant_conversation(uuid) to authenticated;
grant execute on function public.subscriber_get_assistant_conversations(uuid) to authenticated;
