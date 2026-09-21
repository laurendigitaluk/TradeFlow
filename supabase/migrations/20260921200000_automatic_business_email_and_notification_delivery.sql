-- Automatic business email settings and queued notification delivery.
-- Applied to production on 2026-09-21.

alter table public.notification_templates drop constraint if exists notification_templates_event_code_check;
alter table public.notification_templates add constraint notification_templates_event_code_check
check (event_code = any(array[
'offer_sent','offer_accepted','offer_refused','item_received','item_dispatched','payment_sent',
'order_confirmation','order_dispatched','return_received','refund_issued','valuation_received',
'valuation_manual_required','customer_buying_request_received'
]));

create or replace function public.subscriber_save_business_email(p_tenant_id uuid, p_email text)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_name text; v_email text;
begin
 if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'tenant.manage') then raise exception 'Not authorised'; end if;
 v_email:=lower(trim(p_email));
 if v_email is null or v_email='' or v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$' then raise exception 'Please enter a valid business email address.'; end if;
 select name into v_name from public.tenants where id=p_tenant_id;
 insert into public.tenant_email_settings(tenant_id,sender_email,reply_to_email,sender_name,email_enabled,sender_verification_status,sender_verified_at,sender_provider,email_footer,business_name_override)
 values(p_tenant_id,v_email,v_email,v_name,true,'pending',null,'resend',null,v_name)
 on conflict(tenant_id) do update set sender_email=excluded.sender_email,reply_to_email=excluded.reply_to_email,sender_name=excluded.sender_name,email_enabled=true,
 sender_verification_status=case when public.tenant_email_settings.sender_email is distinct from excluded.sender_email then 'pending' else coalesce(public.tenant_email_settings.sender_verification_status,'pending') end,
 sender_verified_at=case when public.tenant_email_settings.sender_email is distinct from excluded.sender_email then null else public.tenant_email_settings.sender_verified_at end,
 sender_provider='resend',business_name_override=excluded.business_name_override,updated_at=now();
 return jsonb_build_object('email',v_email,'sender_name',v_name,'status',(select sender_verification_status from public.tenant_email_settings where tenant_id=p_tenant_id));
end $$;
revoke all on function public.subscriber_save_business_email(uuid,text) from public,anon;
grant execute on function public.subscriber_save_business_email(uuid,text) to authenticated;

create or replace function public.notification_processor_auth_secret()
returns text language plpgsql security definer set search_path='' as $$
begin
 if current_user <> 'service_role' then raise exception 'Not authorised'; end if;
 return (select decrypted_secret from vault.decrypted_secrets where name='tradeflow_notification_processor_secret' limit 1);
end $$;
revoke all on function public.notification_processor_auth_secret() from public,anon,authenticated;
grant execute on function public.notification_processor_auth_secret() to service_role;

create or replace function public.claim_notification_queue_batch(p_limit integer default 20)
returns table(id uuid,tenant_id uuid,recipient_email text,recipient_name text,subject text,template_code text,body_template text,payload jsonb,idempotency_key text,email_settings jsonb)
language plpgsql security definer set search_path='' as $$
begin
 return query with picked as (
 select q.id from public.notification_queue q join public.tenant_email_settings s on s.tenant_id=q.tenant_id
 where q.status='queued' and coalesce(q.scheduled_for,now())<=now() and q.attempts<5 and s.email_enabled=true and s.sender_email is not null and s.sender_verification_status='verified'
 order by q.created_at for update skip locked limit greatest(1,least(coalesce(p_limit,20),100))
 ), claimed as (
 update public.notification_queue q set status='processing',attempts=q.attempts+1,updated_at=now() from picked p where q.id=p.id returning q.*
 )
 select c.id,c.tenant_id,c.recipient_email,c.recipient_name,c.subject,c.template_code,coalesce(t.body_template,''),c.payload,c.idempotency_key,
 jsonb_build_object('sender_email',s.sender_email,'reply_to_email',s.reply_to_email,'sender_name',s.sender_name,'email_enabled',s.email_enabled,'sender_verification_status',s.sender_verification_status)
 from claimed c join public.tenant_email_settings s on s.tenant_id=c.tenant_id
 left join public.notification_templates t on t.template_code=c.template_code and t.enabled=true order by c.created_at;
end $$;
revoke all on function public.claim_notification_queue_batch(integer) from public,anon,authenticated;
grant execute on function public.claim_notification_queue_batch(integer) to service_role;

