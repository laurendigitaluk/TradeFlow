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
          'product_ids',p.product_ids,'products_snapshot',p.products_snapshot,'prompt_text',p.prompt_text,'status',p.status,
          'response_draft',p.response_draft,'candidates_created',p.candidates_created,
          'findings_rejected',p.findings_rejected,'response_submitted_at',p.response_submitted_at,'response_text',p.response_text
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
    'page_access','not_verified_by_tradeflow','original_report',p_response_text,'notes',coalesce(v_ref->>'notes',''))
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

CREATE OR REPLACE FUNCTION public.platform_owner_list_manual_ai_comparison_matches(p_queue_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE v_row public.platform_catalogue_research_queue; v_matches jsonb;
BEGIN
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 select * into v_row from public.platform_catalogue_research_queue where id=p_queue_id and agent_name like 'Manual AI Research · %';
 if not found then raise exception 'Manual AI comparison reference not found'; end if;
 select coalesce(jsonb_agg(jsonb_build_object('product_id',p.id,'manufacturer',m.name,'model',p.model,'package_name',p.package_name,
  'category_name',c.name,'branch_name',b.name) order by p.package_name),'[]'::jsonb) into v_matches
 from public.catalogue_master_products p
 join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
 join public.catalogue_master_categories c on c.id=p.category_id
 left join public.catalogue_master_branches b on b.id=p.branch_id
 where p.active and lower(m.name)=lower(v_row.manufacturer) and lower(p.model)=lower(v_row.model)
 and c.slug=v_row.category_slug;
 return coalesce(v_matches,'[]'::jsonb);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.platform_owner_match_manual_ai_comparison(p_queue_id uuid, p_product_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE v_row public.platform_catalogue_research_queue; v_product public.catalogue_master_products; v_manufacturer text; v_category_id uuid;
BEGIN
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 select * into v_row from public.platform_catalogue_research_queue where id=p_queue_id and agent_name like 'Manual AI Research · %' for update;
 if not found then raise exception 'Manual AI comparison reference not found'; end if;
 if v_row.status not in ('pending_review','needs_research') then raise exception 'Only unapproved comparison references can be matched'; end if;
 select p.* into v_product from public.catalogue_master_products p where p.id=p_product_id and p.active;
 if not found then raise exception 'Selected catalogue product is not active'; end if;
 select m.name,c.id into v_manufacturer,v_category_id from public.catalogue_master_manufacturers m
 join public.catalogue_master_categories c on c.id=v_product.category_id where m.id=v_product.manufacturer_id;
 if lower(v_manufacturer)<>lower(v_row.manufacturer) or lower(v_product.model)<>lower(v_row.model)
 or v_category_id<>(select c.id from public.catalogue_master_categories c where c.slug=v_row.category_slug limit 1) then
  raise exception 'You can only match this reference to the same manufacturer and model in the same catalogue category';
 end if;
 update public.platform_catalogue_research_queue set live_master_product_id=p_product_id,
  raw_payload=raw_payload||jsonb_build_object('evidence_role','catalogue_match_assigned','matched_catalogue_product_id',p_product_id,'matched_package_name',v_product.package_name),
  review_notes='Manually matched to catalogue package "'||coalesce(v_product.package_name,'')||'". Source and actual package still require human verification.',
  updated_at=now() where id=p_queue_id;
 return jsonb_build_object('matched',true,'product_id',p_product_id,'package_name',v_product.package_name);
END;
$function$
;
