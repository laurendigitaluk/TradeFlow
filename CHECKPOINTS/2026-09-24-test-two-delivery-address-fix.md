# Test Two — Customer Delivery Address / Parcel2Go Fix

Date: 24 September 2026

## Issue found
The customer portal showed a Delivery address, but the integrated Parcel2Go shipping handoff reported that no delivery address was available.

Live schema inspection established that `public.customer_addresses.address_type` only permits `primary`, `billing`, `shipping` and `other`. The correct internal value for the customer-facing **Delivery address** is therefore `shipping`. The deployed Parcel2Go Edge Function was stale and was querying `address_type=delivery`.

## Fix
- `customer-dashboard.js` uses `shipping` for the Delivery option and Add delivery address action.
- The Parcel2Go Edge Function was changed to query `customer_addresses.address_type=shipping`.
- Parcel2Go Edge Function `parcel2go-subscriber-shipping` was redeployed as version 3.
- No Supabase schema change was made.
- Test One data was not changed.

## Live verification
The Test Two customer has a saved shipping address:
- Customer: TEST CS CUST
- Address type: `shipping`
- Default: true

The remaining browser test is to refresh the subscriber buying page and request a Parcel2Go quote. The integration should now use that saved shipping address.

## Relevant commits
- Customer portal correction: `144231c001d0bff1158bd217dfe571d92b4d5ebe`
- Parcel2Go source correction: `f32e7c66c9d49eb98b7f12347a6c05449eadfaaa`
- System handbook correction: `ce7c68f535f832c6dd7b91951406a3d7e2bf7209`
- AI manual correction: `33fbcb6bc3952f3c06320c0d457c991e53c1b528`

## Restore points
- checkpoint-test-two-customer-portal-orders-20260924
- checkpoint-test-two-preflight-buying-flow-20260924


## Follow-up — Test Two valuation display

Live data confirms the approved manual trading value is cash £50 and trade-in £55, and the initial trade-in offer for £55 is accepted. The customer dashboard was corrected to display the accepted £55 trade-in amount and retain the underlying £50 cash / £55 trade-in values. The Buying dashboard Parcel2Go explanatory text was clarified so it no longer reads as a current missing-address error.

The customer address itself remains correct: `address_type=shipping`, default=true. Parcel2Go Edge Function version 3 uses the same `shipping` address type. Final quote-flow browser verification remains pending.

## Follow-up — Buying dashboard loading fix

The Test Two Buying dashboard was still showing the initial “Loading buying requests…” and “Loading completed purchases…” placeholders after the optional-data resilience fix. Inspection of the live frontend code found that customer-name enrichment was performed before the dashboard rendered any request data, so a stalled or failed customer enrichment request could leave the whole page looking permanently stuck.

The dashboard has now been changed so that:
- Core buying request/item/valuation/offer data renders first.
- Customer names are enrichment only and are loaded in a single customer query after the dashboard is rendered.
- Failure of customer-name enrichment no longer blocks the buying request list or completed-purchases list.
- The dashboard script cache version was bumped from v55 to v56.

Relevant commits:
- 70dba66432ed6d9395df487028947a7e93e3166e — render buying dashboard before customer enrichment
- a8c68e2c4f1832a48a22442b48dd6a2cfc3547e8 — refresh buying dashboard script after loading fix

The next browser check is a hard refresh of the Buying dashboard. The Test Two request should render instead of remaining on the loading placeholders. If it still does not render, the next step is to capture the browser console/network response rather than making another speculative database change.

## 25 September 2026 — Root-cause regression repair

