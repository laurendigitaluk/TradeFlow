# TradeFlow Master Build Roadmap & Verification Register

**Version:** 3.8  
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

## Subscriber workspace JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling shared the same malformed `esc()` quote mapping, a JavaScript parse fault preventing their controllers from reaching Supabase.

Repairs:
- Category controller: `11bcc0922f368918a26be6c7e8362109fde2ae4f`.
- Inventory repaired runtime: `ccfb93a889903131f24c2a9769b04b095e611c22`; HTML switch `22b17000105860bdadc0337b4828410d95f9e04`.
- Selling repaired runtime: `1692b3f2d7c512fc528f91ead22e07b6ccac0eec`; HTML switch `693ef64cbba12540c9f32856224b0d20c831fb1d`.

## Category / product / media foundation
Operational path:
**Categories & Properties → create category → define properties/options → Inventory → add product → attach photographs → controlled lifecycle → Selling → create listing → Customer Shop.**

Implemented category/property management, direct inventory product creation, dynamic property values, private `tradeflow-media`, tenant-scoped media link tables, listing photo carryover and 90-day post-sale retention metadata/triggers. Physical Storage cleanup scheduling is not yet configured.

## Root cause: subscriber category selectors lacked tenant context — 17 September 2026
The same failure was visible across the subscriber category selectors: the page controllers expected `tenant_id` in the URL, while the subscriber navigation used plain workspace URLs. The database is not missing the category: Test Business A currently contains active Buying/Selling `Drones`.

The durable test-lab repair is a shared `subscriber-tenant-context.js` preloader. It runs before subscriber workspace controllers and establishes the tenant URL context from the existing test-lab session/local tenant context, then stores the selected test tenant for subsequent workspace navigation. It is loaded before the Category, Inventory, Selling and Buying controllers. Inventory and Selling navigation now also points to the fresh Categories entry.

Commits:
- shared tenant context: `695fbd26e47531c76b2a3fe053dfc0f49abb91c9`
- Subscriber Dashboard context: `eb9ee51f743e2e7a9f01d7e61745113d352f12e3`
- Inventory context: `b73b23c96c8e797fb3c5be9b9c9e1c0f4c715e15`
- Selling context: `da905ec27731054067720386cf714bf89cf7d108`
- Buying context: `edab6b403a8c9cc277644c5bc2c9b898d10ec8d4`
- Categories fresh runtime/context: `a9b9d6fc7adfc475567f147d16cbec24fd0b0c28`

This is a front-end tenant-context repair. No subscription, RLS or category data was changed.

## Second category runtime repair — 17 September 2026
The category page remained visibly stuck on `Loading categories…` after the shared tenant-context repair. The controller was hardened again so it no longer depends solely on the URL mutation from the preloader.

Changes:
- `category-management.js` now safely parses the stored test-lab session instead of allowing malformed localStorage JSON to abort the entire controller before `load()` runs.
- Tenant resolution now accepts the URL tenant, the shared `document.documentElement.dataset.tradeflowTenantId`, stored test-lab tenant and known test-lab user mapping.
- The controller writes a visible loading/error message and logs runtime failures, including unhandled promise rejections, rather than leaving the static `Loading categories…` placeholder with no diagnostic.
- `categories.html` cache-busts the context to `v3` and category controller to `v9`.

Commits:
- category controller repair: `92bed1ba6319ce3a7ae1c6d8901ae7939d74c71d`
- category page cache-bust: `7872d4bd06a1a53eb150c2fac89481ac6dbd9e74`

No Supabase schema, category records, subscription features or RLS policies were changed.

## Deep category transport/runtime check — 17 September 2026
The browser symptom remained after the second runtime repair, so the full path was checked rather than making another database change.

Backend verification now includes:
- Supabase project status `ACTIVE_HEALTHY` in `eu-west-2`.
- Test Business A category `Drones` exists and is active for both Buying and Selling.
- The exact category SELECT returns `Drones` under the `authenticated` role with the known Test Business A owner identity and therefore passes the live RLS boundary.
- Test Business A owner/admin identities have `categories.view` and `categories.manage`; staff has `categories.view`.

The remaining common browser-side weakness was identified in the subscriber REST helper: it was adding `Content-Type: application/json` to **GET** requests. That is unnecessary for Supabase REST reads and can introduce a CORS preflight before the actual category request. The helper also had no timeout, allowing a failed/stalled browser request to leave `Loading categories…` indefinitely. The page's previous runtime error listener was also registered after the controller script, so a bootstrap exception could occur before diagnostics were installed.

Repairs:
- `category-management.js` now omits JSON `Content-Type` for GET/HEAD, applies a 10-second timeout and displays the current request phase or concrete error.
- `categories.html` installs `error` and `unhandledrejection` listeners before subscriber scripts and cache-busts the controller to `v10`.
- `subscriber-tenant-context.js` safely establishes tenant context and normalises subscriber GET/HEAD requests before workspace controllers run.
- Subscriber Dashboard, Inventory, Selling and Buying pages now cache-bust the shared context to `v4`.

No database, subscription or RLS workaround was introduced.

## Retail payment / external Stripe
External payment architecture remains **BLUE / Implemented, verification open**. `create-stripe-checkout-session` is JWT-protected and server-side; `stripe-payment-webhook` verifies signed events and delegates reconciliation to `process_external_payment_event()`. Provider/event idempotency and retry handling are implemented.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. Required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states: **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 17 September 2026
The database category and RLS path are verified. The shared tenant-context repair did not resolve the browser symptom. The second repair exposed and hardened the subscriber REST transport/bootstrap path: GET requests no longer carry unnecessary JSON Content-Type, category reads now time out visibly, and runtime diagnostics are installed before the controller.

**Next browser verification:** hard refresh the current Categories page. It should now either populate `Drones` or show a concrete runtime/API/timeout error instead of silently remaining on `Loading categories…`. Do not change subscriptions or database policies as a workaround. Once Categories passes, verify Inventory and Selling selectors using the same shared context.
