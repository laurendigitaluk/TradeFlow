# LIVE explicit deny policies for 14 locked tables — 2026-10-13

Environment: LIVE Supabase `gxsrajtqzdjvmceqcpgv`. TEST `twfbmjwwqzxdxvclxbun` untouched.

Applied migration `20261013201345_explicit_deny_policies_for_locked_tables_20261013` to add a policy named `deny_direct_client_access` on each previously policy-free RLS table:
- `assistant_conversations`
- `assistant_messages`
- `catalogue_master_branches`
- `catalogue_master_categories`
- `catalogue_master_manufacturers`
- `catalogue_master_product_identifiers`
- `catalogue_master_products`
- `customer_bank_details`
- `customer_credit_accounts`
- `customer_credit_holds`
- `payment_provider_events`
- `platform_ai_settings`
- `platform_owner_domain_actions`
- `tenant_catalogue_state`

Each policy is `FOR ALL TO anon, authenticated USING (false) WITH CHECK (false)`. This makes the intended deny-all boundary explicit; it does not grant read access. Direct table grants remain absent. Verification confirms all 14 policies and false predicates. Supabase advisor no longer reports the RLS-enabled/no-policy warning. Existing controlled SECURITY DEFINER RPCs continue under table-owner context because these tables are not FORCE RLS. No records changed; TEST untouched.
