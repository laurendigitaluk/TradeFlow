CREATE OR REPLACE FUNCTION public.platform_owner_stage_manual_ai_report(p_prompt_id uuid, p_response_text text, p_references jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 v_prompt public.platform_manual_ai_research_prompts; v_batch public.platform_manual_ai_research_batches; v_ref jsonb; v_product jsonb;
 v_product_id uuid; v_source_name text; v_source_url text; v_package text; v_evidence_type text; v_price numeric;
 v_price_display text; v_condition text; v_availability text; v_excerpt text; v_notes text; v_dedupe text;
 v_count integer:=0; v_duplicates integer:=0; v_reported_ids uuid[]:='{}'::uuid[];
BEGIN
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 if nullif(trim(p_response_text),'') is null then raise exception 'Paste the assistant research report first'; end if;
 if length(p_response_text)>300000 then raise exception 'Research report is too large'; end if;
 if jsonb_typeof(p_references) is distinct from 'array' or jsonb_array_length(p_references)=0 then
  raise exception 'No price comparison rows were recognised. Save the reply as a draft and check that it contains New prices and Used prices tables.';
 end if;
 if jsonb_array_length(p_references)>200 then raise exception 'A single report may stage no more than 200 comparison references'; end if;
 select p.* into v_prompt from public.platform_manual_ai_research_prompts p
 join public.platform_manual_ai_research_batches b on b.id=p.batch_id
 where p.id=p_prompt_id and b.created_by=auth.uid() for update of p;
 if not found then raise exception 'Research prompt not found'; end if;
 if v_prompt.status in ('completed','no_findings') then raise exception 'This prompt has already been submitted'; end if;
 select b.* into v_batch from public.platform_manual_ai_research_batches b where b.id=v_prompt.batch_id and b.created_by=auth.uid();
 if not found then raise exception 'Research batch not found'; end if;
 for v_ref in select value from jsonb_array_elements(p_references) loop
  begin v_product_id:=(v_ref->>'product_id')::uuid; exception when others then v_product_id:=null; end;
  if v_product_id is null or not (v_product_id=any(v_prompt.product_ids)) then
   raise exception 'A comparison row could not be matched to a selected product in this prompt. Try one product per research prompt or include clear product headings in the report.';
  end if;
  select value into v_product from jsonb_array_elements(v_prompt.products_snapshot) as item(value) where value->>'product_id'=v_product_id::text limit 1;
  if v_product is null then raise exception 'Catalogue product snapshot missing'; end if;
  if lower(trim(coalesce(v_ref->>'manufacturer','')))<>lower(trim(v_product->>'manufacturer'))
     or lower(trim(coalesce(v_ref->>'model','')))<>lower(trim(v_product->>'model')) then
   raise exception 'A comparison row does not match the selected manufacturer and model';
  end if;
  v_evidence_type:=v_ref->>'evidence_type';
  if v_evidence_type not in ('uk_new','uk_used') then raise exception 'Comparison row must be UK new or UK used'; end if;
  v_source_name:=coalesce(nullif(trim(v_ref->>'source_name'),''),'Source not identified in report');
  v_source_url:=nullif(trim(v_ref->>'source_url'),'');
  if v_source_url is not null and v_source_url !~* '^https://[^[:space:]]+$' then v_source_url:=null; end if;
  v_package:=coalesce(nullif(trim(v_ref->>'package_name'),''),'Package not stated');
  v_price_display:=left(coalesce(v_ref->>'price_display',''),120);
  begin v_price:=(v_ref->>'price_gbp')::numeric; exception when others then v_price:=null; end;
  if v_price<=0 or v_price>1000000 then v_price:=null; end if;
  v_condition:=left(coalesce(nullif(trim(v_ref->>'item_condition'),''),case when v_evidence_type='uk_new' then 'New (reported; not verified)' else 'Used (reported; not verified)' end),120);
  v_availability:=left(coalesce(nullif(trim(v_ref->>'availability'),''),'Not verified from source page'),120);
  v_excerpt:=left(coalesce(nullif(trim(v_ref->>'table_row'),''),v_source_name||' · '||v_package||' · '||v_price_display),1000);
  v_notes:=left('Extracted from pasted AI comparison report. NOT independently verified. Actual package: '||v_package||'. '||coalesce(v_ref->>'notes',''),1500);
  v_dedupe:=pg_catalog.md5(lower(v_prompt.id::text||'|'||coalesce(v_source_url,'')||'|'||v_source_name||'|'||v_package||'|'||v_evidence_type||'|'||v_price_display));
  insert into public.platform_catalogue_research_queue(
   record_type,status,dedupe_key,agent_name,task_key,category_slug,branch_slug,manufacturer,model,package_name,live_master_product_id,
   evidence_type,source_name,source_url,observed_price,price_currency,item_condition,sales_channel,availability,source_record_key,source_excerpt,research_notes,raw_payload
  ) values(
   'evidence_candidate','pending_review',v_dedupe,'Manual AI Research · '||v_batch.assistant_name,
   'manual-ai-report:'||v_batch.id::text||':'||v_prompt.id::text,v_product->>'category_slug',v_product->>'branch_slug',
   v_product->>'manufacturer',v_product->>'model',v_package,null,v_evidence_type,v_source_name,v_source_url,v_price,
   case when v_price is not null then 'GBP' else null end,v_condition,coalesce(v_ref->>'source_kind','reported source'),v_availability,
   v_source_name||':'||coalesce(v_source_url,''),v_excerpt,v_notes,
   jsonb_build_object('research_method','manual_ai_report_table','assistant_key',v_batch.assistant_key,'assistant_name',v_batch.assistant_name,
    'batch_id',v_batch.id,'prompt_id',v_prompt.id,'selected_product_id',v_product_id,'evidence_role','comparison_only',
    'needs_manual_verification',true,'price_display',v_price_display,'source_kind',coalesce(v_ref->>'source_kind','unknown'),
    'page_access','not_verified_by_tradeflow','notes',coalesce(v_ref->>'notes',''))
  ) on conflict(dedupe_key) do nothing;
  if found then v_count:=v_count+1; else v_duplicates:=v_duplicates+1; end if;
  if not(v_product_id=any(v_reported_ids)) then v_reported_ids:=array_append(v_reported_ids,v_product_id); end if;
 end loop;
 update public.platform_manual_ai_research_prompts set response_text=p_response_text,response_draft=null,status='completed',
  candidates_created=v_count,findings_rejected=0,response_submitted_at=now(),updated_at=now() where id=v_prompt.id;
 update public.platform_manual_ai_research_batches b set status=case when not exists(
  select 1 from public.platform_manual_ai_research_prompts p where p.batch_id=b.id and p.status not in ('completed','no_findings')
 ) then 'completed' else 'in_progress' end,updated_at=now() where b.id=v_batch.id;
 return jsonb_build_object('submitted',true,'report_captured',true,'references_created',v_count,'duplicates_skipped',v_duplicates,'needs_manual_verification',true,'products_represented',cardinality(v_reported_ids));
END;
$function$
;
