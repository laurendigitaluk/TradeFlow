# Project Memory — 2026-10-09 Anonymous subscriber-domain routing deep audit

A LIVE anonymous test of `www.scenesource.co.uk` exposed a public-routing defect after the domain itself had already reached **Domain active · Primary**.

## Evidence
- `tradeflow.leannelaurenlowe.workers.dev/` correctly served the TradeFlow platform homepage.
- `www.scenesource.co.uk/` served the TradeFlow marketing homepage instead of the subscriber website.
- Production Worker source contained the intended vanity-domain root rewrite.
- Cloudflare production branch/deployment and `*/*` route were already present.

## Actual root cause
The Worker uses Cloudflare Static Assets with `assets.directory = "."`. Static assets are served asset-first unless `assets.run_worker_first` matches the request path.

Production `wrangler.jsonc` previously contained only:

```json
"run_worker_first": ["/*.js"]
```

Therefore the root request `/` could serve the repository's normal `index.html` directly without invoking `worker/index.js`. That exactly explains why the platform marketing page was returned even though the Worker source contained the correct subscriber-host routing logic.

## Repair
Production commit `40c08d470ee9c7778b4418bee07e5b89e56b3b3e` — **Fix Worker-first routing for application entry paths**.

`run_worker_first` now covers:
- `/`
- `/login`
- `/basket`
- `/assistant`
- `/email-confirmed`
- `/reset-password`
- `/owner-reset-password`
- `/platform-owner-dashboard.html`
- `/*.js`

This preserves selective Worker execution while allowing normal static assets to remain asset-first.

## Safety
Do not alter SceneSource DNS, Cloudflare custom-hostname/SSL state, Supabase domain records, domain activation, authentication, or the existing `*/*` route while this repair is being verified.

## Status
**Source/configuration repair committed. LIVE deployment and anonymous SceneSource verification pending.**

This supersedes the earlier narrower root-cause description that treated the problem solely as Worker hostname detection. The Worker hostname logic was correct; the Worker was not being invoked for the root static asset.


## 2026-10-09 follow-up audit
After the Worker-first routing repair, the anonymous SceneSource request began rendering the subscriber public-site application and Adventure Outpost/Action Outfit branding, proving the earlier marketing-page routing defect was repaired.

The rendered page was sparse/starter-like. A separate source audit found that `website-builder.js` contained a destructive migration rule: any draft with `template_reset_version < 2` was automatically cleared and replaced with the fresh starter template, even when a published revision already existed.

Repair commit: `f769bc17c0721b91fcc8d86c4f5bcf42de47c2fb` — **Prevent destructive website reset for existing subscribers**.

New rule: fresh-start initialisation occurs only when there is no published revision and no existing draft content. Existing subscriber content is loaded non-destructively.

No subscriber-specific content was fabricated or overwritten by this follow-up repair. The current public content remains whatever is actually stored in the published revision.

Status: domain routing repaired; destructive reset protection repaired; intended subscriber homepage content still requires final LIVE verification.



## 2026-10-09 second routing root cause — Cloudflare HTML handling

The first Worker-first repair correctly caused subscriber vanity traffic to reach `public-site.html`, but clean URL navigation still failed. Deep audit found that `worker/index.js` fetches `/public-site.html` through the `ASSETS` binding. Cloudflare's default `html_handling: auto-trailing-slash` applies to those asset-binding requests and canonicalises `/public-site.html` to `/public-site`. The browser therefore changed to `/public-site`, after which `public-site.js` correctly treated the unknown path as `home`.

This is why the earlier JavaScript clean-page mapping did not solve the observed behaviour: the browser was being redirected before the clean page route could be interpreted.

LIVE Supabase was audited directly. `published_site_index` has one public row for `www.scenesource.co.uk`, mapped to tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`; `tenant_domains` shows the hostname active and primary; public SELECT policy on `published_site_index` allows anonymous access. The database is not the cause of the current navigation defect.

Repair committed to production:
- `6a94244ec769a1d7f38aac29df0290a432cf1654` — `html_handling: none` and `run_worker_first: true`.
- `49c775fa30d2e5ea1fbad823e76e60e9acbc016e` — trailing-slash page normalisation.
- `ff8ce11cdd1d6ee6c6ce87970dc48a4eb5d2a03` — public-site JS cache refresh.

Status: **root cause identified and source repaired; browser verification pending the new Cloudflare deployment.**


## 2026-10-09 — Persistent loading screen: JavaScript syntax root cause

The later anonymous browser screenshot showed https://www.scenesource.co.uk/ itself, but only the static “Loading website…” shell appeared for hours. Production public-site.js had an invalid regular-expression literal in the trailing-slash normalisation line. The malformed expression used two backslashes before the slash; the corrected expression uses the escaped forward-slash form /\\/+$/ in JavaScript regex literal notation. Because the entire file could not parse, hostname lookup and Supabase loading never began.

Repair commits:
- c1e4952d7588e071dc5ce132030afbd0cca97b89 — corrected the malformed regex in public-site.js.
- 19aedd3cb17626834c1674999950488c9025a802 — bumped the script reference in public-site.html to public-site.js?v=26 to avoid a stale cached copy.

Status: source repaired; wait for the Cloudflare deployment to become Ready, then verify anonymously at the root URL. Do not alter DNS, SSL, domain activation, Supabase publication records, authentication or Cloudflare routes unless new evidence identifies one of those layers as failing.