-- TradeFlow purchase completion: customer bank details and payment confirmation boundary.
-- Applied to live Supabase before repository commit; keep this migration aligned with the live schema.

create table if not exists public.customer_bank_details (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  account_holder_name text not null,
  sort_code text not null,
  account_number text not null,
  bank_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, customer_id)
);

alter table public.customer_bank_details enable row level security;
revoke all on table public.customer_bank_details from anon, authenticated;

create or replace function public.customer_get_bank_details(p_tenant_id uuid)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare v_customer_id uuid; v_row public.customer_bank_details%rowtype;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 select * into v_row from public.customer_bank_details where tenant_id=p_tenant_id and customer_id=v_customer_id;
 if v_row.id is null then return jsonb_build_object('has_details',false); end if;
 return jsonb_build_object('has_details',true,'account_holder_name',v_row.account_holder_name,'sort_code',v_row.sort_code,'account_number',v_row.account_number,'bank_name',v_row.bank_name);
end;
$$;

create or replace function public.customer_save_bank_details(p_tenant_id uuid,p_account_holder_name text,p_sort_code text,p_account_number text,p_bank_name text default null)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare v_customer_id uuid; v_holder text:=btrim(coalesce(p_account_holder_name,'')); v_sort text:=regexp_replace(coalesce(p_sort_code,''),'[^0-9]','','g'); v_account text:=regexp_replace(coalesce(p_account_number,''),'[^0-9]','','g');
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 if v_holder='' then raise exception 'Account holder name is required'; end if;
 if length(v_sort)<>6 then raise exception 'UK sort code must contain 6 digits'; end if;
 if length(v_account)<>8 then raise exception 'UK account number must contain 8 digits'; end if;
 insert into public.customer_bank_details(tenant_id,customer_id,account_holder_name,sort_code,account_number,bank_name)
 values(p_tenant_id,v_customer_id,v_holder,v_sort,v_account,nullif(btrim(coalesce(p_bank_name,'')),''))
 on conflict (tenant_id,customer_id) do update set account_holder_name=excluded.account_holder_name,sort_code=excluded.sort_code,account_number=excluded.account_number,bank_name=excluded.bank_name,updated_at=now();
 return jsonb_build_object('saved',true);
end;
$$;

create or replace function public.subscriber_get_customer_bank_details(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare v_customer_id uuid; v_row public.customer_bank_details%rowtype;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'finance.view') then raise exception 'Finance permission required'; end if;
 select br.customer_id into v_customer_id from public.buying_items bi join public.buying_requests br on br.id=bi.buying_request_id and br.tenant_id=bi.tenant_id where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;
 if v_customer_id is null then raise exception 'Buying item not found'; end if;
 select * into v_row from public.customer_bank_details where tenant_id=p_tenant_id and customer_id=v_customer_id;
 if v_row.id is null then return jsonb_build_object('has_details',false); end if;
 return jsonb_build_object('has_details',true,'account_holder_name',v_row.account_holder_name,'sort_code',v_row.sort_code,'account_number',v_row.account_number,'bank_name',v_row.bank_name);
end;
$$;

revoke execute on function public.customer_get_bank_details(uuid) from public,anon;
grant execute on function public.customer_get_bank_details(uuid) to authenticated;
revoke execute on function public.customer_save_bank_details(uuid,text,text,text,text) from public,anon;
grant execute on function public.customer_save_bank_details(uuid,text,text,text,text) to authenticated;
revoke execute on function public.subscriber_get_customer_bank_details(uuid,uuid) from public,anon;
grant execute on function public.subscriber_get_customer_bank_details(uuid,uuid) to authenticated;