The Buying dashboard remained on its static loading screen because the controller itself was not executable. Current-code syntax validation identified an unescaped ASCII apostrophe inside a single-quoted JavaScript string in buying-dashboard.js, in the Parcel2Go shipping handoff text (customer's). This caused a JavaScript SyntaxError before any Supabase loading request could run.

This supersedes the earlier assumption that asynchronous customer enrichment was the primary cause. The enrichment resilience repair remains in place, but the first failing boundary was the controller parse error.

Repairs:
- buying-dashboard.js corrected and syntax-verified.
- buying-dashboard.js now sets a startup marker.
- buying-dashboard.html now has an inline startup diagnostic and cache-busts buying-dashboard.js to v57.
- subscriber-auth.js, subscriber-tenant-context.js and buying-inspection.js were also syntax-verified.
- System Handbook and AI Operating Manual now contain a mandatory front-end regression gate.

Restore/testing rule:
- Test One branch checkpoint-test-one-20260923 remains frozen and must not be altered.
- Test Two data must not be deleted/reseeded to work around front-end failures.
- Before any further browser repair, identify the first executable boundary and syntax-check all changed/loaded controllers.

Relevant commits:
- 020af4b4654483aef6d55676d0c9943f1eb8bded
- 54b8022ffab4ca369ec0bc339ed4b8d7a847825b
- 3e488347ede1290a6dc8699d4995b23d3b676dfb
- c601b7b454410c02fb1bdf502eaf23db426f6367
- 0f402cceff48c000348ad494069839adc1eeaa2e0

Current state: Implemented in GitHub and syntax-verified. Browser verification remains the next step after GitHub Pages has published the v57 assets.

The parse regression was introduced by commit `5a7189449244399649f384901bcf93bf7c12c4d9` (`Clarify Parcel2Go customer address message`), which changed a safe string to `the customer's saved` inside a single-quoted JavaScript string. The fault was not a database/RLS regression. It has now been corrected and syntax-checked.


## 25 September 2026 — Second Buying navigation cache regression found

A further current-code audit found that the Buying controller had been cache-bumped to `v59`, but the Business Dashboard's three Buying navigation links still used the previous page cache key `?v=58`. This created a real path where clicking Buying could restore an older cached HTML document/controller combination, while a manual refresh fetched the newer page. This matches the observed behaviour: Buying loaded after refresh but not reliably when entered from the dashboard.

Repair:
- `subscriber-dashboard.html` Buying links synchronized from `?v=58` to `?v=59`.
- Current `buying-dashboard.html` loads `buying-dashboard.js?v=59`.
- `buying-dashboard.js`, `subscriber-auth.js`, `subscriber-tenant-context.js` and `buying-inspection.js` all pass JavaScript syntax validation.
- Both inline scripts in `buying-dashboard.html` also pass syntax validation.

Relevant commit:
- `6207f0ca4b028351ebee149598898a563ccf1f58`

State: Implemented in GitHub and syntax-tested. Browser verification remains required.


## 25 September 2026 — Buying dashboard rendering defects corrected

The browser screenshots showed that the earlier cache repair did not resolve the remaining two visual defects. A fresh source + DB audit found:

- buying-dashboard.js converted the stored literal \\n separators in the customer description to real newlines, then incorrectly split on the old literal separator. This is why the Nikon submission appeared as one continuous line despite the earlier attempted formatting repair.
- requestStatusClass() already mapped submitted to status-approved, but buying-dashboard.css contained no definition for status-approved, so the Submitted pill could not appear green.

Current live Test Two data at the time of this repair: request BR-4C34C6F633, item BI-9D1C8F01FB, customer CUS-E82930637A58, request/item status submitted, two media records. No DB state or media was changed.

Repairs:
- 8e6dbea8964296afeccb2d0f378f8ee57aea8f25 — correct newline splitting.
- c76d730df2f8eb823cea44d586781b07385bc2df — define explicit status pill colours.
- 6a7af0a400996db0c1ff7ac7f9c2ff583621013b — Buying page CSS/controller cache-busted to v6/v60.
- ccbbbf136c59a50cea1700a2b4d328e24b5147ad — Business Dashboard Buying links synchronized to v60.

State: Implemented in GitHub, live DB verified, browser verification pending. Test One remains frozen.


## 25 September 2026 — Second Buying rendering correction

The latest screenshot identified the actual remaining parser defect: `buying-dashboard.js` used `:\\s*` in the key/value regex. Because this is a regex literal, it matched a literal backslash plus `s` instead of whitespace, preventing Product type, Manufacturer, Model and the other colon-separated fields from being split. The regex is now `:\s*`.

The Submitted customer-review stage is also now greyed as a whole, with a neutral Submitted pill, instead of presenting only the word Submitted in green.

Repairs:
- 3ab98cbe927b0e2fc988728844601a7684bf8db7
- 1a09216ac77c656ab2636f81a94a6bace76fe6ef
- 65cb2522f5b0fdd1a3a3ab9a28f165b88a45b34a
- 13da412223385bdd73517ef9eebb07aab94b60bf

State: Implemented in GitHub, browser verification pending. No test data reset or database workflow change.
