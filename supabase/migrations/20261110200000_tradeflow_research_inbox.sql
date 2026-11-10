-- TradeFlow prompt-driven research inbox for LM Studio Bionic.
-- Reports are staged for independent review; this migration does not modify catalogue/evidence rows.
create table if not exists public.platform_research_reports (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(trim(title)) between 1 and 200),
  prompt text not null check (char_length(trim(prompt)) between 1 and 20000),
  category_slug text,
  source_app text not null default 'LM Studio Bionic',
  model_name text,
  status text not null default 'submitted_for_review'
    check (status in ('submitted_for_review','in_review','approved','rejected','imported')),
  report_markdown text not null,
  report_json jsonb not null default '{}'::jsonb,
  finding_count integer not null default 0 check (finding_count >= 0),
  source_count integer not null default 0 check (source_count >= 0),
  storage_markdown_path text,
  storage_json_path text,
  metadata jsonb not null default '{}'::jsonb,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid,
  review_notes text,
  imported_at timestamptz
);
create index if not exists platform_research_reports_status_submitted_idx
  on public.platform_research_reports(status, submitted_at desc);
create index if not exists platform_research_reports_category_idx
  on public.platform_research_reports(category_slug, submitted_at desc);
alter table public.platform_research_reports enable row level security;
revoke all on table public.platform_research_reports from public, anon, authenticated;
grant all on table public.platform_research_reports to service_role;

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values (
 'tradeflow-research-inbox',
 'tradeflow-research-inbox',
 false,
 20971520,
 array['text/markdown','text/plain','application/json']
)
on conflict (id) do nothing;
