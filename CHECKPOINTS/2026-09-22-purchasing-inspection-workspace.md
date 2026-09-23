# TradeFlow Checkpoint — 2026-09-22 Purchasing Inspection Workspace

## Live state at start
- GitHub: laurendigitaluk/TradeFlow
- Supabase: twfbmjwwqzxdxvclxbun
- Test acquisition: ACQ-B11FB7341903
- Acquisition ID: f7486bb6-ff0f-49fb-b5f5-40298ff800d2
- Accepted offer: £100.00
- Acquisition status before inspection test: received
- received_at: recorded
- Original accepted offer is not changed by inspection.

## User-visible problem
The item had been marked received, but the Subscriber Buying dashboard did not provide the required next-step CTA or full inspection workflow. The existing Acquisition test workspace had generic status transitions but was not the intended Purchasing inspection experience.

## Implemented workflow
Received
→ START INSPECTION
→ linked Purchasing inspection workspace
→ compare against customer submission
→ record inspection checks/evidence
→ choose:
- Pass inspection — send to Sales
- Requires Testing
- Requires Repair
- Not as described — hold for review

Passed inspection:
- inventory asset inspection → ready_for_sale
- acquisition item inspection → finalised
- acquisition inspection → finalised
- completed inspection remains authoritative/read-only for Sales.

Repair/testing/hold outcomes do not enter Sales.

## Inspection record
The existing inventory_inspections table is used. The new workflow records:
- customer description confirmation;
- condition confirmation;
- package/accessories;
- serial/model verification;
- physical condition/damage;
- function/technical test;
- inspector condition grade;
- discrepancies/missing items/faults;
- inspection notes;
- inspection photographs;
- customer-description and condition snapshots in metadata.

## Database functions added
- subscriber_start_acquisition_inspection(uuid,uuid)
- subscriber_complete_acquisition_inspection(uuid,uuid,text,boolean,text,text,jsonb)

Both are permission/feature checked and use the central transition_workflow_entity for workflow status changes.

Starting inspection also repairs the previously observed acquisition-item lag by synchronising:
accepted → awaiting_item → received → inspection
when necessary.

## Frontend
Added:
- buying-inspection.js
- loaded by buying-dashboard.html

The inspection controller:
- changes the received-stage notification to "You've received the item — inspect it";
- provides a prominent START INSPECTION CTA;
- opens the full Purchasing inspection workspace;
- uploads inspection photographs to the existing private TradeFlow media bucket;
- completes the authoritative inspection workflow;
- preserves the original accepted offer.

The new JavaScript passed a parse-only syntax check after a quoting correction.

## Documentation updated
- docs/TRADEFLOW-HUMAN-USER-MANUAL.md
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- docs/TRADEFLOW-SUBSCRIBER-DASHBOARD-DIAGNOSTIC-ROADMAP.md

## Browser verification still required
Do not manually move the test acquisition yet outside the new CTA.

Open the live Buying dashboard, hard refresh if necessary, open BR-744BA41BDC, and verify:
1. the received notification says "You've received the item — inspect it";
2. START INSPECTION is visible;
3. clicking it changes the workflow to Inspection;
4. the full customer comparison/inspection workspace appears;
5. completing a passing inspection moves the item to Ready for Resale/Sales;
6. the original £100 accepted offer remains £100;
7. Sales sees the completed inspection read-only.

Do not introduce a second inspection state machine or use the legacy Acquisition test workspace as the primary inspection UI.


## 2026-09-22 — Correction: receipt → inspection → final offer

The customer-facing portal no longer exposes the internal term "subscriber". Customer wording now uses business/website terminology instead.

The received Purchasing stage now has a direct START INSPECTION action in the main Buying dashboard itself. This was moved into the authoritative dashboard controller so it does not depend on the supplemental inspection script to create the CTA.

The correct acquisition flow after receipt is:
Received → Inspection → Inspection complete / Final offer required → Customer accepts or refuses final offer → payment process → Sales.

