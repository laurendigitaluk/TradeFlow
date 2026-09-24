create or replace function public.subscriber_connect_shipping_provider(
  p_tenant_id uuid,
  p_provider text,
  p_environment text,
  p_api_client_id text,
  p_api_client_secret text
)
returns jsonb
language plpgsql
security definer
set search_path=public,private,vault
as $$
declare
  v_secret_id uuid;
  v_connection_id uuid;
  v_secret_name text := 'tradeflow_shipping_'||p_tenant_id::text||'_'||p_provider;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'tenant.manage') then
    raise exception 'Not authorised';
  end if;
  if p_provider <> 'parcel2go' then
    raise exception 'This connection flow currently supports Parcel2Go only';
  end if;
  if p_environment not in ('sandbox','live') then
    raise exception 'Invalid environment';
  end if;
  if coalesce(trim(p_api_client_id),'')='' or coalesce(trim(p_api_client_secret),'')='' then
    raise exception 'API client ID and secret are required';
  end if;

  select id,api_client_secret_vault_id
    into v_connection_id,v_secret_id
    from public.shipping_provider_connections
   where tenant_id=p_tenant_id and provider=p_provider;

  if v_secret_id is null then
    select id into v_secret_id
      from vault.secrets
     where name=v_secret_name
     limit 1;
  end if;

  if v_secret_id is null then
    v_secret_id:=vault.create_secret(
      p_api_client_secret,
      v_secret_name,
      'TradeFlow shipping provider credential'
    );
  else
    perform vault.update_secret(
      v_secret_id,
      p_api_client_secret,
      v_secret_name,
      'TradeFlow shipping provider credential'
    );
  end if;

  insert into public.shipping_provider_connections(
    tenant_id,provider,status,connection_type,api_client_id,
    api_client_secret_vault_id,credentials_vault_id,environment,
    auth_mode,updated_at
  )
  values(
    p_tenant_id,p_provider,'pending','subscriber_account',trim(p_api_client_id),
    v_secret_id,v_secret_id,p_environment,'client_credentials',now()
  )
  on conflict(tenant_id,provider) do update set
    status='pending',
    api_client_id=excluded.api_client_id,
    api_client_secret_vault_id=excluded.api_client_secret_vault_id,
    credentials_vault_id=excluded.credentials_vault_id,
    environment=excluded.environment,
    auth_mode=excluded.auth_mode,
    connected_at=null,
    disconnected_at=null,
    last_tested_at=null,
    updated_at=now()
  returning id into v_connection_id;

  return jsonb_build_object('ok',true,'connection_id',v_connection_id,'status','pending');
end
$$;

revoke execute on function public.subscriber_connect_shipping_provider(uuid,text,text,text,text) from anon;
grant execute on function public.subscriber_connect_shipping_provider(uuid,text,text,text,text) to authenticated;