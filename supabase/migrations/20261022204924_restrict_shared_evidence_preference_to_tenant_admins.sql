-- Restrict shared-evidence preference changes to active tenant owners/admins.
-- Staff can have categories.view, so that permission is not sufficient for this setting.
CREATE OR REPLACE FUNCTION public.subscriber_set_shared_evidence_preference(p_tenant_id uuid, p_enabled boolean)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.tenant_memberships tm
    WHERE tm.tenant_id = p_tenant_id
      AND tm.user_id = auth.uid()
      AND tm.status = 'active'
      AND tm.role_code IN ('owner', 'admin')
  ) THEN
    RAISE EXCEPTION 'Only an active tenant owner or admin can change shared evidence settings';
  END IF;

  IF NOT private.has_tenant_feature(p_tenant_id, 'module.buying') THEN
    RAISE EXCEPTION 'Buying is not enabled for this subscription';
  END IF;

  UPDATE public.tenants
     SET settings = coalesce(settings, '{}'::jsonb)
                    || jsonb_build_object('use_shared_evidence', coalesce(p_enabled, true)),
         updated_at = now()
   WHERE id = p_tenant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tenant not found';
  END IF;

  RETURN jsonb_build_object('use_shared_evidence', coalesce(p_enabled, true));
END;
$function$;

REVOKE ALL ON FUNCTION public.subscriber_set_shared_evidence_preference(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.subscriber_set_shared_evidence_preference(uuid, boolean) TO authenticated;
