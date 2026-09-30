-- Return-to-customer workflow after inspection refusal.
create table if not exists public.buying_item_return_shipping (
 id uuid primary key default gen_random_uuid(),
 tenant_id uuid not null references public.tenants(id) on delete cascade,
 buying_item_id uuid not null references public.buying_items(id) on delete cascade,
 return_reason text,
 shipping_method text not null default 'subscriber_override',
 shipping_provider text, shipping_service_url text, shipping_carrier text, shipping_service text,
 shipping_tracking_number text, shipping_tracking_url text, shipping_label_url text,
 shipping_label_storage_path text, shipping_qr_url text, shipping_qr_storage_path text,
 shipping_instructions text, shipping_status text not null default 'return_required',
 shipping_status_updated_at timestamptz not null default now(), shipped_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique (buying_item_id)
);
create index if not exists buying_item_return_shipping_tenant_idx on public.buying_item_return_shipping(tenant_id,buying_item_id);
alter table public.buying_item_return_shipping enable row level security;
drop policy if exists buying_item_return_shipping_subscriber_select on public.buying_item_return_shipping;
create policy buying_item_return_shipping_subscriber_select on public.buying_item_return_shipping for select to authenticated using (private.is_tenant_member(tenant_id,auth.uid()));
drop policy if exists buying_item_return_shipping_customer_select on public.buying_item_return_shipping;
create policy buying_item_return_shipping_customer_select on public.buying_item_return_shipping for select to authenticated using (exists(select 1 from public.buying_items bi join public.buying_requests br on br.id=bi.buying_request_id and br.tenant_id=bi.tenant_id join public.customers c on c.id=br.customer_id and c.tenant_id=bi.tenant_id where bi.tenant_id=buying_item_return_shipping.tenant_id and bi.id=buying_item_return_shipping.buying_item_id and c.auth_user_id=auth.uid()));
drop policy if exists tradeflow_media_buying_item_return_subscriber_insert on storage.objects;
create policy tradeflow_media_buying_item_return_subscriber_insert on storage.objects for insert to authenticated with check (bucket_id='tradeflow-media' and (storage.foldername(name))[2]='buying-items' and (storage.foldername(name))[4] like 'return-label-%' and private.is_tenant_member(((storage.foldername(name))[1])::uuid,auth.uid()));
drop policy if exists tradeflow_media_buying_item_return_customer_select on storage.objects;
create policy tradeflow_media_buying_item_return_customer_select on storage.objects for select to authenticated using (bucket_id='tradeflow-media' and (storage.foldername(name))[2]='buying-items' and (storage.foldername(name))[4] like 'return-label-%' and exists(select 1 from public.buying_items bi join public.buying_requests br on br.id=bi.buying_request_id and br.tenant_id=bi.tenant_id join public.customers c on c.id=br.customer_id and c.tenant_id=bi.tenant_id where bi.tenant_id=((storage.foldername(name))[1])::uuid and bi.id=((storage.foldername(name))[3])::uuid and c.auth_user_id=auth.uid()));

-- Inspection refusal now requires the explicit mismatch check and routes the item to return_pending.
-- The live function definition is deployed by the TEST migration of the same name.

create or replace function public.subscriber_publish_buying_item_return_shipping(
 p_tenant_id uuid,p_buying_item_id uuid,p_shipping_method text default 'subscriber_override',
 p_shipping_label_url text default null,p_shipping_label_storage_path text default null,
 p_shipping_qr_url text default null,p_shipping_qr_storage_path text default null,
 p_shipping_carrier text default null,p_shipping_service text default null,
 p_shipping_tracking_number text default null,p_shipping_tracking_url text default null,
 p_shipping_instructions text default null,p_shipping_provider text default null,p_shipping_service_url text default null)
returns jsonb language plpgsql security definer set search_path to 'public','private'
as $function$
declare v_actor uuid:=auth.uid(); v_stage text;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
 select purchase_stage into v_stage from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if v_stage is null then raise exception 'Buying item not found'; end if;
 if v_stage<>'return_pending' then raise exception 'Buying item is not awaiting return shipping'; end if;
 if coalesce(trim(p_shipping_label_storage_path),'')='' and coalesce(trim(p_shipping_label_url),'')='' then raise exception 'Add the return shipping label before marking the item as returned'; end if;
 if coalesce(trim(p_shipping_tracking_number),'')='' then raise exception 'Enter the return tracking number before sending the return update'; end if;
 insert into public.buying_item_return_shipping(tenant_id,buying_item_id,shipping_method,shipping_label_url,shipping_label_storage_path,shipping_qr_url,shipping_qr_storage_path,shipping_carrier,shipping_service,shipping_tracking_number,shipping_tracking_url,shipping_instructions,shipping_provider,shipping_service_url,shipping_status,shipping_status_updated_at,shipped_at)
 values(p_tenant_id,p_buying_item_id,p_shipping_method,p_shipping_label_url,p_shipping_label_storage_path,p_shipping_qr_url,p_shipping_qr_storage_path,p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_tracking_url,p_shipping_instructions,p_shipping_provider,p_shipping_service_url,'return_shipped',now(),now())
 on conflict (buying_item_id) do update set shipping_method=excluded.shipping_method,shipping_label_url=coalesce(excluded.shipping_label_url,buying_item_return_shipping.shipping_label_url),shipping_label_storage_path=coalesce(excluded.shipping_label_storage_path,buying_item_return_shipping.shipping_label_storage_path),shipping_qr_url=coalesce(excluded.shipping_qr_url,buying_item_return_shipping.shipping_qr_url),shipping_qr_storage_path=coalesce(excluded.shipping_qr_storage_path,buying_item_return_shipping.shipping_qr_storage_path),shipping_carrier=excluded.shipping_carrier,shipping_service=excluded.shipping_service,shipping_tracking_number=excluded.shipping_tracking_number,shipping_tracking_url=excluded.shipping_tracking_url,shipping_instructions=excluded.shipping_instructions,shipping_provider=excluded.shipping_provider,shipping_service_url=excluded.shipping_service_url,shipping_status='return_shipped',shipping_status_updated_at=now(),shipped_at=now(),updated_at=now();
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id) values(p_tenant_id,'buying_item',p_buying_item_id,'return_pending','return_shipped',coalesce(p_shipping_instructions,'Return shipped to customer.'),jsonb_build_object('source','buying_return_shipping','tracking_number',p_shipping_tracking_number),v_actor);
 return jsonb_build_object('ok',true,'buying_item_id',p_buying_item_id,'status','return_shipped');
end;$function$;
grant execute on function public.subscriber_publish_buying_item_return_shipping(uuid,uuid,text,text,text,text,text,text,text,text,text,text,text,text) to authenticated;