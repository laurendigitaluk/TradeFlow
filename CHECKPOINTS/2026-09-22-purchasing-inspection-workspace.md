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


## 2026-09-23 — Payment CTA and customer payment-status refresh follow-up

- The payment completion CTA was adjusted so it is enabled whenever the customer bank details are present. It no longer becomes silently unclickable simply because the payment-reference field is blank. Clicking it without a reference now focuses the reference field and displays the required-reference message.
- The CTA still requires a bank payment reference before `subscriber_complete_purchase` can execute. This preserves the rule that staff must make the external bank transfer before recording it as paid.
- The customer portal now refreshes the selling workflow every 10 seconds while visible. After the purchase-completion transaction changes the buying item to `purchased`, the customer dashboard updates without requiring a manual page refresh.
- The customer-facing purchased status now explicitly reads `Payment sent — purchase complete` and explains that the business has sent the payment and the item is now part of business inventory.
- Current cache versions: customer dashboard `v21`; buying inspection `v12`.


## 2026-09-23 — Inventory payment-order guard repair

- The first live attempt to confirm the Canon payment reached the inventory boundary and returned: `Inventory assets require a recorded acquisition payment`.
- Root cause: `subscriber_complete_purchase` created the paid acquisition and acquisition item, but inserted the inventory asset before linking the outbound `payment_records` row to the acquisition. The inventory guard correctly rejected that ordering.
- The completion transaction has been repaired so `payment_records.acquisition_id` is populated immediately after the paid acquisition is created and before the inventory asset is inserted. The inventory boundary can therefore verify the recorded acquisition payment as designed.
- The failed attempt rolled back cleanly. Current Canon state remains `final_offer_accepted` with zero payment records, zero acquisitions and zero inventory assets. No purchase was completed by the failed attempt.


## 2026-09-23 — Customer payment-complete wording

- Customer-facing purchased-stage wording was simplified. The portal now shows `Payment sent` with the message: `The business has sent your payment. Please check your bank account for the payment.`
- Customer messaging no longer tells the seller that the item has become part of the business inventory. Inventory/acquisition progression remains an internal business-side workflow.
- Customer dashboard cache is now `customer-dashboard.js?v=20`.


## 2026-09-23 — Acquisitions dashboard loading and inventory hand-off

- The Acquisitions page was stuck on `Loading acquisitions…` because its legacy tenant helper only recognised the two old test-business tenant IDs. The live Camerashack tenant ID was valid in the URL but was rejected by that helper before the acquisition query ran.
- The tenant helper now accepts the tenant ID supplied by the authenticated subscriber URL, so the live acquisition query can run for the current tenant. Dashboard cache is now `acquisition-dashboard.js?v=16`.
- The current Canon purchase has already created acquisition `ACQ-BA60C739F2A2`, acquisition item `433b206c-0044-44fc-bdbf-9873c9bb6197`, and inventory asset `AST-20260923-F0856A6E` with status `ready_for_sale`.
- The Acquisitions item view now exposes an `Open in Inventory` link for an existing inventory asset. `ready_for_sale` is the pre-sales inventory stage: the item is owned and in inventory but has not yet been listed/sold. The Inventory workflow can then move it to `listed` when ready.


## 2026-09-23 — Acquisitions retired; Inventory becomes the hand-off point

- The separate Acquisitions UI is being retired from the subscriber navigation. The legacy `acquisition-dashboard.html` now redirects to Inventory so old bookmarks do not strand users on the obsolete workflow.
- A completed purchase already creates the acquisition record internally for audit/payment boundaries, but staff no longer need an Acquisitions screen to move the product onward. The customer payment completion transaction creates the inventory asset directly with `ready_for_sale` status.
- Inventory is now the operational hand-off: staff can edit the asset details, add photographs, and use `Send this item to a sales channel` / `Send to sales` to open the Selling workspace for that inventory asset.
- Selling accepts a preselected inventory asset and lets staff choose an active sales channel. The listing flow carries the inventory photographs into the listing. The inventory asset retains its lifecycle independently from the listing.
- The Selling asset lookup now includes `branch_id`, fixing the listing form's branch requirement for inventory-created assets.
- Inventory and Selling navigation no longer expose Acquisitions. The Inventory script cache is `inventory-dashboard-fixed.js?v=11`; Selling is `selling-dashboard-fixed.js?v=8`.


## 2026-09-23 — Replace Acquisitions with inventory-to-sales workflow

