# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 1.3  
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

## 6. Production onboarding remains OPEN
The development foundation still contains an authenticated tenant insert path with `with check (true)` and temporary test-lab onboarding. Required production sequence remains:

**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## 7. Buying / valuation / offer checkpoints
049 made dynamic option validation authoritative. 050 made Buying request/item transitions authoritative. 051 records customer submission workflow events.

052 removed broad valuation RLS and enforced valuation permission + module capability. 053 removed broad offer/event RLS. 054 binds an offer to a valuation for the same tenant and same buying item. 055 protects valuation/offer state entry and requires an approved same-item valuation for published offers.

Buying, valuation and offers remain **BLUE / partial** because persistent browser/live business journeys remain incomplete even though the relevant database boundaries have been repaired and inspected.

## 8. Acquisition audit checkpoint — 056–057
### 8.1 Migration 056
Removed broad legacy tenant-member/admin RLS policies from `acquisitions` and `acquisition_items`.

Remaining direct-table access is subscription-aware:
- SELECT: `acquisitions.view` + `module.buying`;
- INSERT/UPDATE/DELETE: `acquisitions.manage` + `module.buying`.

Added `acquisitions_one_per_source_offer` partial unique index on `(tenant_id, source_offer_id)` where source offer is non-null.

Live inspection confirmed the index and intended acquisition policies.

### 8.2 Existing workflow authority
`public.transition_workflow_entity()` is SECURITY DEFINER, owned by `postgres`, and maps:
- `acquisition` → `acquisitions.manage` + `module.buying`;
- `acquisition_item` → `acquisitions.manage` + `module.buying`.

Allowed lifecycle:
```text
accepted → awaiting_item → received → inspection → finalised → paid → completed
                         ↘ cancelled
```

The function performs the status update, sets lifecycle timestamps and inserts a `workflow_transitions` record.

### 8.3 Defect found
RLS permissions alone still allowed an authorised tenant member with acquisition-management access to update `status` directly. That could bypass the central workflow function.

### 8.4 Migration 057
Added status-entry trigger guards:
- `acquisitions_status_entry_guard` → `guard_acquisition_status_entry()`;
- `acquisition_items_status_entry_guard` → `guard_acquisition_item_status_entry()`.

Direct client-role status changes are rejected. The existing SECURITY DEFINER workflow function is owned by `postgres`, so its controlled status updates remain permitted.

Live inspection confirmed both triggers. GitHub commit: `00254f9558a33f75c5c3f21bd7e87d356c998532`.

Verification state: **Implemented + live database inspected**. Full authenticated browser transition testing remains open.

## 9. Acquisition handoff finding
The schema is structurally connected:
- `inventory_assets` has tenant-scoped FKs to `acquisition_items` and `buying_items`;
- `payment_records` has a tenant-scoped FK to `acquisitions`;
- `ledger_entries` has tenant-scoped FKs to `acquisitions` and `inventory_assets`.

Live function/trigger inspection found **no public acquisition/inventory/payment/ledger function or trigger that automatically creates those records when acquisition status changes**. Record this as **Not yet implemented/verified**, not as an assumed connection.

## 10. New audit finding for next domain
Inventory currently retains broad legacy member/admin RLS policies alongside subscription-aware inventory policies. Finance/payment tables also retain broad member/admin policies. Existing permission catalogue includes `inventory.view/manage` and `finance.view/manage`; the subscription catalogue contains `module.inventory` but no `module.finance` feature was found.

Therefore the next audit must inspect and, where justified, harden:
1. Inventory RLS and direct status mutation authority;
2. acquisition-item → inventory creation/handoff;
3. Finance/payment RLS and creation/update authority;
4. payment record → acquisition state relationship;
5. ledger posting/reconciliation and duplicate/idempotency rules.

Do not create automatic handoff logic until the intended business rule is established from the existing schema/workflow and UI.

## 11. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**. Never invent a connection to fill a documentation gap.

## 12. Manual UI testing
One manual security/UI test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 13. Change-control record
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

## 14. Current stopping point — 16 September 2026
Customer security/subscription checkpoints remain intact. Production onboarding remains open. Buying 049–051 is hardened. Valuation/Offer 052–055 is hardened at the database boundary. Acquisition 056–057 is hardened for tenant access, source-offer uniqueness and authoritative status entry.

**Next safe action:** continue the acquisition operational handoff audit with Inventory RLS/status authority, then Finance/Payment/ledger authority. Do not assume automatic inventory/payment/ledger creation until actual implementation is verified.
