-- Platform owner controls the single TradeFlow sending address.
create table if not exists public.platform_email_settings(
 id boolean primary key default true check(id=true),
 sender_email text,
 sender_name text not null default 'TradeFlow',
 email_enabled boolean not null default false,
 sender_verification_status text not null default 'not_configured' check(sender_verification_status in ('not_configured','pending','verified','failed')),
 sender_verified_at timestamptz,
 provider text not null default 'resend',
 updated_at timestamptz not null default now(),
 updated_by uuid
);
insert into public.platform_email_settings(id) values(true) on conflict(id) do nothing;
alter table public.platform_email_settings enable row level security;
drop policy if exists platform_email_settings_owner_read on public.platform_email_settings;
drop policy if exists platform_email_settings_owner_write on public.platform_email_settings;
create policy platform_email_settings_owner_read on public.platform_email_settings for select to authenticated using (private.is_platform_owner(auth.uid()));
create policy platform_email_settings_owner_write on public.platform_email_settings for all to authenticated using (private.is_platform_owner(auth.uid())) with check (private.is_platform_owner(auth.uid()));

create or replace function public.platform_owner_save_email(p_email text)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_email text;
begin
 if not private.is_platform_owner(auth.uid()) then raise exception 'Not authorised'; end if;
 v_email:=nullif(lower(trim(p_email)),'');
 if v_email is not null and v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$' then raise exception 'Please enter a valid TradeFlow email address.'; end if;
 update public.platform_email_settings set sender_email=v_email,email_enabled=(v_email is not null),
 sender_verification_status=case when v_email is null then 'not_configured' else 'pending' end,
 sender_verified_at=null,updated_at=now(),updated_by=auth.uid() where id=true;
 return (select to_jsonb(p) from public.platform_email_settings p where id=true);
end $$;
revoke all on function public.platform_owner_save_email(text) from public,anon;
grant execute on function public.platform_owner_save_email(text) to authenticated;

create or replace function public.platform_owner_get_email()
returns jsonb language sql security definer set search_path='' as $$
 select to_jsonb(p) from public.platform_email_settings p where p.id=true and private.is_platform_owner(auth.uid());
$$;
revoke all on function public.platform_owner_get_email() from public,anon;
grant execute on function public.platform_owner_get_email() to authenticated;

create or replace function public.subscriber_get_email_status(p_tenant_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_tenant record; v_platform record;
begin
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Not authorised'; end if;
 select sender_email,email_enabled into v_tenant from public.tenant_email_settings where tenant_id=p_tenant_id;
 select sender_email,email_enabled,sender_verification_status into v_platform from public.platform_email_settings where id=true;
 return jsonb_build_object('business_email',v_tenant.sender_email,'business_email_enabled',coalesce(v_tenant.email_enabled,false),
 'platform_email',v_platform.sender_email,'platform_email_enabled',coalesce(v_platform.email_enabled,false),
 'platform_email_status',coalesce(v_platform.sender_verification_status,'not_configured'),
 'ready',coalesce(v_tenant.email_enabled,false) and coalesce(v_platform.email_enabled,false) and v_platform.sender_verification_status='verified');
end $$;
revoke all on function public.subscriber_get_email_status(uuid) from public,anon;
grant execute on function public.subscriber_get_email_status(uuid) to authenticated;

create or replace function public.claim_notification_queue_batch(p_limit integer default 20)
returns table(id uuid,tenant_id uuid,recipient_email text,recipient_name text,subject text,template_code text,body_template text,payload jsonb,idempotency_key text,email_settings jsonb)
language plpgsql security definer set search_path='' as $$
begin
 return query with picked as (
 select q.id from public.notification_queue q join public.tenant_email_settings ts on ts.tenant_id=q.tenant_id cross join public.platform_email_settings ps
 where q.status='queued' and coalesce(q.scheduled_for,now())<=now() and q.attempts<5 and ts.email_enabled=true and ts.sender_email is not null and ps.email_enabled=true and ps.sender_email is not null and ps.sender_verification_status='verified'
 order by q.created_at for update skip locked limit greatest(1,least(coalesce(p_limit,20),100))
 ), claimed as (
 update public.notification_queue q set status='processing',attempts=q.attempts+1,updated_at=now() from picked p where q.id=p.id returning q.*
 )
 select c.id,c.tenant_id,c.recipient_email,c.recipient_name,c.subject,c.template_code,coalesce(t.body_template,''),c.payload,c.idempotency_key,
 jsonb_build_object('sender_email',ps.sender_email,'sender_name',ps.sender_name,'email_enabled',ps.email_enabled,'sender_verification_status',ps.sender_verification_status,'reply_to_email',ts.sender_email)
 from claimed c join public.tenant_email_settings ts on ts.tenant_id=c.tenant_id cross join public.platform_email_settings ps left join public.notification_templates t on t.template_code=c.template_code and t.enabled=true order by c.created_at;
end $$;
revoke all on function public.claim_notification_queue_batch(integer) from public,anon,authenticated;
grant execute on function public.claim_notification_queue_batch(integer) to service_role;