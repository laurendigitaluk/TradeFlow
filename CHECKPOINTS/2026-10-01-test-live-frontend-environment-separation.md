# Checkpoint — 2026-10-01 — TEST/LIVE frontend environment separation

## Status
TradeFlow remains a Go-Live Candidate. Production PR #108 remains OPEN and MUST NOT be merged until production configuration and smoke tests pass.

## Supabase environments
- TEST: twfbmjwwqzxdxvclxbun
- LIVE: gxsrajtqzdjvmceqcpgv
- TEST and LIVE data remain separate.
- No production database reset or TEST-data copy was performed.

## Frontend routing
Browser-facing TradeFlow code now selects the Supabase environment from the hostname:
- localhost / 127.0.0.1 / GitHub Pages (*.github.io) -> TEST
- other production hosts -> LIVE

The selected LIVE publishable key is used only as a browser publishable credential. No service-role or secret key was added to frontend code.

Customer and subscriber auth layers also rewrite legacy hardcoded TEST Supabase URLs in dependent fetch calls so existing dashboard scripts cannot silently continue against TEST when running on the production host.

Explicit environment selection was added to the public subscriber website, subscriber signup, customer password reset, customer auth, subscriber auth and key dashboard paths.

## Important limitation
The production hostname must be the intended TradeFlow production host. Any non-GitHub-Pages/non-localhost hostname is treated as LIVE by the runtime selector. Do not deploy this build to an untrusted preview/staging hostname without reviewing that rule.

## Next steps
1. Verify TEST browser login and dashboard workflows still use TEST.
2. Verify the production host resolves to LIVE before launch.
3. Configure LIVE Auth redirect/site URLs.
4. Configure LIVE Stripe, Resend and hosting/Cloudflare settings.
5. Run production smoke tests and tenant-isolation tests.
6. Merge PR #108 only after those checks pass.

Created after the LIVE publishable-key handoff and frontend environment-routing repair on main.
