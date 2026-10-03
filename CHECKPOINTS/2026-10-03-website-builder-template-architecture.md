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


## 2026-10-03 banner title treatment and preview/public alignment

- The subscriber Website Builder banner is now treated as a single compact title banner rather than a template hero image.
- The builder no longer reuses the uploaded branding banner as the large template hero photograph; the separate homepage image remains the template hero image.
- The banner can be enabled/disabled and has a saved position setting: left, centre, or right (`homepage.banner_position`).
- Public-site rendering now reads `branding.banner_url` together with `homepage.use_banner` and displays the same compact banner treatment on the homepage hero title area.
- Public Buying and normal content pages also use the selected banner title treatment; Retail Shop already had its own banner treatment.
- Builder/public banner sizing has been reduced so the banner acts as a title treatment rather than dominating the page.
- Cache-busting was updated for the builder and public-site assets.
- TEST/main and LIVE/production were updated consistently for this repair. Browser verification remains required after refresh before treating the change as fully verified.
- Root cause found for the screenshot mismatch: the builder was rendering `branding.banner_url`, while the public homepage renderer was still using only `homepage.image_url` for its hero and therefore fell back to text instead of the branding banner.
