# TradeFlow Master Build Roadmap & Verification Register

**Version:** 1.4  
**Date:** 16 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain audit progress, implementation evidence and exact stopping point.

## Authority
Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour. Uninspected connections are **AMBER / Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow Platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → customers**

Tenant roles are exactly `owner`, `admin`, `staff`. **Platform Owner is a separate platform-level security boundary and is never a tenant role.**

## Current environment
- GitHub: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Recorded health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- Platform Owner has been provisioned through the trusted administrative path.
- Test tenants remain development/test fixtures and are not the production onboarding model.
- GearCashOut is reference material only and must not be modified during TradeFlow work.

## Master roadmap

| # | Domain | Status | Current evidence / next action |
|---|---|---|---|
| 1 | Tenant & identity | AMBER | Production onboarding still must replace/harden development authenticated tenant-insert/test-lab paths. |
| 2 | Subscriptions & capability gating | GREEN | Capability layer implemented; Buying 17/17 and Selling 17/17 customer subscription tests recorded. |
| 3 | Categories, fields & options | AMBER | Buying dynamic option validation hardened; complete category/UI audit remains. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | Migrations 049–051 hardened validation, submission events and authoritative workflow. Persistent UI flow remains unverified. |
| 6 | Media/storage | AMBER | Exact ownership, object paths and access workflow remain to be audited. |
| 7 | Trading Value / valuation | BLUE | RLS boundary repaired in 052; offer-binding/state-entry repairs through 054–055. Full calculation/approval/UI audit remains. |
| 8 | Offers & offer events | BLUE | RLS, same-item valuation binding and published-offer validation repaired. Full lifecycle/UI audit remains. |
| 9 | Acquisition & acquisition items | BLUE | RLS hardened in 056; source-offer uniqueness added; lifecycle authority verified and direct status entry hardened in 057. Receipt/inspection/payment/inventory handoff UI remains. |
| 10 | Fulfilment | AMBER | Operational workflow audit remains. |
| 11 | Inventory | AMBER | Acquisition-to-inventory handoff is schema-connected but no automatic creation path was found in inspected public functions/triggers; inventory RLS still contains broad legacy policies and requires its own audit. |
| 12 | Selling/listings | AMBER | Lifecycle audit remains. |
| 13 | Retail orders | AMBER | Customer boundary tested; complete workflow audit remains. |
| 14 | Returns | AMBER | Full lifecycle audit remains. |
| 15 | Finance/payment | AMBER | Acquisition/payment/ledger FKs exist, but no inspected public function automatically posts acquisition payment or ledger entries; finance RLS retains broad legacy member/admin policies and requires audit/hardening. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Staff security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront | AMBER | Published read model and tenant/publication workflow require audit. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; system-wide final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Security foundation and privileged paths implemented; final browser regression remains. |

## Verified security checkpoints
- Customer isolation/security: **34/34 PASS**.
- Customer subscription tests: **Buying 17/17 PASS; Selling 17/17 PASS**.
- Staff security lab: **19/19 PASS**.
- RLS enabled across the recorded 60/60 public-table checkpoint.
- Platform-owner boundary: migrations 044–045.
- Platform-admin privileged provisioning/read guards: migrations 046–048.

## Production onboarding — OPEN
The original tenant foundation still contains an authenticated tenant insertion path with `with check (true)`, plus temporary test-lab onboarding functions. These must not be public SaaS onboarding.

Required production sequence:
**Platform Owner / approved onboarding → tenant creation → initial owner provisioning → subscription assignment → owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Buying audit — migrations 049–051
Migration 049 makes select/multiselect option validation authoritative inside `customer_submit_buying_request`. Migration 050 makes request/item workflow transitions authoritative through `transition_workflow_entity`. Migration 051 records customer submission workflow events for the request and each item. Transactional tests passed and were rolled back.

Authoritative Buying progression:
```text
Request: draft → submitted → under_review → valued → offer_ready → closed
Item:    draft → submitted → under_review → valued → offer_ready → closed
```

## Valuation / Offer audit — migrations 052–055
**052 — `harden_valuation_rls_boundaries`** removed broad valuation-table member/admin policies and enforced `valuation.view/manage` plus `module.valuation`.

