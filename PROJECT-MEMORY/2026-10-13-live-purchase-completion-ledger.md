# Project Memory — LIVE purchase completion repair — 2026-10-13

Read-only investigation of LIVE project `gxsrajtqzdjvmceqcpgv` found the purchase completion RPC created paid payment/acquisition/acquisition-item/inventory rows but omitted the ledger entry and several lifecycle timestamps. Acquisition and acquisition item remained `paid`, with null `completed_at`; inventory was `ready_for_sale` with null `ready_for_sale_at`; acquisition/item `received_at` were null despite the source buying item having a received timestamp.

Existing transaction ACQ-10F8FFABBC12 (£70 GBP, payment reference `test`) was not modified. Its payment is a manual subscriber-entered paid record, not externally verified by a provider transaction ID. No LIVE data was changed during investigation.

Proposed isolated branch: `fix/live-purchase-completion-ledger-20261013`. Proposed migration: `supabase/migrations/20261013195000_fix_purchase_completion_ledger_and_timestamps.sql`. It adds a linked purchase ledger entry, populates timestamps, calls the existing guarded transition RPC to complete acquisition and item, and revokes anon execution on four platform-owner-only RPCs. Do not apply until the SQL has been reviewed. TEST remains untouched. After merge/application, validate a fresh controlled purchase and rerun security advisors.
