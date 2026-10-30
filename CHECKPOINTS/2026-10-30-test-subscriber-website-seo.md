# TEST Subscriber Website SEO Settings Checkpoint — 30 October 2026

## Environment and branch
- Repository: `laurendigitaluk/TradeFlow`
- TEST branch: `cloudflare-test`
- TEST Cloudflare application: `tradeflow-test`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- LIVE branch: `production`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- Retired project `twfbmjwwqzxdxvclxbun` must not be used.

## Scope ported
The subscriber website SEO implementation from LIVE has been ported selectively into the current TEST builder. The whole LIVE builder was not copied because the branches contain substantial unrelated differences.

Files changed on TEST:
- `website-builder.js`: selected-page SEO controls, homepage SEO state, page-specific SEO state, persistence and draft restoration.
- `website-builder.css`: SEO panel styling.
- `website-builder.html`: builder script cache version increased to v68.
- `public-site.js`: page-specific document title, meta description, Open Graph title and description.
- System Handbook, AI Operating Manual, Backend User Manual and Subscriber Website Manual updated.

## Data contract
- Homepage: `site.homepage.seo_title`, `site.homepage.seo_description`.
- Individual pages: `site.pages[].seo_title`, `site.pages[].seo_description`.
- No database migration required; existing `site_revisions.content` JSON stores the settings.
- Blank description removes the relevant existing meta tag rather than leaving stale metadata.
- TEST builder retains its TEST Supabase endpoint. Do not copy LIVE endpoint values, keys or tenant data into TEST.

## Verification status
- GitHub commits exist on `cloudflare-test`.
- Static source inspection confirmed the SEO controls and persistence hooks are present.
- The TEST branch was not merged wholesale with `production`.
- Cloudflare deployment has NOT been confirmed from GitHub commits alone.
- Browser verification of TEST save, reload, publish and public metadata remains outstanding.
- Do not claim TEST is fixed until the TEST Cloudflare deployment is confirmed and browser tests pass.

## Required acceptance
1. Confirm `tradeflow-test` deploys from `cloudflare-test`.
2. Confirm the deployed builder requests `website-builder.js?v=68` or later.
3. Open Website Builder → Pages → Home page; verify SEO title and meta description controls appear.
4. Enter homepage SEO values, save draft, reload, and confirm values persist.
5. Select a custom page, set separate SEO values, save and reload.
6. Publish a TEST site and inspect title, description and Open Graph tags on Home and the custom page.
7. Verify all requests use TEST Supabase project `nnsshnfkjcflucjrftzi`.
8. Confirm no LIVE customer, tenant, published content, domain ownership or payment data has been changed.

## Safeguards
- Preserve existing TEST builder functionality.
- Do not merge divergent branches wholesale.
- Do not copy tenant/customer/transaction data between environments.
- Do not change LIVE Stripe or Cloudflare settings as part of this TEST repair.


## TEST Website Builder JavaScript parse repair — 30 October 2026

The TEST Website Builder was failing before its first website-data request. The first JavaScript parse failure was in the legacy editable homepage canvas helpers: `heroStyle()` and `renderHeroCanvasEditor()`. Literal backslashes had been added before template-literal delimiters and interpolation markers, making `website-builder.js` invalid JavaScript. This fault was already present in the parent of the 30 October SEO port; the SEO controls did not introduce it.

Minimal repair on `cloudflare-test`:
- Corrected the 16 escaped template-literal delimiters and 30 escaped interpolation markers in the affected canvas block.
- Re-ran a full-file JavaScript parse check successfully.
- Advanced `website-builder.html` from `website-builder.js?v=68` to `website-builder.js?v=69` to avoid the cached broken script.
- Commits: JavaScript `5836eb4ec0b4d4716008cea21098abf13d7d13ff`; HTML cache-bust `bbdcb94a930cbff02fb887db339448bd5afabd26`.

No Supabase schema, rows, tenant content, SEO values, LIVE code, Stripe settings or Cloudflare configuration were changed. TEST project `nnsshnfkjcflucjrftzi` remains the only database target. The TEST project has no structured memory/checkpoint table; this record is maintained in GitHub project documentation.

**Verification remains pending:** no GitHub deployment workflow is configured in this branch and a GitHub commit does not prove the Cloudflare Worker has updated. After the TEST Worker is deployed, confirm the builder serves v69, the browser console has no parse/runtime error, the first `tenant_site_state` request targets TEST, and Save Draft / SEO reload / Preview / Publish work. Do not change LIVE or copy tenant data.