The original accepted offer remains distinct from the post-inspection final valuation and final offer. A passed inspection therefore does not immediately put the inventory item into Sales. The inventory asset remains in inspection while the final offer is sent and awaits the customer's response.

The inspection completion RPC was corrected accordingly: acquisition and acquisition-item move to finalised with next_stage=final_offer; the inventory asset remains inspection and is marked as requiring a final offer. Testing and repair outcomes still leave the item in their respective Purchasing/Repairs routes.


## 2026-09-22 — Inspection CTA ownership and customer wording follow-up

The inspection CTA is now handled by the main Buying dashboard as the authoritative workflow controller. The supplemental inspection workspace delegates its `START INSPECTION` click to that controller when available, preventing the CTA from appearing clickable while being owned by a separate polling script. Customer selling-status wording has also been removed from the internal `subscriber` terminology, including receipt and inspection messages. Browser cache versions were incremented for the Buying and customer dashboard scripts.


## 2026-09-22 — Inspection CTA flicker/root-cause fix

The received-item CTA was being rewritten by the supplemental buying-inspection.js polling observer while the main Buying dashboard also owned the CTA. This caused the button to be repeatedly replaced in the DOM, producing hover flicker and unreliable clicks. The supplemental workspace no longer rewrites the workflow notice or attaches a competing inspection click handler. buying-dashboard.js now owns inspection CTA clicks through a delegated document-level handler, so the handler survives DOM refreshes. Buying dashboard script versions were bumped to v34/v4.


## 2026-09-22 — Live inspection RPC repair verified

The live START INSPECTION RPC was failing before the workflow transition. PostgreSQL reported `trigger functions can only be called as triggers`. Root cause was confirmed in the live function definition: subscriber_start_acquisition_inspection called generate_asset_reference() directly, but that function returns trigger and is only valid when fired by the inventory_assets INSERT trigger. The RPC was repaired and recorded as migration fix_inspection_rpc_trigger_reference; asset references are now generated inline and the existing inventory trigger remains authoritative. The Buying dashboard status notice was also corrected for received and inspection states, and its cache version was bumped to v35.


## 2026-09-22 — Receipt notice and direct Testing navigation

The Buying detail notice was corrected to use the linked acquisition workflow state first. This removes the obsolete “Item on its way — awaiting receipt / The customer has confirmed the item has been sent” message once the acquisition is received or in inspection. The inspection outcome label is now “Send to Testing”. Selecting that outcome exposes an OPEN TESTING link which opens the Inventory workspace directly filtered to status=testing and focuses the current inventory asset. No separate testing state machine was introduced. Dashboard script cache versions were incremented.

## 2026-09-22 — Corrected purchase boundary: inspection is before acquisition

The previous inspection implementation exposed a structural workflow error: accepting the customer's initial offer created an acquisition, and starting inspection created an inventory asset. That is too early.

The corrected architecture is:

**Initial offer accepted → Awaiting item → Shipping → Received → Inspection → Accept/Refuse → Final offer → Customer accepts final offer → Bank payment → Acquisition + Inventory.**

Pre-purchase records now live on buying_items using purchase_stage, with supporting tables buying_item_shipping, buying_item_inspections, and buying_item_media.

The current test Canon EOS R7 workflow was migrated back out of Acquisition/Inventory. The provisional acquisition f7486bb6-ff0f-49fb-b5f5-40298ff800d2 and provisional inventory asset 6f2e44cb-3bdd-48ef-8c81-eb43fb3cbfaf were removed because no final offer payment had occurred. The buying item remains in inspection, with the shipping handoff retained.

### Required future behaviour

- Inspection **Accept** does not create an acquisition; it moves to final_offer_required.
- **Send final offer** creates a separate final valuation/offer and moves to final_offer_sent.
- Customer final-offer acceptance moves to final_offer_accepted; still no acquisition/inventory.
- **Pay customer & create acquisition** records the bank payment and atomically creates the acquisition, acquisition item and inventory asset.
- Inspection **Refuse** routes to return and never creates an acquisition.
- Testing/repair remain pre-acquisition routes.

