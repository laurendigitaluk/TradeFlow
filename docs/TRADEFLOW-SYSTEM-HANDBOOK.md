# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 1.6  
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

## 6. Subscriber website architecture — IMPLEMENTED / LIVE-BACKED, UI VERIFICATION OPEN
The existing website data model is the source of truth:
- `tenant_site_state` identifies each tenant's current draft and published revision;
- `site_revisions` stores versioned draft/published/archived content;
- `published_site_index` is the public read model;
- `public.publish_site_revision(p_tenant_id,p_revision_id)` is the existing publication service.

The publication service is `SECURITY DEFINER`, requires authentication and checks `private.can_tenant(p_tenant_id, 'website.publish', 'website.publish')`. It publishes only the tenant's current draft, creates the next draft revision, and refreshes the public read model for active tenant hostnames.

The Website Builder now uses this existing architecture rather than browser-only `localStorage`:
1. restore the authenticated TradeFlow session;
2. resolve the user's active tenant membership, or require an explicit `tenant_id` for a multi-tenant account;
3. load `tenant_site_state` and its current draft `site_revisions` row;
4. map builder fields into `site_revisions.content` with `schema_version: 1`;
5. save through the existing RLS-protected draft UPDATE policy requiring `website.manage` + `website.editor`;
6. publish through `publish_site_revision` rather than directly changing status;
7. reload the newly-created draft after publication.

Affected files:
- `website-builder.html`
- `website-builder.js`

Verification state: **Implemented in GitHub; authenticated browser verification remains open.** The public storefront renderer, customer authentication journey and custom-domain routing are not yet claimed complete.

## 7. Buying checkpoint — migrations 049–051
Migration 049 made dynamic select/multiselect validation authoritative inside `customer_submit_buying_request`.

Migration 050 made Buying request/item lifecycle transitions authoritative through `transition_workflow_entity`:
```text
Request: draft → submitted → under_review → valued → offer_ready → closed
Item:    draft → submitted → under_review → valued → offer_ready → closed
```

Migration 051 records customer submission workflow events for the request and each item. Transactional tests passed and were rolled back.

Buying remains **BLUE / partial** because a persistent browser journey through review, valuation and offer readiness has not been completed.

## 8. Valuation and Offer checkpoint — migrations 052–055
Migration 052 removed broad valuation-table member/admin policies and enforced valuation permission plus `module.valuation`.

Migration 053 removed broad offer/offer-event access and enforced offer permission plus `module.offers`, with actor checks on offer-event inserts.

Migration 054 binds an offer to a valuation for the **same tenant and same buying item** through a composite foreign key. Existing one-approved-valuation-per-item and one-live-published-offer-per-item indexes were verified.

Migration 055 protects valuation/offer state entry and validates that a published offer references an approved valuation for the same buying item. Live inspection confirmed the `offers_validate_published_valuation` trigger.

Valuation/Offers remain **BLUE / partial**: integrity guards are implemented and database-inspected; complete calculation, staff role matrix, persistent UI and live workflow verification remain open.

## 9. Acquisition and acquisition-item domain — migrations 056–057
Migration 056 removed broad legacy access from acquisitions/acquisition_items and added source-offer uniqueness. Direct-table access is subscription-aware.

`transition_workflow_entity` is the authoritative workflow service. Migration 057 added status-entry guards so authorised client roles cannot bypass that service by directly changing acquisition status.

Allowed lifecycle:
```text
accepted → awaiting_item → received → inspection → finalised → paid → completed
                         ↘ cancelled
```

Verification state: **Implemented + live database inspected.** Full authenticated browser status-transition journey remains open.

## 10. Acquisition → Inventory / Finance handoff finding
The schema contains the expected structural links:
- `inventory_assets` → `acquisition_items` and `buying_items`;
- `payment_records` → `acquisitions`;
- `ledger_entries` → `acquisitions` and `inventory_assets`.

Live inspection found no public acquisition/inventory/payment/ledger function or trigger that automatically creates inventory, payment or ledger records merely because acquisition status changes. This remains an open implementation/verification item and must not be assumed.

## 11. Current workflow audit method
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Check allowed/forbidden states, role permission, subscription capability, tenant boundary, record update, event/audit row, triggers/side effects, failure/rollback, UI result and external integration.

Do not mark a domain GREEN merely because tables/functions exist.

## 12. Manual testing standard
Manual browser security tests are performed one at a time with exact URL, account, action and expected result; screenshot/result is captured before moving on.

Transactional database tests may be rolled back, but a rollback test proves database behaviour only, not a complete persistent UI journey.

## 13. Domain status
| Domain | Status | Current position |
|---|---|---|
| Tenant/identity | AMBER | Production onboarding open. |
| Subscriptions | GREEN | Capability architecture and recorded 17/17 customer tests. |
| Customers | GREEN | 34/34 security/isolation checkpoint. |
| Buying | BLUE | 049–051 hardened; persistent UI remains. |
| Trading Value | BLUE | 052 plus 054–055 integrity/state-entry repairs; full workflow remains. |
| Offers | BLUE | 053–055 integrity repairs; full lifecycle/UI remains. |
| Acquisition | BLUE | 056–057 hardened; operational handoff remains. |
| Inventory | AMBER | Handoff and complete RLS/status audit remain. |
| Finance/payment | AMBER | Handoff and complete RLS/authority audit remain. |
| Selling/listings | AMBER | Audit remains. |
| Orders/fulfilment/returns | AMBER | Audits remain. |
| Notifications/email | AMBER | Integration audit remains. |
| Public storefront/media | BLUE | Subscriber draft/publish path implemented; public renderer/custom domains/customer journey remain. |
| Staff roles | BLUE | Security lab 19/19; management workflow remains. |
| Platform Owner/Admin | BLUE | Foundation implemented; final browser regression remains. |
| System-wide RLS/workflow | BLUE | Multiple paths repaired; final pass remains. |

## 14. Documentation/change control
Every material change records what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap and the AI Operating Manual when architecture/build position changes, and update structured project memory/checkpoint data where available.

## 15. Current stopping point — 16 September 2026
Migrations 049–057 remain the verified database hardening baseline. The prolonged domain audit is no longer the immediate build track. The subscriber Website Builder is now connected to the existing tenant site revision/publication architecture in GitHub.

**Next build action:** wire the subscriber dashboard's Website entry directly into the builder, then build the tenant-specific public storefront renderer and customer account/dashboard journey. Keep acquisition/inventory/finance handoff as a separate open workflow item rather than blocking the customer-facing build.