create or replace function public.mark_notification_sent(p_id uuid,p_provider text,p_provider_message_id text)
returns void language sql security definer set search_path='' as $$
 update public.notification_queue set status='sent',provider=p_provider,provider_message_id=p_provider_message_id,sent_at=now(),last_error=null,updated_at=now() where id=p_id;
$$;
revoke all on function public.mark_notification_sent(uuid,text,text) from public,anon,authenticated;
grant execute on function public.mark_notification_sent(uuid,text,text) to service_role;

create or replace function public.mark_notification_failed(p_id uuid,p_error text)
returns void language plpgsql security definer set search_path='' as $$
declare v_attempts integer;
begin
 select attempts into v_attempts from public.notification_queue where id=p_id for update;
 update public.notification_queue set status=case when coalesce(v_attempts,0)>=5 then 'failed' else 'queued' end,
 scheduled_for=case when coalesce(v_attempts,0)>=5 then scheduled_for else now()+interval '5 minutes' end,
 last_error=left(coalesce(p_error,'Notification delivery failed'),2000),updated_at=now() where id=p_id;
end $$;
revoke all on function public.mark_notification_failed(uuid,text) from public,anon,authenticated;
grant execute on function public.mark_notification_failed(uuid,text) to service_role;

insert into public.notification_templates(tenant_id,event_code,template_code,subject_template,body_template,enabled,is_system)
values(null,'customer_buying_request_received','system_customer_buying_request_received','New customer item submitted for valuation',
'A customer has submitted an item for valuation. Reference: <strong>{{request_reference}}</strong>.<br><br>Customer: {{customer_name}}<br>Item: {{item_title}}<br>Item reference: {{item_reference}}<br><br>Open TradeFlow Buying to review the submission.',true,true)
on conflict do nothing;

create or replace function private.queue_buying_request_received_notification()
returns trigger language plpgsql security definer set search_path='pg_catalog','public' as $$
declare v_customer record; v_item record; v_sender record; v_name text;
begin
 select c.email,c.first_name,c.last_name into v_customer from public.customers c where c.tenant_id=new.tenant_id and c.id=new.customer_id;
 select bi.item_reference,bi.title into v_item from public.buying_items bi where bi.tenant_id=new.tenant_id and bi.buying_request_id=new.id order by bi.sort_order limit 1;
 v_name:=trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,''));
 if v_customer.email is not null then
   perform private.queue_customer_notification(new.tenant_id,'valuation_received','buying_request',new.id,v_customer.email,v_name,jsonb_build_object('customer_name',v_name,'item_title',coalesce(v_item.title,'your item'),'item_reference',coalesce(v_item.item_reference,''),'request_reference',new.request_reference));
 end if;
 select sender_email,sender_name,email_enabled,sender_verification_status into v_sender from public.tenant_email_settings where tenant_id=new.tenant_id;
 if v_sender.sender_email is not null then
   perform private.queue_customer_notification(new.tenant_id,'customer_buying_request_received','buying_request',new.id,v_sender.sender_email,coalesce(v_sender.sender_name,''),jsonb_build_object('customer_name',v_name,'item_title',coalesce(v_item.title,'customer item'),'item_reference',coalesce(v_item.item_reference,''),'request_reference',new.request_reference));
 end if;
 return new;
end $$;

create extension if not exists pg_cron;
create extension if not exists pg_net;
do $$
begin
 if not exists(select 1 from vault.decrypted_secrets where name='tradeflow_notification_processor_secret') then
  perform vault.create_secret(encode(gen_random_bytes(32),'hex'),'tradeflow_notification_processor_secret','Secret used only by the TradeFlow notification queue scheduler.');
 end if;
 if not exists(select 1 from vault.decrypted_secrets where name='tradeflow_project_url') then
  perform vault.create_secret('https://twfbmjwwqzxdxvclxbun.supabase.co','tradeflow_project_url','TradeFlow Supabase project URL for scheduled Edge Function calls.');
 end if;
end $$;
do $$ begin perform cron.unschedule('tradeflow-notification-queue'); exception when others then null; end $$;
select cron.schedule('tradeflow-notification-queue','* * * * *',$cron$
 select net.http_post(
  url:=(select decrypted_secret from vault.decrypted_secrets where name='tradeflow_project_url')||'/functions/v1/process-notification-queue',
  headers:=jsonb_build_object('Content-Type','application/json','x-tradeflow-cron-secret',(select decrypted_secret from vault.decrypted_secrets where name='tradeflow_notification_processor_secret')),
  body:=jsonb_build_object('run_at',now()),timeout_milliseconds:=10000
 ) as request_id;
$cron$);
