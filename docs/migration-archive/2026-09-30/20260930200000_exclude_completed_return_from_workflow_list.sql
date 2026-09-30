create or replace function public.subscriber_get_business_workflow(p_tenant_id uuid)
returns table(request_id uuid,request_reference text,request_status text,buying_item_id uuid,title text,purchase_stage text,amount numeric,currency text,offer_status text,offer_type text,acquisition_id uuid,acquisition_reference text,acquisition_status text)
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
 select br.id,br.request_reference,br.status,bi.id,bi.title,bi.purchase_stage,
 coalesce(final_offer.amount,initial_offer.amount,tv.cash_price,tv.amount),
 coalesce(final_offer.currency,initial_offer.currency,tv.currency,'GBP'),
 coalesce(final_offer.status,initial_offer.status),coalesce(final_offer.offer_type,initial_offer.offer_type),
 a.id,a.acquisition_reference,a.status
 from public.buying_requests br
 join public.buying_items bi on bi.tenant_id=br.tenant_id and bi.buying_request_id=br.id
 left join lateral(select o.* from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='final' order by o.created_at desc limit 1) final_offer on true
 left join lateral(select o.* from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial' order by o.created_at desc limit 1) initial_offer on true
 left join lateral(select tv.* from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved' order by tv.approved_at desc nulls last,tv.created_at desc limit 1) tv on true
 left join lateral(select a.* from public.acquisitions a where a.tenant_id=bi.tenant_id and a.source_offer_id=coalesce(final_offer.id,initial_offer.id) order by a.created_at desc limit 1) a on true
 where br.tenant_id=p_tenant_id
 and bi.purchase_stage<>'offer_refused'
 and not (bi.purchase_stage='return_pending' and exists(select 1 from public.buying_item_return_shipping rs where rs.tenant_id=bi.tenant_id and rs.buying_item_id=bi.id and rs.shipping_status='return_shipped'))
 and (bi.purchase_stage<>'none' or br.status in ('submitted','under_review','valued','offer_ready'))
 order by br.created_at desc,bi.sort_order;
end;$function$;