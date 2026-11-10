-- LIVE Cloud AI research picker: use the master catalogue hierarchy, never free-text product entry.
alter table public.platform_cloud_ai_research_jobs
  add column if not exists master_product_id uuid references public.catalogue_master_products(id) on delete set null,
  add column if not exists branch_slug text;
create index if not exists platform_cloud_ai_research_jobs_master_product_idx
  on public.platform_cloud_ai_research_jobs(master_product_id);

create or replace function public.platform_owner_get_cloud_ai_catalogue_tree(
 p_category_id uuid default null,
 p_branch_id uuid default null
)
returns jsonb language plpgsql stable security definer set search_path = ''
as $function$
declare v_categories jsonb := '[]'::jsonb; v_branches jsonb := '[]'::jsonb; v_products jsonb := '[]'::jsonb; v_truncated boolean := false;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 select coalesce(jsonb_agg(to_jsonb(x) order by x.sort_order,x.name),'[]'::jsonb) into v_categories
 from (select c.id,c.name,c.slug,c.sort_order,count(p.id)::integer product_count
       from public.catalogue_master_categories c join public.catalogue_master_products p on p.category_id=c.id and p.active
       where c.active group by c.id,c.name,c.slug,c.sort_order) x;
 if p_category_id is not null then
  select coalesce(jsonb_agg(to_jsonb(x) order by x.sort_order,x.name),'[]'::jsonb) into v_branches
  from (select b.id,b.category_id,b.name,b.slug,b.sort_order,count(p.id)::integer product_count
        from public.catalogue_master_branches b join public.catalogue_master_products p on p.branch_id=b.id and p.active
        where b.active and b.category_id=p_category_id group by b.id,b.category_id,b.name,b.slug,b.sort_order) x;
 end if;
 if p_branch_id is not null then
  select count(*)>5000 into v_truncated from public.catalogue_master_products p where p.branch_id=p_branch_id and p.active;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb) into v_products
  from (select p.id product_id,p.category_id,p.branch_id,c.slug category_slug,b.slug branch_slug,m.name manufacturer_name,p.model,p.package_name,p.package_key
        from public.catalogue_master_products p
        join public.catalogue_master_categories c on c.id=p.category_id
        join public.catalogue_master_branches b on b.id=p.branch_id
        join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
        where p.active and b.active and b.id=p_branch_id
        order by m.name,p.model,p.package_name limit 5000) x;
 end if;
 return jsonb_build_object('categories',v_categories,'branches',v_branches,'products',v_products,'products_truncated',v_truncated);
end;
$function$;
revoke all on function public.platform_owner_get_cloud_ai_catalogue_tree(uuid,uuid) from public,anon;
grant execute on function public.platform_owner_get_cloud_ai_catalogue_tree(uuid,uuid) to authenticated;

create or replace function public.platform_owner_enqueue_cloud_ai_catalogue_selection(
 p_product_ids uuid[] default null,p_branch_id uuid default null,p_task_type text default 'price_evidence'
)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_queued integer := 0; v_selected integer := 0;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if p_task_type not in ('price_evidence','product_discovery','release_check') then raise exception 'Unsupported task type'; end if;
 if p_branch_id is null and coalesce(array_length(p_product_ids,1),0)=0 then raise exception 'Select a catalogue branch or at least one product'; end if;
 if coalesce(array_length(p_product_ids,1),0)>5000 then raise exception 'Select no more than 5,000 products at once'; end if;
 with selected as materialized (
  select p.id,p.category_id,p.branch_id,c.slug category_slug,b.slug branch_slug,m.name manufacturer,p.model,p.package_name
  from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id
  join public.catalogue_master_branches b on b.id=p.branch_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  where p.active and b.active and ((p_branch_id is not null and p.branch_id=p_branch_id) or (p_branch_id is null and p.id=any(coalesce(p_product_ids,'{}'::uuid[]))))
 ), inserted as (
  insert into public.platform_cloud_ai_research_jobs(job_key,category_slug,branch_slug,master_product_id,manufacturer,model,package_name,task_type)
  select encode(extensions.digest(lower(trim(s.manufacturer)||'|'||trim(s.model)||'|'||coalesce(trim(s.package_name),'')||'|'||p_task_type,'sha256'),'hex'),
   s.category_slug,s.branch_slug,s.id,s.manufacturer,trim(s.model),nullif(trim(s.package_name),''),p_task_type
  from selected s
  on conflict(job_key) do update set
   status=case when public.platform_cloud_ai_research_jobs.status in ('failed','paused') then 'queued' else public.platform_cloud_ai_research_jobs.status end,
   branch_slug=excluded.branch_slug,master_product_id=excluded.master_product_id,updated_at=now()
  returning id
 )
 select (select count(*)::integer from selected),(select count(*)::integer from inserted) into v_selected,v_queued;
 return jsonb_build_object('selected',v_selected,'queued_or_existing',v_queued,'branch_id',p_branch_id,'task_type',p_task_type);
end;
$$;
revoke all on function public.platform_owner_enqueue_cloud_ai_catalogue_selection(uuid[],uuid,text) from public,anon;
grant execute on function public.platform_owner_enqueue_cloud_ai_catalogue_selection(uuid[],uuid,text) to authenticated;
