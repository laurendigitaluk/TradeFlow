# TradeFlow Master Build Roadmap & Verification Register

**Version:** 3.10  
**Date:** 17 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain build progress and exact stopping point.

## Authority
Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour. Uninspected connections are **AMBER / Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow Platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → customers**

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level security boundary and is never a tenant role.

## Current environment
- GitHub: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Recorded health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- GearCashOut is reference material only and must not be modified during TradeFlow work.

## Master roadmap
| # | Domain | Status | Current evidence / next action |
|---|---|---|---|
| 1 | Tenant & identity | AMBER | Production onboarding must replace/harden development authenticated tenant-insert/test-lab paths. |
| 2 | Subscriptions & capability gating | GREEN | Capability layer implemented; Buying 17/17 and Selling 17/17 customer subscription tests recorded. |
| 3 | Categories, fields & options | BLUE | **Category loading is Verified Live** with Test Business A Admin; `Drones` appears. Property creation/options still require browser verification. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | Customer submission and subscriber buying workspace implemented; persistent browser verification remains. |
| 6 | Media/storage | BLUE | Private `tradeflow-media`, tenant-scoped inventory/listing media links and 90-day post-sale retention metadata/triggers implemented. Physical cleanup scheduler remains open. |
| 7 | Trading Value / valuation | BLUE | 052 plus 054–055 integrity/state-entry repairs and valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; lifecycle and explicit inventory hand-off implemented. |
| 10 | Fulfilment | BLUE | Subscriber fulfilment workspace and lifecycle controls implemented; browser verification remains. |
| 11 | Inventory | BLUE | 058 hardened; add products, categories/properties and photographs implemented; browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; listings can be created from ready-for-sale inventory and inherit inventory photographs; browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening, customer checkout, subscriber Orders and Stripe boundary implemented; browser verification remains. |
| 14 | Returns | BLUE | Return-request security and subscriber/customer workflows implemented; browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 and external Stripe boundary implemented; persistent payment verification remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture/public renderer implemented; full public journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains have explicit workflow authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Category / product / media foundation
Operational path:
**Categories & Properties → create category → define properties/options → Inventory → add product → attach photographs → controlled lifecycle → Selling → create listing → Customer Shop.**

Implemented category/property management, direct inventory product creation, dynamic property values, private `tradeflow-media`, tenant-scoped media link tables, listing photo carryover and 90-day post-sale retention metadata/triggers. Physical Storage cleanup scheduling is not yet configured.

## Category investigation and subscriber authentication — 17 September 2026
Test Business A contains active Buying/Selling `Drones`. The exact category SELECT returns `Drones` under the authenticated database role. The browser initially failed because subscriber pages were using customer test-lab session storage rather than a dedicated subscriber session. A dedicated subscriber authentication layer was added for the test environment.

The live browser test is now **PASSED**: using the Test Business A **Admin** account, Categories loads successfully and `Drones` is visible. This proves the current chain:
**Subscriber Admin sign-in → active Test Business A membership → subscriber tenant context → authenticated category query → RLS → `Drones` rendered.**

Owner remains reserved for owner-specific testing; Admin is the primary subscriber workspace test account; Staff remains for permission/restriction testing.

## Current stopping point — 17 September 2026
**Categories loading: VERIFIED LIVE.** Do not change authentication, category RLS or subscriptions for this issue.

Next browser test is deliberately narrow: on Categories, select `Drones` in the Product Property Category selector and create the first product property (using the existing UI). Then verify Inventory's Category selector with the same Admin session. Do not move to Selling or Stripe until the Category → Property → Inventory selector chain is verified.

## Retail payment / external Stripe
External payment architecture remains **BLUE / Implemented, verification open**. `create-stripe-checkout-session` is JWT-protected and server-side; `stripe-payment-webhook` verifies signed events and delegates reconciliation to `process_external_payment_event()`. Provider/event idempotency and retry handling are implemented.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. Required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states: **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.


## Test Business C — Buy & Sell end-to-end test tenant — 18 September 2026

- Created dedicated test tenant Test Business C (50641519-2aa5-4093-95e5-7e92bea733a6) on the live TradeFlow test environment.
- Assigned the existing Test Business A Admin test identity as an Admin member; no Owner account is required for routine workflow testing.
- Assigned the buy_sell plan in trialing state so Inventory/Selling capability checks can be exercised without weakening RLS or changing Test Business A's Buying-only subscription.
- Seeded a Drones category with model_number (text) and condition (select) plus New/Excellent/Good/Fair/Poor options for end-to-end product testing.
- Added Test Business C to the subscriber authentication and tenant-context allowlists and cache-busted Categories, Inventory and Selling runtimes.
- Test Business A remains the Buying subscription test tenant; Test Business B remains the Selling subscription test tenant. This separation preserves subscription-boundary tests.


### Subscriber tenant switching repair — 18 September 2026

The Inventory RLS error was traced to the active browser workspace remaining on Test Business A, whose Buying-only subscription correctly rejects inventory_assets INSERT. Test Business C was verified separately: the Admin test identity is an active member, inventory.manage is true, and the Buy & Sell plan exposes module.inventory. The subscriber authentication layer previously had no visible tenant switch after an authenticated session was established, making the browser repeatedly remain on the stale tenant context. A tenant switcher has now been added to the subscriber top bar and cache-busted. It lists only tenants returned by the authenticated subscriber membership RPC and reloads the workspace with the selected tenant. No RLS policy was weakened.
