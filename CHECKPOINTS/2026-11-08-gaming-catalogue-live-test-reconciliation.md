# Gaming Consoles & Accessories — LIVE/TEST reconciliation checkpoint

Date: 8 November 2026.

## Scope
TradeFlow LIVE project `gxsrajtqzdjvmceqcpgv`; TradeFlow TEST project `nnsshnfkjcflucjrftzi`. Category slug: `gaming-consoles-accessories`.

## Final verified master catalogue state
- 285 products in LIVE and 285 in TEST.
- 20 branches in each; 24 manufacturers in each.
- All 285 products have active evidence in both environments.
- Product identity set and compared product metadata now match exactly: model, package key/name, branch, catalogue category, main category, product type, notes, active and customer-visible flags.
- Both environments retain 2 active product-package aliases for the category, including prior Hyperkin/Microsoft package spellings. No duplicate products were created.

## Evidence state
- LIVE: 413 active rows (248 UK new, 165 UK used), 12 inactive historical rows.
- TEST: 413 active rows (248 UK new, 165 UK used), 13 inactive historical rows.
- One additional inactive historical TEST row is retained. No evidence rows were deleted or blindly copied.
- Active evidence rows are not byte-identical across environments because separate captures retain differing source keys, timestamps, URLs and notes. Counts and new/used totals align; provenance is preserved. If exact evidence parity is later required, reconcile at source-record level, not by bulk overwrite.

## Actions
- Aligned product metadata drift in controller entries and package aliases in both databases.
- No Gemma workers or agents were started/restarted.
- No TEST/LIVE customer, tenant, website or ownership data was copied.

## Outstanding
- Verify Cloudflare dashboard asset deployment/browser refresh for PR #309 active-only dashboard lists.
- Continue preparing remaining product categories and reconcile each LIVE/TEST catalogue.
- After all categories are ready, update all Gemma workers/agents and run controlled research, then consolidate results.