- The separate Acquisitions UI is retired from the operational workflow. A completed purchase now creates the paid acquisition record internally and the inventory asset directly at `ready_for_sale`.
- The old Acquisitions page no longer loads a separate workspace; it redirects to Inventory. This removes the obsolete `Loading acquisitions…` screen from the normal business flow.
- Inventory `ready_for_sale` is now the hand-off point to Selling. The inventory dashboard no longer offers a direct `Mark listed` action. It provides `Send to sales`, opening the Selling workspace focused on that inventory asset.
- Selling is the place where staff add/confirm the sales listing information: title, description, asking price, sales channel and postage/dispatch details. Inventory photographs are carried into the listing automatically.
- A live `TradeFlow Website` storefront sales channel has been created for the Camerashack tenant. The existing public website only displays listings after a listing is actually created and moved to `published`; changing an inventory asset to `listed` was never sufficient to create a website listing.
- The Canon test asset was returned from the accidental `listed` status to `ready_for_sale`. It has not been published as a sales listing because no genuine selling price/details have been supplied yet.
- The selling channel model remains extensible for marketplace channels. A marketplace must have its own configured sales channel/integration before TradeFlow can publish to it; the website channel is the current working storefront channel.
- Cache versions: `inventory-dashboard-fixed.js?v=11`, `selling-dashboard-fixed.js?v=9`.


## 2026-09-23 — Single Inventory → Sales workflow and autofill

- Acquisitions is no longer a separate business-operating category. Completed purchases are created as inventory directly; the acquisition records remain internal accounting/audit records.
- The main subscriber dashboard no longer presents Acquisitions as a workflow step. The legacy acquisitions page redirects to Inventory.
- Inventory `ready_for_sale` is the sales-team hand-off point. Selecting an asset or using `Send to sales` opens Selling with the asset focused.
- Selling now loads the complete inventory context for the selected asset: title, description, currency, current value as the initial asking-price suggestion, condition, serial number, quantity, location, category and selling branch. Category/branch are loaded from the actual tenant data rather than the old test-only lookup.
- Sales staff can then adjust the selling information and add postage/dispatch details before creating the listing for the selected sales channel. Inventory photographs are carried into the listing when it is created.
- The workflow is therefore Buying → purchased → Inventory / Ready for sale → Selling → selected sales channel → published listing. Acquisitions remains a back-office record rather than a user-facing stage.
- Selling dashboard cache is now `selling-dashboard-fixed.js?v=10`.


## 2026-09-23 — Sales listing source information and photographs

- The Selling workspace now treats the original Buying record and completed Inspection as source material for preparing a sales listing.
- When an Inventory asset is selected, Selling loads the linked buying item/request and displays the customer's item description, condition, request notes/explanation and structured customer-supplied fields. It also displays the latest completed inspection outcome, condition grade, inspection notes, inspection checks and discrepancies.
- Customer/inspection photographs linked through `buying_item_media` and `media_assets` are displayed in the Selling workspace using time-limited signed URLs. The underlying media bucket remains private; private Storage assets are intended to be accessed through authorised downloads or signed URLs. citeturn0search0turn0search1
- Sales staff can add further sales photographs directly from the Selling workspace. These are stored against the Inventory asset and are then available to be carried into listings.
- Manual Selling category and branch dropdowns have been removed. The listing inherits the category and branch already attached to the purchased Inventory asset, which are retained from the original Buying category/branch. The shared Category → Branch → Properties structure remains independently enabled for Buying/Selling, but the individual purchased item should not be re-categorised manually during listing preparation.
- The Selling workspace therefore uses the original buying classification as the source of truth for the shop listing, while the sales team concentrates on title, description, price, photographs, postage/dispatch and sales-channel publication.
- Selling dashboard cache is now `selling-dashboard-fixed.js?v=11`.


## 2026-09-23 — Dashboard workflow colour coding and Inventory action layout

