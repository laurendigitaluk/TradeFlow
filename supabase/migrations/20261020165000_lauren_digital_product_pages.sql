-- Lauren Digital parent-brand product pages.
-- Public visitors can read published copy; only authenticated platform owners can edit via RPC.
create table if not exists public.platform_product_pages (
  slug text primary key check (slug in ('tradeflow','studioflow','businessflow')),
  product_name text not null,
  status text not null default 'published' check (status in ('published','coming_soon','hidden')),
  headline text not null,
  tagline text not null default '',
  description text not null default '',
  button_label text not null default 'Learn more',
  button_url text not null default '',
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

alter table public.platform_product_pages enable row level security;
revoke all on public.platform_product_pages from anon, authenticated;
grant select on public.platform_product_pages to anon, authenticated;
drop policy if exists platform_product_pages_public_published_read on public.platform_product_pages;
create policy platform_product_pages_public_published_read
  on public.platform_product_pages for select to anon, authenticated
  using (status <> 'hidden');

insert into public.platform_product_pages
(slug,product_name,status,headline,tagline,description,button_label,button_url)
values
('tradeflow','TradeFlow','published','Your buy and sell business. Built your way.','Buying, inventory, selling and customer workflows in one connected platform.','TradeFlow gives buy-and-sell businesses tools for valuations, buying workflows, inventory, sales and customer-facing websites.','Visit TradeFlow','https://tradeflow.laurendigital.co.uk/'),
('studioflow','StudioFlow','coming_soon','A clearer way to run your creative studio.','StudioFlow is in development.','A planned platform for studio and creative-business workflows. Features and launch details will be shared when they are ready.','View StudioFlow','/studioflow'),
('businessflow','BusinessFlow','coming_soon','Practical digital tools for your business.','A future Lauren Digital product concept.','BusinessFlow is a provisional concept for broader business workflows. Its name, scope and availability may change as the product family develops.','View BusinessFlow','/businessflow')
on conflict (slug) do nothing;

create or replace function public.platform_owner_get_product_pages()
returns setof public.platform_product_pages
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Active platform owner access required';
  end if;
  return query select * from public.platform_product_pages order by
    case slug when 'tradeflow' then 1 when 'studioflow' then 2 else 3 end;
end;
$$;

create or replace function public.platform_owner_update_product_page(
  p_slug text,
  p_product_name text,
  p_status text,
  p_headline text,
  p_tagline text,
  p_description text,
  p_button_label text,
  p_button_url text
)
returns public.platform_product_pages
language plpgsql
security definer
set search_path = public, auth
as $$
declare result_row public.platform_product_pages;
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Active platform owner access required';
  end if;
  if p_slug not in ('tradeflow','studioflow','businessflow') then
    raise exception 'Unknown product page';
  end if;
  if p_status not in ('published','coming_soon','hidden') then
    raise exception 'Invalid product status';
  end if;
  if length(trim(coalesce(p_product_name,''))) not between 1 and 80
     or length(trim(coalesce(p_headline,''))) not between 1 and 180
     or length(coalesce(p_tagline,'')) > 300
     or length(coalesce(p_description,'')) > 2000
     or length(coalesce(p_button_label,'')) > 80
     or length(coalesce(p_button_url,'')) > 500 then
    raise exception 'One or more fields exceed the allowed length or are empty';
  end if;
  update public.platform_product_pages
  set product_name=trim(p_product_name), status=p_status,
      headline=trim(p_headline), tagline=coalesce(p_tagline,''),
      description=coalesce(p_description,''), button_label=coalesce(p_button_label,''),
      button_url=coalesce(p_button_url,''), updated_at=now(), updated_by=auth.uid()
  where slug=p_slug returning * into result_row;
  if not found then raise exception 'Product page not found'; end if;
  return result_row;
end;
$$;

revoke execute on function public.platform_owner_get_product_pages() from public, anon;
revoke execute on function public.platform_owner_update_product_page(text,text,text,text,text,text,text,text) from public, anon;
grant execute on function public.platform_owner_get_product_pages() to authenticated;
grant execute on function public.platform_owner_update_product_page(text,text,text,text,text,text,text,text) to authenticated;
