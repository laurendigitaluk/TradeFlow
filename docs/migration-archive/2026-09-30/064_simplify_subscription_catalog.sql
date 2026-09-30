-- TradeFlow subscription catalogue simplification
-- Applied live: 2026-09-18
-- Active customer-facing plans are now exactly Basic and Enhanced.
-- Basic = the complete operational Buy & Sell core.
-- Enhanced = Basic plus every current advanced/add-on capability.
-- Legacy Buying/Selling/Buy & Sell/Business/Advanced plans remain inactive
-- so historical subscription references remain auditable.

insert into public.plans(code,name,description,active,sort_order)
values
('basic','Basic','Core Buy & Sell workspace with buying, selling, inventory, orders, customer portal, valuation, fulfilment, trade-in and website tools.',true,10),
('enhanced','Enhanced','Basic plus staff management, staff messaging, audit, analytics, integrations and market intelligence.',true,20)
on conflict (code) do update
set name=excluded.name,description=excluded.description,active=true,sort_order=excluded.sort_order,updated_at=now();

insert into public.plan_features(plan_id,feature_code,enabled,config)
select (select id from public.plans where code='basic'),x.feature_code,true,x.config
from (
 select distinct on (pf.feature_code) pf.feature_code,pf.config
 from public.plan_features pf
 join public.plans old on old.id=pf.plan_id
 where old.code='buy_sell'
 order by pf.feature_code,pf.updated_at desc
) x
on conflict (plan_id,feature_code) do update set enabled=true,config=excluded.config,updated_at=now();

insert into public.plan_features(plan_id,feature_code,enabled,config)
select (select id from public.plans where code='enhanced'),x.feature_code,true,x.config
from (
 select distinct on (pf.feature_code) pf.feature_code,pf.config
 from public.plan_features pf
 join public.plans old on old.id=pf.plan_id
 where old.code in ('buy_sell','business','advanced')
 order by pf.feature_code,pf.updated_at desc
) x
on conflict (plan_id,feature_code) do update set enabled=true,config=excluded.config,updated_at=now();

update public.tenant_subscriptions
set plan_id=case
  when tenant_id='50641519-2aa5-4093-95e5-7e92bea733a6'
    then (select id from public.plans where code='enhanced')
  else (select id from public.plans where code='basic')
end,
updated_at=now()
where status in ('trialing','active','past_due');

update public.plans
set active=false,updated_at=now()
where code in ('buying','selling','buy_sell','business','advanced');
