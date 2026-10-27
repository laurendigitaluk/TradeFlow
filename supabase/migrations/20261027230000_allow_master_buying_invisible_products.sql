-- Internal buying catalogue selection is distinct from storefront visibility.
-- Subscriber-owned buying configuration may use any active, customer-hidden master product.
-- Public customer-facing product queries retain their own customer_visible filters.
CREATE OR REPLACE FUNCTION public.add_master_buying_products_filtered_v2(p_tenant_id uuid, p_category_id uuid DEFAULT NULL::uuid, p_branch_id uuid DEFAULT NULL::uuid, p_manufacturer_id uuid DEFAULT NULL::uuid, p_search text DEFAULT NULL::text, p_model_name text DEFAULT NULL::text, p_package_name text DEFAULT NULL::text, p_set_name text DEFAULT NULL::text, p_mode text DEFAULT 'manual'::text, p_sealed_percentage numeric DEFAULT NULL::numeric, p_opened_never_used_percentage numeric DEFAULT NULL::numeric, p_excellent_percentage numeric DEFAULT NULL::numeric, p_good_percentage numeric DEFAULT NULL::numeric, p_poor_percentage numeric DEFAULT NULL::numeric, p_sealed_manual_price numeric DEFAULT NULL::numeric, p_opened_never_used_manual_price numeric DEFAULT NULL::numeric, p_excellent_manual_price numeric DEFAULT NULL::numeric, p_good_manual_price numeric DEFAULT NULL::numeric, p_poor_manual_price numeric DEFAULT NULL::numeric)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ids uuid[]; v_search text:=nullif(trim(coalesce(p_search,'')),'');
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to add Buying catalogue products'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
 select coalesce(array_agg(p.id),'{}'::uuid[]) into ids
 from public.catalogue_master_products p
 where p.active
 and (p_category_id is null or p.category_id=p_category_id)
 and (p_branch_id is null or p.branch_id=p_branch_id)
 and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
 and (nullif(trim(coalesce(p_model_name,'')),'') is null or trim(coalesce(p.model,''))=trim(p_model_name))
 and (nullif(trim(coalesce(p_package_name,'')),'') is null or trim(coalesce(p.package_name,''))=trim(p_package_name))
 and (nullif(trim(coalesce(p_set_name,'')),'') is null or trim(split_part(coalesce(p.package_name,''),'#',1))=trim(p_set_name))
 and (v_search is null or lower(coalesce(p.model,'')) like '%'||lower(v_search)||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(v_search)||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(v_search)||'%' or lower(coalesce(p.notes,'')) like '%'||lower(v_search)||'%')
 and not exists(select 1 from public.tenant_catalogue_selections s join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id join public.tenant_buying_products bp on bp.tenant_id=s.tenant_id and bp.branch_id is not distinct from s.branch_id and lower(bp.manufacturer)=lower(m.name) and lower(bp.model)=lower(p.model) and lower(coalesce(bp.package_name,'') )=lower(coalesce(p.package_name,'') ) and bp.active where s.tenant_id=p_tenant_id and s.master_product_id=p.id and s.active and s.buying_enabled);
 return public.add_master_buying_products_bulk(p_tenant_id,ids,p_mode,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,p_sealed_manual_price,p_opened_never_used_manual_price,p_excellent_manual_price,p_good_manual_price,p_poor_manual_price);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_product(p_tenant_id uuid, p_master_product_id uuid, p_mode text, p_manual_price numeric DEFAULT NULL::numeric, p_sealed_percentage numeric DEFAULT NULL::numeric, p_opened_never_used_percentage numeric DEFAULT NULL::numeric, p_excellent_percentage numeric DEFAULT NULL::numeric, p_good_percentage numeric DEFAULT NULL::numeric, p_poor_percentage numeric DEFAULT NULL::numeric)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare mp record;mc record;mb record;mm record;v_category_id uuid;v_branch_id uuid;v_buying_product_id uuid;v_mode text:=lower(trim(coalesce(p_mode,'')));
