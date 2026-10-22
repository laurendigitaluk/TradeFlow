-- Shared evidence tenant preferences, catalogue evidence selection, and exact-match valuation fallback.
CREATE OR REPLACE FUNCTION public.tenant_uses_shared_evidence(p_tenant_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
  SELECT coalesce((t.settings ->> 'use_shared_evidence')::boolean, true)
  FROM public.tenants t
  WHERE t.id = p_tenant_id
$function$;

CREATE OR REPLACE FUNCTION public.set_tenant_shared_evidence_preference(p_use_shared_evidence boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
  v_tenant_id uuid;
  v_membership_count integer;
BEGIN
  SELECT count(*), min(tm.tenant_id::text)::uuid
    INTO v_membership_count, v_tenant_id
  FROM public.tenant_memberships tm
  WHERE tm.user_id = auth.uid()
    AND tm.status = 'active';

  IF v_membership_count <> 1 OR v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Expected exactly one active tenant membership for this account';
  END IF;

  UPDATE public.tenants t
     SET settings = coalesce(t.settings, '{}'::jsonb)
                   || jsonb_build_object('use_shared_evidence', p_use_shared_evidence),
         updated_at = now()
   WHERE t.id = v_tenant_id
     AND EXISTS (
       SELECT 1
       FROM public.tenant_memberships tm
       WHERE tm.tenant_id = t.id
         AND tm.user_id = auth.uid()
         AND tm.status = 'active'
         AND tm.role_code IN ('owner', 'admin')
     );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Only an active tenant owner or admin can change this preference';
  END IF;

  RETURN true;
END;
$function$;

CREATE OR REPLACE FUNCTION public.subscriber_set_shared_evidence_preference(p_tenant_id uuid, p_enabled boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.tenant_memberships tm
    WHERE tm.tenant_id = p_tenant_id
      AND tm.user_id = auth.uid()
      AND tm.status = 'active'
      AND tm.role_code IN ('owner', 'admin')
  ) THEN
    RAISE EXCEPTION 'Only an active tenant owner or admin can change shared evidence settings';
  END IF;

  IF NOT private.has_tenant_feature(p_tenant_id, 'module.buying') THEN
    RAISE EXCEPTION 'Buying is not enabled for this subscription';
  END IF;

  UPDATE public.tenants
     SET settings = coalesce(settings, '{}'::jsonb)
                    || jsonb_build_object('use_shared_evidence', coalesce(p_enabled, true)),
         updated_at = now()
   WHERE id = p_tenant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant not found';
  END IF;

  RETURN jsonb_build_object('use_shared_evidence', coalesce(p_enabled, true));
END;
$function$;

CREATE OR REPLACE FUNCTION public.resolve_master_product_for_tenant_package(p_manufacturer text, p_model text, p_package_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  v_master_product_id uuid;
  v_match_count integer;
BEGIN
  WITH candidate_products AS (
    SELECT mp.id
    FROM public.catalogue_master_products mp
    JOIN public.catalogue_master_manufacturers mm ON mm.id = mp.manufacturer_id
    WHERE mp.active = true
      AND lower(trim(mm.name)) = lower(trim(coalesce(p_manufacturer, '')))
      AND lower(trim(mp.model)) = lower(trim(coalesce(p_model, '')))
      AND lower(trim(coalesce(mp.package_name, ''))) = lower(trim(coalesce(p_package_name, '')))
    UNION
    SELECT mp.id
    FROM public.catalogue_master_products mp
    JOIN public.catalogue_master_manufacturers mm ON mm.id = mp.manufacturer_id
    JOIN public.catalogue_master_product_package_aliases pa ON pa.master_product_id = mp.id AND pa.is_active = true
    WHERE mp.active = true
      AND lower(trim(mm.name)) = lower(trim(coalesce(p_manufacturer, '')))
      AND lower(trim(mp.model)) = lower(trim(coalesce(p_model, '')))
      AND pa.alias_key = lower(regexp_replace(trim(coalesce(p_package_name, '')), '[^a-zA-Z0-9]+', '-', 'g'))
  )
  SELECT count(*), min(id::text)::uuid
    INTO v_match_count, v_master_product_id
  FROM candidate_products;

  IF v_match_count <> 1 THEN
    RETURN NULL;
  END IF;

  RETURN v_master_product_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_tenant_buying_catalogue_page(p_tenant_id uuid, p_category_id uuid DEFAULT NULL::uuid, p_branch_id uuid DEFAULT NULL::uuid, p_manufacturer_id uuid DEFAULT NULL::uuid, p_search text DEFAULT NULL::text, p_page integer DEFAULT 1, p_page_size integer DEFAULT 50)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
 v_page integer := greatest(coalesce(p_page,1),1);
 v_size integer := least(greatest(coalesce(p_page_size,50),1),75);
 v_offset integer := (v_page-1)*v_size;
 v_total integer;
 v_products jsonb;
 v_use_shared boolean;
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to view Buying catalogue'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
 select coalesce((t.settings->>'use_shared_evidence')::boolean,true) into v_use_shared from public.tenants t where t.id=p_tenant_id;
 v_use_shared := coalesce(v_use_shared,true);
 with filtered as (
  select distinct s.master_product_id from public.tenant_catalogue_selections s
  join public.catalogue_master_products p on p.id=s.master_product_id
  where s.tenant_id=p_tenant_id and s.active and p.active and p.customer_visible
   and (p_category_id is null or p.category_id=p_category_id)
   and (p_branch_id is null or p.branch_id=p_branch_id)
   and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
   and (nullif(trim(coalesce(p_search,'')),'') is null or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
 ) select count(*) into v_total from filtered;
 select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb) into v_products from (
  select p.id product_id,p.category_id,coalesce(nullif(trim(p.catalogue_category),''),c.name) category_name,p.branch_id,b.name branch_name,p.manufacturer_id,m.name manufacturer_name,p.model,p.package_name,p.product_type,p.notes,s.buying_enabled,s.active selection_active,s.website_visible,bp.id buying_product_id,bp.active buying_product_active,bp.manual_offer_price,r.id rule_id,r.sealed_percentage,r.opened_never_used_percentage,r.excellent_percentage,r.good_percentage,r.poor_percentage,r.sealed_reference_type,r.opened_never_used_reference_type,r.excellent_reference_type,r.good_reference_type,r.poor_reference_type,r.sealed_manual_price,r.opened_never_used_manual_price,r.excellent_manual_price,r.good_manual_price,r.poor_manual_price,r.sealed_trade_in_percentage,r.opened_never_used_trade_in_percentage,r.excellent_trade_in_percentage,r.good_trade_in_percentage,r.poor_trade_in_percentage,r.sealed_trade_in_manual_price,r.opened_never_used_trade_in_manual_price,r.excellent_trade_in_manual_price,r.good_trade_in_manual_price,r.poor_trade_in_manual_price,
   rn.observed_price uk_new_research_price,rn.source_name uk_new_research_source,rn.source_url uk_new_research_url,rn.checked_at uk_new_research_checked_at,
   ru.observed_price uk_used_research_price,ru.source_name uk_used_research_source,ru.source_url uk_used_research_url,ru.checked_at uk_used_research_checked_at
  from public.tenant_catalogue_selections s
  join public.catalogue_master_products p on p.id=s.master_product_id
  join public.catalogue_master_categories c on c.id=p.category_id
  left join public.catalogue_master_branches b on b.id=p.branch_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  left join public.tenant_buying_products bp on bp.tenant_id=p_tenant_id and bp.branch_id is not distinct from s.branch_id and lower(bp.manufacturer)=lower(m.name) and lower(bp.model)=lower(p.model) and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,''))
  left join public.tenant_buying_condition_rules r on r.tenant_id=p_tenant_id and r.buying_product_id=bp.id
  left join lateral (
   select ev.observed_price,ev.source_name,ev.source_url,ev.checked_at from (
    select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at,0 priority,tr.created_at,tr.id
    from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
    union all
    select sm.observed_price,sm.source_name,sm.source_url,sm.observed_at,1 priority,sm.created_at,sm.id
    from public.shared_market_evidence sm where v_use_shared and sm.master_product_id=p.id and sm.evidence_type='uk_new' and sm.is_active and sm.observed_price is not null and upper(coalesce(sm.price_currency,'GBP'))='GBP'
   ) ev order by ev.priority,ev.checked_at desc nulls last,ev.created_at desc nulls last,ev.id desc limit 1
  ) rn on true
  left join lateral (
   select ev.observed_price,ev.source_name,ev.source_url,ev.checked_at from (
    select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at,0 priority,tr.created_at,tr.id
    from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_used' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
    union all
    select sm.observed_price,sm.source_name,sm.source_url,sm.observed_at,1 priority,sm.created_at,sm.id
    from public.shared_market_evidence sm where v_use_shared and sm.master_product_id=p.id and sm.evidence_type='uk_used' and sm.is_active and sm.observed_price is not null and upper(coalesce(sm.price_currency,'GBP'))='GBP'
   ) ev order by ev.priority,ev.checked_at desc nulls last,ev.created_at desc nulls last,ev.id desc limit 1
  ) ru on true
  where s.tenant_id=p_tenant_id and s.active and p.active and p.customer_visible
   and (p_category_id is null or p.category_id=p_category_id)
   and (p_branch_id is null or p.branch_id=p_branch_id)
   and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
   and (nullif(trim(coalesce(p_search,'')),'') is null or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
  order by m.name,p.model,p.package_name offset v_offset limit v_size
 ) x;
 return jsonb_build_object('page',v_page,'page_size',v_size,'total',v_total,'products',v_products);
end;
$function$;

CREATE OR REPLACE FUNCTION public.get_master_buying_catalogue_page_filtered(p_tenant_id uuid, p_category_id uuid DEFAULT NULL::uuid, p_branch_id uuid DEFAULT NULL::uuid, p_manufacturer_id uuid DEFAULT NULL::uuid, p_search text DEFAULT NULL::text, p_page integer DEFAULT 1, p_page_size integer DEFAULT 50, p_hide_added boolean DEFAULT true)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
 v_page integer:=greatest(coalesce(p_page,1),1);
 v_size integer:=least(greatest(coalesce(p_page_size,50),1),75);
 v_offset integer:=(v_page-1)*v_size;
 v_total integer; v_products jsonb; v_use_shared boolean;
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to view Buying catalogue'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
 select coalesce((t.settings->>'use_shared_evidence')::boolean,true) into v_use_shared from public.tenants t where t.id=p_tenant_id;
 v_use_shared := coalesce(v_use_shared,true);

 select count(*) into v_total
 from public.catalogue_master_products p
 where p.active and p.customer_visible
 and (p_category_id is null or p.category_id=p_category_id)
 and (p_branch_id is null or p.branch_id=p_branch_id)
 and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
 and (nullif(trim(coalesce(p_search,'')),'') is null
      or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
 and (not coalesce(p_hide_added,true)
      or not exists(select 1 from public.tenant_catalogue_selections s
                   where s.tenant_id=p_tenant_id and s.master_product_id=p.id and s.active and s.buying_enabled));

 select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb)
 into v_products
 from (
   select p.id product_id,p.category_id,coalesce(nullif(trim(p.catalogue_category),''),c.name) category_name,
          p.branch_id,b.name branch_name,p.manufacturer_id,m.name manufacturer_name,p.model,p.package_name,p.product_type,p.notes,
          coalesce(s.buying_enabled,false) buying_enabled,coalesce(s.active,false) selection_active,s.website_visible,
          bp.id buying_product_id,bp.active buying_product_active,bp.manual_offer_price,
          r.id rule_id,r.sealed_percentage,r.opened_never_used_percentage,r.excellent_percentage,r.good_percentage,r.poor_percentage,
          r.sealed_reference_type,r.opened_never_used_reference_type,r.excellent_reference_type,r.good_reference_type,r.poor_reference_type,
          r.sealed_manual_price,r.opened_never_used_manual_price,r.excellent_manual_price,r.good_manual_price,r.poor_manual_price,r.sealed_trade_in_percentage,r.opened_never_used_trade_in_percentage,r.excellent_trade_in_percentage,r.good_trade_in_percentage,r.poor_trade_in_percentage,r.sealed_trade_in_manual_price,r.opened_never_used_trade_in_manual_price,r.excellent_trade_in_manual_price,r.good_trade_in_manual_price,r.poor_trade_in_manual_price,
          rn.observed_price uk_new_research_price,rn.source_name uk_new_research_source,rn.source_url uk_new_research_url,rn.checked_at uk_new_research_checked_at,
          ru.observed_price uk_used_research_price,ru.source_name uk_used_research_source,ru.source_url uk_used_research_url,ru.checked_at uk_used_research_checked_at
   from public.catalogue_master_products p
   join public.catalogue_master_categories c on c.id=p.category_id
   left join public.catalogue_master_branches b on b.id=p.branch_id
   join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
   left join public.tenant_catalogue_selections s on s.tenant_id=p_tenant_id and s.master_product_id=p.id
   left join public.tenant_buying_products bp on bp.tenant_id=p_tenant_id and bp.category_id=p.category_id
      and bp.branch_id is not distinct from p.branch_id and lower(bp.manufacturer)=lower(m.name)
      and lower(bp.model)=lower(p.model) and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,''))
   left join public.tenant_buying_condition_rules r on r.tenant_id=p_tenant_id and r.buying_product_id=bp.id
   left join lateral(
      select ev.observed_price,ev.source_name,ev.source_url,ev.checked_at from (
        select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at,0 priority,tr.created_at,tr.id
        from public.tenant_buying_research tr
        where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_new'
          and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
        union all
        select sm.observed_price,sm.source_name,sm.source_url,sm.observed_at,1 priority,sm.created_at,sm.id
        from public.shared_market_evidence sm
        where v_use_shared and sm.master_product_id=p.id and sm.evidence_type='uk_new'
          and sm.is_active and sm.observed_price is not null and upper(coalesce(sm.price_currency,'GBP'))='GBP'
      ) ev order by ev.priority,ev.checked_at desc nulls last,ev.created_at desc nulls last,ev.id desc limit 1
   ) rn on true
   left join lateral(
      select ev.observed_price,ev.source_name,ev.source_url,ev.checked_at from (
        select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at,0 priority,tr.created_at,tr.id
        from public.tenant_buying_research tr
        where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_used'
          and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
        union all
        select sm.observed_price,sm.source_name,sm.source_url,sm.observed_at,1 priority,sm.created_at,sm.id
        from public.shared_market_evidence sm
        where v_use_shared and sm.master_product_id=p.id and sm.evidence_type='uk_used'
          and sm.is_active and sm.observed_price is not null and upper(coalesce(sm.price_currency,'GBP'))='GBP'
      ) ev order by ev.priority,ev.checked_at desc nulls last,ev.created_at desc nulls last,ev.id desc limit 1
   ) ru on true
   where p.active and p.customer_visible
   and (p_category_id is null or p.category_id=p_category_id)
   and (p_branch_id is null or p.branch_id=p_branch_id)
   and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
   and (nullif(trim(coalesce(p_search,'')),'') is null
        or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
   and (not coalesce(p_hide_added,true)
        or not exists(select 1 from public.tenant_catalogue_selections sx
                     where sx.tenant_id=p_tenant_id and sx.master_product_id=p.id and sx.active and sx.buying_enabled))
   order by m.name,p.model,p.package_name
   offset v_offset limit v_size
 ) x;

 return jsonb_build_object('page',v_page,'page_size',v_size,'total',v_total,'products',v_products);
end;$function$;

CREATE OR REPLACE FUNCTION public.calculate_buying_item_valuation(p_tenant_id uuid, p_buying_item_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 v_item record;
 v_product record;
 v_rule record;
 v_research_new record;
 v_shared_new record;
 v_pct numeric;
 v_base numeric;
 v_manual numeric;
 v_trade_pct numeric;
 v_trade_manual numeric;
 v_condition text;
 v_source text;
 v_url text;
 v_use_shared boolean := true;
 v_master_product_id uuid;
BEGIN
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then raise exception 'Not authorised to calculate buying valuation'; end if;
 select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition into v_item from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected'); end if;
 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id,bp.manual_offer_price into v_product from public.tenant_buying_products bp where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;
 if v_product.manual_offer_price is not null then return jsonb_build_object('mode','manual_override','reason','manual_product_price_configured','amount',v_product.manual_offer_price,'trade_in_amount',null,'currency','GBP','manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 v_condition:=case v_item.item_condition when 'factory-sealed' then 'sealed' when 'opened-unused' then 'opened_never_used' when 'opened_never_used' then 'opened_never_used' when 'sealed' then 'sealed' when 'excellent' then 'excellent' when 'good' then 'good' when 'fair' then 'poor' when 'damaged' then 'poor' when 'not-working' then 'poor' when 'not_working' then 'poor' when 'poor' then 'poor' else v_item.item_condition end;
 if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;
 select * into v_rule from public.tenant_buying_condition_rules r where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition); end if;
 v_pct:=case v_condition when 'sealed' then v_rule.sealed_percentage when 'opened_never_used' then v_rule.opened_never_used_percentage when 'excellent' then v_rule.excellent_percentage when 'good' then v_rule.good_percentage when 'poor' then v_rule.poor_percentage end;
 v_manual:=case v_condition when 'sealed' then v_rule.sealed_manual_price when 'opened_never_used' then v_rule.opened_never_used_manual_price when 'excellent' then v_rule.excellent_manual_price when 'good' then v_rule.good_manual_price when 'poor' then v_rule.poor_manual_price end;
 v_trade_pct:=case v_condition when 'sealed' then v_rule.sealed_trade_in_percentage when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage when 'excellent' then v_rule.excellent_trade_in_percentage when 'good' then v_rule.good_trade_in_percentage when 'poor' then v_rule.poor_trade_in_percentage end;
 v_trade_manual:=case v_condition when 'sealed' then v_rule.sealed_trade_in_manual_price when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price when 'excellent' then v_rule.excellent_trade_in_manual_price when 'good' then v_rule.good_trade_in_manual_price when 'poor' then v_rule.poor_trade_in_manual_price end;
 if v_manual is not null or v_trade_manual is not null then return jsonb_build_object('mode','manual_override','reason','manual_condition_price_configured','condition',v_condition,'amount',v_manual,'trade_in_amount',v_trade_manual,'currency','GBP','percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type','uk_new','manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_new from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
 if not found or v_research_new.observed_price is null then
   select coalesce((t.settings->>'use_shared_evidence')::boolean,true) into v_use_shared from public.tenants t where t.id=p_tenant_id;
   if coalesce(v_use_shared,true) then
     v_master_product_id := public.resolve_master_product_for_tenant_package(v_product.manufacturer, v_product.model, v_product.package_name);
     if v_master_product_id is not null then
       select sme.observed_price,sme.price_currency,sme.source_name,sme.source_url,sme.observed_at into v_shared_new from public.shared_market_evidence sme where sme.master_product_id=v_master_product_id and sme.evidence_type='uk_new' and sme.is_active=true and sme.observed_price is not null and upper(coalesce(sme.price_currency,'GBP'))='GBP' order by sme.observed_at desc nulls last,sme.created_at desc limit 1;
     end if;
   end if;
   if v_shared_new.observed_price is null then return jsonb_build_object('mode','manual','reason','no_research_for_uk_new','condition',v_condition,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type','uk_new'); end if;
   v_base:=v_shared_new.observed_price; v_source:=v_shared_new.source_name; v_url:=v_shared_new.source_url;
 else
   v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url;
 end if;
 if v_pct is null then return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',v_condition,'base_price',v_base,'reference_type','uk_new','trade_in_percentage',v_trade_pct); end if;
 return jsonb_build_object('mode','automatic','reason','percentage_of_uk_new_reference','condition',v_condition,'amount',round(v_base*v_pct/100,2),'trade_in_amount',case when v_trade_pct is null then null else round(v_base*v_trade_pct/100,2) end,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'base_price',v_base,'currency','GBP','reference_type','uk_new','source_name',v_source,'source_url',v_url,'manufacturer',v_product.manufacturer,'model',v_product.model);
END;
$function$;
REVOKE ALL ON FUNCTION public.tenant_uses_shared_evidence(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.tenant_uses_shared_evidence(uuid) TO authenticated, service_role;
REVOKE ALL ON FUNCTION public.set_tenant_shared_evidence_preference(boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_tenant_shared_evidence_preference(boolean) TO authenticated;
REVOKE ALL ON FUNCTION public.subscriber_set_shared_evidence_preference(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.subscriber_set_shared_evidence_preference(uuid, boolean) TO authenticated;
REVOKE ALL ON FUNCTION public.resolve_master_product_for_tenant_package(text, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_master_product_for_tenant_package(text, text, text) TO service_role;
