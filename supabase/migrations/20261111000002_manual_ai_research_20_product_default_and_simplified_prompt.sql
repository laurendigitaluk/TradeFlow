-- Simplify Manual AI research and make 20 products the default prompt size.

CREATE OR REPLACE FUNCTION public.platform_owner_create_manual_ai_research_batch(p_product_ids uuid[], p_assistant_key text, p_products_per_prompt integer DEFAULT 20, p_research_type text DEFAULT 'price_evidence'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_assistant_name text;
  v_assistant_url text;
  v_batch_id uuid;
  v_unique_ids uuid[];
  v_selected_count integer;
  v_prompt_count integer;
  v_chunk record;
  v_today text := to_char(current_date,'FMDD FMMonth YYYY');
  v_research_task text;
  v_prompt text;
begin
  if not public.platform_cloud_ai_owner_check() then
    raise exception 'Platform owner access required';
  end if;

  if p_research_type <> 'price_evidence' then
    raise exception 'Manual research currently supports UK new and used price evidence only';
  end if;
  if p_products_per_prompt not in (5,10,15,20) then
    raise exception 'Choose 5, 10, 15 or 20 products per prompt';
  end if;

  select array_agg(x order by x)
    into v_unique_ids
  from (
    select distinct unnest(coalesce(p_product_ids,'{}'::uuid[])) as x
  ) ids;

  v_selected_count := coalesce(array_length(v_unique_ids,1),0);
  if v_selected_count < 1 then
    raise exception 'Select at least one product from the master catalogue';
  end if;
  if v_selected_count > 500 then
    raise exception 'Manual research batches are limited to 500 products at a time';
  end if;

  if (
    select count(*) from public.catalogue_master_products p
    where p.id = any(v_unique_ids) and p.active = true
  ) <> v_selected_count then
    raise exception 'One or more selected products are no longer active in the master catalogue. Refresh the product list and select again.';
  end if;

  case p_assistant_key
    when 'chatgpt' then v_assistant_name := 'ChatGPT'; v_assistant_url := 'https://chatgpt.com/';
    when 'gemini' then v_assistant_name := 'Google Gemini'; v_assistant_url := 'https://gemini.google.com/app';
    when 'grok' then v_assistant_name := 'Grok'; v_assistant_url := 'https://grok.com/';
    when 'claude' then v_assistant_name := 'Claude'; v_assistant_url := 'https://claude.ai/new';
    when 'perplexity' then v_assistant_name := 'Perplexity'; v_assistant_url := 'https://www.perplexity.ai/';
    when 'mistral' then v_assistant_name := 'Mistral Vibe'; v_assistant_url := 'https://chat.mistral.ai/chat';
    when 'deepseek' then v_assistant_name := 'DeepSeek'; v_assistant_url := 'https://chat.deepseek.com/';
    when 'qwen' then v_assistant_name := 'Qwen Chat'; v_assistant_url := 'https://chat.qwen.ai/';
    when 'copilot' then v_assistant_name := 'Microsoft Copilot'; v_assistant_url := 'https://copilot.microsoft.com/';
    when 'meta_ai' then v_assistant_name := 'Meta AI'; v_assistant_url := 'https://www.meta.ai/';
    else raise exception 'Choose a supported manual AI assistant';
  end case;

  v_research_task := $research$
Research EVERY product in this prompt. Cover all products before spending extra time on one.

For each product:
1. Search UK sources for the exact manufacturer, model and requested package. Check NEW and USED prices separately.
2. Start with one targeted UK-new search and one targeted UK-used search. Use a further search only when needed to find or clarify a real product page. Use the category-specific UK source directory below as a starting point.
3. Open the actual retailer or individual listing page before reporting a price. Record the direct page URL, displayed GBP price, exact model, actual package, condition, availability and date checked. A search snippet or category page is not an opened product page; if that is all you can access, label it comparison_only and say snippet_only/category_page.
4. Same exact model in another bundle/package is useful, but label it comparison_only and name the actual package. Never substitute a different model or claim an alternative bundle is the requested package.
5. Keep UK-new and UK-used separate. Keep VAT-exclusive prices clearly labelled. Do not convert foreign prices or invent missing information.
6. Aim for up to two good distinct UK sources for NEW and two for USED per product when available. Do not keep searching to fill a quota. First make sure EVERY product in this prompt has been checked.
7. If no reliable price is found, include that product in not_found with the actual searches and at least two source sites checked. Never omit a selected product.

Return ONE valid JSON object only, with no Markdown fences or report before or after it:
{"schema_version":"tradeflow_manual_research_v1","findings":[...],"not_found":[...]}.

Each finding must include: product_id (exact supplied UUID), manufacturer, model, package_name (actual source package), evidence_type ("uk_new" or "uk_used"), source_name, source_url (direct page URL), price_gbp (number), currency ("GBP"), item_condition, availability, observed_at ("YYYY-MM-DD"), product_match ("exact" or "likely"), source_excerpt (short verbatim text showing the model and price), search_queries_used (the actual two or more searches used for this product), and research_notes. Add package_match ("exact_package", "same_model_other_package" or "package_not_stated") and evidence_role ("catalogue_evidence" or "comparison_only") where relevant.

Each not_found entry must include product_id, manufacturer, model, package_name, searches_attempted (at least two actual searches), sources_checked (at least two site names), and reason.

Before returning, check that every supplied product_id appears in findings or not_found, every price is UK GBP, new and used are separate, the model/package match is correctly labelled, and each reported URL and quote supports the price.
$research$;

  insert into public.platform_manual_ai_research_batches(
    created_by,assistant_key,assistant_name,assistant_url,research_type,
    products_per_prompt,product_count,prompt_count,status
  )
  values(
    auth.uid(),p_assistant_key,v_assistant_name,v_assistant_url,p_research_type,
    p_products_per_prompt,v_selected_count,ceil(v_selected_count::numeric/p_products_per_prompt)::integer,'in_progress'
  )
  returning id into v_batch_id;

  for v_chunk in
    with selected as (
      select
        p.id as product_id,
        c.name as category_name,
        c.slug as category_slug,
        b.name as branch_name,
        b.slug as branch_slug,
        m.name as manufacturer,
        p.model,
        p.package_name,
        row_number() over(order by c.name,b.name,m.name,p.model,p.package_name,p.id) - 1 as row_num,
        jsonb_build_object(
          'product_id',p.id,
          'category_name',c.name,
          'category_slug',c.slug,
          'branch_name',b.name,
          'branch_slug',b.slug,
          'manufacturer',m.name,
          'model',p.model,
          'package_name',p.package_name,
          'existing_new_evidence_count',coalesce(ev.new_count,0),
          'existing_used_evidence_count',coalesce(ev.used_count,0),
          'existing_evidence_references',coalesce(ev.references,'[]'::jsonb)
        ) as product_json
      from public.catalogue_master_products p
      join public.catalogue_master_categories c on c.id=p.category_id
      left join public.catalogue_master_branches b on b.id=p.branch_id
      join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
      left join lateral (
        select
          count(*) filter(where e.evidence_type='uk_new')::integer as new_count,
          count(*) filter(where e.evidence_type='uk_used')::integer as used_count,
          coalesce((
            select jsonb_agg(jsonb_build_object(
              'evidence_type',recent.evidence_type,
              'source_name',recent.source_name,
              'source_url',recent.source_url,
              'price_gbp',recent.observed_price,
              'condition',recent.item_condition,
              'observed_at',recent.observed_at
            ) order by recent.observed_at desc nulls last)
            from (
              select e2.evidence_type,e2.source_name,e2.source_url,e2.observed_price,e2.item_condition,e2.observed_at
              from public.shared_market_evidence e2
              where e2.master_product_id=p.id and e2.is_active=true
              order by e2.observed_at desc nulls last,e2.created_at desc
              limit 6
            ) recent
          ),'[]'::jsonb) as references
        from public.shared_market_evidence e
        where e.master_product_id=p.id and e.is_active=true
      ) ev on true
      where p.id=any(v_unique_ids) and p.active=true
    ),
    grouped as (
      select
        floor(row_num / p_products_per_prompt)::integer + 1 as prompt_number,
        array_agg(product_id order by row_num) as product_ids,
        jsonb_agg(product_json order by row_num) as products_snapshot
      from selected
      group by floor(row_num / p_products_per_prompt)::integer + 1
    )
    select prompt_number,product_ids,products_snapshot from grouped order by prompt_number
  loop
    v_prompt :=
      'TRADEFLOW — MANUAL UK PRODUCT PRICE EVIDENCE RESEARCH' || E'\n' ||
      'Assistant: ' || v_assistant_name || E'\n' ||
      'Research date: ' || v_today || E'\n' ||
      'Prompt batch: ' || v_chunk.prompt_number || ' of ' || ceil(v_selected_count::numeric/p_products_per_prompt)::integer || E'\n\n' ||
      v_research_task || E'\n\n' ||
      'PRODUCTS TO RESEARCH (catalogue data supplied by TradeFlow; treat it as the authoritative product identity list):' || E'\n' ||
      v_chunk.products_snapshot::text || E'\n\n' ||
      'Return the complete readable price-comparison report followed by the final valid JSON code block. Do not replace the tables and source links with JSON only. Do not omit any selected product: every supplied product_id must appear either in one or more findings or in not_found.';

    insert into public.platform_manual_ai_research_prompts(
      batch_id,prompt_number,product_ids,products_snapshot,prompt_text
    )
    values(
      v_batch_id,v_chunk.prompt_number,v_chunk.product_ids,v_chunk.products_snapshot,v_prompt
    );
  end loop;

  select count(*)::integer into v_prompt_count
  from public.platform_manual_ai_research_prompts where batch_id=v_batch_id;

  return jsonb_build_object(
    'batch_id',v_batch_id,
    'assistant_key',p_assistant_key,
    'assistant_name',v_assistant_name,
    'assistant_url',v_assistant_url,
    'product_count',v_selected_count,
    'prompt_count',v_prompt_count,
    'products_per_prompt',p_products_per_prompt,
    'status','in_progress'
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.platform_owner_submit_manual_ai_research_response(p_prompt_id uuid, p_response_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
 v_prompt public.platform_manual_ai_research_prompts; v_batch public.platform_manual_ai_research_batches; v_payload jsonb; v_finding jsonb; v_product jsonb;
 v_product_id uuid; v_price numeric; v_evidence_type text; v_source_name text; v_source_url text; v_excerpt text;
 v_manufacturer text; v_model text; v_package text; v_catalogue_package text; v_match text; v_condition text; v_availability text;
 v_package_match text; v_evidence_role text; v_source_kind text; v_page_access text;
 v_observed_at date; v_findings_count integer:=0; v_created integer:=0; v_rejected integer:=0; v_duplicates integer:=0;
 v_catalogue_evidence integer:=0; v_comparison_only integer:=0;
 v_dedupe text; v_normal_excerpt text; v_price_token text;
 v_reported_ids uuid[] := '{}'::uuid[]; v_not_found_item jsonb; v_not_found_product jsonb; v_not_found_id uuid;
 v_query_count integer; v_source_count integer;
 v_json_response text;
begin
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if nullif(trim(p_response_text),'') is null then raise exception 'Paste the AI assistant response first'; end if;
 if length(p_response_text)>300000 then raise exception 'Response is too large. Submit one prompt response at a time.'; end if;
 select p.* into v_prompt from public.platform_manual_ai_research_prompts p
 join public.platform_manual_ai_research_batches b on b.id=p.batch_id
 where p.id=p_prompt_id and b.created_by=auth.uid() for update of p;
 if not found then raise exception 'Research prompt not found'; end if;
 if v_prompt.status in ('completed','no_findings') then raise exception 'This prompt response has already been submitted'; end if;
 select b.* into v_batch from public.platform_manual_ai_research_batches b where b.id=v_prompt.batch_id and b.created_by=auth.uid();
 if not found then raise exception 'Research batch not found'; end if;
 v_json_response:=p_response_text;
 if position(chr(96)||chr(96)||chr(96)||'json' in lower(p_response_text))>0 then
  v_json_response:=substring(p_response_text from ('(?is)'||chr(96)||chr(96)||chr(96)||'json[[:space:]]*(.*?)'||chr(96)||chr(96)||chr(96)));
  if nullif(trim(v_json_response),'') is null then
   raise exception 'The response contains a JSON code block but it could not be extracted. Copy the final TradeFlow JSON block again.';
  end if;
 end if;
 begin v_payload:=v_json_response::jsonb;
 exception when others then raise exception 'The AI reply must include the final valid TradeFlow JSON code block. Keep the readable report above it; TradeFlow will extract the JSON block automatically.'; end;
 if jsonb_typeof(v_payload) is distinct from 'object'
    or v_payload->>'schema_version' is distinct from 'tradeflow_manual_research_v1'
    or jsonb_typeof(v_payload->'findings') is distinct from 'array'
    or jsonb_typeof(v_payload->'not_found') is distinct from 'array' then
  raise exception 'The reply must use the TradeFlow JSON format with schema_version, findings and not_found arrays';
 end if;
 for v_finding in select value from jsonb_array_elements(v_payload->'findings') loop
  v_findings_count:=v_findings_count+1;
  begin v_product_id:=(v_finding->>'product_id')::uuid; exception when others then v_product_id:=null; end;
  if v_product_id is null then v_rejected:=v_rejected+1; continue; end if;
  select value into v_product from jsonb_array_elements(v_prompt.products_snapshot) as item(value)
   where value->>'product_id'=v_product_id::text limit 1;
  if v_product is null then v_rejected:=v_rejected+1; continue; end if;
  v_manufacturer:=coalesce(v_finding->>'manufacturer','');
  v_model:=coalesce(v_finding->>'model','');
  v_package:=coalesce(v_finding->>'package_name','');
  v_catalogue_package:=coalesce(v_finding->>'catalogue_package_name','');
  if lower(trim(v_manufacturer))<>lower(trim(v_product->>'manufacturer'))
     or lower(trim(v_model))<>lower(trim(v_product->>'model'))
     or lower(trim(v_catalogue_package))<>lower(trim(coalesce(v_product->>'package_name',''))) then
   v_rejected:=v_rejected+1; continue;
  end if;
  if nullif(trim(v_package),'') is null then
   v_package_match:='package_not_stated';
  elsif lower(trim(v_package))=lower(trim(coalesce(v_product->>'package_name',''))) then
   v_package_match:='exact_package';
  else
   v_package_match:='same_model_other_package';
  end if;
  if coalesce(v_finding->>'package_match','')<>v_package_match then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_evidence_type:=v_finding->>'evidence_type';
  if v_evidence_type not in ('uk_new','uk_used') then v_rejected:=v_rejected+1; continue; end if;
  if jsonb_typeof(v_finding->'search_queries_used') is distinct from 'array' then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_query_count:=jsonb_array_length(v_finding->'search_queries_used');
  if v_query_count<2 or exists(select 1 from jsonb_array_elements_text(v_finding->'search_queries_used') q where nullif(trim(q),'') is null) then
   v_rejected:=v_rejected+1; continue;
  end if;
  if nullif(trim(v_finding->>'item_condition'),'') is null
     or nullif(trim(v_finding->>'availability'),'') is null
     or nullif(trim(v_finding->>'observed_at'),'') is null then
   v_rejected:=v_rejected+1; continue;
  end if;
  begin v_price:=(v_finding->>'price_gbp')::numeric; exception when others then v_price:=null; end;
  if v_price is null or v_price<=0 or v_price>1000000 or coalesce(v_finding->>'currency','GBP')<>'GBP' then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_source_name:=nullif(trim(v_finding->>'source_name'),'');
  v_source_url:=nullif(trim(v_finding->>'source_url'),'');
  v_excerpt:=left(trim(coalesce(v_finding->>'source_excerpt','')),1000);
  v_match:=coalesce(v_finding->>'product_match','');
  v_source_kind:=coalesce(v_finding->>'source_kind','');
  v_page_access:=coalesce(v_finding->>'page_access','');
  if v_source_name is null or v_source_url is null or v_source_url !~* '^https://[^[:space:]]+$'
     or length(v_excerpt)<15 or position(lower(v_model) in lower(v_excerpt))=0
     or v_match<>'exact'
     or v_source_kind not in ('retailer_product_page','marketplace_listing','manufacturer_product_page','price_aggregator','editorial_review','category_page','search_snippet','other')
     or v_page_access not in ('opened','blocked','snippet_only','quoted_by_secondary_source') then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_normal_excerpt:=regexp_replace(lower(replace(v_excerpt,'£','')),'[,[:space:]]','','g');
  v_price_token:=regexp_replace(to_char(v_price,'FM999999999990.00'),'\\.00$','');
  v_price_token:=regexp_replace(v_price_token,'[,.]','','g');
  if position(v_price_token in regexp_replace(v_normal_excerpt,'[,.]','','g'))=0 or lower(v_excerpt) !~ '(£|gbp)' then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_evidence_role:=case
    when v_package_match='exact_package'
     and v_source_kind in ('retailer_product_page','marketplace_listing','manufacturer_product_page')
     and v_page_access='opened'
    then 'catalogue_evidence'
    else 'comparison_only'
  end;
  if coalesce(v_finding->>'evidence_role','')<>v_evidence_role then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_condition:=left(coalesce(nullif(trim(v_finding->>'item_condition'),''),'unknown'),120);
  v_availability:=left(coalesce(nullif(trim(v_finding->>'availability'),''),'unknown'),80);
  begin v_observed_at:=(v_finding->>'observed_at')::date; exception when others then v_observed_at:=null; end;
  if v_observed_at is null or v_observed_at>current_date then v_rejected:=v_rejected+1; continue; end if;
  v_dedupe:=pg_catalog.md5(lower(v_product_id::text||'|'||v_source_url||'|'||v_price::text||'|'||v_evidence_type));
  insert into public.platform_catalogue_research_queue(
   record_type,status,dedupe_key,agent_name,task_key,category_slug,branch_slug,manufacturer,model,package_name,live_master_product_id,
   evidence_type,source_name,source_url,observed_price,price_currency,item_condition,sales_channel,availability,source_record_key,source_excerpt,research_notes,raw_payload
  ) values(
   'evidence_candidate','pending_review',v_dedupe,'Manual AI Research · '||v_batch.assistant_name,
   'manual-ai:'||v_batch.id::text||':'||v_prompt.id::text,v_product->>'category_slug',v_product->>'branch_slug',
   v_manufacturer,v_model,nullif(v_package,''),
   case when v_evidence_role='catalogue_evidence' then v_product_id else null end,
   v_evidence_type,v_source_name,v_source_url,v_price,'GBP',v_condition,
   v_source_kind,v_availability,v_source_name||':'||v_source_url,v_excerpt,
   left('Package match: '||v_package_match||'. '||v_evidence_role||'. Source: '||v_source_kind||' / '||v_page_access||'. Assistant: '||v_batch.assistant_name||'. '||coalesce(v_finding->>'research_notes',''),1000),
   jsonb_build_object('research_method','manual_ai_chat','assistant_key',v_batch.assistant_key,'assistant_name',v_batch.assistant_name,
    'batch_id',v_batch.id,'prompt_id',v_prompt.id,'product_id',v_product_id,
    'package_match',v_package_match,'evidence_role',v_evidence_role,'source_kind',v_source_kind,'page_access',v_page_access,
    'search_queries_used',coalesce(v_finding->'search_queries_used','[]'::jsonb),'original_finding',v_finding)
  ) on conflict(dedupe_key) do nothing;
  if not (v_product_id = any(v_reported_ids)) then v_reported_ids:=array_append(v_reported_ids,v_product_id); end if;
  if found then
   v_created:=v_created+1;
   if v_evidence_role='catalogue_evidence' then v_catalogue_evidence:=v_catalogue_evidence+1;
   else v_comparison_only:=v_comparison_only+1; end if;
  else v_duplicates:=v_duplicates+1; end if;
 end loop;

 for v_not_found_item in select value from jsonb_array_elements(v_payload->'not_found') loop
  begin v_not_found_id:=(v_not_found_item->>'product_id')::uuid; exception when others then v_not_found_id:=null; end;
  if v_not_found_id is null then raise exception 'The not_found list includes an entry without a valid catalogue product ID.'; end if;
  select value into v_not_found_product from jsonb_array_elements(v_prompt.products_snapshot) as item(value)
   where value->>'product_id'=v_not_found_id::text limit 1;
  if v_not_found_product is null then raise exception 'The not_found list contains a product that was not selected in this prompt.'; end if;
  if lower(trim(coalesce(v_not_found_item->>'manufacturer','')))<>lower(trim(v_not_found_product->>'manufacturer'))
     or lower(trim(coalesce(v_not_found_item->>'model','')))<>lower(trim(v_not_found_product->>'model'))
     or lower(trim(coalesce(v_not_found_item->>'package_name','')))<>lower(trim(coalesce(v_not_found_product->>'package_name',''))) then
   raise exception 'A not_found entry does not match the selected catalogue product identity.';
  end if;
  if nullif(trim(v_not_found_item->>'reason'),'') is null
     or jsonb_typeof(v_not_found_item->'searches_attempted') is distinct from 'array'
     or jsonb_typeof(v_not_found_item->'sources_checked') is distinct from 'array' then
   raise exception 'Every not_found entry must state the reason, searches attempted and sources checked.';
  end if;
  v_query_count:=jsonb_array_length(v_not_found_item->'searches_attempted');
  v_source_count:=jsonb_array_length(v_not_found_item->'sources_checked');
  if v_query_count<2 or v_source_count<2
     or exists(select 1 from jsonb_array_elements_text(v_not_found_item->'searches_attempted') q where nullif(trim(q),'') is null)
     or exists(select 1 from jsonb_array_elements_text(v_not_found_item->'sources_checked') q where nullif(trim(q),'') is null) then
   raise exception 'Each not_found product must list at least two searches and at least two sources checked.';
  end if;
  if not (v_not_found_id = any(v_reported_ids)) then v_reported_ids:=array_append(v_reported_ids,v_not_found_id); end if;
 end loop;

 if exists(
  select 1 from unnest(v_prompt.product_ids) as expected(product_id)
  where not (expected.product_id = any(v_reported_ids))
 ) then
  raise exception 'The reply omitted one or more selected products. Each product must appear in findings with validated evidence or in not_found with searches and a reason.';
 end if;

 update public.platform_manual_ai_research_prompts set response_text=p_response_text,response_draft=null,
  status=case when v_created>0 then 'completed' else 'no_findings' end,
  candidates_created=v_created,findings_rejected=v_rejected,response_submitted_at=now(),updated_at=now()
 where id=v_prompt.id;
 update public.platform_manual_ai_research_batches b set status=case when not exists(
   select 1 from public.platform_manual_ai_research_prompts p where p.batch_id=b.id and p.status not in ('completed','no_findings')
  ) then 'completed' else 'in_progress' end,updated_at=now() where b.id=v_batch.id;
 return jsonb_build_object('submitted',true,'prompt_id',v_prompt.id,'findings_received',v_findings_count,
  'candidates_created',v_created,'catalogue_evidence_candidates',v_catalogue_evidence,
  'comparison_only_references',v_comparison_only,'duplicates_skipped',v_duplicates,'findings_rejected',v_rejected,
  'not_found_count',jsonb_array_length(v_payload->'not_found'));
end;
$function$;
