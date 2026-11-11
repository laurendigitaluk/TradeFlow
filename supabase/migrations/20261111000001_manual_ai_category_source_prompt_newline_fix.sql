-- Correct prompt block handling to use literal newline characters and idempotent marker removal.
-- This replaces the initial trigger function implementation without changing its contract.
create or replace function public.platform_inject_manual_ai_category_sources()
returns trigger
language plpgsql
security definer
set search_path = public, pg_catalog
as $function$
declare
  v_category record;
  v_sources text;
  v_marker text := chr(10) || chr(10) || '=== CATEGORY-SPECIFIC UK RESEARCH SOURCES (LIVE OWNER DIRECTORY) ===';
  v_block text := chr(10) || chr(10) || '=== CATEGORY-SPECIFIC UK RESEARCH SOURCES (LIVE OWNER DIRECTORY) ===' || chr(10)
    || 'These sources are selected automatically from the category attached to each catalogue product. Use the matching category list for that product; do not use another category list as a substitute. These are starting points, not an exhaustive limit: search the named sites, inspect relevant product/listing pages, and continue discovering other credible UK sources. Do not report a price unless the page actually shows the exact model and GBP price.' || chr(10);
  v_category_count integer := 0;
begin
  new.prompt_text := coalesce(new.prompt_text, '');
  if strpos(new.prompt_text, v_marker) > 0 then
    new.prompt_text := left(new.prompt_text, strpos(new.prompt_text, v_marker) - 1);
  end if;

  for v_category in
    select distinct nullif(item->>'category_slug','') as category_slug,
      coalesce(nullif(item->>'category_name',''), nullif(item->>'category_slug',''), 'Uncategorised') as category_name
    from jsonb_array_elements(coalesce(new.products_snapshot, '[]'::jsonb)) item
    where nullif(item->>'category_slug','') is not null
    order by 1
  loop
    v_category_count := v_category_count + 1;
    select string_agg(
      '• ' || s.source_name || ' | ' || s.source_kind || ' | scope: ' || s.research_scope || ' | ' || s.homepage_url
      || case when nullif(s.search_url_template,'') is not null then chr(10) || '  Search URL template: ' || s.search_url_template else '' end,
      chr(10) order by s.priority, s.source_name
    ) into v_sources
    from public.platform_research_sources s
    where s.enabled = true and s.country_code = 'GB' and s.research_scope <> 'overseas'
      and (coalesce(s.category_slugs, '{}'::text[]) @> array[v_category.category_slug]::text[]
        or coalesce(s.category_slugs, '{}'::text[]) @> array['*']::text[]);

    v_block := v_block || chr(10) || 'CATEGORY: ' || v_category.category_name
      || ' (slug: ' || v_category.category_slug || ')' || chr(10)
      || coalesce(v_sources, 'No category-specific UK sources are currently enabled in the owner directory. Search UK manufacturer, specialist retailer and used-market sources independently; do not invent directory entries.')
      || chr(10);
  end loop;

  if v_category_count = 0 then
    v_block := v_block || chr(10) || 'No category slug was present in the product snapshot. Do not guess a category or use unrelated category sources. Use only universal UK sources and clearly state the limitation.' || chr(10);
  end if;

  v_block := v_block
    || chr(10) || 'SOURCE-DIRECTORY RULES:' || chr(10)
    || '1. Manufacturer sources establish official model identity and current/new UK pricing where displayed. Retailer sources support current UK new pricing. Used-dealer and marketplace sources support used listings only when the individual item page is inspected.' || chr(10)
    || '2. Treat source_kind and research_scope as guidance, not proof that a page contains the requested product. Open the page and verify exact model, package, condition, availability and GBP price.' || chr(10)
    || '3. If a Search URL template is supplied, replace {query} with URL-encoded manufacturer, model and package search terms. Otherwise use the homepage and the site''s own search.' || chr(10)
    || '4. Record the actual source URL visited. Do not use a homepage URL as an individual product listing. Never claim a page was opened unless it was inspected.' || chr(10)
    || '5. These category-specific websites supplement broader web discovery. Exclude overseas prices from UK evidence.' || chr(10)
    || '6. The enabled source directory is the owner-maintained source of truth. Do not hard-code or assume websites from another category.';

  new.prompt_text := rtrim(new.prompt_text) || v_block;
  return new;
end;
$function$;