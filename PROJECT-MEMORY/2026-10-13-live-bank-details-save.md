# Project memory — LIVE bank-details save failure
Date: 2026-10-13
Root cause confirmed from LIVE logs: customer dashboard requests to `customer_save_bank_details` returned 401/PGRST303 because the already-open browser tab was using an expired access token. The LIVE customer row maps to the signed-in Auth user, but no bank-details row existed after the failed attempts.
Prepared branch: `fix-customer-bank-save-expired-session-20261013`. It adds a single-flight refresh-token flow to the customer dashboard API helper, retries one 401 request after refreshing, and bumps the script cache version to v152. Syntax parse: passed.
No DB/Auth/customer/bank records changed, no bank details entered by us, TEST untouched.
Status: code prepared only; not merged/deployed or verified. Must confirm a real customer can save their own correct bank details, reload them, and clear the notice after deploy.


## Merge status update — 2026-10-13
The expired-session refresh repair has now been merged into `production` in commit `e6dcbb985dd4308a1860ce54642e59df7be5ccd7` (PR #125). Production source verification confirms the refresh/retry helper is present and `customer-dashboard.html` references `customer-dashboard.js?v=152`.

This confirms GitHub production source only. Cloudflare deployment and live customer acceptance are still unverified. The checkpoint remains open until a customer saves their own correct bank details, the save succeeds, the details reload from LIVE, and the bank-details-required warning clears. Do not use the screenshot's sample values.
