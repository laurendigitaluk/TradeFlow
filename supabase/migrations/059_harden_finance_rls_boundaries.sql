-- TradeFlow migration 059: harden finance access boundaries.
-- Finance has explicit view/manage permissions but no separate module.finance
-- capability in the current feature catalogue. Use the permission boundary
-- directly rather than inventing a new subscription capability.

drop policy if exists payment_records_insert_members on public.payment_records;
drop policy if exists payment_records_select_members on public.payment_records;
drop policy if exists payment_records_update_admins on public.payment_records;
drop policy if exists payment_records_delete_admins on public.payment_records;

drop policy if exists ledger_entries_insert_members on public.ledger_entries;
drop policy if exists ledger_entries_select_members on public.ledger_entries;
drop policy if exists ledger_entries_update_admins on public.ledger_entries;
drop policy if exists ledger_entries_delete_admins on public.ledger_entries;

create policy payment_records_finance_select on public.payment_records
for select to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.view'));

create policy payment_records_finance_insert on public.payment_records
for insert to authenticated
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'));

create policy payment_records_finance_update on public.payment_records
for update to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'))
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'));

create policy payment_records_finance_delete on public.payment_records
for delete to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'));

create policy ledger_entries_finance_select on public.ledger_entries
for select to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.view'));

create policy ledger_entries_finance_insert on public.ledger_entries
for insert to authenticated
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'));

create policy ledger_entries_finance_update on public.ledger_entries
for update to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'))
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'));

create policy ledger_entries_finance_delete on public.ledger_entries
for delete to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'));
