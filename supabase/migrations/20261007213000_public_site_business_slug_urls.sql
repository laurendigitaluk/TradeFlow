create or replace function public.get_published_site_by_slug(p_slug text)
returns table(
  tenant_id uuid,
  tenant_name text,
  tenant_slug text,
  revision_number integer,
  content jsonb,
  published_at timestamptz
)
language sql
stable
security definer
set search_path to 'pg_catalog','public'
as $function$
  select
    t.id,
    t.name,
    t.slug,
    sr.revision_number,
    sr.content,
    sr.published_at
  from public.tenants t
  join public.tenant_site_state ts
    on ts.tenant_id=t.id
  join public.site_revisions sr
    on sr.id=ts.published_revision_id
   and sr.tenant_id=ts.tenant_id
   and sr.status='published'
  where t.status='active'
    and lower(t.slug)=lower(trim(p_slug))
  limit 1;
$function$;

grant execute on function public.get_published_site_by_slug(text) to anon, authenticated;

create or replace function public.subscriber_get_my_tenant_slug(p_tenant_id uuid)
returns text
language sql
stable
security definer
set search_path to 'pg_catalog','public'
as $function$
  select t.slug
  from public.tenants t
  join public.tenant_memberships tm
    on tm.tenant_id=t.id
  where t.id=p_tenant_id
    and t.status='active'
    and tm.user_id=auth.uid()
    and tm.status='active'
  limit 1;
$function$;

grant execute on function public.subscriber_get_my_tenant_slug(uuid) to authenticated;

update public.tenants
set slug='adventure-outpost'
where id='b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52'
  and slug='adventure-outpost-f8c8c4ea';
