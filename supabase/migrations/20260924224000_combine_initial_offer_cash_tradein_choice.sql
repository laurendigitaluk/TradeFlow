create or replace function public.customer_get_offer_choices(p_tenant_id uuid)
returns table(
  offer_id uuid,
  buying_item_id uuid,
  trading_value_id uuid,
  offer_reference text,
  offer_type text,
  offer_mode text,
  status text,
  amount numeric,
  cash_amount numeric,
  trade_in_amount numeric,
  currency text,
  expires_at timestamptz,
  published_at timestamptz,
  responded_at timestamptz,
  response_notes text
)
language plpgsql
stable
security definer
set search_path=pg_catalog,public
as $$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  return query
  select
    o.id,o.buying_item_id,o.trading_value_id,o.offer_reference,o.offer_type,o.offer_mode,
    o.status,o.amount,tv.cash_price,tv.trade_in_price,o.currency,o.expires_at,
    o.published_at,o.responded_at,o.response_notes
  from public.offers o
  join public.buying_items i on i.tenant_id=o.tenant_id and i.id=o.buying_item_id
  join public.buying_requests r on r.tenant_id=i.tenant_id and r.id=i.buying_request_id
  join public.customers c on c.tenant_id=r.tenant_id and c.id=r.customer_id
  left join public.trading_values tv on tv.tenant_id=o.tenant_id and tv.id=o.trading_value_id
  where o.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by o.created_at desc;
end;
$$;

revoke all on function public.customer_get_offer_choices(uuid) from public, anon;
grant execute on function public.customer_get_offer_choices(uuid) to authenticated;

create or replace function public.customer_accept_offer_choice(
  p_tenant_id uuid,
  p_offer_id uuid,
  p_offer_mode text,
  p_response_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path=pg_catalog,public
as $$
declare
  v_customer_id uuid; v_item_id uuid; v_offer_type text; v_offer_status text;
  v_offer_mode text; v_offer_amount numeric; v_cash_amount numeric; v_trade_amount numeric;
  v_expires_at timestamptz; v_item_stage text; v_other record;
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_offer_mode not in ('cash','trade_in') then raise exception 'Invalid offer choice'; end if;
  v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;

  select o.buying_item_id,o.offer_type,o.offer_mode,o.status,o.amount,o.expires_at,
         tv.cash_price,tv.trade_in_price
  into v_item_id,v_offer_type,v_offer_mode,v_offer_status,v_offer_amount,v_expires_at,
       v_cash_amount,v_trade_amount
  from public.offers o
  join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  left join public.trading_values tv on tv.tenant_id=o.tenant_id and tv.id=o.trading_value_id
  where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id
  for update of o;

  if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
  if v_offer_status<>'published' then raise exception 'offer is not available for acceptance'; end if;
  if v_expires_at is not null and v_expires_at<=now() then raise exception 'offer has expired'; end if;

  if v_offer_type in ('initial','revised') then
    v_offer_amount:=case when p_offer_mode='cash' then v_cash_amount else v_trade_amount end;
    if v_offer_amount is null then raise exception 'The selected offer option is not available'; end if;
    v_offer_mode:=p_offer_mode;
  else
    v_offer_mode:=coalesce(v_offer_mode,'cash');
  end if;

  select purchase_stage into v_item_stage
  from public.buying_items where tenant_id=p_tenant_id and id=v_item_id for update;

  update public.offers set status='accepted',amount=v_offer_amount,offer_mode=v_offer_mode,
    responded_at=now(),response_notes=p_response_notes,updated_at=now()
  where tenant_id=p_tenant_id and id=p_offer_id;

  insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,amount,notes,actor_user_id)
  values(p_tenant_id,p_offer_id,'accepted','published','accepted',v_offer_amount,p_response_notes,auth.uid());

  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'offer',p_offer_id,'published','accepted',auth.uid(),p_response_notes,
         jsonb_build_object('source','customer_action','offer_mode',v_offer_mode));

  if v_offer_type in ('initial','revised') then
    if v_item_stage not in ('offer_ready','none','final_offer_refused') then
      raise exception 'This item is not available to begin the receipt workflow';
    end if;
    for v_other in
      select id from public.offers
      where tenant_id=p_tenant_id and buying_item_id=v_item_id and id<>p_offer_id
        and offer_type in ('initial','revised') and status='published'
      order by created_at
    loop
      perform public.transition_workflow_entity(
        p_tenant_id,'offer',v_other.id,'published','superseded',
        'Superseded because the customer accepted the combined offer.',
        jsonb_build_object('source','customer_action','accepted_offer_id',p_offer_id)
      );
    end loop;
    update public.buying_items set purchase_stage='awaiting_item',
      purchase_stage_updated_at=now(),updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  elsif v_offer_type='final' then
    if v_item_stage<>'final_offer_sent' then raise exception 'Final offer cannot be accepted at the current purchase stage'; end if;
    update public.buying_items set purchase_stage='final_offer_accepted',
      final_offer_accepted_at=now(),purchase_stage_updated_at=now(),updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  else
    raise exception 'Unsupported offer type for purchase workflow';
  end if;
  return null;
end;
$$;

revoke all on function public.customer_accept_offer_choice(uuid,uuid,text,text) from public, anon;
grant execute on function public.customer_accept_offer_choice(uuid,uuid,text,text) to authenticated;
