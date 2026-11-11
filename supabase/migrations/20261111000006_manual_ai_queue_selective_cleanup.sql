-- Allow the platform owner to clear AI research queue records without deleting imported catalogue evidence.
CREATE OR REPLACE FUNCTION public.platform_owner_delete_catalogue_research_queue_items(p_ids uuid[])
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
 v_ids uuid[];
 v_deleted integer := 0;
BEGIN
 IF auth.uid() IS NULL OR NOT EXISTS (
  SELECT 1 FROM public.platform_memberships pm
  WHERE pm.user_id=auth.uid() AND pm.status='active'
 ) THEN RAISE EXCEPTION 'Platform owner access required'; END IF;
 IF p_ids IS NULL OR cardinality(p_ids)=0 THEN RAISE EXCEPTION 'Select at least one research record to delete'; END IF;
 SELECT array_agg(DISTINCT x) INTO v_ids FROM unnest(p_ids) AS x WHERE x IS NOT NULL;
 DELETE FROM public.platform_catalogue_research_queue q
 WHERE q.id=ANY(v_ids)
   AND (q.agent_name='Cloud AI Research Manager' OR q.agent_name LIKE 'Manual AI Research · %');
 GET DIAGNOSTICS v_deleted=ROW_COUNT;
 IF v_deleted=0 THEN RAISE EXCEPTION 'No selected AI research queue records were found'; END IF;
 RETURN jsonb_build_object('deleted_queue_records',v_deleted,'catalogue_evidence_preserved',true);
END;
$function$;
REVOKE ALL ON FUNCTION public.platform_owner_delete_catalogue_research_queue_items(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.platform_owner_delete_catalogue_research_queue_items(uuid[]) TO authenticated;
