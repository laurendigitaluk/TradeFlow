-- Add server-side manufacturer and evidence-gap filtering to the LIVE manual research catalogue picker.
-- Existing RPCs remain intact for compatibility; the dashboard moves to these scoped endpoints.

create or replace function public.platform_owner_list_cloud_ai_catalogue_manufacturers(
  p_category_id uuid,
  p_branch_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare v_manufacturers jsonb := '[]'::jsonb;
begin
  if not public.platform_cloud_ai_owner_check() then
    raise exception 'Platform owner access required';
  end if;
  if p_category_id is null or not exists (
    select 1 from public.catalogue_master_categories c
    where c.id = p_category_id and c.active
  ) then
    raise exception 'Choose an active catalogue category';
  end if;
  if p_branch_id is not null and not exists (
    select 1 from public.catalogue_master_branches b
    where b.id = p_branch_id and b.category_id = p_category_id and b.active
  ) then
    raise exception 'Selected branch does not belong to this category';
  end if;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.name), '[]'::jsonb)
    into v_manufacturers
  from (
    select m.id, m.name, count(p.id)::integer as product_count
    from public.catalogue_master_products p
    join public.catalogue_master_manufacturers m on m.id = p.manufacturer_id and m.active
    where p.active
      and p.category_id = p_category_id
      and (p_branch_id is null or p.branch_id = p_branch_id)
    group by m.id, m.name
  ) x;

  return jsonb_build_object('manufacturers', v_manufacturers);
end;
$function$;

revoke all on function public.platform_owner_list_cloud_ai_catalogue_manufacturers(uuid,uuid) from public, anon;
grant execute on function public.platform_owner_list_cloud_ai_catalogue_manufacturers(uuid,uuid) to authenticated;

