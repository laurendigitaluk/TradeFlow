# Project memory — LIVE customer portal sign-in recovery
Date: 2026-10-13
Environment: LIVE only. Supabase project `gxsrajtqzdjvmceqcpgv`; TEST project `twfbmjwwqzxdxvclxbun` remains untouched.

## Verified by user
- Existing Adventure Outpost customer portal at `https://www.scenesource.co.uk/login` signs in in both regular Chrome and Chrome Incognito.
- Both browser windows show the same account/portal, the accepted DJI Osmo Action 6 Adventure Combo offer with cash offer £70.00, and the reminder to add bank details before payment.
- The optional empty trailing `#` in `/login#` is harmless and needs no change.
- Do not change or invent customer bank details.

## Production code repair
- PR #123 repaired the customer dashboard JavaScript parse issue and removed an undefined navigation call; merged to production in commit `3e53435367e927f8cd980477ddadd08d2a7973d3`.
- PR #124 corrected the recovery redirect origin: recovery started on a platform hostname resolves the tenant's unique published hostname and redirects to that site's `/reset-password`; missing/ambiguous hostnames fail closed.
- PR #124 merged to production in commit `f676fb13198d78f997ef5cb017af303e83c97efa`.
- No Auth user, password, customer record, bank details, tenant data, DNS, or Supabase Auth configuration was changed as part of these fixes.

## Status boundaries
- User-observed sign-in in two browser contexts: PASS.
- Full fresh password recovery email → tenant reset page → password update → sign-in: NOT YET VERIFIED.
- Cloudflare deployment of PR #124 and Supabase Auth allowed-redirect settings: NOT independently confirmed by the available tools.
- Valuation/bank-details workflow and customer/subscriber messaging: not declared fixed by this login test; require their own end-to-end acceptance.
- No database schema/data change was justified by this code/browser result. Do not write a synthetic record into business tables to imitate a logbook.
