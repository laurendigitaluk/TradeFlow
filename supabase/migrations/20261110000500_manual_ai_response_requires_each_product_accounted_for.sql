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
 v_reported_ids uuid[] := '{}'::uuid[]; v_not_found_item jsonb; v_not_found_product jsonb; v_not_found_id uuid;
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
  if not (v_product_id = any(v_reported_ids)) then v_reported_ids:=array_append(v_reported_ids,v_product_id); end if;
  if found then v_created:=v_created+1; else v_duplicates:=v_duplicates+1; end if;
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
  'candidates_created',v_created,'duplicates_skipped',v_duplicates,'findings_rejected',v_rejected,
  'not_found_count',jsonb_array_length(v_payload->'not_found'));
end;
$function$
;
