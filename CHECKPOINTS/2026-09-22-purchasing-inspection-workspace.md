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