- The Business Dashboard workflow now shows a live numeric count on each core stage: Buying, Inventory, Selling, Orders, Fulfilment and Returns.
- Workflow colour semantics are fixed: **green = action required**, **yellow = no action/waiting**, **blue = completed/active historical state**. Each stage has a clear CTA button rather than relying on plain text.
- Inventory is explicitly shown as the purchased-stock hand-off. A ready-for-sale inventory count appears in the Business Workflow and the Inventory card is green with **SEND TO SALES** when stock needs sales preparation.
- The Inventory page now keeps **Add product** collapsed by default as a dropdown/expandable block. The status/filter/refresh area is a separate block immediately below it.
- Inventory status rows are colour-coded and use explicit action buttons. A ready_for_sale asset is green and exposes **REVIEW & COMPLETE**. The inline Sales hand-off has been removed; **SEND TO SALES** only appears inside the asset detail after the Inventory completion check passes. completed lifecycle states use blue; waiting/no-action states use yellow.
- Selling retains the inherited original buying category/branch rather than asking sales staff to choose unrelated category and branch values. The selling listing should therefore use the original buying classification automatically; the sales team should not have to reclassify the purchased item merely to create a listing.
- Selling also has source-information and photograph areas for the customer's original submission and inspection record, plus customer/inspection photographs and additional sales photographs. These are now part of the intended listing-preparation workflow and should be visible below the listing form when the current deployed page is refreshed.
- Cache/version checkpoints: Inventory inventory-dashboard-fixed.js?v=12; Selling selling-dashboard-fixed.js?v=11.


## 2026-09-23 — Inventory → Sales repair checkpoint

- Live Canon asset: AST-20260923-F0856A6E, status ready_for_sale, linked Buying item 5b9165a4-6795-45dd-81ee-28355a69a066.
- Live Canon request: BR-744BA41BDC.
- Live Inventory photograph exists in inventory_asset_media / media_assets, while the Buying-item media relationship currently has no rows. This explains why the previous Selling photograph panel could report no photographs even though Inventory contained a photograph.
- Selling code was repaired to read both buying_item_media and inventory_asset_media, with media de-duplication and signed URLs.
- Selling now also surfaces customer identity/reference from subscriber_get_buying_item_customer_details and falls back to Not provided for unavailable values.
- The sales submit action now creates the actual listing, carries Inventory media into listing_media, transitions draft → ready → published, then transitions Inventory ready_for_sale → listed.
- The Selling primary button is labelled SEND TO SALES / PUBLISH TO WEBSITE.
- No Supabase schema or migration was changed in this repair.
- GitHub commits: aa72edde2cd097a646f01dd66614c69f6d89b4b5 (Selling media/publication logic), 72b9a1538ad8d330e926189b73a94797b6fafeb8 (Selling primary action wording).
- Verification completed: live database inspection confirmed the Canon inventory asset, linked buying item/request, inspection, Inventory photograph, active TradeFlow Website channel, and published site revision. The code path was inspected against the live schema and workflow RPC.
- Remaining end-to-end test: the Canon has no genuine retail asking price yet, so a real website publication has not been performed. Do not claim the product is live on the public website until that test is completed.


## 2026-09-23 — Inventory completion gate before Sales

The purchased item is represented once as an Inventory asset. It is no longer an active Buying item after purchase completion. The Inventory list now presents each purchased asset as a clear card showing the asset reference, product title, status, condition, quantity, purchase price, current value, location and serial number.

The old inline SEND TO SALES action has been removed from the Inventory list. Staff must select **REVIEW & COMPLETE**, check the Inventory record and complete the required stock information first. The detail view shows a completion checklist. SEND TO SALES is only displayed when the required Inventory information is complete. This prevents an unfinished asset from being handed to Sales and reinforces the workflow: Buying → Inventory → Sales, with one Inventory asset rather than a duplicate purchase item.

The current completion gate checks: product title, description, condition, quantity, purchase price, category, branch, location and serial number. Current value is retained as a separate field and is not treated as the retail asking price.


## 2026-09-23 — Compact Inventory → Product Listing workspace

Inventory is now intentionally compact: each active item is a single green action-required line showing only the product title, status and **REVIEW & COMPLETE**. The row opens the focused product workspace. The previous verbose inventory card and inline hand-off were removed so large inventories do not become long scrolling pages.

The focused product workspace places purchase/customer/inspection information and retained photographs first, followed by a simple retail listing template. The listing template pre-fills the product title and uses inspection notes as the listing description when available, otherwise the original customer/item description. Retail condition uses the business taxonomy: **Poor, Good, Very good, Excellent, Opened, Never used, Sealed**. Existing A/B/C/D values were found in the live `condition_grade` data; they were not part of the newly requested retail taxonomy, so legacy grades are not silently converted and the user is prompted to select the new wording. Additional listing photographs can be added before **SEND TO WEBSITE** publishes the listing.


## 2026-09-23 — Selling list cleanup and Retail Shop diagnosis

The Selling listings panel was redesigned to match the compact Inventory presentation: separated fields, status colour coding, consistent spacing and explicit action buttons. Focused Product mode now hides the general listing panel.

