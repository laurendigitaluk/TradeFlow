alter table public.notification_templates drop constraint if exists notification_templates_event_code_check;
alter table public.notification_templates add constraint notification_templates_event_code_check check (
 event_code = any(array['offer_sent','offer_accepted','offer_refused','item_received','item_dispatched','payment_sent','order_confirmation','order_dispatched','return_received','refund_issued','valuation_received','valuation_manual_required']::text[])
);

insert into public.notification_templates
(tenant_id,event_code,template_code,subject_template,body_template,enabled,is_system)
values
(null,'valuation_received','system_valuation_received','We have received your item for valuation',
'Hello {{customer_name}},<br><br>We have received your item <strong>{{item_title}}</strong> ({{item_reference}}) for valuation.<br><br>We are now reviewing it. If an automatic valuation is available, it will be processed. If not, we will move it to manual valuation and let you know.<br><br>Your reference is <strong>{{request_reference}}</strong>.',true,true),
(null,'valuation_manual_required','system_valuation_manual_required','Your item requires a manual valuation',
'Hello {{customer_name}},<br><br>We cannot automatically value your item <strong>{{item_title}}</strong> ({{item_reference}}).<br><br>Your item has been sent for manual valuation. You will receive your valuation once it has been processed.<br><br>Your reference is <strong>{{request_reference}}</strong>.',true,true)
on conflict do nothing;

create or replace function private.queue_customer_notification(p_tenant_id uuid,p_event_code text,p_entity_type text,p_entity_id uuid,p_recipient_email text,p_recipient_name text default null,p_payload jsonb default '{}'::jsonb)
returns uuid language plpgsql security definer set search_path='pg_catalog','public' as $$
declare v_template public.notification_templates%rowtype; v_enabled boolean; v_notification_id uuid; v_idempotency text;
begin
 if p_tenant_id is null or p_event_code is null or p_entity_type is null or p_entity_id is null or p_recipient_email is null then raise exception 'notification arguments are incomplete'; end if;
 select coalesce(email_enabled,false) into v_enabled from public.tenant_email_settings where tenant_id=p_tenant_id;
 if not found or not v_enabled then return null; end if;
 select enabled into v_enabled from public.tenant_email_notification_settings where tenant_id=p_tenant_id and event_code=p_event_code;
 if not found then v_enabled:=true; end if;
 if not v_enabled then return null; end if;
 select * into v_template from public.notification_templates where tenant_id=p_tenant_id and event_code=p_event_code and enabled=true limit 1;
 if not found then select * into v_template from public.notification_templates where tenant_id is null and event_code=p_event_code and enabled=true and is_system=true limit 1; end if;
 if not found then raise exception 'no notification template configured for event %',p_event_code; end if;
 v_idempotency:=p_tenant_id::text||':'||p_event_code||':'||p_entity_type||':'||p_entity_id::text;
 insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload) values(p_tenant_id,p_event_code,p_entity_type,p_entity_id,p_payload) on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
 insert into public.notification_queue(tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,idempotency_key)
 values(p_tenant_id,p_event_code,p_recipient_email,p_recipient_name,v_template.subject_template,v_template.template_code,p_payload,'queued',v_idempotency)
 on conflict (tenant_id,idempotency_key) do nothing
 returning id into v_notification_id;
 return v_notification_id;
end; $$;

create or replace function private.queue_buying_request_received_notification()
returns trigger language plpgsql security definer set search_path='pg_catalog','public' as $$
declare v_customer record; v_item record;
begin
 select c.email,c.first_name,c.last_name into v_customer from public.customers c where c.tenant_id=new.tenant_id and c.id=new.customer_id;
 if v_customer.email is null then return new; end if;
 select bi.item_reference,bi.title into v_item from public.buying_items bi where bi.tenant_id=new.tenant_id and bi.buying_request_id=new.id order by bi.sort_order limit 1;
 perform private.queue_customer_notification(new.tenant_id,'valuation_received','buying_request',new.id,v_customer.email,trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),jsonb_build_object('customer_name',trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),'item_title',coalesce(v_item.title,'your item'),'item_reference',coalesce(v_item.item_reference,''),'request_reference',new.request_reference));
 return new;
end; $$;

drop trigger if exists buying_requests_customer_valuation_received on public.buying_requests;
create trigger buying_requests_customer_valuation_received after insert on public.buying_requests for each row execute function private.queue_buying_request_received_notification();

create or replace function public.queue_customer_manual_valuation_notification(p_tenant_id uuid,p_buying_item_id uuid)
returns uuid language plpgsql security definer set search_path='pg_catalog','public' as $$
declare v_actor uuid:=auth.uid(); v_item record; v_request record; v_customer record; v_payload jsonb;
begin
 if v_actor is null or not private.is_tenant_member(p_tenant_id,v_actor) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,v_actor,'valuation.manage') then raise exception 'Permission required: valuation.manage'; end if;
 select bi.id,bi.title,bi.item_reference,bi.buying_request_id into v_item from public.buying_items bi where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;
 if not found then raise exception 'Buying item not found'; end if;
 select r.id,r.request_reference,r.customer_id into v_request from public.buying_requests r where r.tenant_id=p_tenant_id and r.id=v_item.buying_request_id;
 select c.email,c.first_name,c.last_name into v_customer from public.customers c where c.tenant_id=p_tenant_id and c.id=v_request.customer_id;
 v_payload:=jsonb_build_object('customer_name',trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),'item_title',coalesce(v_item.title,'your item'),'item_reference',v_item.item_reference,'request_reference',v_request.request_reference);
 insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload) values(p_tenant_id,'valuation_manual_required','buying_item',v_item.id,v_payload) on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
 if v_customer.email is null then return null; end if;
 return private.queue_customer_notification(p_tenant_id,'valuation_manual_required','buying_item',v_item.id,v_customer.email,trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),v_payload);
end; $$;

create or replace function public.customer_get_selling_status(p_tenant_id uuid)
returns table(request_id uuid,request_reference text,buying_item_id uuid,item_reference text,item_title text,request_status text,item_status text,stage text,message text,manual_notification_sent boolean)
language plpgsql stable security definer set search_path='' as $$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select r.id,r.request_reference,bi.id,bi.item_reference,bi.title,r.status,bi.status,
 case when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'offer_ready'
 when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'valued'
 when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'manual_valuation'
 when bi.status in ('submitted','under_review') then 'valuation_in_progress' else 'submitted' end,
 case when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'Your offer is ready to review.'
 when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'Your valuation has been completed.'
 when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'We cannot automatically value this item. Your item has been sent for manual valuation. You will receive your valuation once it has been processed.'
 else 'We have received your item and it is currently being reviewed.' end,
 exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id)
 from public.buying_items bi join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 where bi.tenant_id=p_tenant_id and r.customer_id=v_customer_id order by bi.created_at desc,bi.sort_order;
end; $$;