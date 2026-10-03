-- Website Builder draft revisions are edited by authenticated tenant members.
-- RLS remains authoritative; this grant only supplies the underlying table privilege
-- required for the existing site_revisions_manage_update policy to evaluate.
grant update on table public.site_revisions to authenticated;