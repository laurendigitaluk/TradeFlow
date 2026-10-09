# TEST Retired Domain UI Cleanup — 9 October 2026

## Scope and environment
- Branch: `cleanup/test-retired-domain-ui-20261009`, based on `cloudflare-test`.
- Supabase project used by this branch's current frontend: TEST `twfbmjwwqzxdxvclxbun`.
- This is an isolated candidate branch only. It has not been deployed, merged, or applied to LIVE.

## Changes made in this branch
- Removed the retired `Buy a new domain` link and registrar-pricing/purchase copy from `domain-settings.html`.
- Replaced it with subscriber-owned-domain wording: subscribers buy/renew with their chosen registrar; TradeFlow connects domains they already own.
- Removed the four directly accessible legacy UI files: `domain-purchase.html/js` and `domain-registrant.html/js`.
- Left all Supabase Edge Functions, database rows, migrations and historical checkpoints untouched.

## Caller review
The main subscriber entry points inspected (`index.html`, `subscriber-dashboard.html`, `domain-settings.html/js`, `shipping-settings.js`, `buying-dashboard.js`, `platform-owner-dashboard.html`, `public-site.js`) contain no remaining references to the deleted domain-purchase/registrant pages or legacy purchase functions after the HTML CTA was removed. The old purchase JavaScript called the legacy Stripe/Porkbun endpoints, but those endpoints remain active in TEST Supabase and are not deleted by removing repository files.

## Blocking TEST architecture drift — do not deploy this branch yet
- The current TEST `domain-settings.js` is not equivalent to LIVE production. It directly inserts/patches `tenant_domains` rows and does not call the current `subscriber_request_custom_domain()` or `subscriber_get_custom_domain_status()` RPCs.
- Read-only TEST schema inspection found none of these current domain workflow RPCs: `subscriber_request_custom_domain`, `subscriber_get_custom_domain_status`, `platform_owner_list_domain_actions`, `platform_owner_update_domain_action`.
- TEST `platform-owner-dashboard.html/js` still shows legacy domain pricing/FX controls and does not contain the current owner domain-action workflow. This is inconsistent with the authoritative subscriber-owned-domain architecture documented in the LIVE manuals.
- The current TEST frontend therefore cannot be treated as a production-equivalent test copy. Do not deploy the UI cleanup or use this branch for domain-connection acceptance until the TEST code/schema is brought into alignment in a controlled migration/refresh plan.
- Do not blindly copy LIVE JS into TEST: replace environment-specific Supabase URL/key deliberately and apply/verify required migrations/RPCs first.

## Known legacy backend code retained
TEST Supabase still has active functions including `create-domain-checkout-session`, `porkbun-domain-availability`, `porkbun-domain-registration`, `porkbun-domain-registration-dry-run`, `save-domain-registrant`, `resellerclub-domain-availability`, `parcel2go-customer-shipping`, `parcel2go-subscriber-shipping`, and `shipping-provider-test`. The connector used for this audit does not expose Edge Function deletion. Do not invoke these legacy endpoints; preserve historical order/registrant data until their callers, secrets and dependencies have been reviewed.

## Next safe action
Treat LIVE `production` as the current source of truth. Plan a separate controlled TEST refresh from the current production architecture, including environment-specific Supabase configuration and the missing domain RPC/migration set. Keep this cleanup branch isolated until that refresh and regression tests are complete.
