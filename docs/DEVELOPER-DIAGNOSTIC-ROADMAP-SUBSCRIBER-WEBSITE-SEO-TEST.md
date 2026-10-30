# Developer Diagnostic Roadmap — Subscriber Website SEO (TEST)
**Updated:** 30 October 2026

## Environment map
- TEST GitHub: `laurendigitaluk/TradeFlow` branch `cloudflare-test`.
- TEST Cloudflare app/Worker: `tradeflow-test`.
- TEST Supabase: `nnsshnfkjcflucjrftzi`.
- LIVE branch: `production`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- Retired TEST project: `twfbmjwwqzxdxvclxbun` — never use.

## User action and front-end entry points
- Subscriber opens Website Builder and selects a page in the Pages list.
- Builder entry: `website-builder.html`.
- Builder logic: `website-builder.js`, especially `renderPageManager()`, `selectPage()`, `buildContent()`, and `loadContent()`.
- Styling: `website-builder.css`.
- Published rendering: `public-site.js`, especially `applyContent()`.

## Data flow
1. Page selection refreshes the SEO panel for the selected page.
2. Input handlers update homepage SEO state or the selected `pages[]` object and mark the draft dirty.
3. `buildContent()` serialises homepage values under `site.homepage.seo_title` and `site.homepage.seo_description`; page values remain on `site.pages[].seo_title` and `site.pages[].seo_description`.
4. Existing draft revision persistence stores the content JSON in `site_revisions.content`; no schema migration is required.
5. `loadContent()` restores homepage SEO values and page objects retain their SEO properties.
6. Published `public-site.js` applies the selected page title, meta description, Open Graph title and description.

## Environment safeguards
- TEST must use only `nnsshnfkjcflucjrftzi`.
- LIVE must use only `gxsrajtqzdjvmceqcpgv`.
- Keep tenant, customer, published content, custom domain, ownership and transaction records isolated.
- Do not merge `production` and `cloudflare-test` wholesale; they are divergent.
- Do not change LIVE Stripe configuration during TEST repair.

## Failure investigation order
1. Confirm Cloudflare TEST deployment is sourced from `cloudflare-test`.
2. Inspect deployed HTML script version and loaded builder JS.
3. Check browser console for the first JavaScript exception.
4. Check network requests for TEST Supabase host only.
5. Check draft load and save against TEST `site_revisions`.
6. Check publish route and public-site metadata.
7. Compare deployed asset version with current GitHub commit.

## Known state at checkpoint
SEO code and documentation have been ported to `cloudflare-test`. Cloudflare deployment and authenticated browser acceptance are still outstanding. GitHub commit presence alone does not prove the TEST Worker is updated.


## TEST Website Builder JavaScript parse repair — 30 October 2026

The TEST Website Builder was failing before its first website-data request. The first JavaScript parse failure was in the legacy editable homepage canvas helpers: `heroStyle()` and `renderHeroCanvasEditor()`. Literal backslashes had been added before template-literal delimiters and interpolation markers, making `website-builder.js` invalid JavaScript. This fault was already present in the parent of the 30 October SEO port; the SEO controls did not introduce it.

Minimal repair on `cloudflare-test`:
- Corrected the 16 escaped template-literal delimiters and 30 escaped interpolation markers in the affected canvas block.
- Re-ran a full-file JavaScript parse check successfully.
- Advanced `website-builder.html` from `website-builder.js?v=68` to `website-builder.js?v=69` to avoid the cached broken script.
- Commits: JavaScript `5836eb4ec0b4d4716008cea21098abf13d7d13ff`; HTML cache-bust `bbdcb94a930cbff02fb887db339448bd5afabd26`.

No Supabase schema, rows, tenant content, SEO values, LIVE code, Stripe settings or Cloudflare configuration were changed. TEST project `nnsshnfkjcflucjrftzi` remains the only database target. The TEST project has no structured memory/checkpoint table; this record is maintained in GitHub project documentation.

**Verification remains pending:** no GitHub deployment workflow is configured in this branch and a GitHub commit does not prove the Cloudflare Worker has updated. After the TEST Worker is deployed, confirm the builder serves v69, the browser console has no parse/runtime error, the first `tenant_site_state` request targets TEST, and Save Draft / SEO reload / Preview / Publish work. Do not change LIVE or copy tenant data.
