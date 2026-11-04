# Public pages and image-led examples checkpoint — 4 November 2026

- TEST PR #223 merged to `cloudflare-test` at `f0ec1da8c3ffb39b0df545a22279fa8fe278e9bd`.
- LIVE PR #225 merged to `production` at `2f5b8e1c24c1400c0eae10e8a6f53627b6eada60`.
- Public guide links now target `how-it-works.html`; About/Facts removed from navigation; legacy `facts.html` redirects to How It Works.
- Added `contact-us.html`; official email/company details remain unpublished pending verification.
- Examples renderer presents Card Vault (Pokémon Charizard card), Shutter House (Sony Alpha 7 IV), Altitude Drones (DJI Mini 4 Pro), and Next Level Gaming (PlayStation 5), with four distinct palettes and product imagery.
- Plans copy matches signup: £59.99 monthly / £499.99 annually after the 30-day trial. Stripe was not changed.
- Examples remain rendered by `platform-public-pages.js`; retain the owner editor `visual_layout` path. Current product image URLs are external, not stored in Supabase Storage.
- No `platform_public_pages` rows, Supabase schema, tenant/customer/order/payment data or Stripe settings were changed.
- Cloudflare deployment and browser acceptance are still unverified. Verify both environments before reporting the website live.
