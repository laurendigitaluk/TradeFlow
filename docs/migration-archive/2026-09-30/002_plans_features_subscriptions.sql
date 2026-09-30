create table public.plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.plan_features (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans(id) on delete cascade,
  feature_code text not null,
  enabled boolean not null default true,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plan_id, feature_code)
);

create table public.tenant_subscriptions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  plan_id uuid not null references public.plans(id) on delete restrict,
  status text not null default 'trialing' check (status in ('trialing','active','past_due','paused','cancelled','expired')),
  billing_provider text check (billing_provider is null or billing_provider in ('stripe','manual','other')),
  provider_customer_id text,
  provider_subscription_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  trial_end timestamptz,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index tenant_subscriptions_one_current_idx
on public.tenant_subscriptions (tenant_id)
where status in ('trialing','active','past_due','paused');

create unique index tenant_subscriptions_provider_subscription_idx
on public.tenant_subscriptions (billing_provider, provider_subscription_id)
where provider_subscription_id is not null;

create index tenant_subscriptions_tenant_idx on public.tenant_subscriptions (tenant_id);
create index tenant_subscriptions_plan_idx on public.tenant_subscriptions (plan_id);

create trigger plans_set_updated_at
before update on public.plans
for each row execute function public.set_updated_at();

create trigger plan_features_set_updated_at
before update on public.plan_features
for each row execute function public.set_updated_at();

create trigger tenant_subscriptions_set_updated_at
before update on public.tenant_subscriptions
for each row execute function public.set_updated_at();

alter table public.plans enable row level security;
alter table public.plan_features enable row level security;
alter table public.tenant_subscriptions enable row level security;

create policy plans_select_active
on public.plans
for select
to anon, authenticated
using (active = true);

create policy plan_features_select_active_plans
on public.plan_features
for select
to anon, authenticated
using (
  exists (
    select 1 from public.plans p
    where p.id = plan_id and p.active = true
  )
);

create policy subscriptions_select_admins
on public.tenant_subscriptions
for select
to authenticated
using (private.is_tenant_admin(tenant_id));

create policy subscriptions_insert_admins
on public.tenant_subscriptions
for insert
to authenticated
with check (private.is_tenant_admin(tenant_id));

create policy subscriptions_update_admins
on public.tenant_subscriptions
for update
to authenticated
using (private.is_tenant_admin(tenant_id))
with check (private.is_tenant_admin(tenant_id));

create policy subscriptions_delete_admins
on public.tenant_subscriptions
for delete
to authenticated
using (private.is_tenant_admin(tenant_id));

comment on table public.plans is 'TradeFlow subscription plans; platform configuration, not tenant-owned data.';
comment on table public.plan_features is 'Capability definitions attached to TradeFlow subscription plans.';
comment on table public.tenant_subscriptions is 'Tenant billing/subscription state; restricted to tenant owners and administrators.';
