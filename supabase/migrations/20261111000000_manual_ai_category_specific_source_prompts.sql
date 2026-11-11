-- Inject category-scoped UK research sources into every saved Manual AI Research prompt.
-- The catalogue picker already scopes selected products to one category; this trigger
-- derives category scope from the immutable product snapshot so create and refresh
-- paths use the same source directory without duplicating prompt-generation logic.

create or replace function public.platform_inject_manual_ai_category_sources()
returns trigger
language plpgsql
security definer
set search_path = public, pg_catalog
as $function$
declare
  v_category record;
  v_sources text;
  v_block text := E'\n\n=== CATEGORY-SPECIFIC UK RESEARCH SOURCES (LIVE OWNER DIRECTORY) ===\n'
    || 'These sources are selected automatically from the category attached to each catalogue product. '
    || 'Use the matching category list for that product; do not use another category list as a substitute. '
    || 'These are starting points, not an exhaustive limit: search the named sites, inspect relevant product/listing pages, '
    || 'and continue discovering other credible UK sources. Do not report a price unless the page actually shows the exact model and GBP price.\n';
  v_category_count integer := 0;
begin
  -- Remove any previous injected block before rebuilding it. This makes prompt
  -- refreshes idempotent and means edits to the owner-managed source directory apply.
  new.prompt_text := regexp_replace(
    coalesce(new.prompt_text, ''),
    E'\n\n=== CATEGORY-SPECIFIC UK RESEARCH SOURCES \(LIVE OWNER DIRECTORY\) ===[\\s\\S]*$',
    '',
    'g'
  );

  for v_category in
    select distinct
      nullif(item->>'category_slug','') as category_slug,
      coalesce(nullif(item->>'category_name',''), nullif(item->>'category_slug',''), 'Uncategorised') as category_name
    from jsonb_array_elements(coalesce(new.products_snapshot, '[]'::jsonb)) item
    where nullif(item->>'category_slug','') is not null
    order by 1
  loop
    v_category_count := v_category_count + 1;

    select string_agg(
      '• ' || s.source_name
      || ' | ' || s.source_kind
      || ' | scope: ' || s.research_scope
      || ' | ' || s.homepage_url
      || case when nullif(s.search_url_template,'') is not null
        then E'\n  Search URL template: ' || s.search_url_template
        else '' end,
      E'\n' order by s.priority, s.source_name
    )
    into v_sources
    from public.platform_research_sources s
    where s.enabled = true
      and s.country_code = 'GB'
      and s.research_scope <> 'overseas'
      and (
        coalesce(s.category_slugs, '{}'::text[]) @> array[v_category.category_slug]::text[]
        or coalesce(s.category_slugs, '{}'::text[]) @> array['*']::text[]
      );

    v_block := v_block || E'\nCATEGORY: ' || v_category.category_name
      || ' (slug: ' || v_category.category_slug || ')' || E'\n'
      || coalesce(v_sources, 'No category-specific UK sources are currently enabled in the owner directory. Search the UK manufacturer, specialist retailer and used-market sources independently; do not invent directory entries.')
      || E'\n';
  end loop;

  if v_category_count = 0 then
    v_block := v_block
      || E'\nNo category slug was present in the product snapshot. Do not guess a category or use unrelated category sources. Use only universal UK sources and clearly state the limitation.\n';
  end if;

  v_block := v_block
    || E'\nSOURCE-DIRECTORY RULES:\n'
    || '1. Manufacturer sources establish official model identity and current/new UK pricing where displayed. '
    || 'Retailer sources support current UK new pricing. Used-dealer and marketplace sources support used listings only when the individual item page is inspected.\n'
    || '2. Treat source_kind and research_scope as guidance, not proof that a page contains the requested product. Open the page and verify the exact model, package, condition, availability and GBP price.\n'
    || '3. If a Search URL template is supplied, replace {query} with the URL-encoded manufacturer, model and package search terms. Otherwise use the homepage and the site''s own search.\n'
    || '4. Record the actual source URL visited. Do not use a homepage URL as though it were an individual product listing. Never claim a page was opened unless it was inspected.\n'
    || '5. These category-specific websites supplement the required broader web discovery; they do not replace searching other credible UK sources. Exclude overseas prices from UK evidence.\n'
    || '6. The enabled source directory is the owner-maintained source of truth. Do not hard-code or assume websites from another product category.';

  new.prompt_text := rtrim(new.prompt_text) || v_block;
  return new;
end;
$function$;

drop trigger if exists trg_platform_manual_ai_category_sources
  on public.platform_manual_ai_research_prompts;

create trigger trg_platform_manual_ai_category_sources
before insert or update of prompt_text, products_snapshot
on public.platform_manual_ai_research_prompts
for each row
execute function public.platform_inject_manual_ai_category_sources();

revoke all on function public.platform_inject_manual_ai_category_sources() from public, anon, authenticated;
