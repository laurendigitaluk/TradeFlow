-- Ensure subscriber Returns can read rows through the Data API.
-- RLS remains the authorization boundary; the existing returns_subscription_select
-- policy restricts rows by tenant permission and enabled module.
grant select on table public.returns to authenticated;
