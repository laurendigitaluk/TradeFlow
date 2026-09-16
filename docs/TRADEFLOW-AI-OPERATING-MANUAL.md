# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 2.3  
**Date:** 16 September 2026  
**Project:** TradeFlow

## 1. Purpose
AI continuity companion for TradeFlow. It records architectural truth, decisions, faults, lessons, verification state and exact stopping point so future sessions resume without guessing.

## 2. Mandatory procedure
For significant work: **Retrieve → inspect current GitHub → inspect current Supabase → identify the first actual failure/boundary → change minimally → test → verify live → document → checkpoint.**

Never rely on chat memory when current code/database state can be inspected. Never modify GearCashOut while working on TradeFlow.

## 3. Non-negotiable rules
- `tenant_id` is the primary security boundary.
- Tenant roles are exactly `owner`, `admin`, `staff`.
- Platform Owner is separate from tenant roles and cannot be self-claimed.
- Subscription capabilities belong to the tenant.
- Customer data remains tenant-isolated.
- Dynamic fields/options are database-authoritative.
- Business status changes use authoritative workflow services/RPCs where provided.
- Accepting an offer is not possession; acquisition, receipt, inspection, payment and inventory are separate steps.
- Do not assume a schema FK means an operational workflow exists.
- Do not mark a feature complete solely because code is committed.
- Do not expose test-lab onboarding as production onboarding.
- Never store secrets in docs or project memory.

## 4. Verification states
**Proposed → Implemented → Tested → Verified Live** are separate states. A commit is not live verification. A transactional rollback test proves database behaviour, not a persistent browser journey.

## 5. Current environment checkpoint
- GitHub: `laurendigitaluk/TradeFlow`, `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, `eu-west-2`.
- Recorded health: ACTIVE_HEALTHY.
- Recorded RLS checkpoint: 60/60 public tables.
- Customer security: 34/34.
- Customer subscription tests: Buying 17/17; Selling 17/17.
- Staff security lab: 19/19.
- Hardening sequence through Retail Orders: 044–062, followed by fulfilment/returns hardening.

## 6. Production onboarding remains OPEN
Development tenant insertion/test-lab onboarding remains separate from the required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## 7. Current operational chain
**Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order → Customer checkout → Fulfilment → Returns.**

The acquisition-to-finance/inventory handoff remains deliberately explicit because live inspection did not establish automatic status-driven creation of payment, ledger or inventory records.

## 8. Inventory checkpoint — 058
Inventory status entry is protected by `guard_inventory_asset_status_entry()` and must use `transition_workflow_entity()`.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 9. Finance checkpoint — 059–060
059 applies permission-bound access to payment and ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards.

Finance UI creates pending payment/ledger records and uses the workflow authority for status changes. No `module.finance` feature is to be invented.

## 10. Selling/Listings checkpoint — 061
Selling workspace is implemented against the live schema. It loads active channels, selling-enabled categories and `ready_for_sale` inventory, creates draft listings, advances them to ready and uses the central workflow for subsequent listing lifecycle changes.

## 11. Retail Orders checkpoint — 062
Subscriber Orders and customer checkout are implemented. Customer checkout requires an authenticated active customer, accepts only a published listing, creates a pending-payment order and linked item, reserves the listing and records workflow transitions. Payment collection remains open.

## 12. Fulfilment checkpoint
Live inspection confirmed fulfilment has subscription-aware `fulfilment.view/manage` access and an existing central workflow. `fulfilment-dashboard.html` / `.js` now provides subscriber creation and lifecycle controls.

Lifecycle authority: `awaiting → label → dispatched → delivered`, with dispatched/delivered → returned.

`guard_fulfilment_status_entry()` prevents direct client status edits. No carrier API, shipping-label provider or automatic fulfilment creation is assumed.

## 13. Returns checkpoint
Returns had overlapping legacy member/admin policies. These were removed so the subscription-aware returns policies are authoritative. `guard_return_status_entry()` prevents direct client status edits.

`customer_request_return()` was recreated with the existing signature and hardened to require an authenticated active customer belonging to the tenant, with an order item belonging to that customer and an order in `paid`, `fulfilment` or `completed`. The new request enters `requested` and is recorded in workflow history.

Return lifecycle authority: `requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed`.

`returns-dashboard.html` / `.js` provides subscriber review and lifecycle controls. Customer-facing return display/action UI is still open.

## 14. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**.

## 15. Manual UI testing
One manual test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 16. Change-control and memory
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

TradeFlow's live database must not be assumed to contain a project-memory table unless its actual schema is inspected. Do not invent memory tables, columns or records.

## 17. Current stopping point — 16 September 2026
Fulfilment and Returns are **BLUE / Implemented, persistent browser verification open**. Customer return display/actions, payment integration, shipping-provider integration, production onboarding and final browser verification remain open.

**Next safe action:** finish customer return visibility/actions, then payment integration and persistent browser verification.