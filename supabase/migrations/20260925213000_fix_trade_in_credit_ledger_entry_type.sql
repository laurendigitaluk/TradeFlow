-- Trade-in credit is a customer-account credit, not a new ledger entry type.
-- The ledger schema permits adjustment/payment/etc.; use adjustment for this
-- non-cash customer credit while retaining direction='credit'.
create or replace function public.subscriber_credit_trade_in(p_tenant_id uuid, p_buying_item_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to 'public','private'
as $function$
declare
 v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_offer public.offers%rowtype;
 v_customer_id uuid; v_currency text; v_amount numeric; v_trade uuid; v_acq uuid; v_acq_item uuid; v_ledger uuid; v_asset uuid; v_account uuid;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if v_item.id is null then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage<>'final_offer_required' then raise exception 'This item is not at the post-inspection trade-in decision stage'; end if;
 select * into v_offer from public.offers where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and offer_type='initial' and offer_mode='trade_in' and status='accepted' order by responded_at desc nulls last,created_at desc limit 1;
 if v_offer.id is null then raise exception 'No accepted trade-in offer exists for this item'; end if;
 select br.customer_id into v_customer_id from public.buying_requests br where br.tenant_id=p_tenant_id and br.id=v_item.buying_request_id;
 v_amount:=v_offer.amount; v_currency:=coalesce(v_offer.currency,'GBP');
 if v_amount is null or v_amount<0 then raise exception 'Trade-in credit amount is invalid'; end if;
 if exists(select 1 from public.trade_in_transactions where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and status in ('credited','completed')) then raise exception 'Trade-in credit has already been added'; end if;
 insert into public.customer_credit_accounts(tenant_id,customer_id,balance,currency) values(p_tenant_id,v_customer_id,0,v_currency)
 on conflict(tenant_id,customer_id) do update set currency=excluded.currency,updated_at=now() returning id into v_account;
 insert into public.acquisitions(tenant_id,acquisition_reference,status,customer_id,source_offer_id,currency,agreed_total,payment_total,accepted_at,finalised_at,paid_at,metadata,created_by)
 values(p_tenant_id,'ACQ-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'completed',v_customer_id,v_offer.id,v_currency,v_amount,v_amount,now(),now(),now(),jsonb_build_object('source','trade_in_credit','buying_item_id',p_buying_item_id,'offer_id',v_offer.id,'credit_account_id',v_account),v_actor) returning id into v_acq;
 insert into public.acquisition_items(tenant_id,acquisition_id,buying_item_id,offer_id,status,agreed_amount,final_amount,currency,paid_at,finalised_at,metadata)
 values(p_tenant_id,v_acq,p_buying_item_id,v_offer.id,'completed',v_amount,v_amount,v_currency,now(),now(),jsonb_build_object('source','trade_in_credit')) returning id into v_acq_item;
 insert into public.trade_in_transactions(tenant_id,trade_in_reference,customer_id,buying_request_id,buying_item_id,offer_id,acquisition_id,acquisition_item_id,status,valuation_method,trading_value,trade_in_price,credit_amount,currency,accepted_at,received_at,credited_at,completed_at,staff_notes,metadata,created_by)
 values(p_tenant_id,'TI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),v_customer_id,v_item.buying_request_id,v_item.id,v_offer.id,v_acq,v_acq_item,'credited','manual',v_amount,v_amount,v_amount,v_currency,now(),coalesce(v_item.item_received_at,now()),now(),now(),'Added to customer trade-in credit after inspection.',jsonb_build_object('source','post_inspection_trade_in_credit','offer_id',v_offer.id,'credit_account_id',v_account),v_actor) returning id into v_trade;
 insert into public.ledger_entries(tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,acquisition_id,description,reference_type,reference_id,metadata,posted_at,created_by)
 values(p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'adjustment','credit','posted',v_amount,v_currency,v_customer_id,v_acq,'Trade-in credit added to customer account','trade_in_transaction',v_trade,jsonb_build_object('buying_item_id',p_buying_item_id,'acquisition_id',v_acq,'credit_account_id',v_account),now(),v_actor) returning id into v_ledger;
 update public.customer_credit_accounts set balance=balance+v_amount,updated_at=now() where id=v_account;
 insert into public.inventory_assets(tenant_id,acquisition_item_id,buying_item_id,category_id,branch_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,metadata,received_at,created_by)
 values(p_tenant_id,v_acq_item,v_item.id,v_item.category_id,v_item.branch_id,null,'ready_for_sale',v_item.title,v_item.description,(select condition_grade from public.buying_item_inspections where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id order by created_at desc limit 1),v_item.item_condition,coalesce(v_item.quantity,1),v_amount,null,v_currency,'Created when the accepted trade-in value was added as customer credit.',jsonb_build_object('source','trade_in_credit','trade_in_transaction_id',v_trade,'ledger_entry_id',v_ledger,'credit_account_id',v_account),coalesce(v_item.item_received_at,now()),v_actor) returning id into v_asset;
 update public.buying_items set purchase_stage='purchased',purchased_at=now(),purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
 return jsonb_build_object('trade_in_transaction_id',v_trade,'acquisition_id',v_acq,'acquisition_item_id',v_acq_item,'ledger_entry_id',v_ledger,'inventory_asset_id',v_asset,'credit_account_id',v_account,'credit_amount',v_amount,'status','credited');
end;
$function$;
