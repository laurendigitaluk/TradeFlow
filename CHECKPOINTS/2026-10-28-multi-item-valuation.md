# TradeFlow Multi-Item Valuation Checkpoint — 2026-10-28

## Locked implementation scope
This checkpoint records the combined/multi-item valuation UI and current implementation state. It is a documentation and code checkpoint, not a declaration of full end-to-end acceptance.

## Source branches and files
- TEST branch: `cloudflare-test`
- LIVE branch: `production`
- Updated UI files on both branches: `customer-dashboard.js`, `buying-dashboard.js`
- Updated documentation on both branches:
  - `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
  - `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
  - `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
  - `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
  - `TRADEFLOW-MASTER-ROADMAP.md`

## What is working / visually reviewed
- Subscriber Buying dashboard groups items by their buying request.
- Opening an item from a multi-item request displays each request item's valuation workspace, stacked above research evidence and photographs.
- A single “Submit total valuations” control collects the cash/trade-in values for each item.
- Customer portal shows one combined quote when all items in a request have current published initial/revised offers, with per-item values and totals.
- Customer can accept an individual item for cash or trade-in, refuse an individual item, or use whole-quote accept cash / accept trade-in / refuse actions.
- Standalone requests remain separate. Final offers after inspection remain item-specific.
- UI changes were confirmed through screenshots supplied during testing. JavaScript syntax checks passed after changes.

## Backend behavior
- `customer_respond_to_combined_offer` exists on TEST and LIVE for a whole-request accept/refuse decision in one database transaction.
- Individual customer choices continue to use `customer_accept_offer_choice` and `customer_refuse_offer`.
- Every product remains a separate `buying_items` row and retains its own valuation, offer, workflow state and downstream acquisition/inventory lifecycle.

## Known limitation / not yet locked as fully verified
The subscriber-side “Submit total valuations” action invokes the existing manual valuation RPC once per item, sequentially. It is not atomic: a later failure can occur after an earlier item's offer has already been created. A future hardening change should introduce an atomic batch valuation RPC or implement explicit partial-failure recovery.

Full end-to-end verification remains outstanding for:
1. Mixed decision: accept one item and refuse another.
2. Whole-quote accept cash, accept trade-in and refuse-all actions.
3. Item-level shipping, receipt, inspection, final offer, payment and inventory after mixed decisions.
4. Failure handling during multi-item valuation submission.
5. Regression verification of the same behavior on TEST and LIVE.

## Data and release safeguards
- Do not copy TEST customer, tenant, request, valuation or offer data into LIVE.
- Do not test with real LIVE customer transactions.
- Keep LIVE Stripe and payment configuration unchanged.
- Do not mark this feature end-to-end tested or launch-certified until the checklist above passes.
