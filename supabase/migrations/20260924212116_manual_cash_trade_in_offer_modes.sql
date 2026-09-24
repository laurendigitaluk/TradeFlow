alter table public.offers
  add column if not exists offer_mode text not null default 'cash';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname='offers_offer_mode_check'
      and conrelid='public.offers'::regclass
  ) then
    alter table public.offers
      add constraint offers_offer_mode_check
      check (offer_mode in ('cash','trade_in'));
  end if;
end $$;
