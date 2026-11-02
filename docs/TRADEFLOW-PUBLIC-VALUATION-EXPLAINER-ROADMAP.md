# TradeFlow Public Valuation-to-Sale Explainer — Diagnostic Roadmap

Date: 2 November 2026
Status: Implemented on feature branch; TEST browser verification pending.

## Purpose and boundary
This is a static public SaaS marketing/explanation page. It explains the existing customer valuation journey and the subscriber's post-purchase inventory/resale journey. It is not an operational workflow page.

## User entry points
- TradeFlow SaaS homepage navigation: `index.html` → How it works.
- Homepage hero action: See how it works.
- Homepage workflow summary link.
- Homepage footer Platform links.

## Front-end files
- `index.html`: public homepage entry points.
- `how-it-works.html`: page content, visual process map, customer/subscriber responsibilities, step-by-step description, post-purchase stock flow.
- `how-it-works.css`: responsive presentation.
- `platform.css`: shared TradeFlow SaaS shell, navigation, buttons and footer.

## Data and service dependencies
- Supabase tables/RPCs: none.
- Edge Functions: none.
- Auth/session: none.
- Storage/media: none.
- Stripe/payment APIs: none.
- Courier APIs: none.
- Tenant/customer data: none.
- Page is static HTML/CSS and uses ordinary relative navigation links only.

## Described workflow (content must remain aligned with operational code/manuals)
1. Customer selects item, supplies product/condition details and photographs.
2. Customer submits valuation request.
3. Subscriber reviews request/evidence and sends cash and trade-in offer.
4. Customer accepts cash, accepts trade-in, or refuses; multi-item requests can be decided per item or by an available combined offer.
5. Subscriber arranges shipping outside TradeFlow and supplies label/QR, carrier/tracking details and instructions.
6. Customer confirms dispatch; subscriber separately confirms physical receipt.
7. Subscriber inspects and accepts original offer, makes a revised offer/counteroffer, or refuses.
8. Customer responds to a revised offer when one is issued; unchanged original accepted value remains the basis when no revision is needed.
9. Subscriber records payment and completes purchase.
10. Purchased item enters Inventory, then Selling/listing preparation, published subscriber shop, and retail sale/fulfilment.

## Failure points / review checks
- Homepage navigation or CTA points to a missing page.
- New page CSS fails to load or is not responsive.
- Public copy implies TradeFlow books courier shipments or processes courier payments (incorrect).
- Public copy implies payment is automated or initiated by TradeFlow (not claimed).
- Public copy merges customer valuation stages with Inventory/Selling stages (keep them visually distinct).
- Any customer names, emails, business names, request IDs, customer data, screenshot URLs or private details are introduced (must not happen).
- Public page accidentally introduces live data/API dependencies (must remain static).

## Verification
- Source checks: valid document structure, all relative links resolve to existing public files, no customer-specific strings or external URLs.
- Responsive checks: desktop, tablet and mobile layouts; navigation and CTA reach correct pages/anchors.
- TEST deployment: review via public homepage and new page; verify no existing homepage plans/examples/signup links regress.
- LIVE release: only after explicit approval and a tested promotion from `main` to `production`; no Supabase changes are expected.
