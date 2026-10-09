# TradeFlow LIVE — Full System Audit Checkpoint

**Date:** 9 October 2026  
**Environment:** LIVE production, with TEST used only for comparison  
**Repository:** `laurendigitaluk/TradeFlow`  
**Branch inspected:** `production`  
**LIVE Supabase:** `gxsrajtqzdjvmceqcpgv`  
**TEST Supabase:** `twfbmjwwqzxdxvclxbun`

## Scope and safety

This was a read-only audit of current LIVE Supabase state, current production code and deployment configuration, the existing continuation checkpoint, the AI Operating Manual, System Handbook, Backend User Manual, Human User Manual, Master Roadmap and subscriber Website Manual. No customer accounts were created. No rows, authentication data, subscriptions, domain records, DNS, Cloudflare settings, Edge Functions or published content were changed.

## Verified account state

- LIVE Supabase project `gxsrajtqzdjvmceqcpgv` is `ACTIVE_HEALTHY` in `eu-west-2`. The invalid reference `gxsrajtqzdjvmceqcpgv5` in older manual passages has been corrected in the Markdown operating documents.
- Adventure Outpost tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`, slug `adventure-outpost`, is active.
- LIVE Auth contains 2 non-deleted users, with 2 confirmed users. There is 1 platform-owner membership and 1 active Adventure Outpost subscriber membership.
- LIVE `public.customers` contains 0 records overall and 0 records linked to a customer login for Adventure Outpost. No SceneSource website customer login has been verified or created. Subscriber/business customer records must not be mistaken for public website customer authentication accounts.
- The customer registration UI exists in `customer-auth.js`; it signs up through Supabase Auth and then calls `customer_register_for_tenant`. The RPC is SECURITY DEFINER but executable only by `authenticated`, requires `auth.uid()`, requires an active tenant and a first name, and creates the tenant-linked customer record. This code review does not prove the live browser flow succeeds.

## Public website and domain state

- LIVE `tenant_domains` records `www.scenesource.co.uk` as active and primary for Adventure Outpost.
- LIVE `published_site_index` contains `www.scenesource.co.uk`, revision 1, published 3 October 2026.
- The current Worker route map sends subscriber-domain `/` to `public-site.html`, `/login` to `customer-dashboard.html`, `/basket` to `customer-basket.html`, and other clean subscriber paths to `public-site.html`. The public-site script maps `/`, `/buying`, `/sell`, `/shop`, `/product`, `/about` and `/contact`.
- The previous checkpoint records a screenshot where the homepage rendered after the JavaScript regex fix and cache-bust to `public-site.js?v=26`. This audit could not independently fetch the public site through the available external-fetch tools. Clean-route browser tests remain pending.

## Critical open discrepancy: Worker environment URL

- `public-site.js`, `platform-owner-dashboard.js` and other runtime source refer to the verified LIVE project URL `https://gxsrajtqzdjvmceqcpgv.supabase.co`.
- `wrangler.jsonc` on production currently declares `LIVE_SUPABASE_URL` as `https://gxsrajtqzdjvmceqcpgv2.supabase.co`, with an extra trailing `2` in the project ref.
- An isolated candidate correction is committed on `audit/fix-live-supabase-url-20261009` at `04fc24cad71aaf6efe5e7472022bfd5bc6b8d939`; the branch-only config now uses `https://gxsrajtqzdjvmceqcpgv.supabase.co`.
- A static Worker-source transformation check confirmed the candidate removes the malformed URL and retains the correct LIVE URL in the transformed public-site source. This is not a runtime or browser test.
- **The candidate is not merged or deployed.** First test the Worker rewrite on a controlled non-production runtime, then verify all clean routes and the three-role session test before any promotion.

## Critical open discrepancy: retired domain purchase functions still deployed

LIVE lists these old domain purchase/registration functions as ACTIVE: `porkbun-domain-availability`, `create-domain-checkout-session`, `reconcile-domain-payment`, `save-domain-registrant`, and `porkbun-domain-registration`. The current `domain-settings.js` is the connection-request flow and does not reference those purchase endpoints. `platform-prepare-custom-domain` is a separate current connection function and must be retained.

