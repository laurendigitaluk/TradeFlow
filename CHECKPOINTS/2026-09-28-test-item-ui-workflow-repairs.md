# TradeFlow — Test item BI-63F5AAA6AB workflow UI repairs — 2026-09-28

## Scope
Fresh end-to-end test item:
- Item: Nikon Nikkormat EL Standard
- Buying item: BI-63F5AAA6AB
- Live purchase stage at audit: final_offer_required
- Accepted initial cash offer: £25
- Latest inspection: accepted/passed

Working stages were deliberately left intact. Repairs are limited to the four issues reported during this test.

## Repairs
1. Removed the redundant visible valuation CTA after the valuation engine has returned `manual valuation required`. The workflow now presents one actionable manual valuation CTA: **Approve valuation & send offer**. The initial calculation control is renamed **Check valuation** and is hidden once manual valuation is required.
2. Customer shipping wording changed for `awaiting_item` when the shipping handoff exists:
   **Postage label received — post your item**
   with explicit instruction to print the label, attach it, post the item, and then press **I have sent my item**.
3. Customer shipping label/QR print renderer repaired:
   - 4in × 6in portrait page;
   - no forced 90° rotation;
   - image MIME type detected from the returned blob;
   - image/PDF rendered into the 4in × 6in print area;
   - A4 option keeps the 4in × 6in content at the top-left of an A4 portrait page.
   CSS `@page size` supports explicit 4in × 6in sizing in current browsers. citeturn0search0turn0search2
4. Revised final-offer button given a direct click handler and inline error status. Existing server-side `subscriber_publish_final_offer` RPC was not changed. The current live item is legitimately at `final_offer_required` with an accepted £25 initial cash offer, so a revised value such as £22 remains eligible for the RPC. Any backend error will now be surfaced in the Buying workspace rather than appearing as a dead button.

## Files/versions
- `customer-dashboard.js` updated
- `customer-dashboard.html` cache v135 → v136
- `buying-dashboard.js` updated
- `buying-dashboard.html` cache v54 → v55

## Verification status
- Live DB state verified.
- Code changes committed.
- Browser verification still required for:
  - revised final offer;
  - new shipping wording;
  - 4×6 label orientation;
  - 4×6 QR orientation;
  - A4 top-left print.
- Do not alter payment, inspection, acquisition, Inventory, Selling or Orders logic as part of this repair unless a fresh test demonstrates a separate failure.


## Follow-up: syntax repair
The first UI repair introduced a missing closing brace in `applyValuationResult()`, causing the Buying dashboard JavaScript to fail parsing and leaving Active items / Completed purchases stuck on “Loading…”. The syntax fault was identified by inspecting the deployed source structure and repaired without changing workflow logic.

- `buying-dashboard.js` cache: v55 → v56
- Repair commit: `c54667b797a6f31cdfec00b5df00a05e832b0df9`
- Cache-bump commit: `0233624dc408665667e5c79c19d2c2323636c2aa`
- Browser retest required after Ctrl+F5.


## Follow-up: second syntax fault found and repaired
The dashboard remained on “Loading…” because the valuation-state HTML string in `renderActions()` had a missing closing quote before its newline. This was separate from the earlier missing brace. The complete current `buying-dashboard.js` was syntax-checked after the repair and now parses successfully.

- `buying-dashboard.js` cache: v56 → v57
- Syntax repair commit: `e7857f6041c14464a876cf2549ea058aa9724d94`
- Cache-bump commit: `8010aea66a1f6eb57a4b2730ff1d14b6556f9a57`
- No database/workflow logic changed.


## Follow-up: customer condition submission repair
Fresh browser testing exposed the next small blocker at the customer valuation submission boundary. The customer-facing form submitted `opened-unused`, while the live `buying_items.item_condition` check constraint accepts `sealed`, `opened_never_used`, `excellent`, `good`, or `poor`. The Edge Function `customer-selling-submit` was therefore failing with a database check-constraint error before the request could complete.

Repair applied at the submission boundary only:
- factory-sealed → sealed
- opened-unused → opened_never_used
- excellent → excellent
- good → good
- fair → poor
- damaged → poor
- not-working → poor

Edge Function `customer-selling-submit` deployed as version 4. No existing buying workflow stages or existing records were changed.


