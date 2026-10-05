# LOCKED CHECKPOINT — Standard Website Builder Template — 2026-10-05

## Status
LOCKED BASELINE / POINT SET for the standard company/service subscriber website.

This is the approved starting template for future new subscribers and the reusable standard website template for TradeFlow. No further visual, layout, positioning, sizing, or structural changes should be made unless the user explicitly reopens this baseline.

## Purpose
This template is intended to be reusable for ordinary company/service websites, with:
- Home page
- Standard internal pages
- Reusable content/image/text/button/tile structures
- Subscriber-editable content
- Existing TradeFlow Edit → Save Draft → Preview → Publish → LIVE lifecycle

The style system is NOT the basis of this locked arrangement. The approved editable layout itself is the starting point.

## Locked Home / Top Section
The approved starter arrangement is preserved in `resetToFreshWebsite()`:
- Left text box: x 6, y 7.131578947809846, width 47.093378607809846, height 32.868421052190154
- Right image box: x 56, y 8.236842105263158, width 38, height 34
- Lower text box: x 0, y 53.68421052631579, width 70.44991511035653, height 28
- Starter text boxes are blank.
- Subscriber branding remains tenant-specific.
- Starter state uses `template_reset_version: 2`.

## Locked Page Structures
Default pages remain:
- Home
- What We Buy
- Retail Shop
- About
- Contact
- Customer Account

Buying and Shop pages retain the standard tile structure/capacity. Homepage retains the What We Buy and What We Sell sections and their tile system.

## Locked Builder Controls
The Shared top section and Top of page controls are intentionally retained as part of the approved builder:
- Add text box
- Add image box
- Add call-to-action button
- Add logo
- Add banner
- Text
- Font
- Size
- Text colour
- Line spacing
- Letter spacing
- Border
- Border width
- Border colour
- Round corners
- Background colour where applicable

The toolbars use the approved light neutral treatment with orange-accented control borders.

## Locked Banner / Image / Button Behaviour
- Shared banner area remains directly under the Shared top section controls.
- Image boxes, text boxes, CTA buttons and tiles retain their approved positions and proportions.
- Uploaded image proportions must not be replaced by arbitrary fixed cropping.
- CTA/link controls remain editable for subscribers.

## Links
Builder links are intentional, not dead placeholders. Internal links use TradeFlow page destinations; custom links use validated HTTP/HTTPS destinations. Do not replace working routing with arbitrary `href="#"` placeholders.

## New Subscriber Rule
A new subscriber must receive this approved starting arrangement. The starter reset must not be redesigned or repositioned as part of ordinary subscriber onboarding.

Existing subscriber drafts must not be overwritten simply by opening/reloading the builder. Draft lifecycle remains Save Draft controlled.

## Reuse Rule
When building future standard company/service websites, reuse this locked template as the baseline rather than designing a new builder arrangement from scratch. Future product-specific templates may be separate and must not silently alter this baseline.

## Current production verification
Production Website Builder files were inspected after the final toolbar corrections. Current production contains:
- `resetToFreshWebsite()`
- `template_reset_version: 2`
- Shared top section toolbar
- Shared text formatting menu
- No obsolete `builder-menu-ad-space`
- Light toolbar styling
- Orange control borders
- Current builder HTML references the current CSS/JS assets

## Rule
This checkpoint is the restore/reference point. Any future change to the standard website builder must first state why it is required and explicitly acknowledge that it is reopening the locked baseline.
