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
