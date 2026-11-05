-- Central platform-managed catalogue research review queue.
-- Gemma writes candidate records with the local service role. Platform owners
-- review through the owner-only RPCs or the connected ChatGPT/Supabase workflow.
create table if not exists public.platform_catalogue_research_queue (
  id uuid primary key default gen_random_uuid(),
  record_type text not null check (record_type in ('product_candidate','release_candidate','evidence_candidate')),
  status text not null default 'pending_review'
    check (status in ('pending_review','needs_research','approved','rejected','imported')),
  dedupe_key text not null unique,
  agent_name text not null,
  task_key text,
  category_slug text,
  branch_slug text,
  manufacturer text not null,
  model text not null,
  package_key text,
  package_name text,
  release_status text check (release_status is null or release_status in ('rumoured','announced','preorder','released','available','discontinued','replaced','update')),
  release_date date,
  evidence_type text check (evidence_type is null or evidence_type in ('uk_new','uk_used')),
  source_name text,
  source_url text,
  observed_price numeric(12,2) check (observed_price is null or observed_price > 0),
  price_currency text check (price_currency is null or price_currency = 'GBP'),
  item_condition text,
  sales_channel text,
  availability text,
  source_record_key text,
  source_excerpt text,
  research_notes text,
  raw_payload jsonb not null default '{}'::jsonb,
  review_notes text,
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  approved_at timestamptz,
  imported_at timestamptz,
  test_master_product_id uuid,
  live_master_product_id uuid,
  test_evidence_id uuid,
  live_evidence_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists platform_catalogue_research_queue_status_created_idx
  on public.platform_catalogue_research_queue(status, created_at desc);
create index if not exists platform_catalogue_research_queue_model_idx
  on public.platform_catalogue_research_queue(manufacturer, model);
create index if not exists platform_catalogue_research_queue_type_status_idx
  on public.platform_catalogue_research_queue(record_type, status, created_at desc);

alter table public.platform_catalogue_research_queue enable row level security;
revoke all on public.platform_catalogue_research_queue from anon, authenticated;

create or replace function public.platform_owner_list_catalogue_research_queue(
  p_status text default 'pending_review',
  p_limit integer default 100
) returns jsonb
language plpgsql security definer
set search_path=public,private
as $$
declare result jsonb;
begin
  if not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then raise exception 'Platform owner access required'; end if;
  if p_status is not null and p_status not in ('pending_review','needs_research','approved','rejected','imported','all') then
    raise exception 'Invalid queue status';
  end if;
  select coalesce(jsonb_agg(to_jsonb(q) order by q.created_at desc), '[]'::jsonb)
    into result
    from (
      select * from public.platform_catalogue_research_queue
      where p_status is null or p_status='all' or status=p_status
      order by created_at desc
      limit greatest(1,least(coalesce(p_limit,100),200))
    ) q;
  return result;
end;
$$;

create or replace function public.platform_owner_review_catalogue_research_item(
  p_id uuid,
  p_decision text,
  p_notes text default null
) returns jsonb
language plpgsql security definer
set search_path=public,private
as $$
declare result public.platform_catalogue_research_queue;
begin
  if not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then raise exception 'Platform owner access required'; end if;
  if p_decision not in ('approved','rejected','needs_research') then
    raise exception 'Invalid review decision';
  end if;
  update public.platform_catalogue_research_queue
     set status=p_decision,
         review_notes=nullif(trim(p_notes),''),
         reviewed_by=auth.uid(),
         reviewed_at=now(),
         approved_at=case when p_decision='approved' then now() else null end,
         updated_at=now()
   where id=p_id and status in ('pending_review','needs_research')
   returning * into result;
  if not found then raise exception 'Queue item not found or no longer reviewable'; end if;
  return to_jsonb(result);
end;
$$;

revoke all on function public.platform_owner_list_catalogue_research_queue(text,integer) from public,anon;
revoke all on function public.platform_owner_review_catalogue_research_item(uuid,text,text) from public,anon;
grant execute on function public.platform_owner_list_catalogue_research_queue(text,integer) to authenticated;
grant execute on function public.platform_owner_review_catalogue_research_item(uuid,text,text) to authenticated;
