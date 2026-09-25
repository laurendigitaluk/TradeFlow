# TradeFlow Checkpoint — 2026-09-25 Retail Checkout Session Handoff Fix

## Scope

Test Two only. Test One remains frozen.

The active Test Two customer is the Camerashack customer used for the Nikon COOLPIX P1100 retail checkout test.

## Verified live database state

- Tenant: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`
- Customer: `valley-discounts@outlook.com`
- Customer ID: `7b5d034f-519d-4edb-bfff-5aa920649163`
- Customer credit: £55.00
- Published listing: Nikon COOLPIX P1100
- Listing ID: `b7e21f3c-db50-498c-99b1-2fe53e7b594f`
- Asking price: £75.00
- No retail order has been created by the failed checkout attempts.

## Root-cause investigation

The checkout page had several independent handoff weaknesses:

1. Checkout boot waited on `customer-auth.js` session validation before attempting its own stored-session restore.
2. `customer-checkout.js` used a `started` guard that could prevent a second start after authentication.
3. The checkout URL relied on `tradeflow_customer_tenant_id` in localStorage instead of carrying the tenant explicitly.
4. The checkout HTML/JS could remain behind GitHub Pages/browser caching because the checkout link itself did not change when the implementation changed.
5. The checkout startup loaded the public listing before deciding whether the customer session existed, so a listing-context error could leave the sign-in panel visible and make the failure look like an authentication failure.

## Fix applied

### `customer-checkout.js`

Commit: `228d25a810412e3ec518adb28aa473478ced7c5f`

- Restore customer session from localStorage, with sessionStorage fallback.
- Checkout no longer waits for the separate auth-ready promise before booting an already signed-in customer.
- Authentication state is checked before loading the listing.
- Successful authentication resets the startup guard and reruns checkout initialization.
- Existing authenticated sessions therefore reach the checkout directly; new customers can still use the shared customer-auth UI.

### `public-site.js`

Commit: `04ff7b4c6d7b502f346d0127654de2bd09ba2405`

Buy links now carry:
- `tenant_id`
- `listing_id`
- `checkout_v=5`

This removes the tenant-context dependency from checkout and forces a fresh checkout URL when this fix is tested.

### `customer-checkout.html`

Commit: `b7edb92bc43725b1446d0a2b918b99e5f2760cab`

- `customer-auth.js?v=11`
- `customer-checkout.js?v=5`

## Deployment state

The three fix commits are on the `main` branch, which is the repository default branch. The repository has no GitHub Actions workflow runs associated with these commits, so there is no Actions deployment pipeline to wait for in this repository.

The browser-side live checkout still needs one user-facing retest after GitHub Pages serves the new branch contents.

## Next verification

Open the Camerashack public site in the same browser session where the customer is already signed in, open the Nikon COOLPIX P1100 product, and click **Buy this item**.

Expected result:
- No sign-in screen when the customer session is already present.
- Checkout loads the Nikon product.
- Customer name loads.
- Delivery/payment addresses load.
- £55 customer credit is shown as insufficient for the £75 purchase.
- Internet payment remains available.
- No order is created until the customer actually continues with payment.

Do not alter Test One.


## Additional root cause found after retest

The public website HTML was still loading `public-site.js?v=71`. The contents of `public-site.js` had been changed to send Buy buttons to `customer-checkout.html`, but the script URL/version had not been changed. A browser could therefore continue using the previously cached v71 JavaScript, whose Buy button still followed the older customer-dashboard route.

Final routing/cache fix:

- Commit `065cfc1d603e5d8b8bec8692a7b9ce713577c4fc`
- `public-site.html` now loads `public-site.js?v=72`.
- The freshly loaded v72 script generates the checkout URL with tenant ID, listing ID and `checkout_v=5`.

This is the primary explanation for the observed behaviour where clicking **Buy this item** continued to open the customer login page even after the checkout code itself had been corrected.


## Retest result and second repair — 2026-09-25

The same-browser retest still displayed **Sign in to continue** on Checkout while the Customer Portal in the same Incognito session showed the customer signed in. The screenshots confirm that the portal authentication itself is working; the remaining fault is specifically the checkout session bootstrap/cache path.

Additional repair applied:

- customer-checkout.js commit `cdca7412a3444a464956daa5fa610854db5bd360`
  - Checkout boot now restores `tradeflow_customer_session` directly before starting.
  - It no longer waits for the separate `tradeflowCustomerAuthReady` promise. This removes the remaining auth-module startup race.
  - If a valid access token is already present, the checkout UI is switched to the authenticated checkout state immediately.
- customer-checkout.html commit `7289292e5ecc8514d511c325c6ae63f11b2394a8`
  - Checkout script cache bumped from `customer-checkout.js?v=6` to `v=7`.
- public-site.js commit `2760340d96525c689ef540957b630733ab4a6776`
  - Product Buy links now use `checkout_v=6` instead of `checkout_v=5`.
- public-site.html commit `9c9ff3f55217081f6e4d67df77d73c12da4496e7`
  - Public-site script cache bumped so the new checkout URL is served.
- customer-dashboard.js commit `ad285036d4695020fc18c84af6b822393f1ff470`
  - Legacy public-product fallback now also uses `checkout_v=6`.

The intended flow remains:

Camerashack → Visit Shop → Nikon COOLPIX P1100 → Buy this item → Checkout

For an already authenticated customer, Checkout must open the purchase screen directly. The sign-in form should only appear when no customer session exists.

Test One remains frozen. No retail order should be created by merely opening Checkout.


## Final session-handoff repair before Test Two purchase continuation — 2026-09-25

The fresh-browser test proved customer authentication itself works, but the signed-in Customer Portal still led to Checkout showing `Sign in to continue`. The final repair separates the authenticated customer session from the checkout handoff while retaining the normal customer session.

Changes:
- `customer-auth.js` commit `727b8510b7c23859e7f1053af0290004fde8a09a`
  - Maintains `tradeflow_checkout_session` alongside `tradeflow_customer_session` after successful customer authentication.
  - On passive checkout pages, restores the dedicated checkout handoff session.
  - Clears both session records on authentication failure/sign-out paths.
- `customer-dashboard.js` commit `41bb996ed949746e37ca64502bdaf893a58bbceb`
  - Customer Portal save/sign-out now synchronizes the dedicated checkout handoff session.
- `public-site.js` commit `938a9d519eb24bcf14393933065d5b207e37d088`
  - Buy this item explicitly copies the authenticated customer session into `tradeflow_checkout_session` before navigating to Checkout.
  - Checkout URL version advanced to `checkout_v=7`.
- `customer-checkout.js` commit `b0636fdf5bbcb4963c526b38491b4753ff993593`
  - Reads the dedicated checkout handoff first, then retains the existing session fallbacks.
- `customer-checkout.html` commit `c4c6e1f4002779137230324bd3a4592e71bc1fcb`
  - Bumped customer-auth to v13 and checkout script to v8.
- `public-site.html` commit `b5e7f2302884ac43c2d008775ecb99aea7987e96`
  - Bumped public-site JavaScript cache.
- `customer-dashboard.html` commit `c71f77872a9eb33998dbbf58dd59df9e5f8659af`
  - Bumped customer dashboard/auth assets.

The intended Test Two path is now:
Customer Portal signed in → Visit Shop → Nikon COOLPIX P1100 → Buy this item → Checkout opens the authenticated purchase screen.

Test One remains frozen. No retail order is created by opening Checkout.
