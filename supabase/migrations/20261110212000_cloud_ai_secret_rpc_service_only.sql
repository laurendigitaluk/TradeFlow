create or replace function public.get_cloud_ai_provider_secret(p_provider_key text)
returns text language sql stable security definer set search_path=public,vault
as $$
 select ds.decrypted_secret
 from public.platform_cloud_ai_providers p
 join vault.decrypted_secrets ds on ds.id=p.secret_id
 where p.provider_key=p_provider_key and p.enabled=true and p.free_tier_confirmed=true
 limit 1;
$$;
revoke all on function public.get_cloud_ai_provider_secret(text) from public,anon,authenticated;
grant execute on function public.get_cloud_ai_provider_secret(text) to service_role;
