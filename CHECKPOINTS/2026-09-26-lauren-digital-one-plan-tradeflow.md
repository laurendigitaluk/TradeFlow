# TradeFlow commercial model checkpoint — 26 September 2026

## Commercial structure
- Parent business/brand: Lauren Digital.
- Product: TradeFlow.
- TradeFlow launches with one customer-facing commercial plan.
- The live public plan is code `enhanced`, displayed as TradeFlow.
- Historical plan records remain in the database but are inactive and not website-visible.
- Future additional TradeFlow plans may be developed separately in a sandbox if customer demand requires them.
- A separate ordinary low-cost website product will be introduced later under a different product name; it is not TradeFlow and should support simple 1–6 page business websites.

## Public wording changes
- Replaced the homepage “Choose the plan that matches your business” wording with account creation/start wording.
- Removed customer-facing references to Basic/Enhanced/Catalogue choices.
- Removed public launch-plan wording for Staff, Staff Messaging, Audit, Analytics and Integrations.
- Updated the Plans and Facts pages to describe one commercial TradeFlow plan.
- Signup no longer presents a plan selector; it uses the TradeFlow launch plan internally.
- Login no longer tells customers to choose Basic or Enhanced.
- Added Lauren Digital parent-brand attribution to key TradeFlow marketing footers.

## Live entitlement state
Disabled on the launch TradeFlow plan:
- module.staff
- module.staff_messaging
- module.audit
- module.analytics
- module.integrations

Retained launch capabilities include buying, valuation, trade-ins, offers, inventory, selling, orders, fulfilment, customer portal, Website Builder, market intelligence and the TradeFlow starting catalogue.

## Verification
- `public.public_get_available_plans()` returns exactly one website-visible plan: TradeFlow.
- Historical Basic, Catalogue, Business and Advanced records remain inactive/non-public.
- No legacy plan-selection wording remains in the audited public files: index.html, plans.html, facts.html, subscriber-signup.html, subscriber-login.html, platform-plans.js and subscriber-signup.js.

## Next step
Configure the real Stripe product and recurring subscription boundary for the single TradeFlow commercial plan. Do not invent Stripe IDs; only store live Stripe Product/Price IDs after the real Stripe records exist.
