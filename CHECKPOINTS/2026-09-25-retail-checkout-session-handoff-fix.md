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


## Definitive session architecture correction — 2026-09-25

A new product was created and published and the customer still reached Checkout with **Sign in to continue** while the Customer Portal in the same browser showed the authenticated customer. This ruled out the earlier hypothesis that the problem was caused by the customer buying back the same item they had previously sold.

The earlier dedicated `tradeflow_checkout_session` handoff introduced an unnecessary second customer-session state. That was replaced with a single canonical authenticated customer session:

- `tradeflow_customer_session` is now the sole session source for both Customer Portal and Checkout.
- `customer-auth.js` no longer writes or restores a separate checkout session.
- `customer-checkout.js` restores only the canonical customer session.
- Customer Portal and Checkout now use the same current customer-auth script version.
- Checkout cache: `customer-auth.js?v=14`, `customer-checkout.js?v=9`.
- Customer Portal auth cache: `customer-auth.js?v=14`.

Commits:
- `589ee8a0986faa5fa620c9a6ee552b3f98fede97` — canonical customer session in customer-auth.js
- `f5b813f36e148607388d039ecc7eee96b42d9a70` — canonical customer session in checkout
- `fc0801378b48e7f1fac091cefa7b42d356c87502` — checkout cache publication
- `9a148edbf651d88ff3b8473dee77cd9e1d9d6ca2` — customer portal auth cache publication

This is intended as the architectural correction rather than another checkout-specific handoff patch. Test One remains frozen and no retail order should be created merely by opening Checkout.


## Standalone checkout route retired — 2026-09-26

Repeated live testing showed that the standalone `customer-checkout.html` route continued to display the sign-in screen even when the Customer Portal was authenticated in the same browser. A new product reproduced the issue, ruling out the previous trade-in/buy-back hypothesis.

The standalone checkout route has therefore been retired rather than patched again. The purchase screen is now part of the authenticated Customer Portal itself:

**Public product → Customer Portal with listing_id → authenticated portal → Complete your purchase → Stripe/internet payment or customer credit.**

Changes:
- Buy this item now opens `customer-dashboard.html?tenant_id=...&listing_id=...&purchase=1`.
- Customer Portal owns the authenticated session and the purchase screen uses the same in-memory authenticated session and RPC layer.
- New `customer-purchase.js` handles listing, addresses, customer credit, order creation and payment selection inside the portal.
- Removed the old `customer-checkout.html` and `customer-checkout.js` route completely.
- Removed remaining `tradeflow_checkout_session` storage logic.
- Test One remains outside this route and is not changed.

Commits for this architectural change:
- `97f656987fbd8ff67adab6fda6c4c92eed72bb2d` — integrated purchase module
- `4d228a4667eec1cb25b0d2d1784e15dd2dac5c78` — purchase UI
- `9dc1624be0a93a7414cd68ecc603d5eac98e3cf7` — authenticated portal purchase routing
- `fc7bc36a23b894312749c4e17012b1ace76237bd` — public Buy routing
- `7f7d9b3dc73635194b7eade13f4ef70d72dc72b8` — public-site cache publication
- `75ea89ef4ef065a250d55a28b15a7fd538a153db` / `bc7551d9aa0220f98549846a0ea97ac7516250c` — obsolete checkout route deletion
