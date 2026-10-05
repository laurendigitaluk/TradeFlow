grant select, insert, update on table public.platform_domain_pricing_settings to authenticated;
grant select, insert, update, delete, references, trigger, truncate on table public.platform_domain_pricing_settings to service_role;
notify pgrst, 'reload schema';
