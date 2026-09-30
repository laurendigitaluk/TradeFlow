revoke all on function public.set_updated_at() from public, anon, authenticated;
comment on function public.set_updated_at() is 'Internal trigger helper; not callable by client roles.';
