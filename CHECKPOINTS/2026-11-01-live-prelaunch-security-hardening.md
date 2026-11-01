# TradeFlow LIVE pre-launch security hardening — 1 November 2026

## Environment
- Repository: `laurendigitaluk/TradeFlow`
- LIVE code branch: `production`
- Isolated repair branch: `security/prelaunch-hardening-20261101`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- Retired TEST project `twfbmjwwqzxdxvclxbun` was not used.

## User instruction
Proceed with the security changes identified in the LIVE pre-launch audit. Exclude unfinished product catalogues and catalogue evidence. Preserve all LIVE/TEST subscriber, customer, tenant, website, payment, Stripe and ownership separation. Do not perform real LIVE Stripe payments or change Stripe products/prices/secrets.

## Completed and verified
1. Added version-controlled migration `supabase/migrations/20261101120000_harden_private_media_upload_limits.sql` on the isolated security branch.
2. Applied migration `harden_private_media_upload_limits` to TEST and LIVE Supabase.
3. Both environments now report:
   - `tradeflow-media`: private; 5,242,880 bytes (5 MiB) per object; allowed MIME types `image/jpeg`, `image/png`, `image/webp`, `application/pdf`.
   - `tradeflow-site-media`: public as before; 5 MiB; PNG/JPEG/WebP only.
4. Confirmed storage object policies remain tenant-scoped and no bucket visibility change was made.
5. Updated `buying-dashboard.js` on the isolated security branch to align shipping label/QR client-side size messages with 5 MiB and accepted MIME types with the bucket configuration.

## Critical preservation notes
- Keep `tradeflow-media` private. Earlier repair: Storage objects could be created while the `media_assets` insert-return/SELECT-RLS failed, leaving orphaned objects. The repair used insert without return, separate retrieval/link and cleanup on failure. Do not regress this sequence.
- Continue using the protected subscriber media Edge Function for signed URLs after authentication and tenant membership verification. Do not make the private bucket public or weaken RLS to work around signed URL issues.
- Existing subscriber website image uploads already validate 5 MiB and PNG/JPEG/WebP. Existing website bucket configuration is unchanged.
- Buying dashboard shipping upload controls previously allowed 10 MiB; client code was aligned to 5 MiB on the isolated branch.
- Storage configuration verification is complete, but end-to-end upload tests have not yet been run. Required tests: allowed JPEG/PNG/WebP/PDF under 5 MiB succeeds; over-limit file rejected; disallowed MIME rejected; private bucket remains inaccessible cross-tenant; image/label retrieval works through the existing protected access route.

## Confirmed open issues from current code review
1. `subscriber-create-checkout-session` derives Stripe success/cancel URLs from unvalidated Origin/Referer.
2. `subscriber_finalize_signup` currently updates an existing tenant subscription with the incoming Stripe subscription ID when the user already has an active tenant membership. This can overwrite the existing subscription reference, including a complimentary subscription. Checkout should reject already-provisioned users before creating a Stripe session, and webhook finalization must be idempotent and refuse subscription collisions.
3. Test Lab files remain in LIVE production assets. `test-lab.html` explicitly references retired TEST project `twfbmjwwqzxdxvclxbun`. Before removal, verify whether `app.js`, `test-lab-fix.js` or `testlab-config.js` are shared by any live page.
4. Auth leaked-password protection was previously reported disabled; current Auth setting could not be read or changed with the available management actions. Email confirmation and rate limits remain unverified.
5. Migration history discrepancy: LIVE records migration `20261028215641_add_combined_buying_request_offer_response`, but no matching migration file was found in the production Git tree during the audit. Reconcile before release.
6. The TEST branch `cloudflare-test` is heavily diverged from `production` (130 commits ahead and 1,042 behind at audit time). Do not merge/reset wholesale. The isolated security branch was created from current production.

## Not done / do not claim
- No checkout/webhook code changed or deployed.
- No Stripe configuration, secrets, products, prices, customer payments or subscription records changed.
- No Test Lab assets removed or blocked.
- No Auth setting changed.
- No full multi-tenant adversarial browser test run.
- No Cloudflare Worker deployment confirmed.
- No end-to-end storage upload/retrieval test completed.
- No production subscriber/customer/catalogue/website data copied or changed.

## Next steps
1. Finish checkout hardening in isolated code and add safe, testable idempotency/uniqueness handling. Do not change LIVE Stripe secrets/settings.
2. Test against a controlled TEST Stripe Sandbox configuration without copying LIVE data/secrets.
3. Remove Test Lab only after checking asset dependencies and confirming production Worker deployment route.
4. Obtain/verify Auth settings using a supported Supabase Auth configuration control.
5. Reconcile the missing migration with actual production source/history.
6. Run storage positive/negative tests and verify upload metadata, protected retrieval, and cleanup behaviour.
7. Update the manuals and checkpoint with verified implementation and deployment evidence.
8. Promote only the reviewed release; never merge the divergent TEST branch wholesale.


