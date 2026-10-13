# LIVE private helper ACL hardening — 2026-10-13

- LIVE project: `gxsrajtqzdjvmceqcpgv`; TEST untouched.
- Applied and verified `20261013200946_revoke_anon_private_helper_function_execute_20261013`.
- Revoked EXECUTE from PUBLIC/anon on `private.is_active_tenant(uuid)`, `private.platform_admin_list_subscriber_accounts()`, `private.platform_admin_manage_subscription(uuid,text,text)`, and `private.queue_buying_request_received_notification()`.
- Verified anon EXECUTE is false on all four. The private schema has no anon USAGE; helper calls from SECURITY DEFINER functions continue under owner context.
- No table data or payment/customer records changed.
- Source migration and manuals are in the isolated PR for merge to production.
