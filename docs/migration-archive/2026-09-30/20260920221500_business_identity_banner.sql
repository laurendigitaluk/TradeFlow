-- Add an authoritative business website banner alongside the existing business logo.
alter table public.tenant_public_profiles
  add column if not exists banner_url text;
