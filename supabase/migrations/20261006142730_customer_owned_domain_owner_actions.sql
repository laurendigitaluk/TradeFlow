create table if not exists public.platform_owner_domain_actions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  domain_id uuid not null references public.tenant_domains(id) on delete cascade,
  action_type text not null default 'domain_connection_required',
  status text not null default 'open',
  title text not null,
  message text not null,
  dns_instructions jsonb not null default '{}'::jsonb,
  owner_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint platform_owner_domain_actions_type_chk check (action_type='domain_connection_required'),
  constraint platform_owner_domain_actions_status_chk check (status in ('open','in_progress','awaiting_customer','completed','failed')),
  constraint platform_owner_domain_actions_domain_type_uniq unique(domain_id,action_type)
);
create index if not exists platform_owner_domain_actions_status_idx on public.platform_owner_domain_actions(status,created_at desc);
create index if not exists platform_owner_domain_actions_tenant_idx on public.platform_owner_domain_actions(tenant_id);
alter table public.platform_owner_domain_actions enable row level security;

create or replace function public.subscriber_request_custom_domain(p_hostname text)
returns table(id uuid,tenant_id uuid,hostname text,domain_type text,status text,is_primary boolean,verification_token text,created_at timestamptz)
language plpgsql security definer set search_path=pg_catalog,public,private as $$
declare v_tenant_id uuid; v_hostname text; v_domain_id uuid;
begin
 select tm.tenant_id into v_tenant_id from public.tenant_memberships tm where tm.user_id=auth.uid() and tm.status='active' order by tm.created_at limit 1;
 if v_tenant_id is null then raise exception 'active TradeFlow business membership required'; end if;
 if not private.can_tenant(v_tenant_id,'website.manage','website.editor') then raise exception 'website management permission required'; end if;
 v_hostname:=lower(trim(coalesce(p_hostname,''))); v_hostname:=regexp_replace(v_hostname,'^https?://',''); v_hostname:=split_part(v_hostname,'/',1); v_hostname:=rtrim(v_hostname,'.');
 if v_hostname='' or v_hostname !~ '^[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?\.[a-z]{2,63}$' then raise exception 'enter a valid domain name'; end if;
 if exists(select 1 from public.tenant_domains td where lower(td.hostname)=v_hostname and td.tenant_id<>v_tenant_id and td.status in ('pending','verified','active')) then raise exception 'that domain is already connected to another TradeFlow business'; end if;
 update public.tenant_domains set is_primary=false where tenant_id=v_tenant_id and is_primary=true and lower(hostname)<>v_hostname;
 select td.id into v_domain_id from public.tenant_domains td where td.tenant_id=v_tenant_id and lower(td.hostname)=v_hostname limit 1;
 if v_domain_id is null then
   insert into public.tenant_domains(tenant_id,hostname,domain_type,status,is_primary,verification_token,metadata,acquisition_source)
   values(v_tenant_id,v_hostname,'custom','pending',true,gen_random_uuid()::text,jsonb_build_object('source','subscriber_domain_settings','connection_requested_at',now()),'connected')
   returning tenant_domains.id into v_domain_id;
 else
   update public.tenant_domains set status='pending',is_primary=true,verification_token=gen_random_uuid()::text,verified_at=null,activated_at=null,metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object('source','subscriber_domain_settings','connection_requested_at',now()) where tenant_domains.id=v_domain_id;
 end if;
 insert into public.platform_owner_domain_actions(tenant_id,domain_id,title,message,status)
 values(v_tenant_id,v_domain_id,'Domain connection required','A subscriber has requested connection of a customer-owned domain. Review the hostname, prepare the approved TradeFlow connection, then provide the exact DNS instructions.','open')
 on conflict(domain_id,action_type) do update set status='open',title=excluded.title,message=excluded.message,updated_at=now(),completed_at=null;
 return query select td.id,td.tenant_id,td.hostname,td.domain_type,td.status,td.is_primary,td.verification_token,td.created_at from public.tenant_domains td where td.id=v_domain_id;
end; $$;

create or replace function public.platform_owner_list_domain_actions()
returns table(action_id uuid,tenant_id uuid,business_name text,domain_id uuid,hostname text,domain_status text,action_status text,title text,message text,dns_instructions jsonb,owner_notes text,created_at timestamptz,updated_at timestamptz)
language plpgsql security definer set search_path=pg_catalog,public,private as $$
begin
 perform private.require_platform_owner(auth.uid());
 return query select a.id,a.tenant_id,t.name,a.domain_id,d.hostname,d.status,a.status,a.title,a.message,a.dns_instructions,a.owner_notes,a.created_at,a.updated_at
 from public.platform_owner_domain_actions a join public.tenants t on t.id=a.tenant_id join public.tenant_domains d on d.id=a.domain_id
 where a.status<>'completed' order by a.created_at desc;
end; $$;

create or replace function public.platform_owner_update_domain_action(p_action_id uuid,p_status text,p_dns_instructions jsonb default '{}'::jsonb,p_owner_notes text default null)
returns table(action_id uuid,action_status text,domain_status text,dns_instructions jsonb,owner_notes text,updated_at timestamptz)
language plpgsql security definer set search_path=pg_catalog,public,private as $$
declare v_domain_id uuid;
begin
 perform private.require_platform_owner(auth.uid());
 if p_status not in('open','in_progress','awaiting_customer','completed','failed') then raise exception 'invalid domain action status'; end if;
 select domain_id into v_domain_id from public.platform_owner_domain_actions where id=p_action_id;
 if v_domain_id is null then raise exception 'domain action not found'; end if;
 if p_status='completed' and not exists(select 1 from public.tenant_domains d where d.id=v_domain_id and d.status='active' and d.verified_at is not null and d.activated_at is not null) then raise exception 'domain cannot be completed until DNS, SSL and activation verification has succeeded'; end if;
 update public.platform_owner_domain_actions set status=p_status,dns_instructions=coalesce(p_dns_instructions,dns_instructions),owner_notes=p_owner_notes,updated_at=now(),completed_at=case when p_status='completed' then now() else null end where id=p_action_id;
 return query select a.id,a.status,d.status,a.dns_instructions,a.owner_notes,a.updated_at from public.platform_owner_domain_actions a join public.tenant_domains d on d.id=a.domain_id where a.id=p_action_id;
end; $$;

revoke all on public.platform_owner_domain_actions from anon,authenticated;
grant execute on function public.subscriber_request_custom_domain(text) to authenticated;
grant execute on function public.platform_owner_list_domain_actions() to authenticated;
grant execute on function public.platform_owner_update_domain_action(uuid,text,jsonb,text) to authenticated;