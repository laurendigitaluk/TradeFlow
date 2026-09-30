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
stable
security definer
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
  select
    br.id,
    br.request_reference,
    br.status,
    bi.id,
    bi.title,
    bi.purchase_stage,
    coalesce(final_offer.amount,initial_offer.amount,tv.cash_price,tv.amount),
    coalesce(final_offer.currency,initial_offer.currency,tv.currency,'GBP'),
    coalesce(final_offer.status,initial_offer.status),
    coalesce(final_offer.offer_type,initial_offer.offer_type),
    a.id,
    a.acquisition_reference,
    a.status
  from public.buying_requests br
  join public.buying_items bi
    on bi.tenant_id=br.tenant_id
   and bi.buying_request_id=br.id
  left join lateral (
    select o.*
    from public.offers o
    where o.tenant_id=bi.tenant_id
      and o.buying_item_id=bi.id
      and o.offer_type='final'
    order by o.created_at desc
    limit 1
  ) final_offer on true
  left join lateral (
    select o.*
    from public.offers o
    where o.tenant_id=bi.tenant_id
      and o.buying_item_id=bi.id
      and o.offer_type='initial'
    order by o.created_at desc
    limit 1
  ) initial_offer on true
  left join lateral (
    select tv.*
    from public.trading_values tv
    where tv.tenant_id=bi.tenant_id
      and tv.buying_item_id=bi.id
      and tv.status='approved'
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
    and bi.purchase_stage <> 'offer_refused'
    and (
      bi.purchase_stage <> 'none'
      or br.status in ('submitted','under_review','valued','offer_ready')
    )
  order by br.created_at desc,bi.sort_order;
end;
$function$;

create or replace function public.subscriber_get_business_workflow_counts(p_tenant_id uuid)
returns table(
  active_buying bigint,
  inventory_ready bigint,
  active_listings bigint,
  active_retail_orders bigint,
  fulfilment_action_required bigint,
  active_fulfilments bigint,
  active_returns bigint
)
language plpgsql
stable
security definer
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
  select
    (
      select count(*)
      from public.buying_items b
      where b.tenant_id=p_tenant_id
        and coalesce(b.purchase_stage,'') not in ('purchased','offer_refused')
        and coalesce(b.status,'')<>'closed'
    )::bigint,
    (
      select count(*)
      from public.inventory_assets i
      where i.tenant_id=p_tenant_id and i.status='ready_for_sale'
    )::bigint,
    (
      select count(*)
      from public.listings l
      where l.tenant_id=p_tenant_id and l.status not in ('sold','delisted')
    )::bigint,
    (
      select count(*)
      from public.retail_orders ro
      where ro.tenant_id=p_tenant_id
        and ro.status not in ('cancelled','completed')
        and not exists(
          select 1
          from public.fulfilments f
          where f.retail_order_id=ro.id
            and f.status in ('dispatched','delivered')
        )
    )::bigint,
    (
      select count(*)
      from public.retail_orders ro
      left join public.fulfilments f on f.retail_order_id=ro.id
      where ro.tenant_id=p_tenant_id
        and ro.payment_status='paid'
        and ro.status not in ('cancelled','completed')
        and (f.id is null or f.status in ('awaiting','label'))
    )::bigint,
    (
      select count(*)
      from public.fulfilments f
      join public.retail_orders ro on ro.id=f.retail_order_id
      where ro.tenant_id=p_tenant_id
        and f.status not in ('completed','cancelled','dispatched','delivered')
    )::bigint,
    (
      select count(*)
      from public.returns r
      where r.tenant_id=p_tenant_id and r.status not in ('completed','closed')
    )::bigint;
end;
$function$;