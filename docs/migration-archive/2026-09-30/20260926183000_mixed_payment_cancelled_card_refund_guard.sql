-- Prevent a locally-cancelled Stripe payment attempt from being treated as a successful payment.
-- The Stripe webhook uses a false result to trigger a conflict refund.

create or replace function public.process_external_payment_event(
  p_provider text,
  p_event_id text,
  p_event_type text,
  p_tenant_id uuid,
  p_payment_id uuid,
  p_provider_payment_id text,
  p_new_status text,
  p_amount numeric,
  p_currency text,
  p_metadata jsonb default '{}'::jsonb
)
returns boolean
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare
 v_payment public.payment_records%rowtype;
 v_order public.retail_orders%rowtype;
 v_listing public.listings%rowtype;
 v_existing uuid;
 v_hold public.customer_credit_holds%rowtype;
 v_account public.customer_credit_accounts%rowtype;
 v_credit_payment_id uuid;
 v_credit_ledger_id uuid;
begin
 if current_setting('request.jwt.claim.role',true)<>'service_role' then raise exception 'Service role required'; end if;
 if p_provider is null or p_event_id is null or p_event_type is null then raise exception 'Provider event identity required'; end if;
 if p_new_status not in ('paid','failed','cancelled') then raise exception 'Unsupported external payment status'; end if;

 select id into v_existing from public.payment_provider_events where provider=p_provider and event_id=p_event_id limit 1;
 if v_existing is not null then return true; end if;

 select * into v_payment from public.payment_records where tenant_id=p_tenant_id and id=p_payment_id for update;
 if not found then raise exception 'Payment record not found'; end if;
 if p_provider_payment_id is not null and coalesce(v_payment.provider_payment_id,'')<>p_provider_payment_id then raise exception 'Provider payment mismatch'; end if;
 if v_payment.amount<>p_amount or upper(v_payment.currency)<>upper(p_currency) then raise exception 'Payment amount or currency mismatch'; end if;

 if v_payment.status='cancelled' and p_new_status='paid' then
   return false;
 end if;

 if v_payment.status in ('paid','failed','cancelled','refunded','partially_refunded') then return true; end if;

 if v_payment.retail_order_id is not null then
   select * into v_order from public.retail_orders where tenant_id=p_tenant_id and id=v_payment.retail_order_id for update;
   if not found then raise exception 'Retail order not found'; end if;

   if p_new_status='paid' then
     if v_order.status<>'pending_payment' then raise exception 'Retail order is not awaiting payment'; end if;
     if v_order.amount_due<>p_amount then raise exception 'Retail order amount due does not match payment'; end if;
     select * into v_listing from public.listings l
     where l.tenant_id=p_tenant_id and l.id=(
       select i.listing_id from public.retail_order_items i
       where i.tenant_id=p_tenant_id and i.order_id=v_order.id order by i.created_at limit 1
     ) for update;
     if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then return false; end if;

     select h.* into v_hold from public.customer_credit_holds h
     where h.tenant_id=p_tenant_id and h.retail_order_id=v_order.id and h.status='active'
     for update;

     if found then
       select a.* into v_account from public.customer_credit_accounts a
       where a.tenant_id=p_tenant_id and a.customer_id=v_order.customer_id for update;
       if not found or coalesce(v_account.balance,0)<v_hold.amount then
         raise exception 'Customer credit reserved for this order is no longer available';
       end if;

       update public.customer_credit_accounts set balance=balance-v_hold.amount,updated_at=now() where id=v_account.id;

       insert into public.payment_records(
         tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,
         customer_id,retail_order_id,notes,created_by,processed_at
       ) values(
         p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
         'customer_payment','paid','inbound',v_hold.amount,v_order.currency,'customer_credit',
         v_order.customer_id,v_order.id,'Retail order credit applied as part of mixed payment.',null,now()
       ) returning id into v_credit_payment_id;

       insert into public.ledger_entries(
         tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
         description,reference_type,reference_id,posted_at
       ) values(
         p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
         'payment','credit','posted',v_hold.amount,v_order.currency,v_order.customer_id,v_order.id,
         'Retail order customer credit portion','payment_record',v_credit_payment_id,now()
       ) returning id into v_credit_ledger_id;

       update public.customer_credit_holds set status='applied',applied_at=now() where id=v_hold.id;
     end if;
   elsif p_new_status in ('failed','cancelled') then
     select h.* into v_hold from public.customer_credit_holds h
     where h.tenant_id=p_tenant_id and h.retail_order_id=v_order.id and h.status='active'
     for update;
     if found then
       update public.retail_orders
       set amount_due=amount_due+v_hold.amount,
           trade_in_credit_total=greatest(coalesce(trade_in_credit_total,0)-v_hold.amount,0),
           updated_at=now()
       where tenant_id=p_tenant_id and id=v_order.id;
       update public.customer_credit_holds set status='released',released_at=now() where id=v_hold.id;
     end if;
   end if;
 end if;

 update public.payment_records
 set status=p_new_status,provider=p_provider,provider_payment_id=coalesce(provider_payment_id,p_provider_payment_id),
     processed_at=now(),updated_at=now(),metadata=coalesce(metadata,'{}'::jsonb)||coalesce(p_metadata,'{}'::jsonb)
 where tenant_id=p_tenant_id and id=p_payment_id;

 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
 values(p_tenant_id,'payment_record',v_payment.id,v_payment.status,p_new_status,null,'External payment provider status update',
        jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

 if v_payment.retail_order_id is not null and p_new_status='paid' then
   update public.retail_orders
   set status='paid',payment_status='paid',paid_at=coalesce(paid_at,now()),amount_due=0,placed_at=coalesce(placed_at,now()),updated_at=now()
   where tenant_id=p_tenant_id and id=v_order.id;

   insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
   values(p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',null,'External payment provider confirmed payment',
          jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

   insert into public.ledger_entries(tenant_id,entry_type,direction,status,amount,currency,customer_id,retail_order_id,description,reference_type,reference_id,metadata)
   values(p_tenant_id,'payment','credit','posted',p_amount,p_currency,v_order.customer_id,v_order.id,'Retail order payment','retail_order',v_order.id,
          jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

   update public.listings set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
   where tenant_id=p_tenant_id and id=v_listing.id and status='published';

   update public.inventory_assets set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
   where tenant_id=p_tenant_id and id=v_listing.asset_id and status in ('listed','reserved');

 elsif v_payment.retail_order_id is not null and p_new_status='cancelled' then
   if v_order.status in ('initiated','pending_payment') then
     update public.retail_orders set status='cancelled',cancelled_at=coalesce(cancelled_at,now()),updated_at=now()
     where tenant_id=p_tenant_id and id=v_order.id;

     insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
     values(p_tenant_id,'retail_order',v_order.id,v_order.status,'cancelled',null,'External payment provider cancelled or expired unpaid retail order',
            jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

     update public.listings l set status='published',reserved_at=null,updated_at=now()
     where l.tenant_id=p_tenant_id and l.status='reserved' and l.id in (
       select i.listing_id from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_order.id and i.listing_id is not null
     );
     update public.inventory_assets ia set status='listed',updated_at=now()
     where ia.tenant_id=p_tenant_id and ia.status='reserved' and ia.id in (
       select i.inventory_asset_id from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_order.id and i.inventory_asset_id is not null
     );
   end if;
 end if;

 insert into public.payment_provider_events(provider,event_id,event_type,metadata)
 values(p_provider,p_event_id,p_event_type,coalesce(p_metadata,'{}'::jsonb))
 on conflict(provider,event_id) do nothing;
 return true;
end;
$function$;
