-- Ensure every paid retail order has a fulfilment record.
-- This closes the gap between the mixed-payment/card settlement path and
-- the subscriber fulfilment workflow. Existing fulfilments are preserved.
create or replace function public.ensure_retail_order_fulfilment()
returns trigger
language plpgsql
security definer
set search_path=''
as $function$
begin
  if new.status='paid' and coalesce(old.status,'')<>'paid' then
    insert into public.fulfilments(
      tenant_id,retail_order_id,fulfilment_reference,status,recipient_name,recipient_email,
      shipping_address,notes,metadata
    )
    values(
      new.tenant_id,new.id,
      'FUL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
      'awaiting',
      new.customer_name,new.customer_email,
      coalesce(new.shipping_address,'{}'::jsonb),
      'Retail order paid; fulfilment awaiting shipping label.',
      jsonb_build_object('source','retail_payment','order_id',new.id)
    )
    on conflict do nothing;
  end if;
  return new;
end;
$function$;

drop trigger if exists retail_orders_ensure_fulfilment on public.retail_orders;
create trigger retail_orders_ensure_fulfilment
after update of status on public.retail_orders
for each row
when (new.status='paid')
execute function public.ensure_retail_order_fulfilment();

grant execute on function public.ensure_retail_order_fulfilment() to authenticated;

-- Backfill any already-paid retail orders that were created before the
-- automatic fulfilment trigger existed.
insert into public.fulfilments(
  tenant_id,retail_order_id,fulfilment_reference,status,recipient_name,recipient_email,
  shipping_address,notes,metadata
)
select
  o.tenant_id,o.id,
  'FUL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
  'awaiting',
  o.customer_name,o.customer_email,
  coalesce(o.shipping_address,'{}'::jsonb),
  'Retail order paid; fulfilment awaiting shipping label.',
  jsonb_build_object('source','retail_payment_backfill','order_id',o.id)
from public.retail_orders o
where o.status='paid'
  and o.payment_status='paid'
  and not exists (
    select 1 from public.fulfilments f
    where f.tenant_id=o.tenant_id and f.retail_order_id=o.id
  );