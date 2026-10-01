-- TradeFlow storage buckets shared by TEST and LIVE.
-- Keep customer/acquisition media private; published site media is public.
insert into storage.buckets (id, name, public)
values
  ('tradeflow-media', 'tradeflow-media', false),
  ('tradeflow-site-media', 'tradeflow-site-media', true)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;