# Website Builder Template Architecture — 3 October 2026

## Decision
TradeFlow Website Builder keeps ten templates with materially different layout compositions while sharing the same editable content model.

## Content preservation
Template switching preserves the subscriber's headline, intro and CTA content. Template defaults are only used when no custom content has been entered.

## Banner option
Branding includes a `Use banner in the homepage hero` checkbox. `homepage.use_banner` stores the preference. When enabled and a banner exists, the banner occupies the primary hero title position. When disabled, the editable text headline is displayed. The headline remains stored in both cases.

## Environment
The change is represented in TEST/main and LIVE/production. Website Builder cache versions are JavaScript v69 and CSS v65.

## Next verification
Browser verification is still required: upload the Action Outlet banner, toggle Use banner on/off, switch through all ten templates, confirm the banner/text swap, and confirm headline/intro/CTA content survives template changes.
