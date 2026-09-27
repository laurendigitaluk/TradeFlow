# CHECKPOINT — 2026-09-27 Customer Dashboard JavaScript Syntax Repair

## Finding
Customer authentication was reaching Supabase successfully, but the Customer Portal did not transition from the login panel after authentication.

Supabase auth logs for the test account show successful password login at 2026-09-27 19:04:07 UTC. There was no subsequent customer_get_profile request, indicating the dashboard application code was not executing its auth-success handling.

Inspection of customer-dashboard.js found a JavaScript syntax error in the customer shipping-media fetch URL. The malformed string construction was sufficient to prevent the entire dashboard script from parsing and executing.

## Repair
Replaced the malformed shipping-media URL construction with valid JavaScript using encodeURIComponent for tenant_id, buying_item_id and kind.

Updated customer-dashboard.html:
- customer-dashboard.js?v=132 → customer-dashboard.js?v=133

## Verification evidence
Supabase auth logs recorded a successful password login for the customer account at 19:04:07 UTC, confirming authentication itself was working. The absence of customer_get_profile activity after login matched the front-end JavaScript failure.

## Expected result
After GitHub Pages publishes the new asset:
1. Customer signs in.
2. customer-auth.js dispatches tradeflow-auth-success.
3. customer-dashboard.js receives the event.
4. loadPortal() calls customer_get_profile.
5. Successful profile lookup hides the login panel and displays the Customer Portal.
6. The customer can then use My Sale, My Orders and My Details.

## Related repairs
This follows:
- CHECKPOINTS/2026-09-27-customer-login-session-repair.md
- CHECKPOINTS/2026-09-27-customer-portal-tenant-link-repair.md

## Commits
- 586bd4d201d2d54a06df61fda6d10e6f3c0f6752 — dashboard JavaScript syntax repair
- 6945b7d64fd0e56153fa735e10c5c4fa52051ddd — dashboard cache-bust
