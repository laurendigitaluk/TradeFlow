# Website Builder Starter Template Lock — 2026-10-04

## Status
The production Website Builder starter layout is now the locked default template for new subscribers.

## Locked starter arrangement
- Left text box: x=6, y=7.131578947809846, width=47.093378607809846, height=32.868421052190154.
- Right image box: x=56, y=8.236842105263158, width=38, height=34.
- Lower full-width text box: x=0, y=53.68421052631579, width=70.44991511035653, height=28.
- Starter text boxes are blank on fresh subscriber creation; no placeholder copy is seeded.
- Subscriber logo/banner remains tenant-specific and authoritative.
- Default theme uses the approved starter palette.
- Shared top section / banner and page-builder controls are part of the reusable builder template; their styling is not tenant-specific.

## Fresh subscriber behaviour
loadDraft() calls resetToFreshWebsite() when the draft has not reached template_reset_version: 2, then saves the fresh starter content. The approved starter coordinates above are therefore the source template for a new subscriber.

## Integrity checks
- Production Website Builder JS is intact and approximately 160 KB.
- Production CSS is intact and approximately 133 KB.
- Production HTML is intact at 5,588 bytes.
- Builder cache versions: CSS v95, JS v122.
- No raw dead application links were found in the builder. The two href="#" values are preview-only controls intercepted by [data-nav-page] click handlers.
- Referenced builder pages were verified present in production: settings.html, buying-catalogue.html, subscriber-website-manual.html, selling-dashboard.html, customer-dashboard-preview.html, public-site.html.
- Removed the starter lower-box placeholder Edit this text; fresh subscribers now receive blank starter text boxes.

## Important
This locks the starter arrangement as the reusable default. It does not prevent a subscriber from moving/resizing/editing elements after signup; it defines the starting state before their edits.