-- Keep the Gemma owner dashboard focused on work that still needs attention.
-- Completed/rejected records remain in the database for audit and recovery.

drop function if exists public.platform_owner_list_ai_agent_tasks(integer);

create function public.platform_owner_list_ai_agent_tasks(
  p_limit integer default 50,
  p_status text default 'active'
)
returns jsonb
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Platform owner access required';
  end if;

  if p_status is not null and p_status not in (
    'active', 'queued', 'running', 'failed', 'completed', 'cancelled', 'all'
  ) then
    raise exception 'Invalid AI agent task status';
  end if;

  return coalesce((
    select jsonb_agg(to_jsonb(t) order by t.created_at desc)
    from (
      select *
      from public.platform_ai_agent_tasks
      where
        p_status is null
        or p_status = 'all'
        or (p_status = 'active' and status in ('queued', 'running', 'failed'))
        or status = p_status
      order by created_at desc
      limit greatest(1, least(coalesce(p_limit, 50), 200))
    ) t
  ), '[]'::jsonb);
end;
$function$;

revoke all on function public.platform_owner_list_ai_agent_tasks(integer, text) from public, anon;
grant execute on function public.platform_owner_list_ai_agent_tasks(integer, text) to authenticated;

create or replace function public.platform_owner_list_catalogue_research_queue(
  p_status text default 'open',
  p_limit integer default 100
)
returns jsonb
language plpgsql
security definer
set search_path to 'public', 'private'
as $function$
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Platform owner access required';
  end if;

  if p_status is not null and p_status not in (
    'open', 'completed', 'pending_review', 'needs_research', 'approved', 'rejected', 'imported', 'all'
  ) then
    raise exception 'Invalid queue status';
  end if;

  return coalesce((
    select jsonb_agg(to_jsonb(q) order by q.created_at desc)
    from (
      select *
      from public.platform_catalogue_research_queue
      where
        p_status is null
        or p_status = 'all'
        or (p_status = 'open' and status in ('pending_review', 'needs_research', 'approved'))
        or (p_status = 'completed' and status in ('imported', 'rejected'))
        or status = p_status
      order by created_at desc
      limit greatest(1, least(coalesce(p_limit, 100), 200))
    ) q
  ), '[]'::jsonb);
end;
$function$;

revoke all on function public.platform_owner_list_catalogue_research_queue(text, integer) from public, anon;
grant execute on function public.platform_owner_list_catalogue_research_queue(text, integer) to authenticated;
