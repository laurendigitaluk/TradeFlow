# TradeFlow Public Valuation-to-Sale Explainer — Diagnostic Roadmap

Date: 2 November 2026
Status: Prepared for TEST deployment on the authoritative `cloudflare-test` branch.

## Purpose and boundary
Static public explanation of the customer buying journey and subscriber post-purchase stock/resale journey. This is not an operational workflow and has no live data dependencies.

## Deployment map
- Repository: `laurendigitaluk/TradeFlow`
- TEST source branch: `cloudflare-test`
- TEST Worker: `tradeflow-test`
- TEST Supabase: `nnsshnfkjcflucjrftzi` (not used by this page)
- LIVE source branch: `production`
- LIVE Worker: `tradeflow` (do not modify without approval)
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv` (not used by this page)
- Retired Supabase project `twfbmjwwqzxdxvclxbun` must never be used.

## User entry points
- Homepage navigation → `how-it-works.html`
- Homepage hero CTA → `how-it-works.html`
- Homepage workflow summary → `how-it-works.html`
- Homepage footer → `how-it-works.html`

## Front-end files
- `index.html`: public entry links.
- `how-it-works.html`: seven-stage buying journey, responsibility split, post-purchase stock path.
- `how-it-works.css`: responsive process layout.
- `platform.css`: shared header, buttons and footer.
- `wrangler.jsonc`: TEST Worker config on `cloudflare-test`; do not copy production config.

## Data/service dependencies
None. No Supabase tables, RPCs, triggers, RLS, Edge Functions, Auth, Storage, Stripe, courier integration, customer or tenant data.

## Process described
1. Valuation: customer submits details, condition and photographs; subscriber reviews.
2. Offer: customer accepts cash/trade-in or declines.
3. Shipping: subscriber arranges carrier outside TradeFlow and supplies label/QR, tracking and instructions.
4. Received: customer confirms dispatch; subscriber separately confirms physical receipt.
5. Inspection: subscriber accepts original offer, revises it, or refuses.
6. Payment: subscriber records payment; no automated payout.
7. Complete: item moves into inventory.
8. Resale: Inventory → prepare listing → publish to shop → sale and fulfilment.

## Verification and failure points
- Check homepage entry links resolve to the guide.
- Confirm `how-it-works.css` and shared `platform.css` load.
- Confirm responsive layout at desktop/tablet/mobile.
- Confirm no personal/customer/business identifiers or live API calls.
- Confirm Cloudflare TEST deployment shows the intended `cloudflare-test` commit.
- Confirm TEST URL serves HTTP 200 and guide content; do not infer deployment from GitHub merge alone.
- Confirm LIVE `production` branch and `tradeflow` Worker remain unchanged.


## How It Works screenshots added — 2 November 2026

The public TEST explainer now uses real TradeFlow screenshots, not illustrative mockups. Four screenshots are embedded directly in `how-it-works.html` as optimised WebP data images: customer buying progress, subscriber inspection decision, inventory, and customer-facing shop. This avoids extra asset paths or runtime image requests. The images were cropped and checked before embedding; internal item references and asset identifiers were obscured, and customer names, URLs, email addresses, bank details and transaction references are not displayed.

The page explains the seven-stage customer purchase journey, the customer/subscriber responsibilities, the unchanged-offer rule, the revised-offer acceptance requirement, the manual shipping/payment boundaries, and the separate inventory-to-retail path. It remains static HTML/CSS with no Supabase or other backend dependency. CSS is cache-busted to `how-it-works.css?v=3`.

Scope remains TEST only: branch `cloudflare-test` via a feature branch, Worker `tradeflow-test`. No Supabase, Stripe, tenant/customer data or LIVE configuration was changed. After merge, verify the Cloudflare TEST Worker deployment and the rendered screenshots at `/how-it-works.html`; GitHub merge alone does not prove deployment. Do not promote to LIVE without explicit approval.


## Presentation correction — 2 November 2026
Following review of the first published layout, the seven-stage tile strip was removed. The page is now a screenshot-led walkthrough: four full, real TradeFlow screen examples appear immediately after the hero, before the process explanation. They show customer progress, subscriber inspection decision, inventory and the public customer shop. Screenshots are large, alternating text/image sections, with the original embedded WebP images retained; no generated or mock screenshots. The stage sequence is now a simple numbered list rather than cards. Screenshot images are eager-loaded only for the first image and lazy-loaded for the remaining examples. The page remains static HTML/CSS and TEST-only. Confirm the Cloudflare TEST deployment after merge; no LIVE promotion without approval.


## Customer and subscriber side-by-side examples — 2 November 2026

The opening of the How It Works page now directly compares the two sides of the platform in one responsive, two-column section, under the headline “Two sides of every TradeFlow transaction”. The left example shows the subscriber business dashboard and is captioned “The business manages buying and selling”. The right example shows the customer valuation wizard at the category-selection step and is captioned “The customer chooses what they have to sell”. Both are crops from the user's actual supplied side-by-side screenshot, not generated illustrations. Browser chrome and taskbars are excluded. Subscriber business/account identity fields are blurred. The pair is presented before the later workflow examples.

The separate later screenshot walkthrough retains the real subscriber inspection decision, inventory and customer-facing shop screens. The redundant customer-progress example has been removed. The comparison is one composite WebP screenshot, followed by three later examples (four embedded images total). Stylesheet cache key is `how-it-works.css?v=4`; the comparison stacks on narrow screens. The seven process stages remain a plain numbered sequence, not tiles/cards.

This is static HTML/CSS on TEST only, with no backend, Supabase or Stripe changes. Branch: `feature/customer-subscriber-side-by-side-20261102`, intended base: `cloudflare-test`, Worker: `tradeflow-test`. No LIVE configuration, customer records or tenant data were changed. After merge, verify the new TEST Worker deployment and confirm the pair is side by side at desktop width and stacked at mobile width. Do not promote to LIVE without explicit approval.


## Final comparison layout correction — 2 November 2026
The side-by-side introduction uses one composite WebP screenshot, not two duplicated images. It visibly shows the redacted subscriber dashboard on the left and the customer valuation wizard on the right, with two separate explanatory captions underneath. The caption on the customer side reads “The customer chooses what they have to sell”. The remaining walkthrough retains three separate real screenshots: inspection decision, inventory and public shop. Total embedded images: four. Stylesheet URL: `how-it-works.css?v=5`. Desktop shows the two screenshot panes side by side within the composite; the two captions stack on mobile. This is the definitive intended presentation for the next TEST deployment.


## Original-resolution screenshot replacement — 2 November 2026
The four screenshots on the public How It Works page have been rebuilt from the original full-resolution desktop captures, rather than reusing the earlier reduced 720px images. The opening composite is 2058 × 486 pixels and preserves the subscriber business dashboard on the left beside the customer valuation wizard on the right. The inspection decision, inventory and customer shop captures are each approximately 1024 × 486 pixels. The images are embedded as high-quality WebP data URIs at quality 90, preserving the original screenshot pixel dimensions; responsive CSS no longer imposes a low max-height or resamples the source to 720px. Browser chrome/taskbars were cropped; subscriber business name/email/account labels and the public shop footer business name/test-only description were obscured. No customer identity, personal email, bank details or transaction references are published.

Page stylesheet cache-buster: `how-it-works.css?v=6`. Images are embedded in `how-it-works.html`, so there are no additional asset paths or image fetch dependencies. Static website only; no Supabase, Stripe, tenant/customer data or LIVE configuration changed. After merge, verify the Cloudflare TEST Worker renders all four images at clear resolution and that the comparison remains side-by-side on desktop. Do not promote to LIVE without explicit approval.
