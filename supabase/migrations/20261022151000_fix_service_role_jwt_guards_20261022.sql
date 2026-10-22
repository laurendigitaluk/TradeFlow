-- Fix service-role guards in SECURITY DEFINER RPCs.
-- current_user resolves to the function owner (postgres) inside these functions,
-- so it cannot identify the calling PostgREST JWT role. auth.role() reads the
-- request's verified JWT role claim while preserving service_role-only grants.

CREATE OR REPLACE FUNCTION public.notification_processor_auth_secret()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
BEGIN
  IF coalesce(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'Not authorised';
  END IF;

  RETURN (
    SELECT decrypted_secret
    FROM vault.decrypted_secrets
    WHERE name = 'tradeflow_notification_processor_secret'
    LIMIT 1
  );
END
$function$;

REVOKE ALL ON FUNCTION public.notification_processor_auth_secret() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.notification_processor_auth_secret() TO service_role;

CREATE OR REPLACE FUNCTION public.shipping_provider_credentials_for_service(p_connection_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'private', 'vault'
AS $function$
DECLARE
  v_secret text;
BEGIN
  IF coalesce(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'Not authorised';
  END IF;

  SELECT ds.decrypted_secret
    INTO v_secret
  FROM vault.decrypted_secrets ds
  JOIN public.shipping_provider_connections c
    ON c.credentials_vault_id = ds.id
  WHERE c.id = p_connection_id;

  IF v_secret IS NULL THEN
    RAISE EXCEPTION 'Provider credentials not found';
  END IF;

  RETURN v_secret::jsonb;
END
$function$;

REVOKE ALL ON FUNCTION public.shipping_provider_credentials_for_service(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.shipping_provider_credentials_for_service(uuid) TO service_role;
