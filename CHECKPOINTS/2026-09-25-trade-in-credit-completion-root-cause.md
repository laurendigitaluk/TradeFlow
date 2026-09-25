# TradeFlow Checkpoint — 25 September 2026 — Trade-in credit completion root cause fixed

## Test Two item
- Tenant: Camerashack
- Buying item: 374a6789-72c7-4f01-a448-e97e54c13528
- Customer: 7b5d034f-519d-4edb-bfff-5aa920649163
- Accepted initial offer: trade-in, £55.00

## Intended post-inspection decision
After a passed inspection the subscriber can:
1. Pay the accepted cash offer to the customer's bank, when the accepted mode is cash.
2. Add the accepted trade-in amount to the customer's credit account, when the accepted mode is trade-in.
3. Refuse the item.
4. Send a revised final offer only when the inspected value has changed.

## Root cause
The UI correctly called subscriber_credit_trade_in, and the customer credit account already existed. The RPC was failing at the ledger insert with PostgreSQL SQLSTATE 23514 (check constraint violation). The function attempted to insert ledger entry type trade_in_credit, but ledger_entries_entry_type_check only permits sale, purchase, refund, expense, fee, adjustment, payment, and other.

The earlier unique customer-account constraint was necessary for the RPC's ON CONFLICT (tenant_id, customer_id) clause, but it was not the reason the live action continued to fail. The actual blocking failure was the invalid ledger entry type.

## Repair
subscriber_credit_trade_in now records the customer-account credit as:
- entry_type = adjustment
- direction = credit
- status = posted

The existing customer credit account remains one account per tenant/customer, protected by a unique index on (tenant_id, customer_id).

## Live verification
The repaired RPC was executed under the subscriber's authenticated identity against the Test Two item and completed successfully.

Verified final state:
- buying item: purchased
- customer credit balance: £55.00
- trade-in transaction: credited
- ledger: adjustment / credit / posted / £55.00
- acquisition: completed
- inventory: ready_for_sale

## Code/migration
- Live database migration: fix_trade_in_credit_ledger_entry_type
- GitHub migration: supabase/migrations/20260925213000_fix_trade_in_credit_ledger_entry_type.sql
- Unique account migration: supabase/migrations/20260925201500_add_customer_credit_account_unique_constraint.sql

This checkpoint records the verified root cause and completed Test Two transition. Do not rebuild or alter the earlier valuation, offer, shipping, receipt, or inspection stages when continuing from here.
