-- Explicit default-deny policies for platform marketing page drafts.
drop policy if exists platform_public_pages_deny_anon on public.platform_public_pages;
drop policy if exists platform_public_pages_deny_authenticated on public.platform_public_pages;
create policy platform_public_pages_deny_anon
on public.platform_public_pages for all to anon
using (false) with check (false);
create policy platform_public_pages_deny_authenticated
on public.platform_public_pages for all to authenticated
using (false) with check (false);
