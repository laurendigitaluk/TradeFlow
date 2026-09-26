-- Mixed customer-credit + card checkout.
-- Customer credit is held against the retail order while the card remainder is paid.
create table if not exists public.customer_credit_holds (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  retail_order_id uuid not null references public.retail_orders(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  status text not null default 'active' check (status in ('active','applied','released')),
  created_at timestamptz not null default now(),
  applied_at timestamptz,
  released_at timestamptz,
  unique(retail_order_id)
);
create index if not exists customer_credit_holds_customer_active_idx
  on public.customer_credit_holds(tenant_id,customer_id,status);
alter table public.customer_credit_holds enable row level security;
revoke all on public.customer_credit_holds from public,anon,authenticated;

create or replace function public.customer_get_credit_account(p_tenant_id uuid)
returns table(account_id uuid,balance numeric,currency text)
language plpgsql stable security definer set search_path='public','private'
as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 return query
 select a.id,a.balance-coalesce((select sum(h.amount) from public.customer_credit_holds h where h.tenant_id=a.tenant_id and h.customer_id=a.customer_id and h.status='active'),0),a.currency
 from public.customer_credit_accounts a
 join public.customers c on c.tenant_id=a.tenant_id and c.id=a.customer_id
 where a.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
end; $$;

create or replace function public.customer_apply_retail_credit(p_tenant_id uuid,p_order_id uuid)
returns table(applied_credit numeric,remaining_due numeric,completed boolean,currency text)
language plpgsql security definer set search_path='pg_catalog','public'
as $$
declare v_actor uuid:=auth.uid();v_customer_id uuid;v_order public.retail_orders%rowtype;v_account public.customer_credit_accounts%rowtype;v_available numeric;v_apply numeric;v_hold public.customer_credit_holds%rowtype;v_payment_id uuid;
begin
 if v_actor is null then raise exception 'Authentication required'; end if;
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
 if v_customer_id is null then raise exception 'Active customer account required'; end if;
 select o.* into v_order from public.retail_orders o where o.tenant_id=p_tenant_id and o.id=p_order_id and o.customer_id=v_customer_id for update;
 if not found then raise exception 'Order not found'; end if;
 if v_order.status<>'pending_payment' then raise exception 'Order is not awaiting payment'; end if;
 if coalesce(v_order.amount_due,0)<=0 then return query select 0::numeric,0::numeric,true,v_order.currency;return;end if;
 select h.* into v_hold from public.customer_credit_holds h where h.tenant_id=p_tenant_id and h.retail_order_id=p_order_id and h.status='active' for update;
 if found then return query select h.amount,v_order.amount_due,false,v_order.currency;return;end if;
 if exists(select 1 from public.payment_records p where p.tenant_id=p_tenant_id and p.retail_order_id=p_order_id and p.status in ('pending','processing')) then raise exception 'An existing card payment attempt is active. Cancel that attempt before applying customer credit.';end if;
 select a.* into v_account from public.customer_credit_accounts a where a.tenant_id=p_tenant_id and a.customer_id=v_customer_id for update;
 if not found then raise exception 'Customer credit account not found';end if;
 if upper(coalesce(v_account.currency,'GBP'))<>upper(coalesce(v_order.currency,'GBP')) then raise exception 'Customer credit currency does not match the order';end if;
 v_available:=coalesce(v_account.balance,0)-coalesce((select sum(h.amount) from public.customer_credit_holds h where h.tenant_id=p_tenant_id and h.customer_id=v_customer_id and h.status='active'),0);
 v_apply:=least(greatest(v_available,0),v_order.amount_due);
 if v_apply<=0 then raise exception 'No customer credit is available for this purchase';end if;
 insert into public.customer_credit_holds(tenant_id,customer_id,retail_order_id,amount) values(p_tenant_id,v_customer_id,p_order_id,v_apply) returning * into v_hold;
 update public.retail_orders set trade_in_credit_total=coalesce(trade_in_credit_total,0)+v_apply,amount_due=amount_due-v_apply,updated_at=now() where tenant_id=p_tenant_id and id=p_order_id returning amount_due into v_available;
 if v_available>0 then return query select v_apply,v_available,false,v_order.currency;return;end if;
 update public.customer_credit_accounts set balance=balance-v_apply,updated_at=now() where id=v_account.id;
 insert into public.payment_records(tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,customer_id,retail_order_id,notes,created_by,processed_at)
 values(p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'customer_payment','paid','inbound',v_apply,v_order.currency,'customer_credit',v_customer_id,p_order_id,'Retail order paid using customer credit account.',v_actor,now()) returning id into v_payment_id;
 insert into public.ledger_entries(tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,description,reference_type,reference_id,created_by,posted_at)
 values(p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'payment','credit','posted',v_apply,v_order.currency,v_customer_id,p_order_id,'Retail order paid using customer credit','payment_record',v_payment_id,v_actor,now());
 update public.customer_credit_holds set status='applied',applied_at=now() where id=v_hold.id;
 update public.retail_orders set status='paid',payment_status='paid',paid_at=now(),amount_due=0,updated_at=now() where tenant_id=p_tenant_id and id=p_order_id;
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata) values(p_tenant_id,'retail_order',p_order_id,'pending_payment','paid',v_actor,'Retail order paid using customer credit',jsonb_build_object('source','customer_credit','payment_id',v_payment_id));
 update public.listings set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now() where tenant_id=p_tenant_id and id in(select listing_id from public.retail_order_items where tenant_id=p_tenant_id and order_id=p_order_id and listing_id is not null) and status='published';
 update public.inventory_assets set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now() where tenant_id=p_tenant_id and id in(select inventory_asset_id from public.retail_order_items where tenant_id=p_tenant_id and order_id=p_order_id and inventory_asset_id is not null) and status in('listed','reserved');
 return query select v_apply,0::numeric,true,v_order.currency;
end; $$;
revoke all on function public.customer_apply_retail_credit(uuid,uuid) from public,anon;
grant execute on function public.customer_apply_retail_credit(uuid,uuid) to authenticated;

-- The live process_external_payment_event() also settles/release customer_credit_holds
-- around Stripe payment success/failure/expiry. See the applied production migration
-- retail_mixed_payment_webhook_credit_settlement for the full live definition.
