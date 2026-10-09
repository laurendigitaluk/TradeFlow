# Checkpoint — 2026-10-09 anonymous subscriber-domain routing deep audit and fix

## LIVE test
Subscriber-owned domain:
- Hostname: `www.scenesource.co.uk`
- Subscriber: Adventure Outpost
- Domain state previously verified as **active · Primary**
- Authenticated subscriber workspace functioning.

## Observed defect
An anonymous/incognito request to `https://www.scenesource.co.uk/` was still returning the TradeFlow marketing homepage instead of the SceneSource subscriber public website.

The same Worker URL:
`https://tradeflow.leannelaurenlowe.workers.dev/`
correctly returned the TradeFlow platform homepage.

This established that the Worker deployment itself was healthy and that the remaining failure was at the static-assets/Worker execution boundary.

## Deep audit finding — actual root cause
Production source `worker/index.js` already contained the correct subscriber-host routing rule:
- platform-owned hostnames keep the TradeFlow application root;
- non-platform vanity hostnames rewrite `/` to `/public-site.html`;
- `public-site.js` resolves the tenant from the request hostname.

However, production `wrangler.jsonc` configured:

```json
"run_worker_first": [
  "/*.js"
]
```

Cloudflare Workers Static Assets are asset-first by default. When the requested path matches a static asset, Cloudflare can serve that asset without invoking the Worker unless `run_worker_first` matches the path. Therefore the root request `/` could serve the repository's normal `index.html` directly, bypassing the Worker code that was supposed to rewrite subscriber vanity-domain root requests to `public-site.html`.

This explains the exact symptom:
- browser requested `www.scenesource.co.uk/`;
- document returned the TradeFlow marketing HTML;
- the Worker hostname-based root rewrite never had an opportunity to run.

## Repair committed
Production commit:
`40c08d470ee9c7778b4418bee07e5b89e56b3b3e`

Commit message:
`Fix Worker-first routing for application entry paths`

Production `wrangler.jsonc` now invokes the Worker first for:
- `/`
- `/login`
- `/basket`
- `/assistant`
- `/email-confirmed`
- `/reset-password`
- `/owner-reset-password`
- `/platform-owner-dashboard.html`
- existing `/*.js` transformation path

This is a selective routing repair, not an unconditional Worker-first rule for every static asset.

## Safety
No changes were made to:
- SceneSource DNS;
- Cloudflare custom-hostname/SSL state;
- Supabase domain records;
- domain activation state;
- authentication;
- the existing `*/*` Cloudflare route.

The platform hostname protection in `worker/index.js` remains intact, so `laurendigital.co.uk` and the TradeFlow Worker host continue to use the platform homepage.

## Verification status
The source/configuration repair is committed and awaiting the Cloudflare production deployment.

Do not call the anonymous LIVE workflow fully verified until:
1. the new production deployment is Ready;
2. `https://www.scenesource.co.uk/` is tested anonymously/incognito;
3. the document served is the subscriber public-site shell;
4. SceneSource subscriber content renders;
5. the platform homepage still works on `tradeflow.leannelaurenlowe.workers.dev` and the branded TradeFlow host.

If the anonymous SceneSource test still fails after this deployment, inspect the actual response and Cloudflare custom-hostname invocation boundary rather than repeating the earlier dashboard checks.

## Cloudflare documentation basis
Cloudflare's current Static Assets documentation states that matching static assets are served without invoking Worker code by default, and that `assets.run_worker_first` is the control for invoking Worker code before static asset serving. Cloudflare's Workers-as-fallback-origin documentation separately confirms that the `*/*` zone route is the correct mechanism for custom-hostname traffic.

Status: **deep-audit source fix committed; LIVE verification pending deployment.**


## Follow-up finding from anonymous public-site verification — 2026-10-09
The anonymous request now reaches the subscriber public-site application rather than the TradeFlow marketing homepage. The browser showed the Adventure Outpost/Action Outfit branding and subscriber navigation, confirming the Worker-first root routing repair is functioning.

A second issue was then visible: the published page content is currently a starter/fresh layout with empty hero content rather than populated subscriber copy. Source audit found a separate destructive behaviour in `website-builder.js`: any existing draft with `template_reset_version < 2` was automatically cleared and replaced with the fresh starter template, regardless of whether the subscriber already had a published revision.

## Follow-up repair
Production commit:
`f769bc17c0721b91fcc8d86c4f5bcf42de47c2fb`

Commit message:
`Prevent destructive website reset for existing subscribers`

The builder now initialises the fresh starter template only when there is **no published revision and no existing draft content**. Existing subscribers/drafts are loaded non-destructively, including older content versions.

This repair does not invent or restore subscriber-specific content. Existing published/draft data must remain the source of truth.

## Current status
1. Vanity-domain root routing: source/configuration repaired and browser now reaches subscriber public-site rendering.
2. Domain/SSL/activation: unchanged and previously verified.
3. Existing-subscriber website data: destructive reset protection repaired.
4. SceneSource/Adventure Outpost published content: not modified or fabricated by this audit. The current browser result shows the data currently published is sparse/starter content.

Do not mark the final custom-domain acceptance complete until the intended subscriber homepage content is confirmed on the anonymous root URL.
