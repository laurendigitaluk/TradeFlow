# 2026-09-27 — Customer login/session isolation repair

## Problem
The Customer Portal was still vulnerable to account confusion during repeated testing on the same browser. The custom TradeFlow customer session had been moved toward tab-local storage, but the implementation did not fully isolate the session by tenant and the portal swallowed profile/RPC errors as if the login were simply unregistered. This made a failed login look like a generic return to the login panel.

## Repair
- Customer sessions are now stored in `sessionStorage` under a tenant-specific key: `tradeflow_customer_session:<tenant_id>`.
- The Customer Portal no longer falls back to a tenant ID stored in shared `localStorage`.
- Legacy shared customer/test-lab session keys are cleared when the portal starts or a customer signs in.
- Sign-in validates the returned Supabase access token against `/auth/v1/user` before handing the session to the portal.
- Pending registration state is tenant-specific and tab-local.
- Customer profile/RPC errors are no longer silently converted into “not registered”; genuine errors now surface to the user.
- Customer portal script cache versions were bumped.

## Intended behaviour
- Customer A and Customer B can use separate tabs of the same Chrome installation without sharing the custom TradeFlow customer session.
- Signing out and signing in as another customer on the same tab replaces the previous session cleanly.
- Switching between subscribers/customers on the same computer does not use a shared TradeFlow customer session.
- A bad password, invalid session, missing tenant context, or backend permission/capability error is surfaced rather than silently looping back to the login panel.
- Buying shipping-label/QR access and retail fulfilment shipping architecture are not changed by this repair.

## Verification performed
- Confirmed both current test customer auth users exist and are confirmed in Supabase.
- Confirmed both test customer records are linked to the Camerashack tenant.
- Confirmed `module.customer_portal` is enabled for the Camerashack tenant.
- Inspected the live `customer_get_profile` function and confirmed it requires the authenticated user and matches `customers.auth_user_id = auth.uid()`.
- Updated `customer-auth.js`, `customer-dashboard.js`, and cache-busting references in `customer-dashboard.html`.

## Next test
1. Close any currently open Customer Portal tab.
2. Open the current Customer Portal URL fresh.
3. Use the intended test customer’s actual email and password.
4. Confirm the portal opens as that customer.
5. Open another tab with a different customer and confirm the two tabs remain independent.
6. Sign out one tab and sign in as another customer; confirm the previous customer is not reused.
7. Re-test the Buying shipping label and QR code controls.
