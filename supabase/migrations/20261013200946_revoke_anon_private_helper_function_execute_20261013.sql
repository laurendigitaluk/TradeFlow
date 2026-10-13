-- Private-schema helpers are called by owner-context SECURITY DEFINER functions, not directly by client roles.
-- The private schema has no USAGE for anon; remove latent EXECUTE grants as defense in depth.
REVOKE EXECUTE ON FUNCTION private.is_active_tenant(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION private.platform_admin_list_subscriber_accounts() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION private.platform_admin_manage_subscription(uuid, text, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION private.queue_buying_request_received_notification() FROM PUBLIC, anon;
