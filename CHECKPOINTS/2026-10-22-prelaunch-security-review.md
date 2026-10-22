# TradeFlow Pre-Launch Security Review — 2026-10-22

## Scope
Read-only review of the production GitHub tree, LIVE Supabase, and current TEST Supabase. This checkpoint records evidence and outstanding actions; it does not claim the system is fully secure.

## Environments
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- TEST Supabase reviewed: `nnsshnfkjcflucjrftzi`.
- Older TEST project reference `twfbmjwwqzxdxvclxbun` appears in historical docs and must not be silently substituted for the currently connected TEST project.
- Production GitHub tree: 511 tracked entries; no `.php` file or `composer.json` found.

## Findings
- PHP article: no direct PHP application/dependency found in repository; external hosting/provider runtimes still require verification.
- TEST `public` schema: 99 tables; RLS enabled on all 99; each has at least one policy. This does not prove policy predicates are correct.
- SECURITY DEFINER advisor counts: TEST 8 anon-callable and 164 authenticated-callable; LIVE 8 anon-callable and 165 authenticated-callable. Treat as review queues, not confirmed vulnerability counts.
- The inspected anon-callable functions expose intended public/published data; do not revoke all public function access blindly.
- Inspected catalogue mutation wrappers call permission-checking internal functions; broader privileged-function review remains open.
- Auth leaked-password protection is flagged disabled and requires changing/confirming through Supabase Auth configuration, not SQL.
- Advisor review queue includes `pg_net` in `public`, approximately 65 unindexed foreign keys, multiple permissive RLS policies, unused indexes and duplicate indexes. These require targeted evaluation, not bulk edits.
- LIVE primary `www.scenesource.co.uk` domain record has conflicting metadata: active/primary, while Cloudflare hostname and SSL validation states include pending. Verify provider/DNS/HTTPS state; do not change DNS or published site during this audit.

## Changes made
- Created isolated branch `audit/prelaunch-security-review-20261022` from `production`.
- Appended this dated review to both `docs/TRADEFLOW-SYSTEM-HANDBOOK.md` and `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`.
- No application code, SQL grants, database rows, auth settings, secrets, Edge Functions, DNS, Cloudflare routing, or published content changed.

## Next actions
1. Verify and enable leaked-password protection on TEST via supported Supabase Auth settings, then test sign-up/login/reset.
2. Continue targeted review of elevated functions with focus on payments, tenant membership, platform-owner/admin, customer data and domain operations.
3. Verify SceneSource DNS, Cloudflare custom hostname and HTTPS state without changing configuration.
4. Fix only demonstrated defects on TEST; rerun advisors and functional regression tests.
5. Prepare a controlled release to LIVE only after successful TEST verification and explicit review of the diff.


### External domain spot-check (22 October 2026)
- A web fetch of `https://www.scenesource.co.uk` was not accessible to the inspection tool.
- A fetch of the bare `https://scenesource.co.uk` returned indexed content that redirects to `scenesource.mysharetribe.com`, but the result was marked as crawled three months ago and is not reliable proof of current routing.
- This conflicts with the LIVE database's recorded active `www.scenesource.co.uk` custom-domain entry and pending Cloudflare/SSL metadata. Treat domain routing as **unverified**, not as a confirmed outage. Check current registrar DNS and Cloudflare Custom Hostnames/SSL directly before changing anything. Do not modify DNS, SSL, custom hostname, or published-site routing based on a stale crawl.
