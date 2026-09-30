-- Show accepted customer offers as a distinct selling stage.
create or replace function public.customer_get_selling_status(p_tenant_id uuid)
returns table(request_id uuid, request_reference text, buying_item_id uuid, item_reference text, item_title text, request_status text, item_status text, stage text, message text, manual_notification_sent boolean)
language plpgsql stable security definer set search_path=''
as $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select r.id,r.request_reference,bi.id,bi.item_reference,bi.title,r.status,bi.status,
  case
   when exists(select 1 from public.acquisitions a join public.offers o on o.id=a.source_offer_id where a.tenant_id=bi.tenant_id and a.customer_id=v_customer_id and o.buying_item_id=bi.id and a.status in ('accepted','awaiting_item','received','processing','completed')) then 'offer_accepted'
   when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'offer_ready'
   when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'valued'
   when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'manual_valuation'
   when bi.status in ('submitted','under_review') then 'valuation_in_progress'
   else 'submitted'
  end,
  case
   when exists(select 1 from public.acquisitions a join public.offers o on o.id=a.source_offer_id where a.tenant_id=bi.tenant_id and a.customer_id=v_customer_id and o.buying_item_id=bi.id and a.status in ('accepted','awaiting_item','received','processing','completed')) then 'Offer accepted. Your sale has been created and is now awaiting the next step.'
   when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'Your offer is ready to review.'
   when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'Your valuation has been completed.'
   when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'We cannot automatically value this item. Your item has been sent for manual valuation. You will receive your valuation once it has been processed.'
   else 'We have received your item and it is currently being reviewed.'
  end,
  exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id)
 from public.buying_items bi join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 where bi.tenant_id=p_tenant_id and r.customer_id=v_customer_id order by bi.created_at desc,bi.sort_order;
end; $function$;
