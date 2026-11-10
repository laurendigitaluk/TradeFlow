-- Persistent manual AI research workspace for TradeFlow LIVE.
-- Owner-only security-definer RPCs create catalogue prompt batches, persist drafts,
-- and validate pasted assistant replies into the existing human review queue.
create table if not exists public.platform_manual_ai_research_batches (
 id uuid primary key default gen_random_uuid(),
 created_by uuid not null references auth.users(id) on delete cascade,
 assistant_key text not null,
 assistant_name text not null,
 assistant_url text not null,
 research_type text not null default 'price_evidence' check (research_type in ('price_evidence')),
 products_per_prompt integer not null check (products_per_prompt in (5,10,15,20)),
 product_count integer not null default 0,
 prompt_count integer not null default 0,
 status text not null default 'in_progress' check (status in ('in_progress','completed','cancelled')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.platform_manual_ai_research_prompts (
 id uuid primary key default gen_random_uuid(),
 batch_id uuid not null references public.platform_manual_ai_research_batches(id) on delete cascade,
 prompt_number integer not null,
 product_ids uuid[] not null,
 products_snapshot jsonb not null default '[]'::jsonb,
 prompt_text text not null,
 status text not null default 'ready' check (status in ('ready','draft_saved','completed','no_findings')),
 response_draft text,
 response_text text,
 candidates_created integer not null default 0,
 findings_rejected integer not null default 0,
 response_submitted_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(batch_id,prompt_number)
);
create index if not exists platform_manual_ai_research_batches_owner_created_idx on public.platform_manual_ai_research_batches(created_by,created_at desc);
create index if not exists platform_manual_ai_research_prompts_batch_idx on public.platform_manual_ai_research_prompts(batch_id,prompt_number);
alter table public.platform_manual_ai_research_batches enable row level security;
alter table public.platform_manual_ai_research_prompts enable row level security;
revoke all on public.platform_manual_ai_research_batches from public,anon,authenticated;
revoke all on public.platform_manual_ai_research_prompts from public,anon,authenticated;


CREATE OR REPLACE FUNCTION public.platform_owner_create_manual_ai_research_batch(p_product_ids uuid[], p_assistant_key text, p_products_per_prompt integer DEFAULT 10, p_research_type text DEFAULT 'price_evidence'::text)
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

  v_research_task :=
    'RESEARCH OBJECTIVE: Find exact, current UK retail (NEW) and UK second-hand (USED) market evidence for every product supplied. This is a live web-research assignment, not a general-knowledge question. ' ||
    'You must actively search the web, open the actual retailer or marketplace product/listing pages, inspect each page, and collect verifiable evidence. Do not answer from model memory. Do not rely on search-result snippets, AI overviews, comparison summaries, price-guide estimates or another AI answer as evidence. ' ||
    'If web search/browsing is unavailable in this chat, state that clearly in not_found and do not invent results. ' ||
    'RESEARCH DEPTH FOR EACH PRODUCT: run at least five distinct searches, varying exact manufacturer + model + package/bundle, exact model + UK price, exact model + retailer, exact model + used/second-hand, and exact model + refurbished/pre-owned where relevant. Search spelling variants and common retailer product-name variants, but never silently substitute another model. Search manufacturer/official pages and multiple UK retailers for NEW prices; search UK used retailers, specialist used dealers and current marketplace listings separately for USED prices. ' ||
    'Open promising results. Follow through to the direct product or individual listing page. Confirm that the page identifies the exact manufacturer and model. Check package/bundle, included accessories, generation/revision and model suffix. A similar model, different bundle, accessory-only listing, replacement part or generic category page is not an exact match. Record those only in not_found/research_notes as possible near matches, never as exact evidence. ' ||
    'UK SCOPE: use UK-facing pages and prices displayed in GBP (£). Do not convert foreign prices. Exclude overseas-only pages, VAT-exclusive trade prices unless clearly identified, delivery-only charges, out-of-stock pages presented as available, expired/ended listings and unsupported price claims. Record whether the listing is in stock, out of stock, preorder or unknown. ' ||
    'NEW EVIDENCE: record current new retail prices from actual UK product pages, with retailer, direct URL, page quote and checked date. Seek more than one independent retailer where available. Do not confuse a used/refurbished/open-box offer with new. ' ||
    'USED EVIDENCE: search current UK second-hand listings individually. Record each real asking price, seller/platform, direct listing URL, exact model match, condition and checked date. Do not invent an average or infer a used price from the new price. Do not treat sold/ended listings as current asking prices; if included for context, label them clearly and do not count them as current live evidence. ' ||
    'EVIDENCE STANDARD: every finding must have a direct HTTPS product/listing URL, retailer or marketplace name, GBP price, exact product match, a short verbatim quote from the opened page that contains both the model name and price, condition, availability and date checked. Quote the page; do not paraphrase the crucial model/price proof. One URL is one evidence source; avoid duplicate URLs. Prefer distinct retailers/sellers. Aim for up to three good NEW and three good USED findings per product when genuinely available. Quality and exactness matter more than filling a quota. ' ||
    'EXISTING TRADEFLOW EVIDENCE: the product records include current evidence counts and up to six existing source references. Use these to avoid returning the same URL/listing again. They are reference history, not proof that a price is still current. Search for fresh sources and prices. ' ||
    'WHEN NOTHING IS FOUND: include the product in not_found with the exact search queries you tried, source types/sites checked and why no exact, current UK evidence was available. Never fill gaps with estimates, guesses, fabricated retailer names, fabricated URLs or remembered prices. ' ||
    'OUTPUT: return JSON only, with no Markdown fences or surrounding explanation, using exactly this top-level shape: {"schema_version":"tradeflow_manual_research_v1","findings":[...],"not_found":[...]}. Every finding must include product_id (the supplied catalogue UUID), manufacturer, model, package_name, evidence_type ("uk_new" or "uk_used"), source_name, source_url, price_gbp (number), currency ("GBP"), item_condition, availability, observed_at ("YYYY-MM-DD"), product_match ("exact" or "likely"), source_excerpt (verbatim quote containing the model and displayed GBP price), search_queries_used (array of queries), research_notes. Include product_id exactly as supplied. Never make up or change product UUIDs. Include one finding per distinct live product price/listing, not one combined price range. not_found entries must include product_id, manufacturer, model, package_name, searches_attempted (array), sources_checked (array), reason. If there are no valid findings, return an empty findings array and explain each product in not_found. ' ||
    'Before returning, self-check every finding: correct product UUID; exact manufacturer/model/package; UK page; GBP price visible in quoted source excerpt; direct product/listing URL; no duplicate URL; correct new/used classification; date checked. Remove any finding that fails a check.';

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
      'Return only the required JSON object. Do not omit a product: every supplied product_id must appear either in one or more findings or in not_found.';

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
$function$
;

CREATE OR REPLACE FUNCTION public.platform_owner_save_manual_ai_research_draft(p_prompt_id uuid, p_response_draft text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_prompt public.platform_manual_ai_research_prompts;
begin
  if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
  if length(coalesce(p_response_draft,'')) > 300000 then
    raise exception 'Response draft is too large. Split the response or reduce unnecessary explanation.';
  end if;
  update public.platform_manual_ai_research_prompts p
  set response_draft=nullif(p_response_draft,''),
      status=case when p.status='ready' and nullif(p_response_draft,'') is not null then 'draft_saved' else p.status end,
      updated_at=now()
  from public.platform_manual_ai_research_batches b
  where p.id=p_prompt_id and p.batch_id=b.id and b.created_by=auth.uid()
    and p.status not in ('completed','no_findings')
  returning p.* into v_prompt;
  if not found then raise exception 'Prompt not found, or it has already been submitted'; end if;
  return jsonb_build_object('saved',true,'prompt_id',v_prompt.id,'status',v_prompt.status);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.platform_owner_submit_manual_ai_research_response(p_prompt_id uuid, p_response_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
 v_prompt public.platform_manual_ai_research_prompts; v_batch public.platform_manual_ai_research_batches; v_payload jsonb; v_finding jsonb; v_product jsonb;
 v_product_id uuid; v_price numeric; v_evidence_type text; v_source_name text; v_source_url text; v_excerpt text;
 v_manufacturer text; v_model text; v_package text; v_match text; v_condition text; v_availability text;
 v_observed_at date; v_findings_count integer:=0; v_created integer:=0; v_rejected integer:=0; v_duplicates integer:=0;
 v_dedupe text; v_normal_excerpt text; v_price_token text;
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
 begin v_payload:=p_response_text::jsonb;
 exception when others then raise exception 'The AI reply is not valid JSON. Ask the assistant to return the exact JSON format in the prompt, or paste the JSON-only part of its reply.'; end;
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
  if lower(trim(v_manufacturer))<>lower(trim(v_product->>'manufacturer'))
     or lower(trim(v_model))<>lower(trim(v_product->>'model'))
     or lower(trim(v_package))<>lower(trim(coalesce(v_product->>'package_name',''))) then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_evidence_type:=v_finding->>'evidence_type';
  if v_evidence_type not in ('uk_new','uk_used') then v_rejected:=v_rejected+1; continue; end if;
  begin v_price:=(v_finding->>'price_gbp')::numeric; exception when others then v_price:=null; end;
  if v_price is null or v_price<=0 or v_price>1000000 or coalesce(v_finding->>'currency','GBP')<>'GBP' then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_source_name:=nullif(trim(v_finding->>'source_name'),'');
  v_source_url:=nullif(trim(v_finding->>'source_url'),'');
  v_excerpt:=left(trim(coalesce(v_finding->>'source_excerpt','')),1000);
  v_match:=coalesce(v_finding->>'product_match','');
  if v_source_name is null or v_source_url is null or v_source_url !~* '^https://[^[:space:]]+$'
     or v_source_url ~* '^https://(www\.)?(google\.[^/]+/search|bing\.com/search|search\.brave\.com|duckduckgo\.com/\?)'
     or length(v_excerpt)<25 or position(lower(v_model) in lower(v_excerpt))=0
     or v_match not in ('exact','likely') then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_normal_excerpt:=regexp_replace(lower(replace(v_excerpt,'£','')),'[,[:space:]]','','g');
  v_price_token:=regexp_replace(to_char(v_price,'FM999999999990.00'),'\.00$','');
  v_price_token:=regexp_replace(v_price_token,'[,.]','','g');
  if position(v_price_token in regexp_replace(v_normal_excerpt,'[,.]','','g'))=0 or lower(v_excerpt) !~ '(£|gbp)' then
   v_rejected:=v_rejected+1; continue;
  end if;
  v_condition:=left(coalesce(nullif(trim(v_finding->>'item_condition'),''),'unknown'),120);
  v_availability:=left(coalesce(nullif(trim(v_finding->>'availability'),''),'unknown'),80);
  begin v_observed_at:=coalesce((v_finding->>'observed_at')::date,current_date); exception when others then v_observed_at:=current_date; end;
  if v_observed_at>current_date then v_observed_at:=current_date; end if;
  v_dedupe:=pg_catalog.md5(lower(v_product_id::text||'|'||v_source_url||'|'||v_price::text||'|'||v_evidence_type));
  insert into public.platform_catalogue_research_queue(
   record_type,status,dedupe_key,agent_name,task_key,category_slug,branch_slug,manufacturer,model,package_name,live_master_product_id,
   evidence_type,source_name,source_url,observed_price,price_currency,item_condition,sales_channel,availability,source_record_key,source_excerpt,research_notes,raw_payload
  ) values(
   'evidence_candidate','pending_review',v_dedupe,'Manual AI Research · '||v_batch.assistant_name,
   'manual-ai:'||v_batch.id::text||':'||v_prompt.id::text,v_product->>'category_slug',v_product->>'branch_slug',
   v_manufacturer,v_model,nullif(v_package,''),v_product_id,v_evidence_type,v_source_name,v_source_url,v_price,'GBP',v_condition,
   v_source_name,v_availability,v_source_name||':'||v_source_url,v_excerpt,
   left('Assistant: '||v_batch.assistant_name||'. Match: '||v_match||'. Manual response requires human review before import. '||coalesce(v_finding->>'research_notes',''),1000),
   jsonb_build_object('research_method','manual_ai_chat','assistant_key',v_batch.assistant_key,'assistant_name',v_batch.assistant_name,
    'batch_id',v_batch.id,'prompt_id',v_prompt.id,'product_id',v_product_id,
    'search_queries_used',coalesce(v_finding->'search_queries_used','[]'::jsonb),'original_finding',v_finding)
  ) on conflict(dedupe_key) do nothing;
  if found then v_created:=v_created+1; else v_duplicates:=v_duplicates+1; end if;
 end loop;
 update public.platform_manual_ai_research_prompts set response_text=p_response_text,response_draft=null,
  status=case when v_created>0 then 'completed' else 'no_findings' end,
  candidates_created=v_created,findings_rejected=v_rejected,response_submitted_at=now(),updated_at=now()
 where id=v_prompt.id;
 update public.platform_manual_ai_research_batches b set status=case when not exists(
   select 1 from public.platform_manual_ai_research_prompts p where p.batch_id=b.id and p.status not in ('completed','no_findings')
  ) then 'completed' else 'in_progress' end,updated_at=now() where b.id=v_batch.id;
 return jsonb_build_object('submitted',true,'prompt_id',v_prompt.id,'findings_received',v_findings_count,
  'candidates_created',v_created,'duplicates_skipped',v_duplicates,'findings_rejected',v_rejected,
  'not_found_count',jsonb_array_length(v_payload->'not_found'));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.platform_owner_list_manual_ai_research_batches(p_limit integer DEFAULT 10)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb;
begin
  if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc),'[]'::jsonb)
  into v_result
  from (
    select
      b.id,b.assistant_key,b.assistant_name,b.assistant_url,b.research_type,
      b.products_per_prompt,b.product_count,b.prompt_count,b.status,b.created_at,b.updated_at,
      coalesce((
        select jsonb_agg(jsonb_build_object(
          'id',p.id,'prompt_number',p.prompt_number,'product_count',array_length(p.product_ids,1),
          'product_ids',p.product_ids,'prompt_text',p.prompt_text,'status',p.status,
          'response_draft',p.response_draft,'candidates_created',p.candidates_created,
          'findings_rejected',p.findings_rejected,'response_submitted_at',p.response_submitted_at
        ) order by p.prompt_number)
        from public.platform_manual_ai_research_prompts p where p.batch_id=b.id
      ),'[]'::jsonb) as prompts
    from public.platform_manual_ai_research_batches b
    where b.created_by=auth.uid()
    order by b.created_at desc
    limit greatest(1,least(coalesce(p_limit,10),20))
  ) x;
  return coalesce(v_result,'[]'::jsonb);
end;
$function$
;

revoke all on function public.platform_owner_create_manual_ai_research_batch(uuid[],text,integer,text) from public,anon;
revoke all on function public.platform_owner_save_manual_ai_research_draft(uuid,text) from public,anon;
revoke all on function public.platform_owner_submit_manual_ai_research_response(uuid,text) from public,anon;
revoke all on function public.platform_owner_list_manual_ai_research_batches(integer) from public,anon;
grant execute on function public.platform_owner_create_manual_ai_research_batch(uuid[],text,integer,text) to authenticated;
grant execute on function public.platform_owner_save_manual_ai_research_draft(uuid,text) to authenticated;
grant execute on function public.platform_owner_submit_manual_ai_research_response(uuid,text) to authenticated;
grant execute on function public.platform_owner_list_manual_ai_research_batches(integer) to authenticated;
