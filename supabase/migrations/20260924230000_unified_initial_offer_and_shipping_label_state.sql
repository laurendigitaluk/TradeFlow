-- Present the pre-shipment state accurately after an initial offer is accepted.
-- The database purchase_stage remains awaiting_item so existing workflow transitions are unchanged.
create or replace function public.customer_get_selling_status(p_tenant_id uuid)
returns table(
  request_id uuid,
  request_reference text,
  buying_item_id uuid,
  item_reference text,
  item_title text,
  request_status text,
  item_status text,
  stage text,
  message text,
  manual_notification_sent boolean
)
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id
 from public.customers c
 where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
 limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;

 return query
 select r.id,r.request_reference,bi.id,bi.item_reference,bi.title,r.status,bi.status,
   case
    when bi.purchase_stage='awaiting_item'
      and not exists(
        select 1 from public.buying_item_shipping s
        where s.tenant_id=bi.tenant_id
          and s.buying_item_id=bi.id
          and (
            nullif(s.shipping_label_url,'') is not null
            or nullif(s.shipping_label_storage_path,'') is not null
            or nullif(s.shipping_qr_url,'') is not null
            or nullif(s.shipping_qr_storage_path,'') is not null
          )
      ) then 'awaiting_shipping_label'
    when bi.purchase_stage <> 'none' then bi.purchase_stage
    when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'offer_ready'
    when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'valued'
    when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'manual_valuation'
    when bi.status in ('submitted','under_review') then 'valuation_in_progress'
    else 'submitted'
   end,
   case
    when bi.purchase_stage='awaiting_item'
      and not exists(
        select 1 from public.buying_item_shipping s
        where s.tenant_id=bi.tenant_id
          and s.buying_item_id=bi.id
          and (
            nullif(s.shipping_label_url,'') is not null
            or nullif(s.shipping_label_storage_path,'') is not null
            or nullif(s.shipping_qr_url,'') is not null
            or nullif(s.shipping_qr_storage_path,'') is not null
          )
      ) then 'Your offer has been accepted. The business must now create your shipping label and instructions before you send the item.'
    when bi.purchase_stage='awaiting_item' then 'Your shipping label and instructions are ready. Send the item and confirm when it has been handed to the courier.'
    when bi.purchase_stage='shipping' then 'You have confirmed that the item has been sent. The business is now awaiting receipt.'
    when bi.purchase_stage='received' then 'The business has received your item. It is waiting for inspection.'
    when bi.purchase_stage='inspection' then 'Your item is currently being inspected.'
    when bi.purchase_stage='testing' then 'Your item has been routed for testing. It has not been purchased yet.'
    when bi.purchase_stage='repair' then 'Your item has been routed for repair. It has not been purchased yet.'
    when bi.purchase_stage='return_pending' then 'The item was refused during inspection and is awaiting return to you.'
    when bi.purchase_stage='final_offer_required' then 'The inspection was accepted. The business is preparing a final offer.'
    when bi.purchase_stage='final_offer_sent' then 'A final offer has been sent. Review it and accept or refuse it.'
    when bi.purchase_stage='final_offer_accepted' then 'You accepted the final offer. The business is now completing the payment step.'
    when bi.purchase_stage='final_offer_refused' then 'The final offer was refused. The item remains outside the purchase and inventory process.'
    when bi.purchase_stage='purchased' then 'The final offer was accepted, payment was made and the item is now part of the business inventory.'
    when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'Your offer is ready to review.'
    when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'Your valuation has been completed.'
    when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'We cannot automatically value this item. Your item has been sent for manual valuation.'
    else 'We have received your selling request and it is currently being reviewed.'
   end,
   exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id)
 from public.buying_items bi
 join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 where bi.tenant_id=p_tenant_id and r.customer_id=v_customer_id
 order by bi.created_at desc,bi.sort_order;
end;
$function$;
