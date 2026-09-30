-- Expose completed customer sales with their buying item and request identifiers.
drop function if exists public.customer_get_completed_sales(uuid);

create function public.customer_get_completed_sales(p_tenant_id uuid)
returns table(
  acquisition_id uuid,
  acquisition_reference text,
  buying_item_id uuid,
  request_reference text,
  item_reference text,
  item_title text,
  status text,
  currency text,
  agreed_total numeric,
  paid_at timestamptz,
  completed_at timestamptz
)
language plpgsql
stable
security definer
set search_path='pg_catalog','public'
as $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.buying');
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  return query
  select
    a.id,
    a.acquisition_reference,
    bi.id,
    br.request_reference,
    bi.item_reference,
    bi.title,
    a.status,
    a.currency,
    a.agreed_total,
    a.paid_at,
    a.completed_at
  from public.acquisitions a
  join public.customers c
    on c.tenant_id=a.tenant_id and c.id=a.customer_id
  join public.acquisition_items ai
    on ai.tenant_id=a.tenant_id and ai.acquisition_id=a.id
  join public.buying_items bi
    on bi.tenant_id=ai.tenant_id and bi.id=ai.buying_item_id
  join public.buying_requests br
    on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  where a.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and a.status in ('paid','completed')
  order by coalesce(a.paid_at,a.completed_at,a.created_at) desc;
end;
$function$;

revoke all on function public.customer_get_completed_sales(uuid) from public,anon;
grant execute on function public.customer_get_completed_sales(uuid) to authenticated;
