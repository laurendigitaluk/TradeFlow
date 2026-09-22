-- TradeFlow purchase workflow audit boundary
-- Canonical rule:
-- initial/revised offer acceptance -> receipt/inspection -> final offer ->
-- final offer acceptance -> bank payment -> acquisition + inventory.
-- Acquisitions and inventory must never exist before payment.

create or replace function public.subscriber_get_business_workflow(p_tenant_id uuid)
returns table(
  request_id uuid,
  request_reference text,
  request_status text,
  buying_item_id uuid,
  title text,
  purchase_stage text,
  amount numeric,
  currency text,
  offer_status text,
  offer_type text,
  acquisition_id uuid,
  acquisition_reference text,
  acquisition_status text
)
language plpgsql
security definer
stable
set search_path to 'pg_catalog','public'
as $function$
begin
  if auth.uid() is null or not exists(
    select 1
    from public.tenant_memberships tm
    join public.roles r on r.code=tm.role_code and r.active
    join public.role_permissions rp on rp.role_id=r.id
    join public.permissions p on p.id=rp.permission_id and p.active and p.code='buying.view'
    where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active'
  ) then
    raise exception 'Permission required: buying.view';
  end if;

  return query
  select br.id,br.request_reference,br.status,bi.id,bi.title,bi.purchase_stage,
    coalesce(final_offer.amount,initial_offer.amount,tv.cash_price,tv.amount),
    coalesce(final_offer.currency,initial_offer.currency,tv.currency,'GBP'),
    coalesce(final_offer.status,initial_offer.status),
    coalesce(final_offer.offer_type,initial_offer.offer_type),
    a.id,a.acquisition_reference,a.status
  from public.buying_requests br
  join public.buying_items bi
    on bi.tenant_id=br.tenant_id and bi.buying_request_id=br.id
  left join lateral (
    select o.*
    from public.offers o
    where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='final'
    order by o.created_at desc
    limit 1
  ) final_offer on true
  left join lateral (
    select o.*
    from public.offers o
    where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial'
    order by o.created_at desc
    limit 1
  ) initial_offer on true
  left join lateral (
    select tv.*
    from public.trading_values tv
    where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved'
    order by tv.approved_at desc nulls last,tv.created_at desc
    limit 1
  ) tv on true
  left join lateral (
    select a.*
    from public.acquisitions a
    where a.tenant_id=bi.tenant_id
      and a.source_offer_id=coalesce(final_offer.id,initial_offer.id)
    order by a.created_at desc
    limit 1
  ) a on true
  where br.tenant_id=p_tenant_id
    and (bi.purchase_stage<>'none' or br.status in ('submitted','under_review','valued','offer_ready'))
  order by br.created_at desc,bi.sort_order;
end;
$function$;

revoke all on function public.subscriber_get_business_workflow(uuid) from public,anon;
grant execute on function public.subscriber_get_business_workflow(uuid) to authenticated;

create or replace function public.guard_acquisition_creation_boundary()
returns trigger
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare
  v_offer record;
  v_payment_id uuid;
begin
  if new.status <> 'paid' or new.paid_at is null then
    raise exception 'Acquisitions can only be created after customer payment';
  end if;

  if new.source_offer_id is null then
    raise exception 'Acquisition must reference the accepted final offer';
  end if;

  select o.id,o.offer_type,o.status,o.buying_item_id,o.amount,o.currency
  into v_offer
  from public.offers o
  where o.tenant_id=new.tenant_id and o.id=new.source_offer_id;

  if v_offer.id is null or v_offer.offer_type <> 'final' or v_offer.status <> 'accepted' then
    raise exception 'Acquisition source must be an accepted final offer';
  end if;

  select p.id
  into v_payment_id
  from public.payment_records p
  where p.tenant_id=new.tenant_id
    and p.status='paid'
    and p.direction='outbound'
    and p.customer_id=new.customer_id
    and p.amount=new.payment_total
    and p.acquisition_id is null
    and p.metadata->>'final_offer_id'=new.source_offer_id::text
  order by p.processed_at desc nulls last,p.created_at desc
  limit 1;

  if v_payment_id is null then
    raise exception 'Acquisition requires a recorded bank payment for the accepted final offer';
  end if;

  return new;
end;
$function$;

drop trigger if exists trg_guard_acquisition_creation_boundary on public.acquisitions;
create trigger trg_guard_acquisition_creation_boundary
before insert on public.acquisitions
for each row execute function public.guard_acquisition_creation_boundary();

create or replace function public.guard_inventory_creation_boundary()
returns trigger
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare
  v_acq record;
  v_item_stage text;
begin
  if new.acquisition_item_id is null then
    raise exception 'Inventory assets can only be created from a completed purchase';
  end if;

  select a.id,a.status,a.paid_at,ai.buying_item_id
  into v_acq
  from public.acquisition_items ai
  join public.acquisitions a
    on a.tenant_id=ai.tenant_id and a.id=ai.acquisition_id
  where ai.tenant_id=new.tenant_id and ai.id=new.acquisition_item_id;

  if v_acq.id is null or v_acq.status not in ('paid','completed') or v_acq.paid_at is null then
    raise exception 'Inventory assets require a paid acquisition';
  end if;

  select purchase_stage
  into v_item_stage
  from public.buying_items
  where tenant_id=new.tenant_id and id=v_acq.buying_item_id;

  if v_item_stage not in ('final_offer_accepted','purchased') then
    raise exception 'Inventory assets require an accepted final offer and payment';
  end if;

  if not exists (
    select 1
    from public.payment_records p
    where p.tenant_id=new.tenant_id
      and p.acquisition_id=v_acq.id
      and p.status='paid'
      and p.direction='outbound'
  ) then
    raise exception 'Inventory assets require a recorded acquisition payment';
  end if;

  return new;
end;
$function$;

drop trigger if exists trg_guard_inventory_creation_boundary on public.inventory_assets;
create trigger trg_guard_inventory_creation_boundary
before insert on public.inventory_assets
for each row execute function public.guard_inventory_creation_boundary();

drop function if exists public.subscriber_complete_acquisition_inspection(uuid,uuid,text,boolean,text,text,jsonb);
drop function if exists public.subscriber_start_acquisition_inspection(uuid,uuid);
drop function if exists public.subscriber_mark_acquisition_received(uuid,uuid);

-- Retire two stale test submissions without deleting their audit history.
update public.buying_items
set status='closed',purchase_stage='none',purchase_stage_updated_at=now(),updated_at=now()
where id in (
  '4bd9e24f-c437-4a79-9c08-7f49dd3000d1',
  '671480f4-1643-4780-b504-8ff50e2c2559'
) and purchase_stage='none';

update public.buying_requests
set status='closed',closed_at=coalesce(closed_at,now()),updated_at=now()
where id in (
  '41a19244-7bb3-4d96-838a-46f259483944',
  '3073c75f-1766-45db-ad58-f3c13e40004e'
) and status='submitted';
