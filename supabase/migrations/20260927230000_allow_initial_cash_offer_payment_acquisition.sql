create or replace function public.guard_acquisition_creation_boundary()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $function$
declare
  v_offer record;
  v_payment_id uuid;
begin
  if new.status <> 'paid' and new.status <> 'completed' then
    raise exception 'Acquisition has an invalid completion status';
  end if;

  if new.paid_at is null then
    raise exception 'Acquisition must have a completion timestamp';
  end if;

  if new.source_offer_id is null then
    raise exception 'Acquisition must reference the accepted offer';
  end if;

  select o.id,o.offer_type,o.status,o.offer_mode,o.buying_item_id,o.amount,o.currency
    into v_offer
  from public.offers o
  where o.tenant_id=new.tenant_id
    and o.id=new.source_offer_id;

  if v_offer.id is null or v_offer.status <> 'accepted' then
    raise exception 'Acquisition source must be an accepted offer';
  end if;

  if new.metadata->>'source'='trade_in_credit' then
    if v_offer.offer_type <> 'initial' or v_offer.offer_mode <> 'trade_in' then
      raise exception 'Trade-in credit acquisition must reference the accepted initial trade-in offer';
    end if;
    return new;
  end if;

  if new.status <> 'paid' or v_offer.offer_mode <> 'cash' then
    raise exception 'Cash acquisitions require a paid cash offer and payment';
  end if;

  select p.id into v_payment_id
  from public.payment_records p
  where p.tenant_id=new.tenant_id
    and p.status='paid'
    and p.direction='outbound'
    and p.customer_id=new.customer_id
    and p.amount=new.payment_total
    and p.acquisition_id is null
    and (
      p.metadata->>'final_offer_id'=new.source_offer_id::text
      or p.metadata->>'offer_id'=new.source_offer_id::text
    )
  order by p.processed_at desc nulls last,p.created_at desc
  limit 1;

  if v_payment_id is null then
    raise exception 'Acquisition requires a recorded bank payment for the accepted cash offer';
  end if;

  return new;
end;
$function$;
