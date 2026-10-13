# Project memory — LIVE bank-details save failure
Date: 2026-10-13
Root cause confirmed from LIVE logs: customer dashboard requests to `customer_save_bank_details` returned 401/PGRST303 because the already-open browser tab was using an expired access token. The LIVE customer row maps to the signed-in Auth user, but no bank-details row existed after the failed attempts.
Prepared branch: `fix-customer-bank-save-expired-session-20261013`. It adds a single-flight refresh-token flow to the customer dashboard API helper, retries one 401 request after refreshing, and bumps the script cache version to v152. Syntax parse: passed.
No DB/Auth/customer/bank records changed, no bank details entered by us, TEST untouched.
Status: code prepared only; not merged/deployed or verified. Must confirm a real customer can save their own correct bank details, reload them, and clear the notice after deploy.