**053 — `harden_offer_rls_boundaries`** removed broad offer/offer-event access and enforced `offers.view/manage` plus `module.offers`, with actor checks on offer-event inserts.

**054 — `bind_offer_to_same_buying_item_valuation`** added a composite tenant/item/valuation foreign-key relationship so an offer cannot reference a valuation belonging to a different buying item in the same tenant. The one-approved-valuation-per-item and one-live-published-offer-per-item constraints were verified.

**055 — `harden_valuation_offer_state_entry`** protects lifecycle entry and requires a published offer to reference an approved valuation for the same buying item. Live inspection confirmed `offers_validate_published_valuation`.

Current state: the valuation/offer integrity layer is **implemented and database-inspected**, but full calculation, staff role matrix, persistent browser workflow and live UI verification remain open.

## Acquisition audit — migrations 056–057
### Migration 056 — acquisition RLS/source-offer uniqueness
Broad legacy tenant-member/admin policies were removed from `acquisitions` and `acquisition_items`. The remaining direct-table policies are subscription-aware and require `acquisitions.view/manage` plus `module.buying`.

A partial unique index `acquisitions_one_per_source_offer` now prevents more than one acquisition per tenant/source offer when a source offer is present.

Live verification confirmed:
- migration 056 is present;
- the unique index exists with the intended `(tenant_id, source_offer_id)` definition;
- acquisition/acquisition-item RLS exposes only the subscription-aware policies;
- acquisition and acquisition-item tenant-scoped foreign keys remain intact.

### Acquisition lifecycle authority
`transition_workflow_entity` is the authoritative workflow service for both `acquisition` and `acquisition_item` and requires `acquisitions.manage` plus `module.buying`.

Allowed progression:
```text
accepted → awaiting_item → received → inspection → finalised → paid → completed
                         ↘ cancelled
```

`received`, `finalised`, `paid`, `completed` and `cancelled` timestamps are set by the authoritative function. The database contained no acquisition status trigger before the new repair.

### Migration 057 — acquisition status-entry guard
A direct-status-entry bypass was found: subscription-aware UPDATE RLS still allowed an authorised tenant user to update acquisition status directly rather than using the central workflow RPC. Migration 057 added BEFORE UPDATE status guards to `acquisitions` and `acquisition_items`.

The guards reject status changes from ordinary client roles and permit the existing SECURITY DEFINER `transition_workflow_entity()` path, whose function owner is `postgres`. This preserves the single authoritative lifecycle mechanism without creating a second workflow service.

Live verification confirmed both new triggers exist:
- `acquisitions_status_entry_guard`
- `acquisition_items_status_entry_guard`

GitHub commit for migration 057: `00254f9558a33f75c5c3f21bd7e87d356c998532`.

### Acquisition handoff finding
The acquisition tables are structurally connected to inventory and finance:
- `inventory_assets` has tenant-scoped FKs to `acquisition_items` and `buying_items`;
- `payment_records` has a tenant-scoped FK to `acquisitions`;
- `ledger_entries` has a tenant-scoped FK to `acquisitions` and `inventory_assets`.

However, live inspection found no public acquisition/inventory/payment/ledger function or trigger that automatically creates inventory, payment or ledger records when an acquisition reaches `received`, `finalised`, `paid` or `completed`. This is recorded as **Not yet audited / not automatically connected**, not as an assumed feature.

## Workflow audit standard
For every domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a domain GREEN merely because tables/functions exist. A transactional rollback test proves database behaviour, not a complete persistent UI journey.

## Deliberately outside generic core
GearCashOut specialist catalogue, evidence/research, AI research queue and specialist pricing structures remain outside TradeFlow unless later added as explicit modules.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected code/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
The customer security/subscription layer remains verified. Platform Owner security foundations are implemented; final browser regression for the repaired Platform Administration POST flow remains open. Production onboarding remains open.

Buying has been hardened through 049–051. Valuation/offer integrity has been hardened through 052–055. Acquisition RLS/source-offer uniqueness has been hardened through 056, and the direct acquisition status bypass was repaired through 057.

**Next safe audit:** complete the acquisition operational handoff trace, beginning with Inventory RLS/status authority and then Finance/Payment/ledger authority. Do not assume automatic inventory/payment/ledger creation until an actual implementation is found and verified.
