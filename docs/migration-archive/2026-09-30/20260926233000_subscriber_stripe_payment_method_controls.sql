insert into public.tenant_payment_methods
  (tenant_id,method_code,display_name,enabled,sort_order)
select t.id,v.method_code,v.display_name,true,v.sort_order
from public.tenants t
cross join (values
  ('card'::text,'Credit or debit card'::text,10),
  ('link'::text,'Link'::text,20),
  ('klarna'::text,'Klarna'::text,30),
  ('amazon_pay'::text,'Amazon Pay'::text,40)
) v(method_code,display_name,sort_order)
on conflict (tenant_id,method_code) do nothing;
