-- Keep in-store counter transactions out of the online Buying count.
create or replace function public.subscriber_get_business_workflow_counts(p_tenant_id uuid)
returns table(active_buying bigint,inventory_ready bigint,active_listings bigint,active_retail_orders bigint,fulfilment_action_required bigint,active_fulfilments bigint,active_returns bigint)
language plpgsql stable security definer set search_path to 'pg_catalog','public'
as $function$
begin
  if auth.uid() is null or not exists(
    select 1 from public.tenant_memberships tm
    join public.roles r on r.code=tm.role_code and r.active
    join public.role_permissions rp on rp.role_id=r.id
    join public.permissions p on p.id=rp.permission_id and p.active and p.code='buying.view'
    where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active'
  ) then raise exception 'Permission required: buying.view'; end if;

  return query
  select
    (select count(*) from public.buying_items b
     where b.tenant_id=p_tenant_id
       and coalesce(b.purchase_stage,'') not in ('purchased','offer_refused')
       and coalesce(b.status,'')<>'closed'
       and coalesce(b.metadata->>'source','') <> 'in_store'
       and not(coalesce(b.purchase_stage,'')='return_pending' and exists(
         select 1 from public.buying_item_return_shipping rs
         where rs.buying_item_id=b.id and rs.tenant_id=b.tenant_id and rs.shipping_status='return_shipped'
       )))::bigint,
    (select count(*) from public.inventory_assets i where i.tenant_id=p_tenant_id and i.status='ready_for_sale' and not exists(
      select 1 from public.listings l where l.tenant_id=i.tenant_id and l.asset_id=i.id and l.status not in ('sold','delisted')
    ))::bigint,
    (select count(*) from public.listings l where l.tenant_id=p_tenant_id and l.status not in ('sold','delisted'))::bigint,
    (select count(*) from public.retail_orders ro where ro.tenant_id=p_tenant_id and ro.status not in ('cancelled','completed') and not exists(
      select 1 from public.fulfilments f where f.retail_order_id=ro.id and f.status in ('dispatched','delivered')
    ))::bigint,
    (select count(*) from public.retail_orders ro left join public.fulfilments f on f.retail_order_id=ro.id where ro.tenant_id=p_tenant_id and ro.payment_status='paid' and ro.status not in ('cancelled','completed') and (f.id is null or f.status in ('awaiting','label')))::bigint,
    (select count(*) from public.fulfilments f join public.retail_orders ro on ro.id=f.retail_order_id where ro.tenant_id=p_tenant_id and f.status not in ('completed','cancelled','dispatched','delivered'))::bigint,
    (select count(*) from public.returns r where r.tenant_id=p_tenant_id and r.status not in ('completed','closed','rejected','denied'))::bigint;
end;
$function$;