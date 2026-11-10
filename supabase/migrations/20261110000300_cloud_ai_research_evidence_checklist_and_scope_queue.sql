-- Evidence-aware product checklist and whole-branch/category research selection.
-- LIVE database migration applied 2026-11-10.

create or replace function public.platform_owner_list_cloud_ai_catalogue_products(p_category_id uuid,p_branch_id uuid default null,p_limit integer default 100,p_offset integer default 0)
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare v_products jsonb := '[]'::jsonb; v_total integer := 0;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if p_category_id is null then raise exception 'Choose a catalogue category'; end if;
 if not exists(select 1 from public.catalogue_master_categories c where c.id=p_category_id and c.active) then raise exception 'Catalogue category not found or inactive'; end if;
 if p_branch_id is not null and not exists(select 1 from public.catalogue_master_branches b where b.id=p_branch_id and b.category_id=p_category_id and b.active) then raise exception 'Selected branch does not belong to this category'; end if;
 select count(*)::integer into v_total from public.catalogue_master_products p where p.active and p.category_id=p_category_id and (p_branch_id is null or p.branch_id=p_branch_id);
 select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb) into v_products
 from (
  select p.id product_id,p.category_id,p.branch_id,c.slug category_slug,b.slug branch_slug,b.name branch_name,m.name manufacturer_name,p.model,p.package_name,
   coalesce(ev.new_evidence_count,0)::integer new_evidence_count,coalesce(ev.used_evidence_count,0)::integer used_evidence_count,coalesce(ev.total_evidence_count,0)::integer total_evidence_count
  from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id
  left join public.catalogue_master_branches b on b.id=p.branch_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  left join (
   select e.master_product_id,count(*) filter(where e.evidence_type='uk_new')::integer new_evidence_count,
    count(*) filter(where e.evidence_type='uk_used')::integer used_evidence_count,count(*)::integer total_evidence_count
   from public.shared_market_evidence e where e.is_active group by e.master_product_id
  ) ev on ev.master_product_id=p.id
  where p.active and p.category_id=p_category_id and (p_branch_id is null or p.branch_id=p_branch_id)
  order by m.name,p.model,p.package_name
  limit least(greatest(coalesce(p_limit,100),1),500) offset greatest(coalesce(p_offset,0),0)
 ) x;
 return jsonb_build_object('products',v_products,'total_count',v_total,'limit',least(greatest(coalesce(p_limit,100),1),500),'offset',greatest(coalesce(p_offset,0),0));
end;
$$;
revoke all on function public.platform_owner_list_cloud_ai_catalogue_products(uuid,uuid,integer,integer) from public,anon;
grant execute on function public.platform_owner_list_cloud_ai_catalogue_products(uuid,uuid,integer,integer) to authenticated;

create or replace function public.platform_owner_enqueue_cloud_ai_catalogue_scope(p_product_ids uuid[] default null,p_category_id uuid default null,p_branch_id uuid default null,p_task_type text default 'price_evidence')
returns jsonb language sql security definer set search_path = ''
as $$
 with selected as materialized (
  select p.id,p.category_id,p.branch_id,c.slug category_slug,b.slug branch_slug,m.name manufacturer,p.model,p.package_name
  from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id
  left join public.catalogue_master_branches b on b.id=p.branch_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  where public.platform_cloud_ai_owner_check() and p.active
   and p_task_type in ('price_evidence','product_discovery','release_check')
   and (p_category_id is null or p.category_id=p_category_id)
   and (p_branch_id is null or p.branch_id=p_branch_id)
   and ((p_category_id is not null or p_branch_id is not null) or p.id=any(coalesce(p_product_ids,'{}'::uuid[])))
 ), inserted as (
  insert into public.platform_cloud_ai_research_jobs(job_key,category_slug,branch_slug,master_product_id,manufacturer,model,package_name,task_type)
  select encode(extensions.digest(lower(trim(s.manufacturer)||'|'||trim(s.model)||'|'||coalesce(trim(s.package_name),'')||'|'||p_task_type),'sha256'),'hex'),
   s.category_slug,s.branch_slug,s.id,s.manufacturer,trim(s.model),nullif(trim(s.package_name),''),p_task_type
  from selected s
  on conflict(job_key) do update set
   status=case when public.platform_cloud_ai_research_jobs.status in ('failed','paused') then 'queued' else public.platform_cloud_ai_research_jobs.status end,
   branch_slug=excluded.branch_slug,master_product_id=excluded.master_product_id,updated_at=now()
  returning id
 )
 select jsonb_build_object('selected',(select count(*)::integer from selected),'queued_or_existing',(select count(*)::integer from inserted),'category_id',p_category_id,'branch_id',p_branch_id,'task_type',p_task_type);
$$;
revoke all on function public.platform_owner_enqueue_cloud_ai_catalogue_scope(uuid[],uuid,uuid,text) from public,anon;
grant execute on function public.platform_owner_enqueue_cloud_ai_catalogue_scope(uuid[],uuid,uuid,text) to authenticated;
