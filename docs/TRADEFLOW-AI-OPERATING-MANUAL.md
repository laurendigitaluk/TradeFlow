# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 1.5  
**Date:** 16 September 2026  
**Project:** TradeFlow

## 1. Purpose
This is the AI continuity companion to the TradeFlow System Handbook. It records architectural truth, decisions, faults, lessons, verification state and the exact stopping point so future sessions can resume without guessing.

## 2. Mandatory procedure
For significant work:

**Retrieve → inspect current GitHub → inspect current Supabase → identify the first actual failure/boundary → change minimally → test → verify live → document → checkpoint.**

Never rely on chat memory when current code/database state can be inspected. Never modify GearCashOut while working on TradeFlow.

## 3. Non-negotiable rules
- `tenant_id` is the primary security boundary.
- Tenant roles are exactly `owner`, `admin`, `staff`.
- Platform Owner is separate from tenant roles and cannot be self-claimed.
- Subscription capabilities belong to the tenant.
- Customer data must remain tenant-isolated.
- Dynamic fields/options are database-authoritative.
- Business status changes must use authoritative workflow services/RPCs where provided.
- Accepting an offer is not possession; acquisition, receipt, inspection, payment and inventory are separate lifecycle steps.
- Do not assume a schema FK means an operational workflow exists.
- Do not mark a feature complete solely because code is committed.
- Do not expose test-lab onboarding as production onboarding.
- Never store secrets in docs or project memory.

## 4. Verification states
**Proposed → Implemented → Tested → Verified Live** are separate states. A commit is not live verification. A transactional rollback test proves database behaviour, not a persistent browser journey.

## 5. Current environment checkpoint
- GitHub: `laurendigitaluk/TradeFlow`, `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, `eu-west-2`.
- Recorded health: ACTIVE_HEALTHY.
- Recorded public-table RLS checkpoint: 60/60.
- Customer security: 34/34.
- Customer subscription tests: Buying 17/17; Selling 17/17.
- Staff security lab: 19/19.
- Platform Owner foundation: 044–045.
- Platform-admin privileged path: 046–048; final browser regression remains open.
- Buying hardening: 049–051.
- Valuation/Offer hardening: 052–055.
- Acquisition hardening: 056–057.
- Inventory hardening: 058.
- Finance/payment hardening: 059.

## 6. Production onboarding remains OPEN
The development foundation still contains an authenticated tenant insert path with `with check (true)` and temporary test-lab onboarding. Required production sequence remains:

**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## 7. Buying / valuation / offer checkpoints
049 made dynamic option validation authoritative. 050 made Buying request/item transitions authoritative. 051 records customer submission workflow events.

052 removed broad valuation RLS and enforced valuation permission + module capability. 053 removed broad offer/event RLS. 054 binds an offer to a valuation for the same tenant and same buying item. 055 protects valuation/offer state entry and requires an approved same-item valuation for published offers.

Buying, valuation and offers remain **BLUE / partial** because persistent browser/live business journeys remain incomplete even though the relevant database boundaries have been repaired and inspected.

## 8. Acquisition checkpoint — 056–057
056 hardened acquisition access and source-offer uniqueness. 057 added status-entry guards so authorised client roles cannot bypass `transition_workflow_entity` by directly changing acquisition status.

Allowed lifecycle remains:
```text
accepted → awaiting_item → received → inspection → finalised → paid → completed
                         ↘ cancelled
```

Verification state: **Implemented + live database inspected**. Full authenticated browser transition testing remains open.

## 9. Acquisition → Finance → Inventory operational position
The schema contains tenant-scoped relationships between acquisitions, acquisition items, payments, ledger entries and inventory assets. These relationships do not by themselves create records.

Current implementation deliberately treats the handoff as explicit operational work:
1. Offer acceptance creates the acquisition and acquisition item.
2. Acquisition workspace advances receipt/inspection/finalisation/payment/completion states through the central workflow authority.
3. Inventory creation is an explicit action against an acquisition item; it is not assumed to happen merely because an acquisition reaches a status.
4. Finance records are explicit payment and ledger records associated with acquisitions and/or inventory.

No automatic status-driven creation of inventory, payment or ledger records has been established as a business rule.

## 10. Inventory hardening — 058
Migration 058 removed broad legacy inventory member/admin policies and retained permission/subscription-aware access. `inventory_assets` status entry is protected by `guard_inventory_asset_status_entry()` so direct client-role status changes cannot bypass `transition_workflow_entity()`.

Inventory lifecycle:
```text
received → inspection → testing → repair → ready_for_sale → listed → reserved → sold
                                                               ↘ returned
```

The dedicated Inventory workspace lists/filter assets, edits non-status asset details and routes lifecycle changes through the workflow authority. It is implemented but not yet browser-verified live.

## 11. Finance hardening and operational UI
Migration 059 removed broad finance policies and recreated permission-bound policies for `payment_records` and `ledger_entries` using the existing `finance.view` / `finance.manage` permissions. No `module.finance` feature is to be invented.

The Finance workspace now reads tenant-scoped payment and ledger records, creates new payment/ledger records in `pending` state, and routes payment/ledger status changes through `transition_workflow_entity()` rather than direct status mutation.

Payment states include pending, processing, paid, failed, cancelled, refunded and partially_refunded. Ledger states include pending, posted, voided and reversed.

No automatic ledger creation or payment creation is inferred from acquisition status. Reconciliation rules remain a later workflow concern.

## 12. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**. Never invent a connection to fill a documentation gap.

## 13. Manual UI testing
One manual security/UI test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 14. Change-control record
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

## 15. Memory/checkpoint rule
TradeFlow's live database must not be assumed to contain a project-memory table unless its actual schema is inspected. If structured project memory is maintained separately, identify the real project key/schema before writing. Do not invent memory tables, columns or records. GitHub documentation remains a continuity source alongside confirmed project-level memory/checkpoints.

## 16. Current stopping point — 16 September 2026
Customer security/subscription checkpoints remain intact. Production onboarding remains open. Buying 049–051 is hardened. Valuation/Offer 052–055 is hardened. Acquisition 056–057 is hardened. Inventory 058 and Finance 059 are hardened at the database boundary.

The subscriber UI now has Website Builder, public storefront, customer dashboard/auth flow, Buying, Offers, Acquisitions, Inventory and Finance workspaces. Inventory and Finance operational actions are implemented in GitHub but remain **not yet browser-verified live**.

**Next safe action:** continue into Selling/Listings using the existing tenant, permission and workflow architecture. Do not invent automatic handoff behaviour.