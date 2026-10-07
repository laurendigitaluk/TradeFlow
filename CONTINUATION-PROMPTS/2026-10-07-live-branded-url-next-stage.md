# TradeFlow Continuation Prompt — 2026-10-07 — Continue From LIVE Branded URL

Continue TradeFlow from the verified current production state. Do not reconstruct the previous domain/Worker setup.

## Current LIVE state

- Repository: `laurendigitaluk/TradeFlow`
- LIVE branch: `production`
- Existing LIVE Worker: `tradeflow`
- LIVE platform URL: `https://tradeflow.laurendigital.co.uk`
- Parent/company domain: `laurendigital.co.uk`
- Cloudflare zone is active.
- TradeFlow Custom Domain is connected to the existing `tradeflow` Worker.
- Public homepage, subscriber Sign In and Adventure Outpost Business Dashboard have been browser-verified.

## URL rule

`tenant_id` remains the internal tenant/security identifier.

Do not remove or replace it in database, RLS, authentication or internal API logic.

Normal subscriber-facing browser URLs should use a business slug rather than exposing the raw tenant UUID where possible. Example:

`Adventure Outpost` → `adventure-outpost`

The subscriber workspace removes the legacy `tenant_id` query parameter from the visible URL after authenticated tenant context is established.

## Brand/domain architecture

Lauren Digital is the parent/company brand.

- `laurendigital.co.uk` = future Lauren Digital parent/company website.
- `tradeflow.laurendigital.co.uk` = TradeFlow platform.
- Future Lauren Digital products may use their own subdomains when ready.
- Subscriber-owned customer domains remain separate and use the existing connection/verification workflow.

Do not turn the parent domain into a subscriber tenant.

## Future parent site

A Lauren Digital parent homepage with links to TradeFlow and future products is planned.

A separate owner-only login page may be used in the future, but hidden URLs are not a security boundary. Existing authentication and Platform Owner permission checks remain mandatory.

Do not implement the parent homepage or owner login as part of unrelated TradeFlow fixes unless explicitly instructed.

## Mandatory working method

Before any change:
1. Read the latest checkpoint and manuals.
2. Inspect current production GitHub.
3. Inspect relevant LIVE Supabase state.
4. Identify the first actual failure or missing boundary.
5. Make the smallest necessary change.
6. Test.
7. Verify.
8. Update manuals, project memory and checkpoint.

Do not revive:
- retired TradeFlow/Porkbun subscriber domain registration;
- Parcel2Go API shipping;
- obsolete TEST customer URL workarounds;
- raw tenant UUIDs as normal subscriber-facing URL identifiers.

