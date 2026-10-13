-- Subscriber domain RPCs operate on authenticated tenant membership only.
-- The function bodies independently verify auth.uid(), membership and website.manage.
revoke execute on function public.subscriber_get_my_tenant_slug(uuid) from public, anon;
grant execute on function public.subscriber_get_my_tenant_slug(uuid) to authenticated;

revoke execute on function public.subscriber_request_custom_domain(text) from public, anon;
grant execute on function public.subscriber_request_custom_domain(text) to authenticated;
