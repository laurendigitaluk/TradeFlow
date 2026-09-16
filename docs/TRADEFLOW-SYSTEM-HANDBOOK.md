# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 1.8  
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
    │   ├── Public Website
    │   └── Customers
    │       └── Customer Dashboard
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

## 6. Customer-facing SaaS build — IMPLEMENTED / LIVE VERIFICATION OPEN
The current build track uses the existing security and data model rather than parallel stores.

Implemented UI paths include:
- Website Builder backed by `tenant_site_state`, `site_revisions` and `publish_site_revision`.
- Tenant-specific public storefront renderer.
- Customer sign-in/test-lab registration and tenant-specific customer dashboard.
- Customer buying request submission.
- Customer Accept/Refuse actions for published offers through existing secure customer RPCs.
- Subscriber Buying workspace for review, valuation and offer publication.
- Subscriber Acquisition workspace for acquisition/item lifecycle operations.
- Explicit inventory creation from an acquisition item.
- Dedicated Subscriber Inventory workspace for asset listing, filtering, editable asset details and controlled lifecycle transitions.
- Subscriber Finance workspace exposing existing payment and ledger structures.

These are implementation milestones. They are not marked GREEN until authenticated browser journeys have been persistently tested.

## 7. Buying, valuation and offers — migrations 049–055
049 made dynamic select/multiselect validation authoritative inside `customer_submit_buying_request`.

050 made Buying request/item lifecycle transitions authoritative through `transition_workflow_entity`.

051 records customer submission workflow events.

052 removed broad valuation-table member/admin policies and enforced valuation permission plus module capability.

053 removed broad offer/offer-event access and enforced offer permission plus module capability.

054 binds an offer to a valuation for the same tenant and same buying item.

055 protects valuation/offer state entry and requires an approved same-item valuation for a published offer.

The subscriber Buying workspace now provides UI actions over these services; persistent browser verification remains open.

## 8. Acquisition — migrations 056–057
056 hardened acquisition access and source-offer uniqueness.

057 added status-entry guards so authorised client roles cannot bypass `transition_workflow_entity` by directly changing acquisition status.

Allowed lifecycle:
```text
accepted → awaiting_item → received → inspection → finalised → paid → completed
                         ↘ cancelled
```

The subscriber Acquisition workspace exposes acquisition and acquisition-item progression and can explicitly create a linked inventory asset from an acquisition item.

## 9. Inventory — migration 058 and dedicated workspace
Migration 058 removed broad legacy member/admin inventory policies and added authoritative status-entry protection for `inventory_assets`.

The dedicated `inventory-dashboard.html` / `inventory-dashboard.js` workspace now:
- lists tenant inventory assets;
- filters by inventory status;
- shows linked acquisition/buying/category identifiers;
- edits non-status asset details such as title, condition, serial number, quantity, purchase/current value, location, description and notes;
- routes lifecycle changes through `transition_workflow_entity()` with entity type `inventory_asset`.

The implemented lifecycle authority is:
```text
received → inspection → testing → repair → ready_for_sale → listed → reserved → sold
                                      ↘ returned
                                      ↘ written_off
                                      ↘ archived
```

Other controlled transitions include testing/repair returning to testing or ready-for-sale, listed/reserved movement, sold→returned, returned→inspection/written_off/archived, and written_off→archived, exactly as supported by the live workflow function.

The workspace is implemented in GitHub but remains **not yet browser-verified live**. Direct status PATCH is deliberately not used.

## 10. Finance and inventory handoff
The live schema contains tenant-scoped structural links:
- `inventory_assets` → `acquisition_items` and `buying_items`;
- `payment_records` → `acquisitions`;
- `ledger_entries` → `acquisitions` and `inventory_assets`.

Live inspection did not find an automatic function/trigger that creates payment, ledger or inventory records merely because an acquisition status changes. The UI therefore uses explicit operations rather than assuming hidden automation.

`payment_records` supports payment types including seller payment/payout and statuses including pending, processing, paid, failed, cancelled, refunded and partially_refunded.

`ledger_entries` supports purchase, payment, refund, expense, fee and adjustment entries with pending/posted/voided/reversed states.

The current Finance workspace exposes these existing structures. Payment creation/posting rules and full browser verification remain implementation/verification work.

## 11. Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a domain GREEN merely because tables/functions exist or a commit succeeds.

## 12. Manual testing standard
Manual browser security tests are performed one at a time with exact URL, account, action and expected result; screenshot/result is captured before moving on.

Transactional database tests may be rolled back, but a rollback test proves database behaviour only, not a complete persistent UI journey.

## 13. Domain status
| Domain | Status | Current position |
|---|---|---|
| Tenant/identity | AMBER | Production onboarding open. |
| Subscriptions | GREEN | Capability architecture and recorded 17/17 customer tests. |
| Customers | GREEN | 34/34 security/isolation checkpoint. |
| Buying | BLUE | Subscriber workspace implemented; persistent journey remains. |
| Trading Value | BLUE | Database hardening plus subscriber valuation UI; live journey remains. |
| Offers | BLUE | Database hardening plus customer response UI; live journey remains. |
| Acquisition | BLUE | Operational workspace implemented; live journey remains. |
| Inventory | BLUE | Dedicated workspace implemented with controlled lifecycle; browser verification remains. |
| Finance/payment | BLUE | Finance workspace implemented against existing tables; payment/ledger actions and live journey remain. |
| Selling/listings | AMBER | Build remains. |
| Orders/fulfilment/returns | AMBER | Build remains. |
| Notifications/email | AMBER | Integration remains. |
| Public storefront/media | BLUE | Renderer implemented; production public-read/custom-domain/auth journey remains. |
| Staff roles | BLUE | Security lab 19/19; management workflow remains. |
| Platform Owner/Admin | BLUE | Foundation implemented; final browser regression remains. |
| System-wide RLS/workflow | BLUE | Multiple paths repaired; final pass remains. |

## 14. Documentation/change control
Every material change records what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap and the AI Operating Manual when architecture/build position changes, and update structured project memory/checkpoint data where available.

## 15. Current stopping point — 16 September 2026
The prolonged broad audit is no longer the immediate build track. TradeFlow is being developed forward through the subscriber operational workflow while preserving the verified security baseline.

**Current operational path:** Buying → Valuation → Offer → Customer response → Acquisition → Receiving/Inspection → Finance/Payment → Inventory → Selling/Listing.

**Next build action:** complete Finance payment/ledger operational actions, then continue into Selling/Listings. Production onboarding and persistent browser verification remain tracked open items.