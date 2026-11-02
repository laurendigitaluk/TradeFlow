# TradeFlow Public Valuation-to-Sale Explainer — Diagnostic Roadmap

Date: 2 November 2026
Status: Implemented on feature branch; TEST browser verification pending.

## Purpose and boundary
Static public SaaS marketing/explanation page. It describes the customer valuation journey and subscriber's post-purchase inventory/resale journey. It is not an operational workflow page.

## User entry points
- TradeFlow SaaS homepage navigation: `index.html` → How it works.
- Homepage hero action: See how it works.
- Homepage workflow summary link.
- Homepage footer Platform link.

## Front-end files
- `index.html`: homepage entry points.
- `how-it-works.html`: process map, customer/subscriber responsibilities, stage explanations and post-purchase stock flow.
- `how-it-works.css`: responsive presentation.
- `platform.css`: shared SaaS header, navigation, buttons and footer.

## Data and service dependencies
- Supabase tables/RPCs: none.
- Edge Functions, Auth/session, Storage/media, Stripe/payment APIs, courier APIs: none.
- Tenant/customer data: none.
- Static HTML/CSS only; ordinary relative navigation links.

## Described workflow
1. Customer selects item, supplies product/condition details and photographs.
2. Customer submits valuation request.
3. Subscriber reviews request/evidence and sends cash and trade-in offer.
4. Customer accepts cash, accepts trade-in, or refuses; multi-item requests support per-item or available combined decisions.
5. Subscriber arranges shipping outside TradeFlow and supplies label/QR, carrier/tracking details and instructions.
6. Customer confirms dispatch; subscriber separately confirms physical receipt.
7. Subscriber inspects and accepts original offer, makes revised offer/counteroffer, or refuses.
8. Customer responds to a revised offer when one is issued; unchanged original accepted value remains the basis when no revision is needed.
9. Subscriber records payment and completes purchase.
10. Purchased item enters Inventory, then listing preparation, published subscriber shop, sale and fulfilment.

## Failure points / review checks
- Homepage navigation or CTA points to a missing page.
- CSS fails to load or page is not responsive.
- Public copy implies TradeFlow books courier shipments or processes courier payments.
- Public copy implies automated customer payouts.
- Customer valuation stages are conflated with Inventory/Selling stages.
- Customer names, emails, subscriber business names, request IDs, screenshot URLs or private details are introduced.
- Static page accidentally introduces live data/API dependencies.

## Verification
- Static source: valid structure, relative links resolve, no private identifiers or external URLs.
- Responsive: desktop, tablet and mobile; navigation and CTAs.
- TEST browser: open homepage and new page; verify plans, examples and signup links still work.
- LIVE release: only after explicit approval and tested promotion from `main` to `production`; no Supabase changes expected.
