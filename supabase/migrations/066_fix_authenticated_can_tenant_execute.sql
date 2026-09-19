-- Restore the EXECUTE privilege required by authenticated RLS policies.
-- The function remains SECURITY DEFINER and continues to enforce tenant permission/feature checks.
grant execute on function private.can_tenant(uuid,text,text) to authenticated;
