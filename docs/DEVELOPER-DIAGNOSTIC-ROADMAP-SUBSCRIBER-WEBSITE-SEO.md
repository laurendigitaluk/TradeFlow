# Developer Diagnostic Roadmap — Subscriber Website SEO
Date: 30 October 2026
Status: Implemented in code; authenticated browser and deployment verification pending.

## User action and entry points
Subscriber opens Website Builder, selects Home or an internal page, edits SEO Settings in the Pages panel, saves draft, previews and publishes.

## Front-end files and functions
- `website-builder.html`: page shell and script loading.
- `website-builder.js`: `renderPageList()` selects pages; `renderPageManager()` renders SEO inputs; `loadContent()` restores homepage and per-page values; `buildContent()` serializes them; `saveDraft()` updates the draft; `publish()` invokes the existing publish RPC.
- `website-builder.css`: SEO panel styling.
- `public-site.js`: `applyContent()` resolves active-route metadata and sets document title, meta description, Open Graph title and description.

## Supabase data path
- Tables: `public.tenant_site_state`, `public.site_revisions`.
- Draft/published pointers: `tenant_site_state.draft_revision_id`, `published_revision_id`.
- Home JSONB: `site_revisions.content.site.homepage.seo_title`, `seo_description`.
- Other pages: `site_revisions.content.site.pages[]` fields `seo_title`, `seo_description`.
- Existing RPC: `public.publish_site_revision(p_tenant_id, p_revision_id)`.
- No new table, column, trigger, RLS policy, Edge Function or RPC is needed.

## Expected flow
Subscriber UI → builder state → `buildContent()` → draft `site_revisions.content` → `publish_site_revision` → public content loader → `applyContent()` → HTML head metadata.

## Failure points
Page selection not refreshing controls; draft load not refreshing controls; homepage fields mistakenly stored in `pages[]`; serializer omitting homepage SEO; public runtime using only business name; stale description after navigation; draft saved but not published.

## Known history and constraints
Per-page SEO keys existed in defaults and normalization, but were not exposed in the editor. Home is not a page object in `site.pages[]`; it is `site.homepage`. Preserve the locked standard website template and existing page content. Keep LIVE and TEST tenant data isolated. Scope excludes canonical URLs, robots directives, XML sitemap generation and structured data.

## Verification
Save/reload Home and internal-page SEO in TEST; publish; inspect title, description and Open Graph tags; navigate between pages to check stale metadata; confirm empty descriptions remove the tag; syntax-check both runtimes on both branches; confirm LIVE deployment separately.


### TEST/LIVE runtime endpoint correction — 30 October 2026
The Website Builder must use `window.TRADEFLOW_CONFIG.supabaseUrl` supplied by `subscriber-auth.js`; it must not hard-code the LIVE Supabase URL. The subscriber auth layer selects TEST (`nnsshnfkjcflucjrftzi`) on the TEST worker and LIVE (`gxsrajtqzdjvmceqcpgv`) on the production worker. A hard-coded LIVE URL caused the TEST builder to send TEST credentials to LIVE and prevented the TEST draft from loading. This is an environment-routing defect, not an SEO schema or tenant-data migration. Keep the two projects isolated and verify the TEST builder loads and saves against TEST only.


## LIVE server-rendered subscriber SEO — 30 October 2026

- LIVE Worker source change: `worker/index.js`, commit `8c441953c69d6c1b73e4a9593ba82f10a7cddf62` (production branch).
- On subscriber custom-domain requests routed to `/public-site.html`, the Worker now looks up exactly one row in the environment-specific `published_site_index`, filtered by the incoming hostname. It reads only the published `content` JSON and selects homepage SEO or the matching enabled page's SEO fields.
- The Worker injects the title, meta description, Open Graph title and Open Graph description into the initial HTML response. Values are HTML-escaped. If the lookup fails, the original HTML response is returned; existing `public-site.js` metadata handling remains as a client-side fallback.
- The lookup uses the Worker environment's matching Supabase URL/key (TEST variables on TEST, LIVE variables on production). It does not query all tenants, alter published content, or copy data between projects. Responses remain no-store.
- LIVE read-only verification before the code change: `published_site_index` contained the active hostname `www.scenesource.co.uk`, tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`, revision 7, published at `2026-10-30 22:25:54.985446+00`; homepage SEO title and description were both the agreed temporary value `test`. These values were not changed.
- The Cloudflare Production deployment visible around 30 minutes before the user's screenshot corresponded to commit `05cc0ff71eee93647bffacea1d55c68b9500bd34`; that commit changed documentation only and explicitly recorded no Worker deployment/code changes. It did not include this SEO implementation.
- New SEO code was committed to LIVE `production` at `8c441953c69d6c1b73e4a9593ba82f10a7cddf62`. Cloudflare's post-commit deployment and raw HTTP response still require verification. Do not describe this as live until the deployed Worker version and returned HTML are checked.
- Next verification: confirm Cloudflare Production deployed the new commit; request `https://www.scenesource.co.uk/` and inspect the raw response source for the title, description and OG tags; inspect an internal published page; confirm an unknown hostname or missing index row falls back safely; check no TEST data is read by production.


## Website Status Preview CTA correction — 30 October 2026

- The subscriber reported that the dark Preview website CTA beside Open Website Builder did not navigate, while the sidebar Preview website link worked.
- In `subscriber-website.html`, the central `#preview-link-main` control is now a real `button type=button` rather than an anchor. Its click handler explicitly navigates to the same tenant-scoped draft preview URL (`public-site.html?preview=draft&business=<slug>`) generated after subscriber authentication and tenant slug resolution.
- The sidebar preview link and dashboard preview tile remain ordinary links and retain their existing behavior. The action styling is covered by the existing `.actions button` CSS rule.
- LIVE production commit: `72c2a521dd2d1834afb98094d0456d85b6aa875f`.
- Deployment and browser click verification are still required; do not claim the button is fixed on the deployed site until tested after the production Worker/static asset update.
