-- Complete subscriber buying detail access through a controlled RPC.
create or replace function public.subscriber_get_buying_item_customer_details(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare v jsonb;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'buying.view') then raise exception 'Buying permission required'; end if;
 select jsonb_build_object(
  'customer',jsonb_build_object('customer_reference',c.customer_reference,'first_name',c.first_name,'last_name',c.last_name,'email',c.email,'phone',c.phone),
  'request_notes',r.notes,
  'item',jsonb_build_object('id',bi.id,'item_reference',bi.item_reference,'title',bi.title,'description',bi.description,'quantity',bi.quantity,'item_condition',bi.item_condition,'category_id',bi.category_id),
  'fields',coalesce((select jsonb_agg(jsonb_build_object('field_id',f.id,'label',f.label,'field_key',f.field_key,'field_type',f.field_type,'value',case when f.field_type in ('text','textarea','email','phone','url','select','multiselect') then vfv.value_text when f.field_type in ('number','currency') then to_jsonb(vfv.value_number) when f.field_type='boolean' then to_jsonb(vfv.value_boolean) when f.field_type='date' then to_jsonb(vfv.value_date) else vfv.value_json end) order by f.sort_order,f.label) from public.buying_item_field_values vfv join public.category_fields f on f.id=vfv.field_id and f.tenant_id=vfv.tenant_id where vfv.tenant_id=p_tenant_id and vfv.buying_item_id=bi.id),'[]'::jsonb)
 ) into v
 from public.buying_items bi join public.buying_requests r on r.id=bi.buying_request_id and r.tenant_id=bi.tenant_id join public.customers c on c.id=r.customer_id and c.tenant_id=r.tenant_id
 where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;
 if v is null then raise exception 'Buying item not found'; end if; return v;
end; $$;
revoke execute on function public.subscriber_get_buying_item_customer_details(uuid,uuid) from public,anon;
grant execute on function public.subscriber_get_buying_item_customer_details(uuid,uuid) to authenticated;

-- Customer status must reflect an accepted offer rather than reverting to "valued".
create or replace function public.customer_get_selling_status(p_tenant_id uuid)
returns table(request_id uuid,request_reference text,buying_item_id uuid,item_reference text,item_title text,request_status text,item_status text,stage text,message text,manual_notification_sent boolean)
language plpgsql stable security definer set search_path=''
as $$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select r.id,r.request_reference,bi.id,bi.item_reference,bi.title,r.status,bi.status,
 case
  when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='accepted') then 'offer_accepted'
  when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'offer_ready'
  when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'valued'
  when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'manual_valuation'
  when bi.status in ('submitted','under_review') then 'valuation_in_progress'
  else 'submitted'
 end,
 case
  when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='accepted') then 'You accepted the offer. Your acquisition is now being processed.'
  when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'Your offer is ready to review. Please accept or refuse it.'
  when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'Your valuation has been completed. Your offer will appear here when it is sent.'
  when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'We cannot automatically value this item. Your item has been sent for manual valuation. You will receive your valuation once it has been processed.'
  else 'We have received your item and it is currently being reviewed.'
 end,
 exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id)
 from public.buying_items bi join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 where bi.tenant_id=p_tenant_id and r.customer_id=v_customer_id order by bi.created_at desc,bi.sort_order;
end; $$;