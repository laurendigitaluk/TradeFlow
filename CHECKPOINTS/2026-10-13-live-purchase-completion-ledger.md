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
PR #126 was merged to production at `708dba463a2aa67ac1d8acbf9c59fd8f8806b407`. Migration `fix_purchase_completion_ledger_and_timestamps_20261013` was applied successfully to LIVE (recorded version `20261013183319`). Read-only checks confirmed the function contains the ledger insert, guarded completion transitions and placeholder-reference rejection; the four platform-owner-only RPCs now deny anon while allowing authenticated callers. Existing ACQ-10F8FFABBC12 remains untouched. A fresh controlled purchase-flow test remains pending.


## Security follow-up — 13 October 2026
A second branch `fix/restrict-subscriber-domain-rpcs-20261013` contains migration `supabase/migrations/20261013200000_restrict_subscriber_domain_rpcs.sql`, removing PUBLIC/anon execute from `subscriber_get_my_tenant_slug(uuid)` and `subscriber_request_custom_domain(text)` while retaining authenticated execute. PR #127 was merged and migration `restrict_subscriber_domain_rpcs_20261013` applied successfully to LIVE (version `20261013183455`). Read-only checks confirm anon execution is false and authenticated execution is true for both functions.


## Security follow-up — 13 October 2026
PR #127 was merged and migration `restrict_subscriber_domain_rpcs_20261013` applied to LIVE. Permission checks confirm `subscriber_get_my_tenant_slug(uuid)` and `subscriber_request_custom_domain(text)` are no longer executable by anon and remain executable by authenticated users. The remaining 8 anon-executable SECURITY DEFINER functions are the public catalogue, published-site/listing/media, and plan endpoints; their output boundaries should be reviewed, not blanket-revoked.
