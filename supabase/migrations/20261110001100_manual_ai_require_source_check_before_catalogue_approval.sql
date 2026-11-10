CREATE OR REPLACE FUNCTION public.platform_owner_verify_manual_ai_comparison(p_queue_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
 v_row public.platform_catalogue_research_queue;
 v_kind text;
BEGIN
 if not public.platform_cloud_ai_owner_check() then raise exception 'Platform owner access required'; end if;
 select * into v_row from public.platform_catalogue_research_queue
 where id=p_queue_id and agent_name like 'Manual AI Research · %'
 for update;
 if not found then raise exception 'Manual AI comparison reference not found'; end if;
 if v_row.status not in ('pending_review','needs_research') then raise exception 'Only unapproved references can be verified'; end if;
 if v_row.live_master_product_id is null then raise exception 'Match this comparison to a catalogue product first'; end if;
 v_kind:=coalesce(v_row.raw_payload->>'source_kind','');
 if v_kind not in ('marketplace_listing','retailer_product_page','manufacturer_product_page') then
  raise exception 'This source is an aggregator, editorial, category or search page. It can remain a useful comparison, but it cannot be verified as direct product evidence.';
 end if;
 if nullif(v_row.source_url,'') is null or v_row.source_url !~* '^https://[^[:space:]]+$' then
  raise exception 'A direct HTTPS product or individual listing URL is required';
 end if;
 if v_row.source_url ~* '/(search|shop)([/?]|$)' or v_row.source_url ~* '(pricespy|e-catalog|road\.cc|visordown)' then
  raise exception 'This URL is a search, aggregator or editorial page, not an individual product/listing page.';
 end if;
 update public.platform_catalogue_research_queue
 set raw_payload=raw_payload||jsonb_build_object(
      'source_verified',true,
      'source_verified_at',now(),
      'source_verified_by',auth.uid()
     ),
     review_notes=concat_ws(' ',nullif(review_notes,''),'Reviewer confirmed the direct source page and displayed price after opening the URL.'),
     updated_at=now()
 where id=p_queue_id;
 return jsonb_build_object('verified',true,'queue_id',p_queue_id,'master_product_id',v_row.live_master_product_id);
END;
$function$;
REVOKE ALL ON FUNCTION public.platform_owner_verify_manual_ai_comparison(uuid) FROM public,anon;
GRANT EXECUTE ON FUNCTION public.platform_owner_verify_manual_ai_comparison(uuid) TO authenticated;