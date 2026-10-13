# Checkpoint — LIVE customer password recovery origin repair
Date: 2026-10-13
Branch: `fix-customer-password-reset-tenant-origin-20261013`
Environment: LIVE source branch only; TEST Supabase `twfbmjwwqzxdxvclxbun` untouched.

## Evidence
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- Customer login POST returned `invalid_credentials`; this does not justify creating a replacement Auth user or changing account records.
- LIVE Auth logs showed a recovery request from `https://tradeflow.leannelaurenlowe.workers.dev`, and the supplied recovery link returned `otp_expired`.
- Current `customer-auth.js` originally built the recovery redirect from `location.origin`. When the request originated on the platform Worker host, the email link returned to that platform host instead of the tenant customer website.
- `customer-password-reset.html` requires the recovery access/refresh tokens in the URL hash and then updates the password through Supabase Auth.

## Candidate repair
`customer-auth.js` now resolves the unique published hostname for the tenant from LIVE `published_site_index` when Forgot password is initiated on a platform hostname. It directs recovery to that tenant's `/reset-password`. On a tenant hostname it preserves the current origin. Missing/ambiguous tenant hostname fails closed with an explanatory message.

## Scope / safety
- No Supabase rows, Auth accounts, passwords, memberships, subscriptions, DNS, Cloudflare settings or Supabase Auth URL settings changed.
- No new customer/account created; no existing account deleted.
- TEST environment untouched.
- System Handbook and AI Operating Manual updated to record this candidate and its pending status.

## Status: PARTIAL PASS — sign-in verified; recovery still pending
The change must be reviewed, merged to production, deployed to Cloudflare and tested with a newly requested recovery email. Verify that the email redirects to `https://www.scenesource.co.uk/reset-password`, password update succeeds, normal sign-in succeeds, and the customer portal dashboard loads. Also verify that the LIVE Supabase Auth redirect allow-list accepts the tenant hostname. Do not report the portal fixed until this complete journey passes. Previous recovery links may be expired and are not valid test evidence.


## User-observed follow-up — 2026-10-13 15:26 UK
The user confirmed that sign-in now works in both regular Chrome and Chrome Incognito. Both show the same customer account and the same accepted £70 cash offer; the customer portal displays the bank-details-required notice. The empty trailing fragment in `/login#` is harmless. This does not prove the fresh recovery-email/password-update flow, Cloudflare deployment, allowed-redirect configuration, or valuation/messaging flow. Do not mark those as passed.
