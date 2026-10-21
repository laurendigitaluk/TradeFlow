-- The Website Builder saves an existing draft revision with PATCH.
-- Grant the authenticated role the table privilege required for the existing
-- site_revisions_manage_update RLS policy to enforce tenant and draft access.
GRANT UPDATE ON TABLE public.site_revisions TO authenticated;
