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


## 2026-10-09 deep audit — second routing defect identified and repaired

The previous selective `run_worker_first` repair did not fully solve clean public-page navigation. A deeper audit of Cloudflare Static Assets behaviour and the Worker's internal `env.ASSETS.fetch()` path identified the missing interaction.

### Actual second root cause
`worker/index.js` internally rewrites subscriber routes such as `/`, `/buying`, `/sell`, `/shop`, `/about` and `/contact` to the static asset `/public-site.html`.

Production Wrangler was still using Cloudflare's default `html_handling: "auto-trailing-slash"`. Cloudflare's asset binding applies HTML handling to requests made through `env.ASSETS.fetch()`. Under that mode, a direct `/public-site.html` asset request is canonicalised to `/public-site` with a redirect. The Worker was therefore returning a redirect to `/public-site` instead of returning the public-site shell at the originally requested clean URL.

That explains the observed behaviour:
- `/` could become `/public-site`;
- the public-site application then loaded its homepage because `/public-site` is not one of the clean page slugs;
- clicking What We Buy/About/Contact could therefore appear to return to the same homepage instead of remaining on the requested clean route.

This was a routing/asset-handling interaction, not a Supabase tenant-data failure.

### LIVE database audit
LIVE Supabase project `gxsrajtqzdjvmceqcpgv2` is healthy. The `published_site_index` contains exactly one published row for `www.scenesource.co.uk`, mapped to tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`. `tenant_domains` contains the same hostname as `active` and `is_primary=true`. `published_site_index` permits public/anonymous SELECT. This confirms the tenant/domain publication data is present and publicly readable; no database repair is justified for this defect.

### Second repair
Production `wrangler.jsonc` was changed to:

```json
"html_handling": "none",
"run_worker_first": true
```

Commit: `6a94244ec769a1d7f38aac29df0290a432cf1654` — **Correct Worker-first routing configuration**.

`html_handling: "none"` prevents the internal `/public-site.html` asset fetch from generating the unwanted canonical redirect. `run_worker_first: true` makes the Worker own application routing before static-asset matching, removing path-pattern gaps from the public clean URL boundary. Normal assets are still returned through the existing `ASSETS` binding.

The public-site JavaScript was also cache-bumped and made tolerant of trailing slashes:
- `49c775fa30d2e5ea1fbad823e76e60e9acbc016e` — **Handle trailing-slash clean subscriber page routes**
- `ff8ce11cdd1d6ee6c6ce87970dc48a4eb5d2a03` — **Refresh public-site JavaScript asset version**

### Verification state
The code/configuration repair is committed to production. The screenshot supplied after the repair still shows the browser on the older `/public-site` URL and the Cloudflare deployment in progress, so this repair is **not yet browser-verified**.

Next verification must start with a fresh anonymous request to `https://www.scenesource.co.uk/` after the new deployment is Ready. Expected: the address remains `/`, SceneSource renders, What We Buy becomes `/buying`, Retail Shop `/shop`, About `/about`, Contact `/contact`, and Sell to us `/sell` without returning to `/public-site`.

Do not change DNS, Cloudflare custom-hostname/SSL, Supabase domain records, activation, authentication, or the existing SaaS `*/*` route.

## 2026-10-09 — Root cause of persistent “Loading website…” screen

The user's later browser screenshot showed the clean root URL https://www.scenesource.co.uk/ but the page remained on the static “Loading website…” screen for hours. This differs from the earlier /public-site redirect.

Production public-site.js contained a malformed regular-expression literal in trailing-slash normalisation: the slash was incorrectly escaped, making the expression invalid JavaScript syntax. The corrected source expression is /\\/+$/ in the JavaScript regex literal notation (one escaped forward slash followed by +$). This parse-time error prevents the entire public-site controller from executing. Consequently, hostname resolution and the Supabase query never started, leaving the static loading shell visible. The LIVE publication was present, so no database change was warranted.

Repairs committed to production:
- c1e4952d7588e071dc5ce132030afbd0cca97b89 — Fix public website startup regex syntax.
- 19aedd3cb17626834c1674999950488c9025a802 — Refresh public-site script after startup fix; public-site.html now loads public-site.js?v=26 to bypass the cached invalid script.

Status: source repaired; browser verification is still required after the Cloudflare deployment. Do not change DNS, SSL, domain activation, Supabase records, authentication, or the existing Cloudflare route for this client-side parse failure. Wait for deployment to show Ready, then test the root URL anonymously. If the loading shell remains, inspect the first Console/Network error before making further changes.

## 2026-10-09 — Platform root 404 introduced by disabled HTML fallback

The screenshot after setting Cloudflare Static Assets to `html_handling: "none"` showed `https://tradeflow.laurendigital.co.uk/` returning 404. With HTML handling disabled, the Worker must explicitly map the platform-owned root path to `/index.html`; the previous code only explicitly mapped the subscriber-owned root to `/public-site.html` and had relied on Cloudflare's automatic index fallback for the platform root.

Repair committed to production: `adf0021c25a95fc39c46587dbde98a0af6ef654a` — `Restore platform homepage with explicit index routing`. `worker/index.js` now maps `/` to `/index.html` for platform-owned hostnames, while subscriber vanity domains continue to map `/` to `/public-site.html`.

Status: code committed; wait for Cloudflare deployment to become Ready, then verify both `https://tradeflow.laurendigital.co.uk/` and `https://www.scenesource.co.uk/`. Do not change DNS, SSL, Supabase or the existing SaaS route.