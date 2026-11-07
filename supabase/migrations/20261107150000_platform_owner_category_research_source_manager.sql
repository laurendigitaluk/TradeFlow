-- Owner-managed category-specific Gemma research sources.
create or replace function public.platform_owner_list_research_sources(p_category_slug text)
returns jsonb language plpgsql security definer set search_path=public,private as $$
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 if not exists(select 1 from public.catalogue_master_categories c where c.slug=p_category_slug and c.active=true) then raise exception 'Unknown or inactive catalogue category'; end if;
 return coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'source_name',s.source_name,'domain',s.domain,'homepage_url',s.homepage_url,'source_kind',s.source_kind,'research_scope',s.research_scope,'enabled',s.enabled,'priority',s.priority,'category_slugs',s.category_slugs,'universal',coalesce(s.category_slugs @> array['*']::text[],false)) order by s.priority,s.source_name) from public.platform_research_sources s where s.category_slugs @> array[p_category_slug]::text[] or s.category_slugs @> array['*']::text[]),'[]'::jsonb);
end; $$;
create or replace function public.platform_owner_add_research_source(p_source_name text,p_domain text,p_homepage_url text,p_category_slug text,p_source_kind text default 'retailer',p_research_scope text default 'new_uk')
returns jsonb language plpgsql security definer set search_path=public,private as $$
declare v_row public.platform_research_sources;
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 if not exists(select 1 from public.catalogue_master_categories c where c.slug=p_category_slug and c.active=true) then raise exception 'Unknown or inactive catalogue category'; end if;
 if nullif(trim(p_source_name),'') is null or nullif(trim(p_domain),'') is null or p_domain !~ '^[a-z0-9.-]+$' or p_domain like '.%' or p_domain like '%.' then raise exception 'Enter a valid source name and domain'; end if;
 if p_homepage_url !~ '^https://[a-zA-Z0-9.-]+(/[^[:space:]]*)?$' then raise exception 'Source homepage must be a valid HTTPS URL'; end if;
 if p_source_kind not in('manufacturer','retailer','marketplace','used_dealer','auction','other') then raise exception 'Invalid source type'; end if;
 if p_research_scope not in('all','new_uk','used_uk','official','discovered','manufacturer') then raise exception 'Invalid research scope'; end if;
 insert into public.platform_research_sources(source_name,domain,homepage_url,source_kind,country_code,research_scope,enabled,priority,category_slugs,notes)
 values(trim(p_source_name),lower(trim(p_domain)),trim(p_homepage_url),p_source_kind,'GB',p_research_scope,true,100,array[p_category_slug]::text[],'Added by platform owner from AI Research Centre')
 on conflict(domain) do update set source_name=excluded.source_name,homepage_url=excluded.homepage_url,source_kind=excluded.source_kind,country_code='GB',research_scope=excluded.research_scope,enabled=true,category_slugs=(select array_agg(distinct x order by x) from unnest(coalesce(platform_research_sources.category_slugs,'{}'::text[])||array[p_category_slug]::text[]) x),updated_at=now()
 returning * into v_row;
 return jsonb_build_object('id',v_row.id,'source_name',v_row.source_name,'domain',v_row.domain,'homepage_url',v_row.homepage_url,'category_slugs',v_row.category_slugs,'enabled',v_row.enabled);
end; $$;
create or replace function public.platform_owner_set_research_source_category(p_source_id uuid,p_category_slug text,p_enabled boolean)
returns jsonb language plpgsql security definer set search_path=public,private as $$
declare v_row public.platform_research_sources;
begin
 if auth.uid() is null or not exists(select 1 from public.platform_memberships pm where pm.user_id=auth.uid() and pm.status='active') then raise exception 'Platform owner access required'; end if;
 if not exists(select 1 from public.catalogue_master_categories c where c.slug=p_category_slug and c.active=true) then raise exception 'Unknown or inactive catalogue category'; end if;
 update public.platform_research_sources s set category_slugs=case when p_enabled then (select array_agg(distinct x order by x) from unnest(coalesce(s.category_slugs,'{}'::text[])||array[p_category_slug]::text[]) x) else array_remove(coalesce(s.category_slugs,'{}'::text[]),p_category_slug) end,updated_at=now()
 where s.id=p_source_id and not coalesce(s.category_slugs @> array['*']::text[],false) returning * into v_row;
 if not found then raise exception 'Source not found or universal source cannot be changed here'; end if;
 return jsonb_build_object('id',v_row.id,'category_slugs',v_row.category_slugs,'enabled',v_row.enabled);
end; $$;
revoke all on function public.platform_owner_list_research_sources(text) from public,anon;
revoke all on function public.platform_owner_add_research_source(text,text,text,text,text,text) from public,anon;
revoke all on function public.platform_owner_set_research_source_category(uuid,text,boolean) from public,anon;
grant execute on function public.platform_owner_list_research_sources(text) to authenticated;
grant execute on function public.platform_owner_add_research_source(text,text,text,text,text,text) to authenticated;
grant execute on function public.platform_owner_set_research_source_category(uuid,text,boolean) to authenticated;
