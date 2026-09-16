# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 1.5  
**Date:** 16 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose and authority
This handbook records verified TradeFlow architecture, security boundaries, workflow rules, implementation decisions, faults, lessons and exact build position.

Authority order: **current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour**. A Git commit is implementation evidence, not proof of live behaviour.

## 2. Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant boundary.

```text
TradeFlow Platform
└── Platform Owner
    ├── Subscriber Tenant
    │   ├── Owner
    │   ├── Admin
    │   ├── Staff
    │   └── Customers
    └── ...
```

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level boundary and is never a tenant role.

GearCashOut is reference material only and must never be modified during TradeFlow work.

## 3. Verified security checkpoints
- Customer isolation/security: **34/34 passed** at the recorded checkpoint.
- Customer subscription tests: **Buying 17/17; Selling 17/17 passed**.
- Staff security lab: **19/19 passed**.
- RLS enabled across the recorded 60/60 public-table checkpoint.
- Platform Owner security foundation: migrations 044–045.
- Platform-admin privileged provisioning/read guards: migrations 046–048.

## 4. Production onboarding — OPEN
The development tenant foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding functions. These are not approved for public SaaS onboarding.

Required production sequence:
**Platform Owner / approved onboarding → tenant creation → initial owner provisioning → subscription assignment → owner/admin/staff management.**

Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Tenant capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Inspected permissions include `acquisitions.view/manage`, `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `inventory.view/manage` and `finance.view/manage`.

Future modules must enforce both tenant permission and required module capability where that capability exists.

## 6. Buying checkpoint — migrations 049–051
Migration 049 made dynamic select/multiselect validation authoritative inside `customer_submit_buying_request`.

Migration 050 made Buying request/item lifecycle transitions authoritative through `transition_workflow_entity`:
```text
Request: draft → submitted → under_review → valued → offer_ready → closed
Item:    draft → submitted → under_review → valued → offer_ready → closed
```

Migration 051 records customer submission workflow events for the request and each item. Transactional tests passed and were rolled back.

Buying remains **BLUE / partial** because a persistent browser journey through review, valuation and offer readiness has not been completed.

## 7. Valuation and Offer checkpoint — migrations 052–055
Migration 052 removed broad valuation-table member/admin policies and enforced valuation permission plus `module.valuation`.

Migration 053 removed broad offer/offer-event access and enforced offer permission plus `module.offers`, with actor checks on offer-event inserts.

Migration 054 binds an offer to a valuation for the **same tenant and same buying item** through a composite foreign key. Existing one-approved-valuation-per-item and one-live-published-offer-per-item indexes were verified.

Migration 055 protects valuation/offer state entry and validates that a published offer references an approved valuation for the same buying item. Live inspection confirmed the `offers_validate_published_valuation` trigger.

Valuation/Offers remain **BLUE / partial**: integrity guards are implemented and database-inspected; complete calculation, staff role matrix, persistent UI and live workflow verification remain open.

## 8. Acquisition and acquisition-item domain — migrations 056–057
### 8.1 Migration 056 — RLS/source-offer uniqueness
Legacy broad tenant-member/admin policies were removed from `acquisitions` and `acquisition_items`. Live inspection shows only subscription-aware policies requiring:
- SELECT: `acquisitions.view` + `module.buying`;
- INSERT/UPDATE/DELETE: `acquisitions.manage` + `module.buying`.

A partial unique index `acquisitions_one_per_source_offer` on `(tenant_id, source_offer_id)` where the source offer is non-null prevents duplicate acquisitions from one accepted commercial offer.

Tenant-scoped foreign keys remain in place for acquisitions/customer/source offer and acquisition items/acquisition/buying item/offer.

### 8.2 Acquisition lifecycle authority
`transition_workflow_entity` is a SECURITY DEFINER workflow service owned by `postgres`. It maps both `acquisition` and `acquisition_item` to `acquisitions.manage` plus `module.buying`.

Allowed lifecycle:
```text
accepted → awaiting_item → received → inspection → finalised → paid → completed
                         ↘ cancelled
