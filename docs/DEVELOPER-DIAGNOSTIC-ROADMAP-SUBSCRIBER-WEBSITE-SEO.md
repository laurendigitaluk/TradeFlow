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
