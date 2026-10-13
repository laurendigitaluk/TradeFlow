# LIVE purchase completion and security checkpoint — 2026-10-13

## Environment and safety
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- TEST Supabase: `twfbmjwwqzxdxvclxbun` — untouched by writes.
- Existing transaction records have not been changed by this repair.

## Repair applied
- Reconciled `public.subscriber_complete_purchase(uuid, uuid, text, text, text)` from the deployed LIVE function into `supabase/migrations/20261013183319_fix_purchase_completion_ledger_and_timestamps_20261013.sql`.
- Function enforces authenticated subscriber permissions for buying, finance, acquisitions and inventory; accepted cash offer only; bank details required; placeholder payment references rejected; creates payment/acquisition/acquisition-item/inventory/ledger/notification atomically; sets lifecycle timestamps; transitions acquisition and item from paid to completed via the guarded workflow RPC.
- Revoked direct `anon` and `authenticated` table privileges on `public.customer_credit_accounts`; access should remain through tenant-/identity-checked RPCs.
- The database function was read back from LIVE after the fix. Direct credit-account grants were rechecked and are now absent.

## Existing test transaction — deliberately not rewritten
- Acquisition: `ACQ-10F8FFABBC12`, payment amount £70.00.
- Current record still has reference `test`, status `paid`, no linked ledger entry, and null `completed_at`; inventory is `ready_for_sale` but `ready_for_sale_at` is null.
- Because the reference is a placeholder and no external bank-transfer confirmation is available, do not fabricate an accounting entry or assert a genuine transfer. Handle as test data only after explicit confirmation, or verify a real transfer and record its actual reference.

## Remaining security work
- Supabase advisor still lists 14 RLS-enabled/no-policy tables, 8 anonymous-executable SECURITY DEFINER functions and `pg_net` in `public`.
- `customer_credit_accounts` had broad direct grants despite having no RLS policies; those grants have been revoked.
- The remaining public SECURITY DEFINER warnings require per-function output review; current candidates are public catalogue, published-site/listing/media and public-plan functions. Do not bulk-revoke without confirming public-site behaviour.
- No broad policies were added. No TEST data or customer/payment records were modified.

## Acceptance criteria before next test
1. Verify production source/migration file aligns with the LIVE deployed definition and migrations history.
2. In a controlled follow-up purchase, use genuine customer bank details and a non-placeholder payment reference only after the subscriber has actually sent payment.
3. Confirm payment, acquisition, acquisition item, ledger, inventory and notification are linked to the same tenant and item.
4. Confirm acquisition/item status and completion timestamps, plus `inventory_assets.ready_for_sale_at`, are populated consistently.
5. Confirm customer portal status matches the backend and no bank details or private credit data are exposed through direct table access.
6. Re-run security advisor and record which warnings are intentionally public versus needing remediation.
