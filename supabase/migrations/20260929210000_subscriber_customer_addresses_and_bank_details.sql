-- Subscriber customer record details: tenant-scoped addresses plus finance-protected bank details.
-- Addresses are visible to authenticated tenant members. Bank details require finance.view.
create or replace function public.subscriber_get_customer_addresses(p_tenant_id uuid,p_customer_id uuid)
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare v_rows jsonb;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 select coalesce(jsonb_agg(jsonb_build_object(
   'id',a.id,'address_type',a.address_type,'recipient_name',a.recipient_name,
   'company_name',a.company_name,'line1',a.line1,'line2',a.line2,'city',a.city,
   'county',a.county,'postcode',a.postcode,'country_code',a.country_code,'is_default',a.is_default
   ) order by a.address_type,a.is_default desc,a.created_at desc),'[]'::jsonb)
 into v_rows
 from public.customer_addresses a
 where a.tenant_id=p_tenant_id and a.customer_id=p_customer_id;
 return v_rows;
end;
$$;
revoke execute on function public.subscriber_get_customer_addresses(uuid,uuid) from public,anon;
grant execute on function public.subscriber_get_customer_addresses(uuid,uuid) to authenticated;

create or replace function public.subscriber_get_customer_bank_details_for_customer(p_tenant_id uuid,p_customer_id uuid)
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare v_row public.customer_bank_details%rowtype;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'finance.view') then raise exception 'Finance permission required'; end if;
 select * into v_row from public.customer_bank_details
 where tenant_id=p_tenant_id and customer_id=p_customer_id;
 if v_row.id is null then return jsonb_build_object('has_details',false); end if;
 return jsonb_build_object('has_details',true,'account_holder_name',v_row.account_holder_name,'sort_code',v_row.sort_code,'account_number',v_row.account_number,'bank_name',v_row.bank_name);
end;
$$;
revoke execute on function public.subscriber_get_customer_bank_details_for_customer(uuid,uuid) from public,anon;
grant execute on function public.subscriber_get_customer_bank_details_for_customer(uuid,uuid) to authenticated;