This supersedes earlier checkpoint wording that described the received/inspection record as an acquisition or inventory asset.

### Additional verification — acquisition visibility

The customer acquisition list and subscriber Acquisitions workspace now show only paid/completed acquisitions. Initial and revised offer acceptance remains in the pre-acquisition purchasing workflow.

## 2026-09-22 — Restored inspection navigation and job-board visibility

The Buying detail inspection state now includes the direct **OPEN INSPECTION** shortcut again. The shortcut navigates to the existing inspection workspace and does not create an acquisition.

The Business Dashboard workflow board was also corrected to read buying_items.purchase_stage, so customer-owned items in Received/Inspection/Testing/Repair/Final Offer/Payment stages are visible as active work even though no acquisition exists yet.
## 2026-09-22 — Direct inspection anchor corrected

The OPEN INSPECTION shortcut had been pointing at the parent item-detail container, causing the page to scroll to the quotation area. It now anchors directly to `#tradeflow-inspection-workspace`, the actual embedded inspection section.
## 2026-09-22 — Open Inspection async rendering repair

The URL hash was changing to `#tradeflow-inspection-workspace`, but the embedded inspection element was not yet present when the browser performed the native anchor jump. The shortcut now waits for the element to render and then scrolls directly to it.
## 2026-09-22 — Dashboard action repair

The Business Dashboard previously showed the inspection row but all summary cards remained at zero and the row only offered a generic Open Buying link. It now has a Needs attention count and an inspection-specific OPEN INSPECTION action. The action carries the request ID to Buying, which opens the request and waits for the embedded inspection workspace before scrolling to it.

## 2026-09-23 — Full audit and boundary hardening

A full audit of Quote -> Offer -> Shipping -> Receipt -> Inspection -> Final Offer -> Payment -> Acquisition -> Inventory identified two immediate UI defects and one architectural risk.

UI defects:
- OPEN INSPECTION was racing the asynchronous creation of #item-detail. It now waits for the inspection host and Buying triggers a refresh after rendering the request.
- The Business Dashboard expected a Needs attention element that had not actually been added to the HTML. The dashboard now contains the element and reads the live workflow through subscriber_get_business_workflow.

Architecture hardening:
- Acquisition creation now requires a paid acquisition status, an accepted final offer and a matching paid outbound payment record.
- Inventory creation now requires a paid/completed acquisition and a matching paid outbound payment.
- Obsolete acquisition-level inspection/receipt RPCs were removed.
- The Acquisitions UI no longer exposes pre-purchase lifecycle controls.
- Stale TEST1 requests were closed rather than deleted so their audit history remains available.

The Canon test remains at purchase_stage=inspection with zero acquisition and zero inventory records.

## 2026-09-23 — Second inspection-navigation repair

The first async fix did not resolve the live symptom. Code inspection found that the OPEN INSPECTION handler only waited for the inspection workspace; it did not call the renderer if the element had never been created. The renderer could also abort before appending the workspace because the optional buying_item_media query was not protected.

The repair now:
- actively calls the inspection renderer from OPEN INSPECTION when needed;
- prevents the native hash jump from competing with the renderer;
- treats inspection media as optional and non-blocking;
- returns a success flag from the inspection refresh;
- shows a visible error when the core workspace cannot be rendered;
- bumps Buying/inspection cache versions.

Current live DB state remains unchanged: Canon EOS R7 is purchase_stage=inspection, with no acquisition and no inventory asset. Browser confirmation is the remaining verification step.

## 2026-09-23 — Final offer, customer bank details and payment completion

The post-inspection path is now connected end-to-end around the existing pre-acquisition workflow.

