# 3D Printers & Equipment — LIVE/TEST reconciliation checkpoint

Date: 8 November 2026.
LIVE project: gxsrajtqzdjvmceqcpgv.
TEST project: nnsshnfkjcflucjrftzi.
Category slug: 3d-printers-equipment; branch: 3d-printers.

## Prior fix/history checked
Read CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-13.md and PROJECT-MEMORY/2026-11-04-3d-printer-catalogue.md. The documented canonical product IDs are:
- TEST: d51a8e10-7c21-4a91-9e01-000000000601/602/603; canonical evidence IDs ...000000000611/612/613.
- LIVE: e62b9f21-8d32-4ba2-8f12-000000000601/602/603; canonical evidence IDs ...000000000611/612/613.
Duplicate product rows are c7e4a901...601/602/603 in TEST and d8f5b012...601/602/603 in LIVE. Those duplicate rows were intended to be inactive/hidden.

## Repairs applied
- Restored canonical SPARKX i7, HALOT-MAGE S 14K and HALOT-R6 standard-package product rows to active/customer-visible in both environments.
- Restored their canonical evidence rows to active.
- Set their duplicate printer-only product rows and duplicate evidence rows inactive/hidden.
- Deactivated the later parallel duplicate evidence rows f73c9d20...611/612/613 in TEST.
- Normalised the nine remaining shared product-note differences in TEST to the LIVE product master. Product metadata now matches exactly for the 208 shared product identities.
- TEST retains one extra inactive/hidden Ender-3 V3 Neo / Printer only duplicate. It is the sole product-set difference and is retained for audit.

## Active evidence reconciliation
Compared every active evidence record by manufacturer/model/package key/package name/branch/source name/source record key.
- Seven equivalent TEST observations were updated to the matching LIVE observation key and values.
- 21 missing active LIVE evidence observations were inserted into TEST.
- Seven additional older active source-key observations present in LIVE were added to TEST after the source-key comparison showed they were separate observations, not duplicates of the newer rows.
- No LIVE evidence rows were changed. No evidence rows were deleted.
- Active evidence sets now have 260 rows in each environment and no source-key differences.
- Three existing note-text differences remain; TEST has slightly more descriptive notes for Prusa Pro HT90 and SL1S SPEED and a minor wording difference for HALOT-X1 Max. Retained rather than reducing information.

## Final verified state
| Metric | LIVE | TEST |
|---|---:|---:|
| Product rows | 208 | 209 |
| Active/customer-visible products | 201 | 201 |
| Inactive products | 7 | 8 |
| Branches | 2 | 2 |
| Manufacturers | 18 | 18 |
| Active evidence | 260 | 260 |
| UK-new evidence | 239 | 239 |
| UK-used evidence | 21 | 21 |
| Inactive evidence history | 17 | 21 |
| Active products missing evidence | 0 | 0 |
| Invalid active evidence | 0 | 0 |
| Duplicate active source-key groups | 0 | 0 |

The extra TEST product and four extra inactive evidence history rows are retained audit records. UK-used evidence remains reference-only and must not affect automatic valuations.

## Gemma gate
PR #300 (fix/gemma-3d-printer-json-reliability-20261108) remains draft/open, not merged; latest head 09621a509c0cc31d4e3af659ede856b4cbab8258, CI 54/54 passed. Cloudflare TEST preview deployments exist, but Research PC installation and Ollama structured-output acceptance remain unverified. Do not start/restart Gemma or queue research until the updater/launcher and local Ollama acceptance gate is completed. No worker was started/restarted by this reconciliation.

## Next
Continue reconciling remaining intended categories and category-specific source selections. Do not treat PR CI or Cloudflare preview deployment as proof that the Research PC runtime is updated. Update all Gemma agents/workers together only after the category catalogue and source-selection gates are complete.
