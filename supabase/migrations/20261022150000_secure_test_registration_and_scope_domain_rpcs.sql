-- LIVE security hardening: test-lab registration guards and explicit tenant scoping for domain RPCs.
-- Legacy RPC signatures remain as safe wrappers for single-tenant subscribers.
-- No customer, catalogue, valuation, pricing, or transaction data is changed.

CREATE OR REPLACE FUNCTION public.admin_complete_test_registration(p_tenant_slug text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_tenant_id uuid;
  v_membership_id uuid;
  v_email text;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  IF p_tenant_slug NOT IN ('test-business-a','test-business-b') THEN
    RAISE EXCEPTION 'Test tenant not permitted';
  END IF;
  SELECT email INTO v_email
  FROM auth.users
  WHERE id=v_uid AND email_confirmed_at IS NOT NULL;
  IF v_email IS NULL THEN RAISE EXCEPTION 'Confirmed email required'; END IF;
  SELECT id INTO v_tenant_id
  FROM public.tenants
  WHERE slug=p_tenant_slug
    AND status='active'
    AND lower(coalesce(settings->>'test_lab','false'))='true';
  IF v_tenant_id IS NULL THEN RAISE EXCEPTION 'Test tenant not found'; END IF;
  IF EXISTS (SELECT 1 FROM public.customers WHERE auth_user_id=v_uid) THEN
    RAISE EXCEPTION 'Auth account is already linked to a customer';
  END IF;
  IF EXISTS (SELECT 1 FROM public.tenant_memberships WHERE user_id=v_uid) THEN
    RAISE EXCEPTION 'Auth account already has a tenant membership';
  END IF;
  INSERT INTO public.tenant_memberships (tenant_id,user_id,role_code,status)
  VALUES (v_tenant_id,v_uid,'admin','active')
  RETURNING id INTO v_membership_id;
  RETURN v_membership_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.staff_complete_test_registration(p_tenant_slug text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_tenant_id uuid;
  v_membership_id uuid;
  v_email_confirmed boolean;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  IF p_tenant_slug NOT IN ('test-business-a','test-business-b') THEN
    RAISE EXCEPTION 'Test tenant only';
  END IF;
  SELECT email_confirmed_at IS NOT NULL INTO v_email_confirmed
  FROM auth.users WHERE id=v_uid;
  IF coalesce(v_email_confirmed,false)=false THEN
    RAISE EXCEPTION 'Email confirmation is required before staff registration';
  END IF;
  SELECT id INTO v_tenant_id
  FROM public.tenants
  WHERE slug=p_tenant_slug
    AND status='active'
    AND lower(coalesce(settings->>'test_lab','false'))='true';
  IF v_tenant_id IS NULL THEN RAISE EXCEPTION 'Test tenant not found'; END IF;
  IF EXISTS (SELECT 1 FROM public.customers WHERE auth_user_id=v_uid) THEN
    RAISE EXCEPTION 'This Auth account is already registered as a customer';
  END IF;
  IF EXISTS (SELECT 1 FROM public.tenant_memberships WHERE user_id=v_uid) THEN
    RAISE EXCEPTION 'This Auth account already has a tenant membership';
  END IF;
  INSERT INTO public.tenant_memberships (tenant_id,user_id,role_code,status,joined_at)
  VALUES (v_tenant_id,v_uid,'staff','active',now())
  RETURNING id INTO v_membership_id;
  RETURN v_membership_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.subscriber_get_custom_domain_status(p_tenant_id uuid)
RETURNS TABLE(
  action_id uuid,
  tenant_domain_id uuid,
  hostname text,
  domain_status text,
  status text,
  notes text,
  metadata jsonb,
  created_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  IF p_tenant_id IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.tenant_memberships tm
    JOIN public.tenants t ON t.id=tm.tenant_id
    WHERE tm.tenant_id=p_tenant_id
      AND tm.user_id=v_user_id
      AND tm.status='active'
      AND t.status='active'
  ) THEN
    RAISE EXCEPTION 'Active membership for the selected tenant is required';
  END IF;
  IF NOT private.has_tenant_permission(p_tenant_id,v_user_id,'website.manage') THEN
    RAISE EXCEPTION 'Website domain management is not permitted for this tenant';
  END IF;
  RETURN QUERY
  SELECT a.id,d.id,d.hostname,d.status,a.status,a.notes,a.metadata,a.created_at
  FROM public.platform_owner_domain_actions a
  JOIN public.tenant_domains d ON d.id=a.tenant_domain_id AND d.tenant_id=p_tenant_id
  WHERE a.tenant_id=p_tenant_id
  ORDER BY a.created_at DESC
  LIMIT 1;
END;
$function$;

CREATE OR REPLACE FUNCTION public.subscriber_get_custom_domain_status()
RETURNS TABLE(
  action_id uuid,
  tenant_domain_id uuid,
  hostname text,
  domain_status text,
  status text,
  notes text,
  metadata jsonb,
  created_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
DECLARE
  v_user_id uuid := auth.uid();
  v_tenant_id uuid;
  v_tenant_count integer;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT count(DISTINCT tm.tenant_id), min(tm.tenant_id::text)::uuid
    INTO v_tenant_count, v_tenant_id
  FROM public.tenant_memberships tm
  JOIN public.tenants t ON t.id=tm.tenant_id
  WHERE tm.user_id=v_user_id AND tm.status='active' AND t.status='active';
  IF coalesce(v_tenant_count,0)=0 THEN RETURN; END IF;
  IF v_tenant_count>1 THEN
    RAISE EXCEPTION 'Multiple active businesses found. Refresh the page and select a business.';
  END IF;
  RETURN QUERY SELECT * FROM public.subscriber_get_custom_domain_status(v_tenant_id);
END;
$function$;

CREATE OR REPLACE FUNCTION public.subscriber_request_custom_domain(
  p_tenant_id uuid,
  p_hostname text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
DECLARE
  v_user_id uuid := auth.uid();
  v_hostname text;
  v_domain public.tenant_domains%rowtype;
  v_action public.platform_owner_domain_actions%rowtype;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  IF p_tenant_id IS NULL OR NOT EXISTS (
    SELECT 1
    FROM public.tenant_memberships tm
    JOIN public.tenants t ON t.id=tm.tenant_id
    WHERE tm.tenant_id=p_tenant_id
      AND tm.user_id=v_user_id
      AND tm.status='active'
      AND t.status='active'
  ) THEN
    RAISE EXCEPTION 'Active membership for the selected tenant is required';
  END IF;
  IF NOT private.has_tenant_permission(p_tenant_id,v_user_id,'website.manage') THEN
    RAISE EXCEPTION 'Website domain management is not permitted for this tenant';
  END IF;

  v_hostname := lower(trim(coalesce(p_hostname,'')));
  v_hostname := regexp_replace(v_hostname,'^https?://','');
  v_hostname := split_part(v_hostname,'/',1);
  v_hostname := regexp_replace(v_hostname,'[.]$','');
  IF v_hostname !~ '^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?([.][a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)+$' THEN
    RAISE EXCEPTION 'Enter a valid domain name';
  END IF;

  SELECT * INTO v_domain FROM public.tenant_domains WHERE hostname=v_hostname LIMIT 1;
  IF FOUND AND v_domain.tenant_id<>p_tenant_id THEN
    RAISE EXCEPTION 'That domain is already connected to another TradeFlow business';
  END IF;

  IF FOUND THEN
    UPDATE public.tenant_domains
    SET domain_type='custom',
        status='pending',
        is_primary=true,
        verification_token=coalesce(verification_token,gen_random_uuid()::text),
        acquisition_source='connected',
        registrar_provider=null,
        registrar_domain_id=null,
        registered_at=null,
        expires_at=null,
        auto_renew=false,
        provider_metadata='{}'::jsonb,
        metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object('source','subscriber_domain_settings'),
        updated_at=now()
    WHERE id=v_domain.id
    RETURNING * INTO v_domain;
  ELSE
    UPDATE public.tenant_domains
    SET is_primary=false
    WHERE tenant_id=p_tenant_id AND is_primary=true AND status<>'disabled';
    INSERT INTO public.tenant_domains (
      tenant_id,hostname,domain_type,status,is_primary,verification_token,
      metadata,acquisition_source,auto_renew
    )
    VALUES (
      p_tenant_id,v_hostname,'custom','pending',true,gen_random_uuid()::text,
      jsonb_build_object('source','subscriber_domain_settings'),'connected',false
    )
    RETURNING * INTO v_domain;
  END IF;

  INSERT INTO public.platform_owner_domain_actions(tenant_id,tenant_domain_id,status,metadata)
  VALUES (
    p_tenant_id,v_domain.id,'requested',
    jsonb_build_object('requested_by',v_user_id,'hostname',v_hostname)
  )
  ON CONFLICT (tenant_domain_id) WHERE status NOT IN ('active','verification_failed')
  DO UPDATE SET updated_at=now(),status='requested'
  RETURNING * INTO v_action;

  RETURN jsonb_build_object(
    'domain_id',v_domain.id,
    'hostname',v_domain.hostname,
    'status',v_domain.status,
    'is_primary',v_domain.is_primary,
    'action_id',v_action.id,
    'action_status',v_action.status
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.subscriber_request_custom_domain(p_hostname text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
DECLARE
  v_user_id uuid := auth.uid();
  v_tenant_id uuid;
  v_tenant_count integer;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  SELECT count(DISTINCT tm.tenant_id), min(tm.tenant_id::text)::uuid
    INTO v_tenant_count, v_tenant_id
  FROM public.tenant_memberships tm
  JOIN public.tenants t ON t.id=tm.tenant_id
  WHERE tm.user_id=v_user_id AND tm.status='active' AND t.status='active';
  IF coalesce(v_tenant_count,0)=0 THEN
    RAISE EXCEPTION 'Active subscriber membership required';
  END IF;
  IF v_tenant_count>1 THEN
    RAISE EXCEPTION 'Multiple active businesses found. Refresh the page and select a business.';
  END IF;
  RETURN public.subscriber_request_custom_domain(v_tenant_id,p_hostname);
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.subscriber_get_custom_domain_status(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.subscriber_request_custom_domain(uuid,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.subscriber_get_custom_domain_status(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.subscriber_request_custom_domain(uuid,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.subscriber_get_custom_domain_status() TO authenticated;
GRANT EXECUTE ON FUNCTION public.subscriber_request_custom_domain(text) TO authenticated;
