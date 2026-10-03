-- TradeFlow master catalogue snapshot metadata. System-owned catalogue only; no tenant/customer data.
insert into public.catalogue_master_categories(name,slug,active,sort_order) values
 on conflict (slug) do update set name=excluded.name,active=excluded.active,sort_order=excluded.sort_order;

insert into public.catalogue_master_manufacturers(name,active) values
 on conflict (name) do update set active=excluded.active;

with data(category_slug,name,slug,active,sort_order) as (values
) insert into public.catalogue_master_branches(category_id,name,slug,active,sort_order)
select c.id,d.name,d.slug,d.active,d.sort_order from data d join public.catalogue_master_categories c on c.slug=d.category_slug
on conflict (category_id,slug) do update set name=excluded.name,active=excluded.active,sort_order=excluded.sort_order;
