create table if not exists public.assistant_conversations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  status text not null default 'open' check (status in ('open','closed')),
  subject text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_message_at timestamptz not null default now()
);
create unique index if not exists assistant_conversations_open_customer_idx
  on public.assistant_conversations(tenant_id, customer_id) where status='open';
create index if not exists assistant_conversations_tenant_idx
  on public.assistant_conversations(tenant_id,last_message_at desc);

create table if not exists public.assistant_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.assistant_conversations(id) on delete cascade,
  sender_type text not null check (sender_type in ('customer','subscriber','assistant')),
  sender_user_id uuid references auth.users(id),
  body text not null check (char_length(trim(body)) > 0 and char_length(body) <= 4000),
  created_at timestamptz not null default now()
);
create index if not exists assistant_messages_conversation_idx
  on public.assistant_messages(conversation_id,created_at);

alter table public.assistant_conversations enable row level security;
alter table public.assistant_messages enable row level security;

revoke all on public.assistant_conversations from anon, authenticated;
revoke all on public.assistant_messages from anon, authenticated;

create or replace function public.customer_get_assistant_conversation(p_tenant_id uuid)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
declare v_customer_id uuid; v_conversation_id uuid; v_messages jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select c.id into v_customer_id from public.customers c
   where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;
  select ac.id into v_conversation_id from public.assistant_conversations ac
   where ac.tenant_id=p_tenant_id and ac.customer_id=v_customer_id and ac.status='open'
   order by ac.last_message_at desc limit 1;
  if v_conversation_id is null then
    insert into public.assistant_conversations(tenant_id,customer_id) values(p_tenant_id,v_customer_id)
    returning id into v_conversation_id;
  end if;
  select coalesce(jsonb_agg(jsonb_build_object('id',m.id,'sender_type',m.sender_type,'body',m.body,'created_at',m.created_at) order by m.created_at),'[]'::jsonb)
    into v_messages from public.assistant_messages m where m.conversation_id=v_conversation_id;
  return jsonb_build_object('conversation_id',v_conversation_id,'messages',v_messages);
end $$;

create or replace function public.customer_send_assistant_message(p_tenant_id uuid,p_body text)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
declare v_customer_id uuid; v_conversation_id uuid; v_message_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_body is null or char_length(trim(p_body))=0 then raise exception 'Message cannot be empty'; end if;
  if char_length(p_body)>4000 then raise exception 'Message is too long'; end if;
  select c.id into v_customer_id from public.customers c
   where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;
  select ac.id into v_conversation_id from public.assistant_conversations ac
   where ac.tenant_id=p_tenant_id and ac.customer_id=v_customer_id and ac.status='open'
   order by ac.last_message_at desc limit 1;
  if v_conversation_id is null then
    insert into public.assistant_conversations(tenant_id,customer_id) values(p_tenant_id,v_customer_id)
    returning id into v_conversation_id;
  end if;
  insert into public.assistant_messages(conversation_id,sender_type,sender_user_id,body)
    values(v_conversation_id,'customer',auth.uid(),trim(p_body)) returning id into v_message_id;
  update public.assistant_conversations set updated_at=now(),last_message_at=now() where id=v_conversation_id;
  return jsonb_build_object('conversation_id',v_conversation_id,'message_id',v_message_id);
end $$;

create or replace function public.subscriber_get_assistant_conversations(p_tenant_id uuid)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
begin
  if auth.uid() is null or not exists(select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active' and tm.role_code in ('owner','admin','staff')) then
    raise exception 'Subscriber access required';
  end if;
  return coalesce((select jsonb_agg(x order by (x->>'last_message_at') desc) from (
    select jsonb_build_object('conversation_id',ac.id,'customer_id',c.id,'customer_name',trim(concat(c.first_name,' ',c.last_name)),'customer_email',c.email,'status',ac.status,'last_message_at',ac.last_message_at,'message_count',(select count(*) from public.assistant_messages am where am.conversation_id=ac.id)) x
    from public.assistant_conversations ac join public.customers c on c.id=ac.customer_id
    where ac.tenant_id=p_tenant_id
  ) x),'[]'::jsonb);
end $$;

create or replace function public.subscriber_get_assistant_messages(p_tenant_id uuid,p_conversation_id uuid)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
begin
  if auth.uid() is null or not exists(select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active' and tm.role_code in ('owner','admin','staff')) then
    raise exception 'Subscriber access required';
  end if;
  if not exists(select 1 from public.assistant_conversations ac where ac.id=p_conversation_id and ac.tenant_id=p_tenant_id) then raise exception 'Conversation not found'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id',m.id,'sender_type',m.sender_type,'body',m.body,'created_at',m.created_at) order by m.created_at) from public.assistant_messages m where m.conversation_id=p_conversation_id),'[]'::jsonb);
end $$;

create or replace function public.subscriber_send_assistant_message(p_tenant_id uuid,p_conversation_id uuid,p_body text)
returns jsonb
language plpgsql security definer set search_path=public,private
as $$
declare v_message_id uuid;
begin
  if auth.uid() is null or not exists(select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active' and tm.role_code in ('owner','admin','staff')) then
    raise exception 'Subscriber access required';
  end if;
  if p_body is null or char_length(trim(p_body))=0 then raise exception 'Message cannot be empty'; end if;
  if char_length(p_body)>4000 then raise exception 'Message is too long'; end if;
  if not exists(select 1 from public.assistant_conversations ac where ac.id=p_conversation_id and ac.tenant_id=p_tenant_id) then raise exception 'Conversation not found'; end if;
  insert into public.assistant_messages(conversation_id,sender_type,sender_user_id,body)
    values(p_conversation_id,'subscriber',auth.uid(),trim(p_body)) returning id into v_message_id;
  update public.assistant_conversations set updated_at=now(),last_message_at=now() where id=p_conversation_id;
  return jsonb_build_object('message_id',v_message_id);
end $$;

create or replace function public.subscriber_close_assistant_conversation(p_tenant_id uuid,p_conversation_id uuid)
returns boolean
language plpgsql security definer set search_path=public,private
as $$
begin
  if auth.uid() is null or not exists(select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active' and tm.role_code in ('owner','admin','staff')) then
    raise exception 'Subscriber access required';
  end if;
  update public.assistant_conversations set status='closed',updated_at=now() where id=p_conversation_id and tenant_id=p_tenant_id;
  return found;
end $$;

revoke all on function public.customer_get_assistant_conversation(uuid) from public,anon;
revoke all on function public.customer_send_assistant_message(uuid,text) from public,anon;
revoke all on function public.subscriber_get_assistant_conversations(uuid) from public,anon;
revoke all on function public.subscriber_get_assistant_messages(uuid,uuid) from public,anon;
revoke all on function public.subscriber_send_assistant_message(uuid,uuid,text) from public,anon;
revoke all on function public.subscriber_close_assistant_conversation(uuid,uuid) from public,anon;
grant execute on function public.customer_get_assistant_conversation(uuid) to authenticated;
grant execute on function public.customer_send_assistant_message(uuid,text) to authenticated;
grant execute on function public.subscriber_get_assistant_conversations(uuid) to authenticated;
grant execute on function public.subscriber_get_assistant_messages(uuid,uuid) to authenticated;
grant execute on function public.subscriber_send_assistant_message(uuid,uuid,text) to authenticated;
grant execute on function public.subscriber_close_assistant_conversation(uuid,uuid) to authenticated;
