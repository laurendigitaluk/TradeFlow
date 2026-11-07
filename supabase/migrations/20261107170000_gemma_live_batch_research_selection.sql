-- LIVE owner-only catalogue coverage and batch selection for Gemma research.
-- No TEST catalogue or customer data is read or modified.

create or replace function public.platform_owner_list_gemma_research_categories()
returns jsonb
language plpgsql
security definer
set search_path = public, private
as $$
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Platform owner access required';
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'slug', c.slug,
        'name', c.name,
        'branches', coalesce((
          select jsonb_agg(jsonb_build_object('slug', b.slug, 'name', b.name) order by b.sort_order, b.name)
          from public.catalogue_master_branches b
          where b.category_id = c.id and b.active = true
        ), '[]'::jsonb)
      ) order by c.sort_order, c.name
    )
    from public.catalogue_master_categories c
    where c.active = true
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.platform_owner_list_gemma_research_categories() from public, anon;
grant execute on function public.platform_owner_list_gemma_research_categories() to authenticated;

create or replace function public.platform_owner_list_gemma_research_products(
  p_category_slug text,
  p_branch_slug text default null,
  p_evidence_filter text default 'any',
  p_limit integer default 100
)
returns jsonb
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_category_id uuid;
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Platform owner access required';
  end if;
  if nullif(trim(p_category_slug), '') is null then
    raise exception 'Category is required';
  end if;
  if p_evidence_filter not in ('any','missing_new','missing_used','missing_both','missing_either','has_new','has_used') then
    raise exception 'Invalid evidence filter';
  end if;

  select id into v_category_id
  from public.catalogue_master_categories
  where slug = trim(p_category_slug) and active = true;
  if v_category_id is null then
    raise exception 'Active catalogue category not found';
  end if;

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.branch_name, x.manufacturer, x.model)
    from (
      select
        p.id as product_id,
        p.model,
        p.package_key,
        p.package_name,
        b.slug as branch_slug,
        b.name as branch_name,
        m.name as manufacturer,
        count(e.id) filter (where e.evidence_type = 'uk_new' and e.is_active) as new_evidence_count,
        count(e.id) filter (where e.evidence_type = 'uk_used' and e.is_active) as used_evidence_count
      from public.catalogue_master_products p
      left join public.catalogue_master_branches b on b.id = p.branch_id
      left join public.catalogue_master_manufacturers m on m.id = p.manufacturer_id
      left join public.shared_market_evidence e on e.master_product_id = p.id
      where p.category_id = v_category_id
        and p.active = true
        and (p_branch_slug is null or b.slug = p_branch_slug)
      group by p.id, b.slug, b.name, m.name
      having case p_evidence_filter
        when 'missing_new' then count(e.id) filter (where e.evidence_type = 'uk_new' and e.is_active) = 0
        when 'missing_used' then count(e.id) filter (where e.evidence_type = 'uk_used' and e.is_active) = 0
        when 'missing_both' then
          count(e.id) filter (where e.evidence_type = 'uk_new' and e.is_active) = 0
          and count(e.id) filter (where e.evidence_type = 'uk_used' and e.is_active) = 0
        when 'missing_either' then
          count(e.id) filter (where e.evidence_type = 'uk_new' and e.is_active) = 0
          or count(e.id) filter (where e.evidence_type = 'uk_used' and e.is_active) = 0
        when 'has_new' then count(e.id) filter (where e.evidence_type = 'uk_new' and e.is_active) > 0
        when 'has_used' then count(e.id) filter (where e.evidence_type = 'uk_used' and e.is_active) > 0
        else true
      end
      order by b.name, m.name, p.model
      limit greatest(1, least(coalesce(p_limit, 100), 500))
    ) x
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.platform_owner_list_gemma_research_products(text, text, text, integer) from public, anon;
grant execute on function public.platform_owner_list_gemma_research_products(text, text, text, integer) to authenticated;
