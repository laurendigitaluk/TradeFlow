# 2026-09-27 — Customer session isolation

## Problem
Customer Portal stored its custom customer session in browser `localStorage`. That storage is shared by every tab/window for the same origin, so testing or using different customer accounts in multiple tabs on the same browser could cause one account's session to replace another's. This can present as the portal falling back to the customer login/profile panel even though the browser is authenticated.

## Repair
- Customer authentication now stores the custom TradeFlow customer session in `sessionStorage`, which is isolated per browser tab.
- Customer Portal restore/sign-out paths use the tab-local session.
- Legacy `localStorage` session data is cleared so an old shared session cannot contaminate the new flow.
- Pending customer registration state is also tab-local.
- Customer dashboard and authentication script cache versions were bumped.

## Intended behaviour
- Two customer accounts can be tested independently in separate browser tabs/windows without sharing the custom TradeFlow customer session.
- Different browsers remain naturally isolated.
- A user can sign out and another household member can sign in on the same computer/browser without inheriting the previous TradeFlow customer session.
- The underlying Supabase authentication and tenant/customer records are unchanged.
- Buying shipping-label/QR security and retail fulfilment shipping are unchanged.

## Test
1. Hard-refresh the Customer Portal.
2. Sign in as customer A in one tab.
3. Open another Customer Portal tab and sign in as customer B.
4. Confirm each tab remains on its own account.
5. Sign out customer B and sign in again as customer A; confirm the previous account is not reused.
6. Re-test the Buying shipping label and QR controls.
