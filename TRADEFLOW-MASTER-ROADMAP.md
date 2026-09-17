# TradeFlow Master Build Roadmap & Verification Register

**Version:** 3.9  
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
| 3 | Categories, fields & options | BLUE | Independent Categories & Properties workspace implemented. Test Business A has active Buying/Selling `Drones`. Browser verification is open. |
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

## Customer dashboard browser repair — 16–17 September 2026
Customer authentication/controller is **Verified Live**. Customer category loading was separately isolated from optional `Promise.all()` modules because Test Business A lacks `module.orders`; `customer-dashboard-nav.js` independently loads `customer_get_buying_categories()` after portal reveal. No subscription capability was changed.

## Subscriber JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling shared the same malformed `esc()` quote mapping, a JavaScript parse fault preventing their controllers from reaching Supabase. Clean repaired runtimes were deployed.

## Category / product / media foundation
Operational path:
**Categories & Properties → create category → define properties/options → Inventory → add product → attach photographs → controlled lifecycle → Selling → create listing → Customer Shop.**

Implemented category/property management, direct inventory product creation, dynamic property values, private `tradeflow-media`, tenant-scoped media link tables, listing photo carryover and 90-day post-sale retention metadata/triggers. Physical Storage cleanup scheduling is not yet configured.

## Category investigation — tenant context and REST transport — 17 September 2026
Test Business A contains active Buying/Selling `Drones`. The exact category SELECT returns `Drones` under the authenticated database role with the known Test Business A owner identity. Category permissions are present. Therefore the database, category data and category RLS are not the primary cause of the browser symptom.

The subscriber front-end was found to depend on temporary customer test-lab storage keys. The Category page was reading `tradeflow_testlab_session` / `tradeflow_testlab_publishable_key`, while the current browser was not signed into that customer test-lab session. The screenshot state `Sign in through the TradeFlow test environment before opening Categories.` proves the controller reached its authentication guard but had no appropriate subscriber session. This is a **subscriber authentication/session architecture problem**, not a category-data problem.

The earlier REST repair remains in place: GET/HEAD requests no longer add JSON `Content-Type`, category reads have a 10-second timeout, and runtime diagnostics load before the controller.

## Dedicated subscriber authentication repair — 17 September 2026
A dedicated `subscriber-auth.js` test-environment authentication layer has now been added. It is intentionally separate from Customer and Platform Owner sessions.

It:
- uses the same TradeFlow Supabase project publishable key, falling back to the already-connected Platform Admin key only as a browser convenience;
- stores subscriber sessions under `tradeflow_subscriber_session` and the key under `tradeflow_subscriber_publishable_key`;
- signs in an Owner/Admin/Staff account with email/password;
- verifies the authenticated user has an active membership in the selected test tenant;
- resolves Test Business A or B and writes the tenant context;
- does not store the password.

`subscriber-auth-bridge.js` provides compatibility for the existing subscriber controllers by translating their legacy test-lab storage reads to the dedicated subscriber session **on subscriber workspace pages only**. It never changes the Customer Test Lab storage itself. After a new subscriber sign-in, it reloads the workspace so the existing controllers start with the authenticated subscriber session.

`subscriber-auth-controls.js` intercepts the legacy page sign-out button and signs out the dedicated subscriber session.

The dedicated authentication layer is currently wired into:
- `categories.html`
- `inventory-dashboard.html`
- `selling-dashboard.html`

This is a test-environment repair. It is not the final production authentication architecture; production onboarding and subscriber tenant selection remain open.

## Current stopping point — 17 September 2026
The browser symptom has now been traced to the missing **subscriber** session rather than the category query. The next live test is to open Categories, sign in as an active Test Business A Owner/Admin/Staff account, and verify that `Drones` loads. Once that is proven, Inventory and Selling use the same dedicated subscriber session and tenant context.

Do not change category records, RLS policies or subscription capabilities to work around this authentication issue.

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