Sequence:
1. Inspection accepted -> purchase_stage=final_offer_required.
2. Staff sends a separate final offer -> purchase_stage=final_offer_sent.
3. Customer accepts the final offer -> purchase_stage=final_offer_accepted.
4. Customer portal immediately asks for the UK bank account details to receive payment. The customer can save or update account holder name, sort code, account number and optional bank name.
5. The subscriber Buying workspace checks whether bank details are on file. Full bank details are exposed only through the finance.view-protected subscriber RPC; the payment operation requires buying.manage and finance.manage.
6. Staff sends the bank payment and records the bank payment reference using CONFIRM PAYMENT SENT & COMPLETE PURCHASE.
7. The authoritative purchase RPC verifies the accepted final offer, customer bank details and payment reference, then creates the paid Payment Record, Acquisition, Acquisition Item and Inventory Asset atomically and moves the buying item to purchased. The inventory asset starts at ready_for_sale.

Customer bank details are stored in a dedicated tenant/customer table with RLS enabled and no direct authenticated/anonymous table grants. Customer and subscriber access is through controlled security-definer RPCs.

The current Canon test remains at final_offer_required until the final offer is sent. No acquisition or inventory record is created merely by passing inspection.


## 2026-09-23 — Final offer, bank details and payment handoff verified

The post-inspection purchase backend already contains the intended next-stage workflow:

- Passed inspection moves the buying item to final_offer_required.
- subscriber_publish_final_offer creates the separate final offer and moves the item to final_offer_sent.
- The customer portal already presents the final offer for acceptance and, after final-offer acceptance, presents the secure bank-details form.
- customer_bank_details stores account holder name, UK sort code, account number and optional bank name; customer access is through customer_get_bank_details/customer_save_bank_details rather than direct browser table access.
- The subscriber Buying inspection workspace already checks subscriber_get_customer_bank_details after final-offer acceptance and masks the account number for display.
- subscriber_complete_purchase refuses to complete the purchase unless the final offer is accepted, bank details exist and a bank payment reference has been entered. It then creates the outbound paid payment record, acquisition, acquisition item and inventory asset with status ready_for_sale, and moves purchase_stage to purchased in the same transaction.

The missing connection found in this audit was the customer notification when a final post-inspection offer is published. The final-offer RPC now records an offer_sent notification event and queues the existing customer notification infrastructure when the customer has an email address. Migration 20260923000001_final_offer_customer_notification.sql was applied to live Supabase and committed to the repository.

For the current Canon test, the item is at final_offer_required with no bank details and no final offer yet. No purchase/payment/inventory record has been created. Staff must choose the final offer amount and publish it; the customer can then accept it and enter bank details; staff can verify the bank details, make the bank transfer, enter the bank payment reference and use CONFIRM PAYMENT SENT & COMPLETE PURCHASE. Only then is the item purchased and the inventory asset created ready_for_sale.


## 2026-09-23 — Customer portal login repair
**Symptom:** customer portal remained on the Customer account login screen after sign-in.

**Root cause:** `customer-auth.js` and `customer-dashboard.js` were both binding the same Sign in/Create customer account controls. The dedicated auth controller had been introduced to own the sign-in handoff, but the dashboard still contained its older direct authentication handlers. A sign-in could therefore trigger two authentication/initialisation paths concurrently.

**Repair:** removed the duplicate `signIn`, `signUp`, and password-keydown bindings from `customer-dashboard.js`. `customer-auth.js` remains the single auth controller and hands the authenticated session to the dashboard. Bumped the dashboard cache version to `v=16`.

**Expected flow:** enter customer credentials → `customer-auth.js` authenticates → session is saved → portal is revealed → dashboard `handleAuthSuccess` registers/loads the customer and loads portal data.


## 2026-09-23 — Follow-up customer login repair
**Observed:** the first duplicate-handler repair did not resolve the customer's live login screen.

**Second root cause identified:** the authentication handoff was dependent on the dashboard handler already being registered. The authentication controller did not itself reveal the portal when dispatching the successful session. Script ordering was also not deterministic because the authentication and dashboard scripts were not both deferred in a controlled order.

