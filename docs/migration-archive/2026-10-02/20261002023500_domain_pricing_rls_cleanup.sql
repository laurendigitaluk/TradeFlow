-- TradeFlow domain pricing RLS cleanup
-- Applied to TEST/STAGING on 2026-10-02.
-- Keep a single owner-only ALL policy to avoid duplicate permissive policies
-- and wrap the owner predicate in SELECT for better RLS planning.
drop policy if exists platform_domain_pricing_owner_read on public.platform_domain_pricing_settings;
drop policy if exists platform_domain_pricing_owner_write on public.platform_domain_pricing_settings;

create policy platform_domain_pricing_owner_all
  on public.platform_domain_pricing_settings
  for all to authenticated
  using ((select private.is_platform_owner(auth.uid())))
  with check ((select private.is_platform_owner(auth.uid())));
