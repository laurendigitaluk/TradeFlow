-- Keep the legacy shared-evidence preference helpers aligned with the canonical top-level tenant setting.
-- This filename matches the migration version already recorded in TEST.
-- The subscriber settings page and catalogue RPCs read settings.use_shared_evidence.
CREATE OR REPLACE FUNCTION public.set_tenant_shared_evidence_preference(p_use_shared_evidence boolean)
RETURNS boolean
LANGUAGE plpgsql
SET search_path TO ''
AS $function$
DECLARE
  v_tenant_id uuid;
  v_membership_count integer;
BEGIN
  SELECT count(*), min(tm.tenant_id::text)::uuid
    INTO v_membership_count, v_tenant_id
  FROM public.tenant_memberships tm
  WHERE tm.user_id = auth.uid()
    AND tm.status = 'active';

  IF v_membership_count <> 1 OR v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Expected exactly one active tenant membership for this account';
  END IF;

  UPDATE public.tenants t
     SET settings = coalesce(t.settings, '{}'::jsonb)
                   || jsonb_build_object('use_shared_evidence', p_use_shared_evidence),
         updated_at = now()
   WHERE t.id = v_tenant_id
     AND EXISTS (
       SELECT 1
       FROM public.tenant_memberships tm
       WHERE tm.tenant_id = t.id
         AND tm.user_id = auth.uid()
         AND tm.status = 'active'
         AND tm.role_code IN ('owner', 'admin')
     );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Only an active tenant owner or admin can change this preference';
  END IF;

  RETURN true;
END;
$function$;

CREATE OR REPLACE FUNCTION public.tenant_uses_shared_evidence(p_tenant_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path TO ''
AS $function$
  SELECT coalesce((t.settings ->> 'use_shared_evidence')::boolean, true)
  FROM public.tenants t
  WHERE t.id = p_tenant_id
$function$;

REVOKE ALL ON FUNCTION public.set_tenant_shared_evidence_preference(boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_tenant_shared_evidence_preference(boolean) TO authenticated;
REVOKE ALL ON FUNCTION public.tenant_uses_shared_evidence(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.tenant_uses_shared_evidence(uuid) TO authenticated, service_role;