create or replace function public.platform_owner_list_cloud_ai_catalogue_products_filtered(
  p_category_id uuid,
  p_branch_id uuid default null,
  p_manufacturer_id uuid default null,
  p_evidence_filter text default 'all',
  p_limit integer default 100,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_products jsonb := '[]'::jsonb;
  v_total integer := 0;
  v_filter text := lower(coalesce(nullif(trim(p_evidence_filter), ''), 'all'));
begin
  if not public.platform_cloud_ai_owner_check() then
    raise exception 'Platform owner access required';
  end if;
  if p_category_id is null or not exists (
    select 1 from public.catalogue_master_categories c
    where c.id = p_category_id and c.active
  ) then
    raise exception 'Choose an active catalogue category';
  end if;
  if p_branch_id is not null and not exists (
    select 1 from public.catalogue_master_branches b
    where b.id = p_branch_id and b.category_id = p_category_id and b.active
  ) then
    raise exception 'Selected branch does not belong to this category';
  end if;
  if p_manufacturer_id is not null and not exists (
    select 1
    from public.catalogue_master_products p
    join public.catalogue_master_manufacturers m on m.id = p.manufacturer_id
    where p.active and p.category_id = p_category_id
      and (p_branch_id is null or p.branch_id = p_branch_id)
      and m.id = p_manufacturer_id and m.active
  ) then
    raise exception 'Selected manufacturer is not in this category and branch';
  end if;
  if v_filter not in ('all','no_evidence','missing_both','missing_new','missing_used','complete') then
    raise exception 'Unsupported evidence filter';
  end if;

  with evidence_counts as (
    select e.master_product_id,
      count(*) filter (where e.evidence_type = 'uk_new')::integer as new_evidence_count,
      count(*) filter (where e.evidence_type = 'uk_used')::integer as used_evidence_count,
      count(*)::integer as total_evidence_count
    from public.shared_market_evidence e
    where e.is_active
    group by e.master_product_id
  ), scoped as materialized (
    select p.id as product_id, p.category_id, p.branch_id,
      c.slug as category_slug, b.slug as branch_slug, b.name as branch_name,
      m.id as manufacturer_id, m.name as manufacturer_name,
      p.model, p.package_name,
      coalesce(ev.new_evidence_count,0)::integer as new_evidence_count,
      coalesce(ev.used_evidence_count,0)::integer as used_evidence_count,
      coalesce(ev.total_evidence_count,0)::integer as total_evidence_count
    from public.catalogue_master_products p
    join public.catalogue_master_categories c on c.id = p.category_id
    left join public.catalogue_master_branches b on b.id = p.branch_id
    join public.catalogue_master_manufacturers m on m.id = p.manufacturer_id
    left join evidence_counts ev on ev.master_product_id = p.id
    where p.active
      and p.category_id = p_category_id
      and (p_branch_id is null or p.branch_id = p_branch_id)
      and (p_manufacturer_id is null or m.id = p_manufacturer_id)
  ), filtered as materialized (
    select * from scoped s
    where case v_filter
      when 'no_evidence' then s.new_evidence_count = 0 and s.used_evidence_count = 0
      when 'missing_both' then s.new_evidence_count = 0 and s.used_evidence_count = 0
      when 'missing_new' then s.new_evidence_count = 0
      when 'missing_used' then s.used_evidence_count = 0
      when 'complete' then s.new_evidence_count > 0 and s.used_evidence_count > 0
      else true
    end
  )
  select count(*)::integer into v_total from filtered;

  with evidence_counts as (
    select e.master_product_id,
      count(*) filter (where e.evidence_type = 'uk_new')::integer as new_evidence_count,
      count(*) filter (where e.evidence_type = 'uk_used')::integer as used_evidence_count,
      count(*)::integer as total_evidence_count
    from public.shared_market_evidence e
    where e.is_active
    group by e.master_product_id
  ), filtered as materialized (
    select p.id as product_id, p.category_id, p.branch_id,
      c.slug as category_slug, b.slug as branch_slug, b.name as branch_name,
      m.id as manufacturer_id, m.name as manufacturer_name,
      p.model, p.package_name,
      coalesce(ev.new_evidence_count,0)::integer as new_evidence_count,
      coalesce(ev.used_evidence_count,0)::integer as used_evidence_count,
      coalesce(ev.total_evidence_count,0)::integer as total_evidence_count
    from public.catalogue_master_products p
    join public.catalogue_master_categories c on c.id = p.category_id
    left join public.catalogue_master_branches b on b.id = p.branch_id
    join public.catalogue_master_manufacturers m on m.id = p.manufacturer_id
    left join evidence_counts ev on ev.master_product_id = p.id
    where p.active and p.category_id = p_category_id
      and (p_branch_id is null or p.branch_id = p_branch_id)
      and (p_manufacturer_id is null or m.id = p_manufacturer_id)
      and case v_filter
        when 'no_evidence' then coalesce(ev.new_evidence_count,0) = 0 and coalesce(ev.used_evidence_count,0) = 0
        when 'missing_both' then coalesce(ev.new_evidence_count,0) = 0 and coalesce(ev.used_evidence_count,0) = 0
        when 'missing_new' then coalesce(ev.new_evidence_count,0) = 0
        when 'missing_used' then coalesce(ev.used_evidence_count,0) = 0
        when 'complete' then coalesce(ev.new_evidence_count,0) > 0 and coalesce(ev.used_evidence_count,0) > 0
        else true
      end
    order by m.name, p.model, p.package_name
    limit least(greatest(coalesce(p_limit,100),1),500)
    offset greatest(coalesce(p_offset,0),0)
  )
  select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb)
    into v_products from filtered x;

  return jsonb_build_object(
    'products', v_products,
    'total_count', v_total,
    'limit', least(greatest(coalesce(p_limit,100),1),500),
    'offset', greatest(coalesce(p_offset,0),0),
    'evidence_filter', v_filter
  );
end;
$function$;

revoke all on function public.platform_owner_list_cloud_ai_catalogue_products_filtered(uuid,uuid,uuid,text,integer,integer) from public, anon;
grant execute on function public.platform_owner_list_cloud_ai_catalogue_products_filtered(uuid,uuid,uuid,text,integer,integer) to authenticated;
