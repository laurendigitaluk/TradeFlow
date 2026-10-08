# Project Memory — 2026-10-08 Anonymous subscriber-domain routing defect

A LIVE anonymous test of `www.scenesource.co.uk` exposed a final public-routing defect after the domain itself had already reached **Domain active · Primary** in the subscriber workspace.

Observed:
- Authenticated subscriber workspace: domain active.
- Incognito/customer request to `www.scenesource.co.uk/`: TradeFlow platform landing page appeared instead of the subscriber homepage.

Root cause:
The public-site application already resolves subscriber content by request hostname through `published_site_index`. The Worker root-path boundary was not safely distinguishing platform-owned hosts from subscriber vanity hosts.

Repair:
Production commit `8309776842514f707eb5e6ef08a800a887668d77` — `Route subscriber vanity domains to public website`.

Rule:
- Platform hosts retain the normal TradeFlow application root.
- Subscriber vanity hosts rewrite `/` to `/public-site.html`.
- Public-site JavaScript then resolves the tenant from the actual hostname.

Do not change SceneSource DNS, Supabase domain state, SSL/custom-hostname state or activation while this routing repair is being deployed/verified.

Status: source repair committed; anonymous LIVE browser verification pending.