begin
if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.manage') then raise exception 'Tenant user is not authorised to manage catalogue pricing'; end if;
if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
if not private.has_tenant_feature(p_tenant_id,'catalogue.pre_filled') then raise exception 'Pre-filled catalogue is not enabled for this subscription'; end if;
if v_mode not in ('off','manual','automatic') then raise exception 'Invalid buying mode. Use off, manual or automatic'; end if;
if v_mode='automatic' and (p_sealed_percentage is null or p_opened_never_used_percentage is null or p_excellent_percentage is null or p_good_percentage is null or p_poor_percentage is null or p_sealed_percentage<0 or p_sealed_percentage>100 or p_opened_never_used_percentage<0 or p_opened_never_used_percentage>100 or p_excellent_percentage<0 or p_excellent_percentage>100 or p_good_percentage<0 or p_good_percentage>100 or p_poor_percentage<0 or p_poor_percentage>100) then raise exception 'Automatic pricing requires five percentages between 0 and 100'; end if;
select p.*,c.name master_category_name,b.name master_branch_name,m.name manufacturer_name into mp from public.catalogue_master_products p join public.catalogue_master_categories c on c.id=p.category_id left join public.catalogue_master_branches b on b.id=p.branch_id join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id where p.id=p_master_product_id and p.active;
if not found then raise exception 'Master catalogue product not found'; end if;
select id,name into mm from public.tenant_buying_manufacturers where tenant_id=p_tenant_id and lower(name)=lower(mp.manufacturer_name) limit 1;
if not found then insert into public.tenant_buying_manufacturers(tenant_id,name,active) values(p_tenant_id,mp.manufacturer_name,true) returning id,name into mm; end if;
insert into public.categories(tenant_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order) values(p_tenant_id,coalesce(nullif(trim(mp.catalogue_category),''),mp.master_category_name),lower(regexp_replace(regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mp.master_category_name),'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),'TradeFlow master catalogue category',true,true,false,0) on conflict do nothing;
select id into v_category_id from public.categories where tenant_id=p_tenant_id and lower(slug)=lower(regexp_replace(regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mp.master_category_name),'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')) limit 1;
if mp.branch_id is not null then
insert into public.category_branches(tenant_id,category_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order) values(p_tenant_id,v_category_id,mp.master_branch_name,lower(regexp_replace(regexp_replace(mp.master_branch_name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),'TradeFlow master catalogue branch',true,true,false,0) on conflict do nothing;
select id into v_branch_id from public.category_branches where tenant_id=p_tenant_id and category_id=v_category_id and lower(slug)=lower(regexp_replace(regexp_replace(mp.master_branch_name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')) limit 1; end if;
insert into public.tenant_catalogue_selections(tenant_id,master_product_id,category_id,branch_id,manufacturer,model,package_name,buying_enabled,selling_enabled,active,updated_at) values(p_tenant_id,p_master_product_id,v_category_id,v_branch_id,mp.manufacturer_name,mp.model,mp.package_name,v_mode<>'off',false,true,now()) on conflict(tenant_id,master_product_id) do update set category_id=excluded.category_id,branch_id=excluded.branch_id,manufacturer=excluded.manufacturer,model=excluded.model,package_name=excluded.package_name,buying_enabled=excluded.buying_enabled,updated_at=now(),active=true;
select id into v_buying_product_id from public.tenant_buying_products where tenant_id=p_tenant_id and category_id=v_category_id and branch_id is not distinct from v_branch_id and lower(manufacturer)=lower(mp.manufacturer_name) and lower(model)=lower(mp.model) and lower(coalesce(package_name,''))=lower(coalesce(mp.package_name,'')) order by active desc,updated_at desc limit 1;
if v_mode='off' then
 if v_buying_product_id is not null then update public.tenant_buying_products set active=false,automatic_percentage=null,manual_offer_price=null,updated_at=now() where id=v_buying_product_id and tenant_id=p_tenant_id; delete from public.tenant_buying_condition_rules where tenant_id=p_tenant_id and buying_product_id=v_buying_product_id; end if;
else
 if v_buying_product_id is null then insert into public.tenant_buying_products(tenant_id,category_id,branch_id,manufacturer,model,package_name,active,automatic_percentage,manual_offer_price,pricing_notes) values(p_tenant_id,v_category_id,v_branch_id,mp.manufacturer_name,mp.model,mp.package_name,true,null,null,'TradeFlow master catalogue selection.') returning id into v_buying_product_id; else update public.tenant_buying_products set active=true,updated_at=now() where id=v_buying_product_id and tenant_id=p_tenant_id; end if;
 if v_mode='manual' then update public.tenant_buying_products set manual_offer_price=p_manual_price,automatic_percentage=null,pricing_notes='Manual buying price controlled from the master catalogue pricing page.',updated_at=now() where id=v_buying_product_id; delete from public.tenant_buying_condition_rules where tenant_id=p_tenant_id and buying_product_id=v_buying_product_id;
 else update public.tenant_buying_products set manual_offer_price=p_manual_price,automatic_percentage=null,pricing_notes='Automatic condition pricing controlled from the master catalogue pricing page.',updated_at=now() where id=v_buying_product_id;
 insert into public.tenant_buying_condition_rules(tenant_id,buying_product_id,sealed_percentage,opened_never_used_percentage,excellent_percentage,good_percentage,poor_percentage,sealed_reference_type,opened_never_used_reference_type,excellent_reference_type,good_reference_type,poor_reference_type,sealed_manual_price,opened_never_used_manual_price,excellent_manual_price,good_manual_price,poor_manual_price) values(p_tenant_id,v_buying_product_id,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,'uk_new','uk_new','uk_used','uk_used','uk_used',null,null,null,null,null) on conflict(tenant_id,buying_product_id) do update set sealed_percentage=excluded.sealed_percentage,opened_never_used_percentage=excluded.opened_never_used_percentage,excellent_percentage=excluded.excellent_percentage,good_percentage=excluded.good_percentage,poor_percentage=excluded.poor_percentage,sealed_reference_type=excluded.sealed_reference_type,opened_never_used_reference_type=excluded.opened_never_used_reference_type,excellent_reference_type=excluded.excellent_reference_type,good_reference_type=excluded.good_reference_type,poor_reference_type=excluded.poor_reference_type,updated_at=now();
 end if;
end if;
update public.categories c set buying_enabled=exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.category_id=c.id and s.buying_enabled and s.active),updated_at=now() where c.tenant_id=p_tenant_id and c.id=v_category_id;
if v_branch_id is not null then update public.category_branches b set buying_enabled=exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.branch_id=b.id and s.buying_enabled and s.active),updated_at=now() where b.tenant_id=p_tenant_id and b.id=v_branch_id; end if;
return jsonb_build_object('mode',v_mode,'master_product_id',p_master_product_id,'buying_product_id',v_buying_product_id,'category_id',v_category_id,'branch_id',v_branch_id);
end;$function$
;
