-- Explicitly deny direct anon/authenticated access to intentionally RPC-only tables.
-- Do not add tenant read policies here: customer bank/credit/payment and internal AI/domain data
-- must remain accessible only through the existing controlled RPCs or trusted service role.
DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'assistant_conversations',
    'assistant_messages',
    'catalogue_master_branches',
    'catalogue_master_categories',
    'catalogue_master_manufacturers',
    'catalogue_master_product_identifiers',
    'catalogue_master_products',
    'customer_bank_details',
    'customer_credit_accounts',
    'customer_credit_holds',
    'payment_provider_events',
    'platform_ai_settings',
    'platform_owner_domain_actions',
    'tenant_catalogue_state'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', 'deny_direct_client_access', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL TO anon, authenticated USING (false) WITH CHECK (false)',
      'deny_direct_client_access', t
    );
  END LOOP;
END $$;
