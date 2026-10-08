# Checkpoint — 2026-10-08 anonymous subscriber-domain routing repair

## Current test
LIVE subscriber-owned domain:
- Hostname: `www.scenesource.co.uk`
- Subscriber: Adventure Outpost
- Subscriber dashboard previously showed: **Domain active · Primary**
- Authenticated subscriber workspace is functioning.

## New defect found
An anonymous/incognito browser request to `https://www.scenesource.co.uk/` did **not** render the subscriber public homepage. It rendered the TradeFlow platform landing page instead.

This is a different boundary from the domain-connection workflow itself:
- domain ownership/connection state is already active;
- subscriber Website URL reports the domain active;
- the public-site application code already contains hostname-based lookup against `published_site_index`;
- the failing boundary is the Worker's root-path asset selection for a subscriber vanity hostname.

## Root cause identified in production source
`worker/index.js` had root-path rewriting mixed into the general route table. The correct architecture is:
- platform-owned hosts keep the normal TradeFlow application homepage;
- subscriber-owned vanity hosts rewrite only `/` to `/public-site.html`;
- `public-site.js` then resolves the tenant using the actual request hostname.

## Repair committed
Production commit:
`8309776842514f707eb5e6ef08a800a887668d77`

Commit message:
`Route subscriber vanity domains to public website`

The repair explicitly recognises platform hosts:
- `tradeflow.laurendigital.co.uk`
- `tradeflow.leannelaurenlowe.workers.dev`
- `tradeflow-test.leannelaurenlowe.workers.dev`
- `laurendigital.co.uk`
- `www.laurendigital.co.uk`
- localhost/127.0.0.1

Only non-platform, non-GitHub-Pages hostnames are treated as subscriber vanity domains for the root rewrite.

## Safety
Do not change:
- SceneSource DNS;
- Cloudflare custom-hostname/SSL state;
- Supabase tenant/domain records;
- domain activation state.

Do not add an unconditional `/` → `public-site.html` rewrite, because that would risk breaking the TradeFlow platform root.

## Verification still required
The source repair is committed but must not be called LIVE-verified until the Cloudflare production deployment is confirmed and an anonymous/incognito request to `www.scenesource.co.uk` shows the SceneSource subscriber homepage.

If it still shows the TradeFlow landing page after the new deployment, inspect the Cloudflare Worker route/deployment boundary next; do not make further application/database changes blindly.

## Documentation state
This checkpoint supersedes any earlier statement that the anonymous customer-facing custom-domain homepage was fully verified. The authenticated domain status remains verified; anonymous public-host routing is now a separate pending verification item.
