# TradeFlow Unified Workflow Rebuild — 25 September 2026

## Protected baseline
- Test One remains frozen on branch `checkpoint-test-one-20260923`.
- Pre-rebuild Test Two code restore point: `checkpoint-pre-rebuild-20260925`.
- Post-rebuild code checkpoint: `checkpoint-unified-workflow-20260925`.

## Rebuild
The buying/customer workflow UI has been replaced with a single physical-item journey:

Valuation → Offer → Shipping → Received → Inspection → Payment → Inventory → Sale

The existing Supabase data model and security boundaries are retained. The existing `buying_items.purchase_stage` field is used as the authoritative item-stage value rather than adding another competing workflow column.

## Frontend changes
- Rebuilt `buying-dashboard.html` as the single buying workspace.
- Rebuilt `buying-dashboard.js` around the item-stage workflow and existing secured RPCs.
- Rebuilt `customer-dashboard.html` around the same journey.
- Rebuilt `customer-dashboard.js` around existing customer RPCs.
- Removed obsolete `buying-inspection.js`.
- Removed obsolete `buying-dashboard.css`; the new Buying workspace contains its required styles.
- Updated subscriber Dashboard Buying links to controller version 100 and simplified the workflow wording.

## Preserved configuration
- Test Two tenant: Camerashack.
- Test Two transactional data was already reset before this rebuild.
- 261 tenant buying catalogue products remain.
- 1 Parcel2Go connection remains.
- No Test Two customer, request, item, offer or inventory test records remain.

## Backend
No destructive schema rebuild was performed. Existing secured RPCs for valuation, offers, shipping, receipt, inspection, final offer, payment and inventory creation are reused.

## Verification
- New Buying JavaScript: syntax checked.
- New Customer JavaScript: syntax checked.
- Deleted frontend files are no longer referenced by the updated Buying page.
- Live browser verification is still required after GitHub Pages publishes the new main branch. GitHub notes Pages changes can take up to 10 minutes to publish.
