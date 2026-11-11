 -- Owner-only removal of selected manual AI research prompt boxes.
CREATE OR REPLACE FUNCTION public.platform_owner_delete_manual_ai_research_prompts(p_prompt_ids uuid[])
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
 v_ids uuid[];
 v_deleted integer := 0;
 v_batches_removed integer := 0;
BEGIN
 IF NOT public.platform_cloud_ai_owner_check() THEN RAISE EXCEPTION 'Platform owner access required'; END IF;
 IF p_prompt_ids IS NULL OR cardinality(p_prompt_ids)=0 THEN RAISE EXCEPTION 'Select at least one research prompt to delete'; END IF;
 SELECT array_agg(DISTINCT x) INTO v_ids FROM unnest(p_prompt_ids) AS x WHERE x IS NOT NULL;
 IF coalesce(cardinality(v_ids),0)=0 THEN RAISE EXCEPTION 'Select at least one valid research prompt to delete'; END IF;
 DELETE FROM public.platform_manual_ai_research_prompts p USING public.platform_manual_ai_research_batches b
 WHERE p.batch_id=b.id AND b.created_by=auth.uid() AND p.id=ANY(v_ids);
 GET DIAGNOSTICS v_deleted = ROW_COUNT;
 IF v_deleted=0 THEN RAISE EXCEPTION 'No selected prompts were found in your research batches'; END IF;
 DELETE FROM public.platform_manual_ai_research_batches b WHERE b.created_by=auth.uid()
 AND NOT EXISTS (SELECT 1 FROM public.platform_manual_ai_research_prompts p WHERE p.batch_id=b.id);
 GET DIAGNOSTICS v_batches_removed = ROW_COUNT;
 RETURN jsonb_build_object('deleted_prompts',v_deleted,'empty_batches_removed',v_batches_removed,'review_queue_preserved',true);
END;
$function$;
REVOKE ALL ON FUNCTION public.platform_owner_delete_manual_ai_research_prompts(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.platform_owner_delete_manual_ai_research_prompts(uuid[]) TO authenticated;
