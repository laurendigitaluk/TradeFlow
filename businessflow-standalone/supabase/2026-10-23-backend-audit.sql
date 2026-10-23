-- Read-only BusinessFlow backend audit.
-- Run in the BusinessFlow project's Supabase SQL Editor only.
-- This script does not modify data or schema.
select c.table_schema, c.table_name, c.column_name, c.data_type, c.is_nullable, c.column_default
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name in ('businessflow_sites', 'businessflow_pages')
order by c.table_name, c.ordinal_position;

select t.relname as table_name, t.relrowsecurity as row_level_security_enabled,
       t.relforcerowsecurity as row_level_security_forced
from pg_class t
join pg_namespace n on n.oid = t.relnamespace
where n.nspname = 'public'
  and t.relname in ('businessflow_sites', 'businessflow_pages')
order by t.relname;

select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('businessflow_sites', 'businessflow_pages')
order by tablename, policyname;

select b.id as bucket_id, b.name, b.public, b.file_size_limit, b.allowed_mime_types
from storage.buckets b
where b.id = 'businessflow-assets';

select policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and policyname ilike '%BusinessFlow%'
order by policyname;
