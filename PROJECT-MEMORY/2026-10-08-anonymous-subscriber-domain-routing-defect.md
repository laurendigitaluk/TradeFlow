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
