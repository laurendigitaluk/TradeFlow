# Gemma evidence backlog and category source routing checkpoint

Date: 8 November 2026 (UTC)
Environment changed: TradeFlow LIVE only.
Code branch: fix/gemma-category-scoped-source-loading-20261108b.
Draft PR: #308.

## LIVE evidence backlog

The LIVE 3D-printer research queue contained 65 rows. ChatGPT reviewed captured page text, price contexts, product identity and the LIVE master catalogue.

- 9 rows were matched to existing master products and imported into public.shared_market_evidence.
- 56 rows were marked processed/rejected with a reason; their raw queue records and captures were retained.
- Verified status counts: 9 imported, 56 rejected.
- No rows remain in pending_review or needs_research for 3d-printers-equipment.

Imported observations:
- Bambu Lab A1 AMS Lite Combo: 3D Prima £315.00 new; 3DJake £305.83 new; Gumtree £250.00 used (seller says 134 print hours).
- Anycubic Kobra S1 Max standard: Anycubic UK £549.00 new; 3D Prima £619.00 new, out of stock.
- Anycubic Kobra S1 Max 4-colour Combo: Anycubic UK £749.00 new; 3D Prima £819.00 new.
- Creality K1: Creality UK £299.00 new.
- Creality K1 Max: Creality UK £589.00 new.

All nine records link to existing LIVE master product IDs and evidence IDs. No TEST records were copied. Evidence is market-reference data, not an automatic valuation or buying-price change.

## Queue/dashboard contract

public.platform_owner_list_catalogue_research_queue(p_status,p_limit) supports pending_review, needs_research, approved, rejected, imported and all. Its default is pending_review. Completed rows should leave the outstanding list but remain retrievable as imported/rejected history. Do not delete raw queue records to clear dashboard work.

## Agent source routing audit

LIVE source registry assignments were verified:
- 3D printers: 13 category-specific UK sources
- Cameras: 14
- Camera equipment: 14
- Drones: 6
- Gaming consoles: 12
- Laptops: 7
- Metal detectors: 6
- Mobile phones: 11

Explicit universal marketplace sources remain separate. The code currently downloads up to 100 enabled sources globally and filters category afterwards. PR #308 changes the query to load only the requested category plus * universal sources, enabled UK rows. It adds tests for 3D printers, cameras, drones, gaming consoles, laptops, metal detectors and mobile phones.

PR #308 is draft and must pass CI/review before merge. No worker deployment, Research PC restart or source-registry edits have been made for this routing change.

## Follow-up

1. Verify PR #308 CI and review its PostgREST array-overlap filter.
2. Merge only after tests pass; use the approved updater to install on Research PC and run one controlled task per agent category.
3. Confirm each agent only loads its category-specific sources plus universal sources.
4. Inspect the completed-history UI in the owner dashboard. Backend supports imported/rejected filters; browser verification of the UI remains outstanding.
5. Continue evidence review on any newly captured queue rows. Keep TEST and LIVE separate.