**Repair:** `customer-auth.js` now reveals the portal immediately after successful authentication and before handing the session to the dashboard. `customer-dashboard.html` now loads `customer-dashboard.js` first with `defer`, navigation second with `defer`, and `customer-auth.js` last with `defer`. Cache versions were raised to dashboard v17 and auth v5.

**Expected flow:** page loads → dashboard controller registers handoff → auth controller binds → customer signs in → login panel is hidden immediately → portal is revealed → authenticated session is handed to dashboard → customer registration/data loads.


## 2026-09-23 — Customer portal empty-account repair

- The customer portal was revealing its static `Welcome back` shell but showing zero requests/orders/returns because `customer-dashboard.js` contained a JavaScript parse error in the bank-details rendering block. The error was caused by single-quoted HTML containing the conditional text `hasBank?'Update bank details':'Save bank details'`, which terminated the JavaScript string before the portal controller could load.
- The broken block was converted to a template literal and the resulting file was syntax-checked successfully. `customer-dashboard.html` now references `customer-dashboard.js?v=18` to force the repaired controller to load.
- Live Supabase verification for customer `valley-discounts@outlook.com`, tenant `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`, confirms the customer profile, request `BR-744BA41BDC`, approved £100 valuation, published final offer `OF-A03E4C24CB`, and customer-facing RPCs all return the expected records when run under the customer's auth identity.
- The test buying item had a published final offer but was still marked `final_offer_required`. This was repaired to `final_offer_sent`, guarded by the existence of the published final offer. No acquisition or inventory record was created.
- Next customer step remains: review the £100 final offer and accept/refuse it. If accepted, the portal should collect bank details; the business then completes the external bank transfer and records the payment reference before acquisition/inventory creation.


## 2026-09-23 — Final payment, bank-detail reveal and purchase completion

- After final-offer acceptance, the Buying workflow now has a payment-completion path in the current repository. It checks the accepted final offer and customer bank details through a finance-gated RPC before enabling payment confirmation.
- Customer bank details are masked by default in the subscriber Buying workspace. Sort code and account number can be hovered to reveal the full values. Full values are only returned by `subscriber_get_buying_item_payment_details`, which requires both `buying.view` and `finance.manage` permissions.
- `CONFIRM PAYMENT SENT & COMPLETE PURCHASE` remains disabled until the payment prerequisites are present and a bank payment reference has been entered. TradeFlow does not perform the external bank transfer; staff make the bank transfer first, then record the reference in TradeFlow.
- `subscriber_complete_purchase` is now wired to the Buying dashboard. A successful confirmation atomically records the outbound seller payment, creates the acquisition and acquisition item, creates the inventory asset with `ready_for_sale`, moves the buying item to `purchased`, and queues the existing `payment_sent` customer notification.
- The current Canon test item remains uncompleted. It is at `final_offer_accepted`, with customer bank details present, and has no acquisition or inventory record yet. No payment was recorded during this repair.


## 2026-09-23 — Payment UI consolidation and CTA repair

- The first payment UI repair created a duplicate payment panel because both the Buying item workspace and the existing inspection workspace rendered payment controls. The duplicate Buying-dashboard payment panel has been removed. The inspection workspace is now the single payment UI for the `final_offer_accepted` stage.
- Bank details now use explicit Reveal/Hide controls rather than relying on a browser `title` tooltip. Sort code and account number are masked by default and can be revealed by an authorised subscriber user when making the bank transfer.
- The payment CTA is intentionally disabled until bank details are present and a bank payment reference has been entered. Typing a reference now immediately enables `CONFIRM PAYMENT SENT & COMPLETE PURCHASE`.
- The CTA calls `subscriber_complete_purchase`; successful completion records the payment, creates the acquisition/acquisition item and ready-for-sale inventory asset, changes the buying item to `purchased`, queues the existing `payment_sent` customer notification, and refreshes the workflow in place.
- Buying dashboard cache versions are now `buying-dashboard.js?v=44` and `buying-inspection.js?v=11`.
