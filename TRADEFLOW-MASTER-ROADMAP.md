# TradeFlow Master Build Roadmap & Verification Register

**Version:** 3.1  
**Date:** 16 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain build progress and exact stopping point.

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
- GearCashOut is reference material only and must not be modified during TradeFlow work.

## Master roadmap
| # | Domain | Status | Current evidence / next action |
|---|---|---|---|
| 1 | Tenant & identity | AMBER | Production onboarding still must replace/harden development authenticated tenant-insert/test-lab paths. |
| 2 | Subscriptions & capability gating | GREEN | Capability layer implemented; Buying 17/17 and Selling 17/17 customer subscription tests recorded. |
| 3 | Categories, fields & options | BLUE | Subscriber Categories & Properties workspace now creates categories and product properties/options independently of Buying. Browser verification remains. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | Customer submission and subscriber buying workspace implemented; persistent browser verification remains. |
| 6 | Media/storage | BLUE | Private `tradeflow-media` bucket plus tenant-scoped inventory/listing media links and 90-day post-sale retention metadata implemented. Automated physical object cleanup scheduling remains to be configured. |
| 7 | Trading Value / valuation | BLUE | 052 plus 054–055 integrity/state-entry repairs and subscriber valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; workspace supports lifecycle progression and explicit inventory hand-off. |
| 10 | Fulfilment | BLUE | Subscriber fulfilment workspace and lifecycle controls implemented; browser verification remains. |
| 11 | Inventory | BLUE | 058 hardened; subscriber can now add products, assign categories/properties and attach photographs. Browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; Selling workspace creates listings from ready-for-sale inventory and now carries inventory photographs into the listing. Browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening plus customer checkout and subscriber Orders workspace. Internal payment capture and external Stripe checkout boundary are implemented; browser verification remains. |
| 14 | Returns | BLUE | Return-request security hardened and subscriber Returns workspace implemented; customer visibility/actions implemented. Browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 permission/workflow hardening, internal payment capture, provider-payment records and external Stripe checkout/webhook boundary implemented. Stripe secrets/configuration and live payment verification remain. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Customer dashboard browser repair — 16 September 2026
The browser-layer authentication/controller fault is now **Verified Live**. Supabase password authentication succeeds, the portal is revealed, the corrected synchronous controller executes and the customer portal loads without the previous controller-unavailable message.

Root cause was an invalid JavaScript quote mapping in `customer-dashboard.js` `esc()`. The helper was corrected and the controller cache-buster advanced to `customer-dashboard.js?v=11`.

Latest repair commits:
- controller syntax repair: `ae47d539f23324bcce78537f865502e4adfb8bea`
- dashboard HTML/cache-bust v11: `271d52c2c079810bdf657b3d17e8aa37e9a89c84`
- navigation repair: `8c84b2ae8c9c666f92e7dea51a92af9e170e03ad`

No service-role credential is exposed in browser code.

## Category / product / media foundation — 16 September 2026
The subscriber UI previously had a Selling listing form but no independent category/property management and no way to add an inventory product. That dependency has been removed.

New operational path:
**Categories & Properties → create category → define product properties/options → Inventory → add product → attach photographs → controlled lifecycle → Selling → create listing → publish → Customer Shop.**

Implemented:
- `category-management.html` / `.js` for tenant category creation and product property/option setup.
- `inventory-dashboard.html` / `.js` product creation with category assignment, dynamic property values and photograph upload.
- private Supabase Storage bucket `tradeflow-media`.
- `inventory_asset_media` and `listing_media` tenant-scoped link tables.
- Selling automatically carries inventory photographs into newly created listings.
- `media_assets` now records retention policy and expiry metadata.
- Inventory/listing sold-status triggers set photograph retention to **90 days after sale** and clear the expiry if the item returns from sold.

Physical storage deletion must use the Storage API; deleting only the database metadata row is not sufficient to reclaim object storage. The production cleanup scheduler remains a configuration step.

## Retail payment / external Stripe
External payment architecture remains **BLUE / Implemented, verification open**. `create-stripe-checkout-session` is JWT-protected and server-side; `stripe-payment-webhook` verifies signed Stripe events and delegates reconciliation to `process_external_payment_event()`. Provider/event idempotency and retry handling are implemented.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. These are not the production SaaS onboarding model.

Required sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a feature complete solely because code is committed. A transactional rollback test proves database behaviour, not a persistent browser journey.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
Customer authentication/controller is verified live. The next build/test sequence is now the newly added operational product path: create a Test Business A category, add a product with at least one photograph and product property, move it through `ready_for_sale`, create/publish a listing, confirm the listing appears in Customer Shop, then run the persistent Stripe Sandbox purchase and verify payment/order/ledger reconciliation.

**Next build action:** browser-verify Categories → Product → Photograph → Ready for Sale → Listing → Customer Shop, then run the Stripe Sandbox transaction end-to-end.