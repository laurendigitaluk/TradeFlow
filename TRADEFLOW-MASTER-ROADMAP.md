# TradeFlow Master Build Roadmap & Verification Register

**Version:** 3.4  
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
Customer authentication/controller is **Verified Live**. The browser fault was traced to an invalid JavaScript quote mapping in `customer-dashboard.js` and repaired; controller cache-buster reached `v11`.

Customer category loading was separately isolated from the aggregate `Promise.all()` in `loadPortalData()`: Test Business A does not currently have `module.orders`, so `customer_get_orders()` can reject before category loading. `customer-dashboard-nav.js` now independently loads `customer_get_buying_categories()` after portal reveal and observes the portal hidden state. No subscription capability was changed to mask the fault.

## Subscriber workspace JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling shared the same malformed `esc()` quote mapping. Because it was a JavaScript parse fault, the controllers never reached their Supabase calls.

Repairs:
- `category-management.js` repaired in place: `11bcc0922f368918a26be6c7e8362109fde2ae4f`.
- `inventory-dashboard-fixed.js` created: `ccfb93a889903131f24c2a9769b04b095e611c22`.
- `inventory-dashboard.html` switched to repaired runtime: `22b17000105860bdadc03377b4828410d95f9e04`.
- `selling-dashboard-fixed.js` created: `1692b3f2d7c512fc528f91ead22e07b6ccac0eec`.
- `selling-dashboard.html` switched to repaired runtime: `693ef64cbba12540c9f32856224b0d20c831fb1d`.

The live `private` schema `USAGE` repair remains valid. No subscription capability was changed.

## Category / product / media foundation
Operational path:
**Categories & Properties → create category → define properties/options → Inventory → add product → attach photographs → controlled lifecycle → Selling → create listing → Customer Shop.**

Implemented:
- `category-management.html` / `.js` for category/property/option management.
- `inventory-dashboard.html` / repaired runtime for product creation, dynamic values and photographs.
- private Storage bucket `tradeflow-media`.
- `inventory_asset_media` and `listing_media` tenant-scoped link tables.
- Selling carries inventory photographs into new listings.
- `media_assets` retention metadata and sold-status 90-day expiry triggers.

Physical storage deletion must use the Storage API. Automated cleanup scheduling is not yet configured.

## Category tenant-context repair — 17 September 2026
The live screenshot showed Categories still stuck at `Loading categories…` even though the database contained `Drones`. Inspection of the current page URL identified the missing tenant context: the subscriber navigation links to `category-management.html` without `tenant_id`.

The Category controller previously required `tenant_id` from the query string, so navigation from the subscriber dashboard could open the page without a tenant. The controller is now tenant-context aware:
- if a valid `tenant_id` query parameter exists, it is used;
- otherwise the authenticated session's active `tenant_memberships` is queried;
- exactly one active TradeFlow test tenant must match; the resolved tenant is then placed into the URL with `history.replaceState()`;
- category/property/option requests continue to use the resolved tenant boundary.

`category-management.html` cache-buster was advanced from `v4` to `v5`, and its browser fallback was updated to use the same authenticated tenant-membership resolution. Commits:
- controller: `682ce22d8e5dcec9dd2d30815e565f05a3442c11`
- page/fallback: `96474f2a346cc1598aeaacf39b37a3702c8d5574`

This is a browser-context repair, not a database or subscription change.

## Retail payment / external Stripe
External payment architecture remains **BLUE / Implemented, verification open**. `create-stripe-checkout-session` is JWT-protected and server-side; `stripe-payment-webhook` verifies signed Stripe events and delegates reconciliation to `process_external_payment_event()`. Provider/event idempotency and retry handling are implemented. Stripe secrets/configuration remain server-side.

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
The shared subscriber JavaScript parse fault is repaired. The latest Categories fault is now traced to missing tenant context when the subscriber navigation opens the page without a `tenant_id`. The controller and fallback have been repaired to resolve the authenticated active test tenant.

**Next browser action:** hard refresh/open the Categories page again. Confirm the page resolves Test Business A and displays `Drones`. Then test Properties, create the first product property, and proceed one page at a time through Inventory → Photograph → Ready for Sale → Listing → Customer Shop → Stripe Sandbox.