create or replace function public.subscriber_complete_purchase(p_tenant_id uuid,p_buying_item_id uuid,p_payment_method text,p_payment_reference text,p_payment_notes text default null)
returns jsonb language plpgsql security definer set search_path='public','private'
as $$
declare v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_offer public.offers%rowtype; v_customer_id uuid; v_bank public.customer_bank_details%rowtype; v_acq uuid; v_acq_item uuid; v_asset uuid; v_payment uuid; v_currency text; v_amount numeric;
begin
 if v_actor is null then raise exception 'Authentication required'; end if;
 if not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if not private.has_tenant_permission(p_tenant_id,v_actor,'finance.manage') then raise exception 'Permission required: finance.manage'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if v_item.id is null then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage<>'final_offer_accepted' then raise exception 'The final offer must be accepted by the customer before payment can be recorded'; end if;
 select * into v_offer from public.offers where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and offer_type='final' and status='accepted' order by responded_at desc nulls last,created_at desc limit 1;
 if v_offer.id is null then raise exception 'No accepted final offer exists for this item'; end if;
 select br.customer_id into v_customer_id from public.buying_requests br where br.tenant_id=p_tenant_id and br.id=v_item.buying_request_id;
 if v_customer_id is null then raise exception 'Customer not found for buying item'; end if;
 select * into v_bank from public.customer_bank_details where tenant_id=p_tenant_id and customer_id=v_customer_id;
 if v_bank.id is null then raise exception 'Customer bank details are required before payment can be recorded'; end if;
 if nullif(trim(coalesce(p_payment_reference,'')),'') is null then raise exception 'Bank payment reference is required before payment can be recorded'; end if;
 v_amount:=v_offer.amount; v_currency:=coalesce(v_offer.currency,'GBP');
 insert into public.payment_records(tenant_id,payment_reference,payment_type,status,direction,amount,currency,customer_id,payment_method,notes,metadata,requested_at,processed_at,created_by)
 values(p_tenant_id,trim(p_payment_reference),'seller_payment','paid','outbound',v_amount,v_currency,v_customer_id,nullif(trim(p_payment_method),''),nullif(trim(p_payment_notes),''),jsonb_build_object('source','post_inspection_final_offer','buying_item_id',p_buying_item_id,'final_offer_id',v_offer.id,'bank_details_on_file',true,'account_holder_name',v_bank.account_holder_name,'sort_code_last4',right(v_bank.sort_code,2),'account_number_last4',right(v_bank.account_number,4)),now(),now(),v_actor)
 returning id into v_payment;
 insert into public.acquisitions(tenant_id,acquisition_reference,status,customer_id,source_offer_id,currency,agreed_total,payment_total,accepted_at,finalised_at,paid_at,metadata,created_by)
 values(p_tenant_id,'ACQ-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'paid',v_customer_id,v_offer.id,v_currency,v_amount,v_amount,now(),now(),now(),jsonb_build_object('source','final_offer_payment','buying_item_id',p_buying_item_id,'final_offer_id',v_offer.id,'payment_record_id',v_payment),v_actor)
 returning id into v_acq;
 insert into public.acquisition_items(tenant_id,acquisition_id,buying_item_id,offer_id,status,agreed_amount,final_amount,currency,paid_at,finalised_at,metadata)
 values(p_tenant_id,v_acq,p_buying_item_id,v_offer.id,'paid',v_amount,v_amount,v_currency,now(),now(),jsonb_build_object('source','final_offer_payment')) returning id into v_acq_item;
 insert into public.inventory_assets(tenant_id,acquisition_item_id,buying_item_id,category_id,branch_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,metadata,received_at,created_by)
 values(p_tenant_id,v_acq_item,p_buying_item_id,v_item.category_id,v_item.branch_id,null,'ready_for_sale',v_item.title,v_item.description,(select condition_grade from public.buying_item_inspections where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id order by created_at desc limit 1),v_item.item_condition,coalesce(v_item.quantity,1),v_amount,null,v_currency,'Created only after final offer acceptance, bank details and payment.',jsonb_build_object('source','final_offer_payment','buying_item_id',p_buying_item_id,'acquisition_id',v_acq,'final_offer_id',v_offer.id,'payment_record_id',v_payment),coalesce(v_item.item_received_at,now()),v_actor) returning id into v_asset;
 update public.payment_records set acquisition_id=v_acq,updated_at=now() where id=v_payment;
 update public.buying_items set purchase_stage='purchased',purchased_at=now(),purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
 return jsonb_build_object('payment_record_id',v_payment,'acquisition_id',v_acq,'acquisition_item_id',v_acq_item,'inventory_asset_id',v_asset,'status','purchased');
end;
$$;