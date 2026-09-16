# TradeFlow Master Build Roadmap & Verification Register

**Version:** 2.8  
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
| 3 | Categories, fields & options | AMBER | Buying dynamic option validation hardened; complete category/UI audit remains. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | Customer submission and subscriber buying workspace implemented; persistent browser verification remains. |
| 6 | Media/storage | AMBER | Exact ownership, object paths and access workflow remain to be audited. |
| 7 | Trading Value / valuation | BLUE | 052 plus 054–055 integrity/state-entry repairs and subscriber valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; workspace supports lifecycle progression and explicit inventory hand-off. |
| 10 | Fulfilment | BLUE | Subscriber fulfilment workspace and lifecycle controls implemented; browser verification remains. |
| 11 | Inventory | BLUE | 058 hardened; dedicated workspace manages assets and controlled lifecycle. Browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; Selling workspace creates listings from ready-for-sale inventory and controls listing lifecycle. Browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening plus customer checkout and subscriber Orders workspace. Internal payment capture and external Stripe checkout boundary are implemented; provider configuration and browser verification remain. |
| 14 | Returns | BLUE | Return-request security hardened and subscriber Returns workspace implemented; customer visibility/actions implemented. Browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 permission/workflow hardening, internal payment capture, provider-payment records and external Stripe checkout/webhook boundary implemented. Stripe secrets/configuration and live payment verification remain. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Customer dashboard browser repair — 16 September 2026
The persistent browser test exposed two browser-layer faults: the Sign in action initially gave no visible response, and the navigation controller prevented native hash navigation while `#portal` was hidden. Navigation was corrected so it only intercepts hashes after the portal is visible.

The dashboard HTML was then hardened with an inline capture-phase Supabase Auth fallback, removing dependency on a separate authentication-fix file being loaded correctly. The fallback uses only the public publishable key and performs the standard password-token exchange.

The first version stored the session and forced a page reload. Browser testing showed that the reload returned to the authentication panel, so the handoff was changed: after successful token exchange the inline fallback dispatches `tradeflow-auth-success`; the main controller now receives that event, adopts the authenticated session, validates `/auth/v1/user`, and calls the existing portal initialisation without a reload. This directly tests the real session handoff instead of relying on a second page startup.

Latest relevant commits:
- dashboard inline fallback: `b8fabeee759d10f8a7585b6e64d01610aec668f2`
- main controller session handoff: `0e1a56cefd2f9c96c7005d4a76109cbb93dd1929`
- navigation repair: `8c84b2ae8c9c666f92e7dea51a92af9e170e03ad`

No service-role credential is exposed in browser code.

**Verification state:** Implemented in GitHub; persistent live browser confirmation still required.

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
The navigation fault is repaired and the customer authentication handoff has been changed from reload-based restoration to a direct in-page session handoff. The next browser test is to hard-refresh the deployed customer dashboard, enter the existing Test Business A customer credentials and click Sign in once. If the portal appears, continue Shop → Buy → Stripe Checkout. Persistent Stripe payment verification, shipping-provider integration and production onboarding remain open.

**Next build action:** verify the direct customer auth handoff in the live browser, then continue the persistent customer checkout/payment journey.