LIVE has two legacy `tenant_domain_orders` records (one `pending_payment`, one `registrant_details_saved`) and one `tenant_domain_registrants` record for the subscriber. The registration function contains guards for missing/sandbox credentials and order status, but it also contains a real registrar API registration path if production credentials are configured. Do not invoke it during this audit. Do not delete legacy records or disable functions until credentials/configuration, function callers, payment state and record ownership are reviewed. The current architecture remains subscriber-owned domains connected by Platform Owner preparation and DNS/SSL/routing verification—not TradeFlow selling/registering domains.

## Supabase security and performance findings

- 98/98 public tables have RLS enabled.
- Security advisors: 14 RLS-enabled tables have no policies; 14 anon-callable SECURITY DEFINER functions; 160 authenticated-callable SECURITY DEFINER functions; leaked-password protection is disabled; one warning for `pg_net` in `public`.
- Some no-policy tables appear intentionally service-only; for example, master catalogue tables are not selectable by `anon` or `authenticated`. Do not add broad policies or grants just to clear the advisor.
- Performance advisors: 64 unindexed foreign keys, 166 RLS initialization-plan findings, 105 unused indexes, 14 multiple-permissive-policy findings, 3 duplicate indexes and one Auth connection-strategy notice.
- These findings require scoped review and targeted tests. No security policy, grant, extension, index or Auth setting was changed.

## Branch and documentation findings

- GitHub reports `production` and `main` as diverged, with a shared merge base and substantial changes on both sides. Do not merge, reset or force-sync the branches as part of this audit.
- Older manual sections still describe the retired domain purchase/registrant workflow as if it were current. A dated audit snapshot was added near the start of the AI Operating Manual, System Handbook, Backend User Manual, Human User Manual and Master Roadmap. Invalid `gxsrajtqzdjvmceqcpgv5` references were corrected in those Markdown documents.
- The subscriber Website Manual was reviewed and left unchanged because it contains no references to the retired Parcel2Go/domain-purchase route and its current domain guidance aligns with the subscriber-owned-domain connection model.

## Current pass/fail status

| Audit item | Status | Evidence / next step |
|---|---|---|
| Correct LIVE Supabase project identified | PASS | Project `gxsrajtqzdjvmceqcpgv`, ACTIVE_HEALTHY |
| Adventure Outpost tenant exists and is active | PASS | Tenant ID and slug verified read-only |
| Existing SceneSource customer login exists | FAIL / none found | 0 LIVE customer CRM rows and 0 customer-login links; create only via public registration after user approval |
| Owner and subscriber identities present | PASS | One platform-owner membership and one active subscriber membership |
| Website domain active and published | PASS | Primary domain + published revision 1 in LIVE tables |
| Three roles coexist in same Chrome browser | PENDING | Must be observed in browser; no session-isolation claim yet |
| Customer registration and sign-in | PENDING | Run through `https://www.scenesource.co.uk/login` and confirm email/auth flow |
| Public clean routes | PENDING | Browser-test buying, sell, shop, about, contact and login routes |
| Worker URL config discrepancy | OPEN | Correct `wrangler.jsonc` only in controlled candidate branch and test before deployment |
| Retired LIVE domain purchase functions | OPEN / HIGH RISK | Review function callers, secret state and two legacy orders before safe deactivation |
| Supabase security/performance advisories | OPEN | Scoped review; no blanket changes |

## Next actions (in order)

1. Preserve current LIVE state and the known-good Website Builder baseline.
2. Test the existing candidate branch `audit/fix-live-supabase-url-20261009` in a controlled non-production Worker runtime; verify all clean routes and the three-role session test before any promotion.
3. Review the five retired domain-purchase Edge Functions, their secret configuration and the two legacy orders. Keep `platform-prepare-custom-domain` intact.
4. Run the user-observed Chrome test: platform owner, Adventure Outpost subscriber and a new SceneSource website customer, including refresh/navigation and sign-out isolation. Do not create the customer until the user approves the LIVE registration step.
5. Browser-test the clean public routes and record actual results.
6. Review Supabase advisor findings one function/table/index at a time, with intended security boundaries and regression tests.
7. Update this checkpoint with observed outcomes and the approved repair commits. Do not mark pending tests as passed.