## Image upload hardening update — 2026-11-01
- On isolated branch `security/prelaunch-hardening-20261101`, Website Builder image uploads and subscriber inventory/retail listing photo uploads now convert JPEG/PNG/WebP source images to WebP in the browser, resize longest dimension to 2,000 px, and encode at quality 0.82. Upload paths use `.webp`; Storage content type and `media_assets.mime_type` are `image/webp`; recorded byte size is the converted object size. Website Builder retains the source filename in `media_assets.original_filename`.
- The private `tradeflow-media` bucket remains private, tenant-scoped and capped at 5 MiB; allowed MIME types remain JPEG, PNG, WebP and PDF. Existing storage policies and protected media retrieval were not changed. `tradeflow-site-media` remains public as previously configured and retains its 5 MiB limit.
- Shipping labels and QR uploads are not passed through image conversion; PDF label files remain PDFs. Their UI file-size checks were reduced to 5 MiB to match Storage.
- `customer-selling-submit` now enforces JPEG/PNG/WebP and 5 MiB server-side. Automatic WebP conversion is NOT yet connected to customer valuation submissions: the active front-end caller was not identified in the reviewed customer dashboard/basket scripts, so the endpoint deliberately retains compatibility rather than rejecting existing image formats.
- Verification status: code edits are committed on the isolated branch only. No browser upload tests, Edge Function deployment, Cloudflare Worker deployment or production promotion have been performed. Do not describe these code changes as live until deployment and positive/negative tests are completed.


## Subscriber signup checkout hardening update — 1 November 2026

### Findings confirmed against LIVE
- Platform Worker routing confirms the four LIVE platform origins: `https://tradeflow.laurendigital.co.uk`, `https://laurendigital.co.uk`, `https://www.laurendigital.co.uk`, and `https://tradeflow.leannelaurenlowe.workers.dev`.
- LIVE `subscriber-create-checkout-session` version 12 trusted unvalidated Origin/Referer values for Stripe return URLs, did not check existing active memberships, and did not send a Stripe idempotency key.
- LIVE `stripe-payment-webhook` version 16 calls `subscriber_finalize_signup` after Stripe signature verification and subscription retrieval.
- LIVE `subscriber_finalize_signup` overwrote an existing tenant subscription when the user already had an active membership. The current database has a unique index on (billing_provider, provider_subscription_id), but that does not prevent replacing the existing ID.

### Candidate changes committed to the isolated branch
- Edge Function origin validation and exact-origin CORS; Referer fallback removed. LIVE accepts only the four verified platform origins. The same source selects a TEST-only allowlist containing only `https://tradeflow-test.leannelaurenlowe.workers.dev` when `SUPABASE_URL` is the current TEST project `nnsshnfkjcflucjrftzi`; TEST origin is never accepted by LIVE.
- Existing active membership check via `subscriber_get_my_memberships()`; fail closed if lookup fails.
- Stable per-user Stripe idempotency key; repeated calls cannot create a second session for the same user during Stripe's idempotency retention window. This is not a permanent checkout-attempt ledger; if webhook finalisation remains unresolved beyond that window, reconcile the completed Stripe session before allowing another attempt.
- New migration `20261101130000_guard_subscriber_signup_subscription_collisions.sql`: per-user advisory lock, same-subscription webhook retry returns the existing tenant, different subscription ID is rejected without mutating the existing subscription.
- New diagnostic roadmap: `docs/DEVELOPER-DIAGNOSTIC-ROADMAP-SUBSCRIBER-CHECKOUT.md`.
- New project-memory record: `PROJECT-MEMORY/2026-11-01-subscriber-checkout-security.md`.

### Release and verification status
- Edge Function source and SQL migration are committed on `security/prelaunch-hardening-20261101` only.
- The SQL migration has not been applied to TEST or LIVE.
- No Edge Function or Worker deployment has been performed.
- No browser, Stripe Sandbox, webhook replay, duplicate-session or subscription-collision tests have been run.
- Stripe products, prices, secrets, settings, payment records and existing subscription rows were not changed.
- Do not merge the isolated branch wholesale or promote it before review and TEST verification.
- Next: review the diff; confirm current TEST project `nnsshnfkjcflucjrftzi` and its own Stripe Sandbox configuration; apply and verify the migration in TEST; run the roadmap test matrix; then make a separate LIVE release decision.


## LIVE release update — 1 November 2026

**Production deployment completed after direct inspection of the LIVE database function signatures and current LIVE Edge Function.**

- Supabase project: `gxsrajtqzdjvmceqcpgv` (TradeFlow Live, EU West 2).
- `subscriber-create-checkout-session` deployed successfully as version **13**, with JWT verification still enabled.
- LIVE database migration `guard_subscriber_signup_subscription_collisions` applied successfully and recorded as migration version `20261101130118`.
- The LIVE `subscriber_finalize_signup(uuid,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb)` definition was re-read after migration and confirmed to contain the per-user advisory lock, same-Stripe-subscription retry guard and rejection of a different subscription ID for an existing active member.
- The deployed checkout source was re-read from Supabase and confirmed to contain the strict LIVE origin allowlist, no Referer fallback, exact-origin CORS, active-membership lookup, and stable per-user Stripe idempotency key.
- The current TEST project and its Stripe configuration were not used or changed. TEST Stripe is not a prerequisite for this LIVE deployment.
- Stripe products, prices, API secrets, dashboard settings, customer records, payment records and existing subscription rows were not changed.
- No live payment or customer signup was initiated during deployment. Full browser checkout and webhook E2E verification remain outstanding; do not describe the checkout journey as fully tested until those tests are completed.
