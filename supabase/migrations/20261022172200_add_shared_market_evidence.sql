create table if not exists public.shared_market_evidence (
  id uuid primary key default gen_random_uuid(),
  master_product_id uuid not null references public.catalogue_master_products(id) on delete restrict,
  evidence_type text not null check (evidence_type in ('uk_new','uk_used','overseas')),
  source_name text not null,
  source_url text,
  observed_price numeric(12,2) not null check (observed_price >= 0),
  price_currency text not null default 'GBP' check (char_length(price_currency)=3),
  item_condition text,
  sales_channel text,
  availability text,
  observed_at timestamptz,
  notes text,
  is_active boolean not null default true,
  source_record_key text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (source_name, source_record_key)
);

create index if not exists shared_market_evidence_product_type_date_idx
  on public.shared_market_evidence (master_product_id, evidence_type, observed_at desc)
  where is_active;
create index if not exists shared_market_evidence_source_url_idx
  on public.shared_market_evidence (source_url)
  where source_url is not null;

alter table public.shared_market_evidence enable row level security;

drop policy if exists shared_market_evidence_read_active on public.shared_market_evidence;
create policy shared_market_evidence_read_active
  on public.shared_market_evidence for select to authenticated
  using (is_active);

drop policy if exists shared_market_evidence_client_write_deny on public.shared_market_evidence;
create policy shared_market_evidence_client_write_deny
  on public.shared_market_evidence for all to anon, authenticated
  using (false) with check (false);

comment on table public.shared_market_evidence is
  'Platform-managed shared market evidence. Subscriber research remains private in tenant_buying_research; writes must use trusted server-side ingestion.';
