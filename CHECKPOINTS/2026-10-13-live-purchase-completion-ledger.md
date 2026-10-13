# LIVE Purchase Completion and Ledger Repair — 13 October 2026

## Scope
- Environment: LIVE Supabase `gxsrajtqzdjvmceqcpgv`; GitHub `production`.
- TEST project `twfbmjwwqzxdxvclxbun` is reference-only and was not accessed or changed for this repair.
- Existing test transaction was inspected read-only and was not altered.

## Verified existing discrepancy
The LIVE `subscriber_complete_purchase(uuid,uuid,text,text,text)` function recorded a paid payment, acquisition and acquisition item, and created inventory. It did not create a ledger entry, did not populate acquisition/item `received_at`, left inventory `ready_for_sale_at` null, and left acquisition/item status `paid` with `completed_at` null even though the customer UI presented Complete.

The existing transaction is ACQ-10F8FFABBC12 for £70 GBP. Its payment reference is `test`; that is a manually entered reference and is not independent proof of a bank transfer. No provider payment ID exists. Existing data was not edited.

## Proposed code migration
`20261013195000_fix_purchase_completion_ledger_and_timestamps.sql`:
- Requires buying, finance, acquisition and inventory permissions before completing the purchase.
- Keeps the accepted cash-offer, customer bank-details and non-empty manual reference checks.
- Records manual confirmation mode explicitly.
- Populates received/finalised/paid timestamps and inventory ready-for-sale timestamp.
- Creates a posted outbound purchase ledger entry linked to payment, acquisition, inventory and customer.
- Uses the existing guarded workflow transition RPC for acquisition and acquisition-item paid -> completed, creating workflow history and completed timestamps.
- Revokes anonymous execution from four platform-owner-only domain management RPCs while preserving authenticated calls and their internal platform-owner checks.

## Release status
The migration is a proposed change on an isolated branch and is not applied to LIVE yet. Before applying, inspect the migration and verify SQL syntax/function signatures. Then apply to LIVE, run read-only catalog/permission checks and validate a fresh controlled purchase flow. Do not retroactively modify ACQ-10F8FFABBC12 without a separate explicit reconciliation step.
