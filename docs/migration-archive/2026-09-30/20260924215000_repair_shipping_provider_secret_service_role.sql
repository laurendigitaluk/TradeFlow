-- TradeFlow shipping provider secret reader.
-- Only service_role may execute this function. The SECURITY DEFINER function
-- reads the matching Vault secret without exposing it to browser roles.
create or replace function public.shipping_provider_secret_for_service(p_connection_id uuid)
returns text
language plpgsql
security definer
set search_path=public,private,vault
as $$
declare
  v_secret text;
begin
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