```

The function updates the authoritative acquisition record and sets the corresponding receipt/finalisation/payment/completion/cancellation timestamps, then records a `workflow_transitions` row.

### 8.3 Defect found — direct acquisition status mutation
The audit found that the subscription-aware acquisition UPDATE policies did not themselves make status immutable. Therefore an authorised tenant user could potentially update `acquisitions.status` or `acquisition_items.status` directly and bypass the central workflow transition function.

This was a genuine authority-boundary defect, not merely a UI issue.

### 8.4 Migration 057 — status-entry guard
Migration 057 added:
- `public.guard_acquisition_status_entry()`;
- `public.guard_acquisition_item_status_entry()`;
- `acquisitions_status_entry_guard` BEFORE UPDATE OF status;
- `acquisition_items_status_entry_guard` BEFORE UPDATE OF status.

The guards reject status changes when the database execution identity is not `postgres`. The existing SECURITY DEFINER `transition_workflow_entity()` is owned by `postgres`, so legitimate workflow updates continue through the single authoritative service.

Live inspection confirmed both triggers exist. GitHub commit: `00254f9558a33f75c5c3f21bd7e87d356c998532`.

**Verification state:** Implemented + live database inspected. A full authenticated browser status-transition journey remains to be tested.

## 9. Acquisition → Inventory / Finance handoff finding
The schema contains the expected structural links:
- `inventory_assets` → `acquisition_items` and `buying_items`;
- `payment_records` → `acquisitions`;
- `ledger_entries` → `acquisitions` and `inventory_assets`.

However, live inspection found no public acquisition/inventory/payment/ledger function or trigger that automatically creates inventory, payment or ledger records as acquisition status changes. This is therefore recorded as **not yet implemented/verified**, not assumed.

The next audit must trace the Inventory domain and Finance/Payment domain separately, including their RLS policies, status authority, creation functions, ledger rules and UI controllers.

## 10. Current workflow audit method
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Check allowed/forbidden states, role permission, subscription capability, tenant boundary, record update, event/audit row, triggers/side effects, failure/rollback, UI result and external integration.

Do not mark a domain GREEN merely because tables/functions exist.

## 11. Manual testing standard
Manual browser security tests are performed one at a time with exact URL, account, action and expected result; screenshot/result is captured before moving on.

Transactional database tests may be rolled back, but a rollback test proves database behaviour only, not a complete persistent UI journey.

## 12. Domain status
| Domain | Status | Current position |
|---|---|---|
| Tenant/identity | AMBER | Production onboarding open. |
| Subscriptions | GREEN | Capability architecture and recorded 17/17 customer tests. |
| Customers | GREEN | 34/34 security/isolation checkpoint. |
| Buying | BLUE | 049–051 hardened and transactionally tested; persistent UI remains. |
| Trading Value | BLUE | 052 RLS plus 054–055 integrity/state-entry repairs; full workflow remains. |
| Offers | BLUE | 053–055 integrity repairs; full lifecycle/UI remains. |
| Acquisition | BLUE | 056 RLS/source-offer uniqueness + 057 status-entry authority; operational handoff remains. |
| Inventory | AMBER | Broad legacy RLS policies remain; full audit next. |
| Finance/payment | AMBER | Broad legacy RLS policies remain; acquisition linkage exists but automatic posting not found. |
| Selling/listings | AMBER | Audit remains. |
| Orders/fulfilment/returns | AMBER | Audits remain. |
| Notifications/email | AMBER | Integration audit remains. |
| Public storefront/media | AMBER | Access/publication audit remains. |
| Staff roles | BLUE | Security lab 19/19; management workflow remains. |
| Platform Owner/Admin | BLUE | Foundation implemented; final browser regression remains. |
| System-wide RLS/workflow | BLUE | Multiple paths repaired; final pass remains. |

## 13. Documentation/change control
Every material change records what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap and the AI Operating Manual when architecture/build position changes, and update structured project memory/checkpoint data where available.

## 14. Current stopping point — 16 September 2026
Migrations 049–051 hardened Buying. Migrations 052–055 hardened valuation/offer boundaries and same-item valuation integrity. Migration 056 hardened acquisition RLS and source-offer uniqueness. Migration 057 closed the direct acquisition/acquisition-item status-entry bypass.

**Next safe audit:** Inventory RLS and lifecycle authority → acquisition-to-inventory handoff → Finance/Payment/ledger RLS and authority → actual payment/ledger posting path. Do not assume these connections are automatic until verified.
