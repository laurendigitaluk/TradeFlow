-- TradeFlow migration 056: harden acquisition boundaries and prevent duplicate
-- acquisitions from the same source offer.
--
-- The acquisition tables retained older broad tenant-member policies alongside
-- subscription-aware permission policies. Those permissive policies could grant
-- access without acquisitions.view/manage + module.buying. Remove them so the
-- subscription-aware policies are the effective client boundary.
--
-- A source offer represents one accepted commercial offer. Enforce one acquisition
-- per tenant/source offer at database level so direct inserts cannot create a
-- duplicate acquisition outside the customer acceptance RPC.

drop policy if exists acquisitions_insert_members on public.acquisitions;
drop policy if exists acquisitions_select_members on public.acquisitions;
drop policy if exists acquisitions_update_members on public.acquisitions;
drop policy if exists acquisitions_delete_admins on public.acquisitions;

drop policy if exists acquisition_items_insert_members on public.acquisition_items;
drop policy if exists acquisition_items_select_members on public.acquisition_items;
drop policy if exists acquisition_items_update_members on public.acquisition_items;
drop policy if exists acquisition_items_delete_admins on public.acquisition_items;

create unique index if not exists acquisitions_one_per_source_offer
  on public.acquisitions (tenant_id, source_offer_id)
  where source_offer_id is not null;
