# Checkpoint — LIVE Server-Rendered Subscriber SEO
Date: 30 October 2026

## Scope
Enable subscriber SEO metadata in the initial HTML response for published custom-domain websites. No tenant website content or database schema was changed.

## Environment
- LIVE GitHub branch: `production`.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- TEST Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE hostname read before change: `www.scenesource.co.uk`.
- LIVE tenant: `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`.
- Published revision: 7, published at `2026-10-30 22:25:54.985446+00`.
- Homepage SEO title and description: `test` / `test` (user-confirmed temporary placeholders; left unchanged).

## Deployment history reconciliation
The Cloudflare Production screenshot showed a deployment approximately 30 minutes before 22:59 UTC, titled “Log further Xbox 360 500GB sold-listing research”. It matched GitHub commit `05cc0ff71eee93647bffacea1d55c68b9500bd34` (23:00:06 UTC). Its diff changed documentation only and stated no Worker/application code or deployment changes. It did not contain the SEO runtime fix.

## Implementation
- Initial implementation commit: `8c441953c69d6c1b73e4a9593ba82f10a7cddf62`.
- Follow-up correction commit: `02dbc30fa8c6bde9d723fa25d179e685e864dfa2`; public REST lookup sends the Supabase publishable key in the `apikey` header only, matching the existing public-site client pattern (no Bearer token).
- File: `worker/index.js` only.
- Subscriber custom-domain HTML requests routed to `/public-site.html` now look up exactly one `published_site_index` row by incoming hostname, using the Worker environment's corresponding Supabase URL/key.
- The Worker reads only that row's published content, resolves homepage or enabled page SEO, HTML-escapes values, and inserts title, description and Open Graph title/description into the initial response.
- Lookup failures return the original response. Existing client-side SEO behavior remains as fallback. Response cache-control remains no-store.
- No SQL, tenant data, published website content, authentication, Stripe, builder UI or TEST data was modified.

## Documentation updated
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `docs/DEVELOPER-DIAGNOSTIC-ROADMAP-SUBSCRIBER-WEBSITE-SEO.md`

## Verification still required
1. Confirm Cloudflare Production deployed commit `8c441953c69d6c1b73e4a9593ba82f10a7cddf62` (or a later production build containing it).
2. Fetch raw HTML from `https://www.scenesource.co.uk/` and confirm the title, meta description and Open Graph tags are present before JavaScript executes.
3. Verify at least one published internal page uses its own SEO values.
4. Confirm a missing hostname mapping safely returns generic HTML and production never falls back to TEST data.
5. Run a Worker syntax/build check and inspect deployment logs for errors.

Do not mark this checkpoint fully verified or claim the SEO feature is live until steps 1–4 pass.
