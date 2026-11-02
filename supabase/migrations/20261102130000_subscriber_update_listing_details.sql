-- Tenant-authorised listing editor write boundary.
-- Keep direct authenticated UPDATE on public.listings revoked; never change listing status here.
create or replace function public.subscriber_update_listing_details(
  p_tenant_id uuid,
  p_listing_id uuid,
  p_title text,
  p_description text,
  p_asking_price numeric,
  p_currency text,
  p_listing_data jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_listing_id uuid;
  v_status text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'selling.manage')
     or not private.has_tenant_feature(p_tenant_id, 'module.selling') then
    raise exception 'Selling management permission required';
  end if;

  if nullif(trim(p_title), '') is null or length(trim(p_title)) > 200 then
    raise exception 'Enter a listing title of 1 to 200 characters';
  end if;
  if p_asking_price is null or p_asking_price < 0 then
    raise exception 'Enter a valid asking price';
  end if;
  if p_currency is null or p_currency !~ '^[A-Z]{3}$' then
    raise exception 'Enter a valid three-letter currency code';
  end if;

  update public.listings l
     set title = trim(p_title),
         description = nullif(trim(coalesce(p_description, '')), ''),
         asking_price = p_asking_price,
         currency = p_currency,
         listing_data = coalesce(p_listing_data, '{}'::jsonb),
         updated_at = now()
   where l.id = p_listing_id
     and l.tenant_id = p_tenant_id
     and l.status not in ('sold', 'delisted')
  returning l.id, l.status into v_listing_id, v_status;

  if v_listing_id is null then
    raise exception 'Editable listing not found for this business';
  end if;

  return jsonb_build_object('ok', true, 'listing_id', v_listing_id, 'status', v_status);
end;
$function$;

revoke all on function public.subscriber_update_listing_details(uuid, uuid, text, text, numeric, text, jsonb) from public, anon;
grant execute on function public.subscriber_update_listing_details(uuid, uuid, text, text, numeric, text, jsonb) to authenticated;
