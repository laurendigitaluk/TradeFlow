# UK Used Evidence — Inspection-Only Policy Checkpoint

**Date:** 13 November 2026  
**Repository:** `laurendigitaluk/TradeFlow`  
**Branch:** `main`  
**Environment reviewed:** TradeFlow LIVE (`gxsrajtqzdjvmceqcpgv`)  
**Purpose:** Record the approved distinction between automatic valuation evidence and customer-facing used-market references.

## Decision

- UK New evidence is the only shared market evidence type used as the automatic valuation price reference.
- UK Used evidence is for customer inspection, comparison and source click-through only. It must never set, reduce, increase or otherwise influence an automatic offer.
- Keep useful UK Used listings where an exact package is unavailable if the closest model/package relationship can be verified and clearly disclosed.
- Match priority: exact model + exact package; exact model + different package; closest verifiable model/variant in the same product family.
- Mark sold/expired observations as historical, not current stock.
- Do not mislabel a related package/model as exact. Exclude unrelated models, accessories-only records, unverified bundles and non-UK sellers.
- Use existing `notes` to describe match quality, differences, seller location, asking/completed-sale status and limitations. No schema change or new evidence type is required.

## LIVE valuation boundary verification

Inspected `public.calculate_buying_item_valuation(p_tenant_id, p_buying_item_id)` directly in LIVE. Both tenant-specific research and shared market evidence fallback explicitly filter to `evidence_type = 'uk_new'`. The function returns `reference_type = 'uk_new'`. This confirms UK Used evidence is not used as the automatic valuation base.

No valuation function, database schema, RLS policy, RPC, Edge Function, catalogue master, tenant/customer/transaction data or deployment was changed.

## Research state at checkpoint

After Drone Batch 72:
- 541 active customer-visible drone products.
- 179 with neither UK New nor UK Used evidence.
- 148 UK New only.
- 112 UK Used only.
- 102 with both.
- 291 missing UK New.
- 327 missing UK Used.

Batch 72 added one UK Used observation:
- Yuneec Q500 4K Standard Package — £175 GBP, Gumtree UK, Good condition, seller in Ely, Cambridgeshire.
- Evidence ID: `9cb255f5-fec1-4621-bc75-d1f247e2c129`.
- URL: https://www.gumtree.com/p/drones/yuneec-typhoon-drone/1804442372

Batches 67, 68 and 69: 60 products reviewed, no qualifying imports. Batch 70 and 71: 40 products reviewed, no qualifying imports. Batch 72: 8 products reviewed, one import.

## Files updated

- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

No production code change was made. The documentation updates are on `main`; no deployment or branch promotion was performed.
