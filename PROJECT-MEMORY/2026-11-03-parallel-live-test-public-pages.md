# Project Memory — Parallel LIVE and TEST public page editor — 3 November 2026

User confirmed: TradeFlow is being built in LIVE and TEST simultaneously. Do not ask which environment to target for this feature; maintain equivalent code in both, with separate databases and separate published page content.

Platform owner CMS:
- Public marketing pages: How It Works, Examples and homepage Examples preview.
- Separate from tenant-scoped subscriber Website Builder.
- Owner dashboard section: Public Website Pages.
- Editor supports copy, lists, examples, screenshot title/caption/alt text and image URL. Save draft / Preview draft / Publish are separate. Existing screenshot retained if URL blank. Direct image uploads not yet implemented.

TEST:
- Branch `cloudflare-test`, Worker `tradeflow-test`, Supabase `nnsshnfkjcflucjrftzi`.
- PR #204 merged with CMS.
- Existing TEST renderer/editor use TEST URL and publishable key.

LIVE:
- Branch `production`, Worker `tradeflow`, Supabase `gxsrajtqzdjvmceqcpgv`.
- Feature branch `feature/owner-editable-public-pages-live-20261103` contains matching CMS using LIVE URL/key.
- LIVE How It Works static page was missing from production branch; copied the high-resolution TEST page and its stylesheet into LIVE branch.
- LIVE owner sign-in code retains the existing newer production auth and password reset; CMS load hook added.
- LIVE migrations applied and source migration files added to feature branch.

Both DBs:
- `platform_public_pages` with rows for `how-it-works`, `examples`.
- RLS, explicit deny policies, no direct anon/authenticated table access.
- Owner RPCs gated by active platform_memberships; public read RPC returns published JSON only.
- Separate database content; no copying TEST content into LIVE after seed other than initial idempotent default seed; subsequent edits are environment-specific.
- No tenant/customer/transaction/Stripe/inventory/domain changes.

Remaining: merge LIVE feature branch into production; verify Worker deployments; browser-test sign-in/editor/draft/preview/publish independently in both environments. Do not claim browser/deployment verified before that check.


## Final LIVE merge/deployment status — 3 November 2026
- LIVE PR #205 merged into `production` with merge commit `f3cabb78556ccca1898d459c68c09acb5bb54f8a`.
- TEST PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- LIVE and TEST database migrations applied and access-control read-back verified; each database has its own two page records.
- JavaScript syntax checks passed for owner dashboard, editor and renderer in LIVE; environment URL/key checks passed.
- Direct Worker URL checks for LIVE and TEST were inaccessible through the available browser tool. Cloudflare deployment commit/runtime and owner browser flow remain unverified. Do not state deployment is complete until the Worker version and browser flow are confirmed.
- The user confirmed simultaneous LIVE and TEST development. Continue keeping code behaviour aligned and content/data isolated.
