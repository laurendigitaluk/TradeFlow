# LIVE Owner Authentication Recovery Audit — 3 October 2026

## Purpose

This checkpoint records the fuller audit of the LIVE platform-owner login/password-reset failure reported on 3 October 2026. It supersedes the assumption that the remaining problem was only stale browser caching.

## Verified LIVE state

- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Project name: TradeFlow Live
- Region: eu-west-2
- Status: ACTIVE_HEALTHY
- LIVE platform owner auth user exists and is email-confirmed.
- LIVE `public.platform_memberships` contains one active membership for that owner.
- LIVE migration ledger includes the production AI/messaging/release-cleanup migrations.
- LIVE Edge Function `tradeflow-assistant` is ACTIVE, version 1, JWT protected.
- LIVE AI configuration remains `active_provider=none`, with `allowed_providers=["none"]`.
- LIVE inventory serial uniqueness has been restored and TEST helper RPCs were removed.

## Root cause found

The password-reset email shown during testing redirected to:

`http://localhost:3000/error_access_denied?...error_code=expired...`

There were two separate defects:

1. **LIVE Supabase Auth URL configuration was still using the development/default localhost destination.**
   Supabase documents that the Site URL is the default redirect used when no valid redirect is supplied, and that password reset `redirectTo` destinations must be included in the allowed Redirect URLs.
2. **The production Owner Dashboard had no dedicated owner password-recovery page.**
   The existing `customer-password-reset.html` was customer-specific and redirected to the customer dashboard. It was not suitable as the platform-owner recovery target.

The earlier stale-dashboard-cache problem was real and was already repaired separately, but it was not the remaining cause of the localhost reset failure.

## Production code repair

Production branch now contains:

- Owner Dashboard **Forgot your password?** control.
- Owner recovery request using an explicit Supabase `redirect_to` of `/owner-reset-password`.
- New `platform-owner-password-reset.html` page.
- Recovery page verifies the Supabase recovery session.
- Recovery page verifies an active `platform_memberships` row before permitting a password change.
- Recovery page calls Supabase Auth `updateUser({password})`.
- Worker routes `/owner-reset-password` in both TEST and LIVE route maps.
- Owner dashboard JS asset version advanced to `v7`.

Relevant production commits:
- `ad6470e7e898413cf5d344538f64069686690edc` — owner reset UI
- `50c11769ad346e1383c4ab98bdf3014dd49ce843` — owner recovery flow
- `010e86d3ad79834da69e0277a54d43cd03e2fea0` — owner reset page
- `c2f5409af76cd3e96d57a1de5af1c10864943d7c` — complete recovery UI wiring
- `a8821a4fcb5613d9e3117b41f2b4e1602c884272` — Worker route for both environments

Current production branch HEAD: `a8821a4fcb5613d9e3117b41f2b4e1602c884272`.

## Validation performed

- Owner dashboard JS parses successfully as JavaScript.
- Worker source parses successfully after treating its ES-module export as a module wrapper.
- Recovery page contains LIVE Supabase configuration.
- Recovery page performs active platform-owner membership verification.
- Recovery page performs password update through Supabase Auth.
- Worker contains the owner reset route for both TEST and LIVE route maps.
- Owner dashboard references JS asset `v7`.

## Remaining live infrastructure action

The code repair is committed, but the LIVE Supabase Auth URL Configuration cannot be changed through the currently available Supabase project tool surface.

Before the next password-reset test:

1. Open LIVE Supabase Dashboard → Authentication → URL Configuration.
2. Set the Site URL to the actual production application origin. If the permanent customer domain has not yet been selected, the current Worker origin may be used temporarily:
   `https://tradeflow.leannelaurenlowe.workers.dev`
3. Add this exact Redirect URL:
   `https://tradeflow.leannelaurenlowe.workers.dev/owner-reset-password`
4. Save.
5. Use the Owner Dashboard's new **Forgot your password?** control to generate a fresh reset email.
6. Do not reuse the expired localhost reset email.

The permanent Site URL should be changed again when the real TradeFlow customer domain is selected. The temporary Worker URL must not become an accidental permanent production identity.

## Broader audit notes

Supabase security advisors currently report a number of pre-existing warnings across the large LIVE schema, including tables with RLS but no direct policies where access is routed through security-definer RPCs, public security-definer functions that are intentionally used for published-site access, and several performance/index observations. These are not the cause of the owner reset problem and should be treated as a separate hardening/audit workstream rather than mixed into this repair.

## Status

**Code repair complete.**

**LIVE Auth URL configuration and fresh end-to-end reset test remain to be completed.**

No LIVE business data was deleted or changed as part of this authentication repair.
