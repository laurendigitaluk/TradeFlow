-- Repair the service-only shipping credential reader.
-- The reader is SECURITY DEFINER, so current_user is its definer rather than the
-- JWT role. Authorize the intended service-role caller from the request JWT.
create or replace function public.shipping_provider_secret_for_service(p_connection_id uuid)
returns text
language plpgsql
security definer
set search_path=public,private,vault
as $$
declare
  v_secret text;
begin
  if coalesce(current_setting('request.jwt.claim.role', true),'') <> 'service_role' then
    raise exception 'Not authorised';
  end if;

  select ds.decrypted_secret into v_secret
  from vault.decrypted_secrets ds
  join public.shipping_provider_connections c
    on c.api_client_secret_vault_id=ds.id
  where c.id=p_connection_id;

  if v_secret is null then
    raise exception 'Provider credential not found';
  end if;

  return v_secret;
end
$$;

revoke execute on function public.shipping_provider_secret_for_service(uuid) from public, anon, authenticated;
grant execute on function public.shipping_provider_secret_for_service(uuid) to service_role;