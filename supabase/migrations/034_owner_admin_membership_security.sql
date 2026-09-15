-- TradeFlow 034: close the membership role-escalation surface before owner/admin testing.
-- Direct authenticated membership mutation is disabled. Future membership changes
-- must use tightly scoped authorization RPCs.

REVOKE INSERT, UPDATE, DELETE ON TABLE public.tenant_memberships FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.tenant_memberships FROM anon;

CREATE OR REPLACE FUNCTION public.admin_complete_test_registration(p_tenant_slug text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_tenant_id uuid;
  v_membership_id uuid;
  v_email text;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF p_tenant_slug NOT IN ('test-business-a','test-business-b') THEN
    RAISE EXCEPTION 'Test tenant not permitted';
  END IF;

  SELECT email INTO v_email
  FROM auth.users
  WHERE id = v_uid
    AND email_confirmed_at IS NOT NULL;

  IF v_email IS NULL THEN
    RAISE EXCEPTION 'Confirmed email required';
  END IF;

  SELECT id INTO v_tenant_id
  FROM public.tenants
  WHERE slug = p_tenant_slug
    AND is_active = true;

  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Test tenant not found';
  END IF;

  IF EXISTS (SELECT 1 FROM public.customers WHERE auth_user_id = v_uid) THEN
    RAISE EXCEPTION 'Auth account is already linked to a customer';
  END IF;

  IF EXISTS (SELECT 1 FROM public.tenant_memberships WHERE user_id = v_uid) THEN
    RAISE EXCEPTION 'Auth account already has a tenant membership';
  END IF;

  INSERT INTO public.tenant_memberships (tenant_id, user_id, role_code, status)
  VALUES (v_tenant_id, v_uid, 'admin', 'active')
  RETURNING id INTO v_membership_id;

  RETURN v_membership_id;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_complete_test_registration(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.admin_complete_test_registration(text) FROM anon;
GRANT EXECUTE ON FUNCTION public.admin_complete_test_registration(text) TO authenticated;

COMMENT ON FUNCTION public.admin_complete_test_registration(text) IS
'TEMPORARY TEST-LAB ONLY. Creates one Admin membership for confirmed auth users in marked TradeFlow test tenants. Must be removed before production onboarding.';
