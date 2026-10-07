# Project Memory — 2026-10-07 — LIVE URL, Business Slugs and Lauren Digital Architecture

## Current LIVE platform

The LIVE TradeFlow application is now available at:

`https://tradeflow.laurendigital.co.uk`

This is the existing `tradeflow` Cloudflare Worker connected to the active `laurendigital.co.uk` Cloudflare zone through a Worker Custom Domain. No second Worker was created.

Browser verification completed:
- branded TradeFlow public homepage loads over HTTPS;
- Sign In works;
- the existing Adventure Outpost subscriber account authenticates;
- the Adventure Outpost business workspace loads.

## Tenant UUID / URL rule

The internal `tenant_id` remains the authoritative tenant/security identifier and must continue to be used internally for Supabase tenant scoping, authentication state, RLS and database/API calls.

Normal subscriber-facing browser URLs should not expose the raw tenant UUID where a stable business slug can be used.

Current example:

`Adventure Outpost` → `adventure-outpost`

The subscriber workspace resolves the tenant slug and removes the legacy `tenant_id` query parameter from the visible browser URL after the authenticated tenant context is established.

This is a URL presentation/routing improvement only. It does not replace the internal tenant UUID or weaken tenant isolation.

## Lauren Digital / TradeFlow brand architecture

Lauren Digital is the parent/company brand. TradeFlow is a product of Lauren Digital.

Planned structure:
- `laurendigital.co.uk` — Lauren Digital parent/company website.
- `tradeflow.laurendigital.co.uk` — LIVE TradeFlow platform.
- Future Lauren Digital products may receive their own subdomains when ready.

A future Lauren Digital parent homepage and separate owner-only login route are planned architecture, not current implementation scope.

## Domain ownership rule

Subscriber-owned domains remain the approved customer-domain architecture. TradeFlow does not purchase or renew subscriber domains.

The subscriber-owned domain workflow remains:

subscriber owns domain → Website URL request → Platform Owner connection preparation → exact DNS instructions → subscriber DNS change → DNS/SSL/routing verification → activation.

The platform infrastructure domain `laurendigital.co.uk` was purchased directly through Porkbun by Lauren Digital and is separate from subscriber-owned domains.

## Documentation updated

The current working documentation was updated to reflect this state:
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `TRADEFLOW-MASTER-ROADMAP.md`
- `subscriber-website-manual.html`

The current continuation prompt and checkpoint record the same architecture.

## Guardrails

Do not:
- replace internal tenant UUIDs in database/RLS/authentication logic;
- expose raw tenant UUIDs unnecessarily in subscriber-facing URLs;
- create another Worker for TradeFlow;
- use `laurendigital.co.uk` as a subscriber tenant;
- revive the retired TradeFlow/Porkbun subscriber domain-purchase workflow;
- redesign the locked Website Builder as part of this URL change.

Next development should continue from the verified branded LIVE platform rather than reconstructing the old Worker/domain arrangement.