Live verification found listing LST-20260923-B5AAABFB is published and assigned to active storefront channel TradeFlow Website. The reason it does not appear in the Retail Shop is the inherited Camera category and Camera branch both have selling_enabled = false; the storefront publication function filters these out. No listing row is missing from the database.


## 2026-09-23 — Duplicate listing prevention and storefront repair

The Canon test identified and repaired a duplicate sales-listing path. Eight listings had been created against the same Inventory asset; one was published and seven were duplicate drafts. The seven drafts were removed. The Inventory asset is now `listed`, and a database partial unique index plus client preflight prevents another active listing being created for the same asset.

`buying_item_media` lacked the authenticated table-level SELECT grant despite having a SELECT policy, causing the Product workspace to show `permission denied for table buying_item_media`. The grant was restored.

Camera category and Camera branch were enabled for selling. The live published-store function now returns the Canon listing, so the listing is eligible for the Retail Shop.
## 2026-09-23 — Public Retail Shop image and product-page repair

- The live Canon listing remains LST-20260923-B5AAABFB, published, with one linked Inventory photograph.
- The existing get_published_store_listings function was verified to return the Canon listing, but it does not itself return media paths. The public storefront therefore now uses a separate get_published_store_listing_media security-definer function.
- The tradeflow-media bucket remains private. A storage SELECT policy now permits anonymous/public reads only when the object is linked to a published listing whose category and sales channel are active and selling-enabled and whose tenant has a published site revision.
- public-site.js now loads the published listing media, signs the private object URLs and attaches the first image to each listing card.
- Retail Shop cards now use **View product** and route to a public product page instead of customer-dashboard.html.
- A new public page=product&listing=... route renders the product details and gallery without requiring a customer login. The separate Buy action can still enter the customer account journey.
- The literal development search placeholder PLACEHOLDER was removed and replaced by the configured/default search placeholder.
- public-site.html cache versions were incremented to public-site.css?v=57 and public-site.js?v=56.

## 2026-09-23 — Inventory listed-state and focused Selling workspace repair

- Inventory rendering was corrected so listed no longer appears as **Action required**. Listed/completed lifecycle states show their actual status and use **VIEW PRODUCT**.
- Inventory script cache was incremented to inventory-dashboard-fixed.js?v=13.
- Focused Selling pages now hide the Existing listings panel before listing queries are rendered. This prevents the focused Product workspace from remaining on a misleading Loading listings… state.
- Selling script cache was incremented to selling-dashboard-fixed.js?v=15.
- JavaScript syntax was verified for public-site.js, inventory-dashboard-fixed.js and selling-dashboard-fixed.js.
- Live database verification confirms: Canon inventory asset status listed; exactly one active listing for the asset; one published listing returned by the public storefront function; one published listing media row returned by the new public media function.

## 2026-09-23 — Selling focused workspace lookup repair

The focused Product workspace was still showing the general Existing listings panel and lookup fields remained on Loading because the focused-mode initialization was running before the asset lookup completed. The Selling lookup loader now fetches the requested asset directly when an asset query parameter is present, handles the four lookup requests independently so one optional lookup cannot leave the whole form stuck in Loading, and applies focused-product mode only after lookups finish. The general Existing listings panel is hidden after focused initialization. The listed-item submit lock selector was also corrected so a listed product cannot expose an active publish button.

Selling dashboard cache version: **selling-dashboard-fixed.js?v=17**.

## 2026-09-23 — Final Selling loading and public product image repair

- The Selling Product workspace had a second loading problem caused by waiting indefinitely on the subscriber-auth readiness promise. The Selling loader now uses the already-established subscriber auth object immediately when available and has an eight-second failure timeout instead of remaining on Loading forever.
- Focused Product lookup and initialization therefore completes even when the authentication readiness promise has already been established elsewhere on the page.
- Selling dashboard cache version is now selling-dashboard-fixed.js?v=18.
- Retail product images were still broken because the public browser was attempting to create private Storage signed URLs directly. A public validation-only Edge Function named public-listing-media now validates that the requested listing is published, its category/channel are active and selling-enabled, and its tenant has a published site revision, then creates time-limited signed URLs using the server-side service role.
- The function source is stored in supabase/functions/public-listing-media/index.ts and is deployed to the live Supabase project.
- public-site.js now calls that function for published listing media instead of attempting browser-side private-bucket signing. Public site cache is now public-site.js?v=57 with CSS v57.
- The underlying tradeflow-media bucket remains private; this repair does not make the mixed business/customer media bucket public.
