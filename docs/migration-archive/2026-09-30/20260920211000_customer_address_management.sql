-- Customer address management RPCs.
create or replace function public.customer_upsert_address(
 p_tenant_id uuid,p_address_id uuid default null,p_address_type text default 'shipping',
 p_recipient_name text default null,p_company_name text default null,p_line1 text default null,p_line2 text default null,
 p_city text default null,p_county text default null,p_postcode text default null,p_country_code text default 'GB',
 p_is_default boolean default false
) returns uuid language plpgsql security definer set search_path=''
as $$
declare v_user uuid:=auth.uid(); v_customer uuid; v_id uuid;
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 select id into v_customer from public.customers where tenant_id=p_tenant_id and auth_user_id=v_user limit 1;
 if v_customer is null then raise exception 'Customer account not found for this subscriber'; end if;
 if nullif(btrim(coalesce(p_line1,'')),'') is null or nullif(btrim(coalesce(p_city,'')),'') is null or nullif(btrim(coalesce(p_postcode,'')),'') is null then raise exception 'Address line 1, city and postcode are required'; end if;
 if p_is_default then update public.customer_addresses set is_default=false where tenant_id=p_tenant_id and customer_id=v_customer; end if;
 if p_address_id is null then
   insert into public.customer_addresses(tenant_id,customer_id,address_type,recipient_name,company_name,line1,line2,city,county,postcode,country_code,is_default)
   values(p_tenant_id,v_customer,p_address_type,nullif(btrim(p_recipient_name),''),nullif(btrim(p_company_name),''),btrim(p_line1),nullif(btrim(p_line2),''),btrim(p_city),nullif(btrim(p_county),''),btrim(p_postcode),upper(coalesce(p_country_code,'GB')),p_is_default)
   returning id into v_id;
 else
   update public.customer_addresses set address_type=p_address_type,recipient_name=nullif(btrim(p_recipient_name),''),company_name=nullif(btrim(p_company_name),''),
   line1=btrim(p_line1),line2=nullif(btrim(p_line2),''),city=btrim(p_city),county=nullif(btrim(p_county),''),postcode=btrim(p_postcode),
   country_code=upper(coalesce(p_country_code,'GB')),is_default=p_is_default,updated_at=now()
   where id=p_address_id and tenant_id=p_tenant_id and customer_id=v_customer returning id into v_id;
   if v_id is null then raise exception 'Address not found'; end if;
 end if;
 return v_id;
end $$;
revoke execute on function public.customer_upsert_address(uuid,uuid,text,text,text,text,text,text,text,text,text,boolean) from public,anon;
grant execute on function public.customer_upsert_address(uuid,uuid,text,text,text,text,text,text,text,text,text,boolean) to authenticated;

create or replace function public.customer_delete_address(p_tenant_id uuid,p_address_id uuid)
returns void language plpgsql security definer set search_path=''
as $$
declare v_user uuid:=auth.uid(); v_customer uuid;
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 select id into v_customer from public.customers where tenant_id=p_tenant_id and auth_user_id=v_user limit 1;
 if v_customer is null then raise exception 'Customer account not found for this subscriber'; end if;
 delete from public.customer_addresses where id=p_address_id and tenant_id=p_tenant_id and customer_id=v_customer;
 if not found then raise exception 'Address not found'; end if;
end $$;
revoke execute on function public.customer_delete_address(uuid,uuid) from public,anon;
grant execute on function public.customer_delete_address(uuid,uuid) to authenticated;

create or replace function public.customer_set_default_address(p_tenant_id uuid,p_address_id uuid)
returns void language plpgsql security definer set search_path=''
as $$
declare v_user uuid:=auth.uid(); v_customer uuid;
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 select id into v_customer from public.customers where tenant_id=p_tenant_id and auth_user_id=v_user limit 1;
 if v_customer is null then raise exception 'Customer account not found for this subscriber'; end if;
 update public.customer_addresses set is_default=false where tenant_id=p_tenant_id and customer_id=v_customer;
 update public.customer_addresses set is_default=true,updated_at=now() where id=p_address_id and tenant_id=p_tenant_id and customer_id=v_customer;
 if not found then raise exception 'Address not found'; end if;
end $$;
revoke execute on function public.customer_set_default_address(uuid,uuid) from public,anon;
grant execute on function public.customer_set_default_address(uuid,uuid) to authenticated;