## Follow-up: initial offer sent display
After an initial offer is successfully published, the Buying item workspace was still rendering the editable “Customer offer / Send cash & trade-in offer” block because both `valued` and `offer_ready` used the same renderer. The stage/status at the top already correctly showed “Offer sent”. The renderer is now split: `valued` retains the offer-entry CTA; `offer_ready` displays “Offer sent” and a waiting message with no duplicate send CTA.

- `buying-dashboard.js` cache: v57 → v58
- Repair commit: `0a1b77921b6704fca65b653d8c06e2234e7a86ee`
- Cache-bump commit: `40614b5a040378ff174dd29b16c810f7e5cfe1a6`
- No workflow/database logic changed.


## Follow-up: customer shipping stage wording
When the business has supplied the shipping label/QR, the customer card still displayed the raw internal stage name `awaiting item`, even though the detail panel correctly said “Postage label received — post your item”. The customer card stage is now derived as “Shipping label received — post your item” whenever the awaiting-item stage has a shipping handoff/label/QR available. The underlying workflow stage remains `awaiting_item`.

- `customer-dashboard.js` cache: v136 → v137
- Repair commit: `109328cc57447bd1473eb1e44638b8570a072d20`
- Cache-bump commit: `052cef4e8109287c79200e7e95f9cccb048f3624`
- No database/workflow status change.


## Follow-up: shipping label verification and inspection decision workflow
Live verification of Canon EOS R8 (BI-29E78F3A13) shows the customer shipping row contains a QR storage path but both `shipping_label_storage_path` and `shipping_label_url` are NULL. The label is therefore not merely hidden by the customer UI; there is no label reference stored for this test item. The existing subscriber upload control still accepts PDF/PNG/JPEG labels and remains available at the pre-dispatch handoff stage. No fake/reconstructed label was created.

Inspection workflow repair:
- Inspection now presents one decision point covering Accept original offer, Make a counter offer, Send for testing, Send for repair, and Refuse purchase.
- Counter offer requires a new amount different from the accepted value, completes the inspection as accepted, then publishes the revised final offer.
- Testing and repair stages now have continuation controls. Completing the work returns the item to inspection/offer decision; refusal closes the purchase as refused.
- The live inspection RPC now records Refuse as `offer_refused` rather than `return_pending`.
- New RPC: `subscriber_complete_buying_item_followup`.
- Buying Dashboard cache: v58 → v59.
- JS commit: `04a225b590acb94a47b427f190008693fc176092`.
- Migration commit: `bec222b624d4bd5c6c086a1aa4590c220e27f0ca`.
- Cache-bump commit: `180cfa5f2c5fe085188a1f90b57383a0cd1a1d9d`.
- No existing test item was manually advanced or reset.


## Follow-up: revised final offer blocked by incorrect currency source

Browser testing of Canon EOS R8 (BI-29E78F3A13) exposed the exact failure beneath the revised-final-offer button:

> column "currency" does not exist

The screenshot showed the revised value entered as £79.00 and the error rendered directly below the Notes field. Live schema inspection confirmed the root cause:
- public.buying_items has no currency column.
- public.offers does have currency.
- public.trading_values does have currency.
- The live subscriber_publish_final_offer function incorrectly attempted to read purchase_stage,currency directly from buying_items.

Minimal backend repair applied:
- subscriber_publish_final_offer now reads purchase_stage from buying_items.
- It derives the final-offer currency from the latest accepted offer for that buying item.
- It falls back to GBP for legacy records where the accepted offer has no currency.
- No purchase-stage rules, inspection rules, payment rules, shipping rules, or existing test records were reset.

Live migration:
- fix_final_offer_currency_source
- GitHub migration: supabase/migrations/20260928161000_fix_final_offer_currency_source.sql
- Commit: 2cf16e35a5fe8b5676cac192f8c917b0a93ba97c

Current Canon EOS R8 live state before browser retest remains:
- item reference BI-29E78F3A13
- purchase stage final_offer_required
- accepted initial offer £99
- no final offer created by the failed attempt

Next browser verification:
1. Refresh the Buying dashboard.
2. Keep the Canon EOS R8 at final_offer_required.
3. Enter a revised value different from £99, e.g. £79.
4. Send revised final offer.
5. Confirm the subscriber stage changes to final_offer_sent.
6. Confirm the customer portal receives the revised final offer.
7. Do not manually alter the item if the test fails; capture the exact displayed error.
