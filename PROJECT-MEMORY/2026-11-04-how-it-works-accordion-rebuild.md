# Project memory — How It Works accordion rebuild — 4 November 2026

The user rejected the screenshot-based public How It Works page and the visual page canvas. The agreed design is a simple accordion page matching the TradeFlow landing page, with no screenshots or illustrative media and a link to GearCashOut.co.uk as an example.

Implementation is isolated on:
- LIVE branch: `feature/how-it-works-accordion-live-20261104` (base `production`).
- TEST branch: `feature/how-it-works-accordion-test-20261104` (base `cloudflare-test`).

The page is now static source-managed HTML/CSS. Public renderer bypasses How It Works so the old `platform_public_pages` visual layout cannot overwrite it. The owner visual page editor is limited to Examples. Existing How It Works database records remain unchanged for audit continuity; no Supabase migration or data write is required.

The ten sections explain subscription (£59.99/month after 30-day trial), website template, Website Builder, catalogue/AI research, Stripe payment connection, valuation/offers, customer payment, manual shipping, inventory/retail sales and day-to-day dashboard. The copy distinguishes platform subscription billing from retail customer payments, says customer payouts are made by the business (not automatic), and says courier booking/payment occurs outside TradeFlow.

Do not mark this complete until PRs are reviewed/merged, both Workers are verified against the intended branch commits, and public pages are checked in browser on desktop and mobile. Keep TEST and LIVE data isolated.
