# Project Memory — 3D Printers & Equipment LIVE/TEST reconciliation

8 November 2026. LIVE gxsrajtqzdjvmceqcpgv; TEST nnsshnfkjcflucjrftzi; category 3d-printers-equipment / branch 3d-printers.

Prior 5 November checkpoint confirmed canonical product IDs d51a8e10...601/602/603 (TEST) and e62b9f21...601/602/603 (LIVE); duplicates c7e4a901...601/602/603 (TEST) and d8f5b012...601/602/603 (LIVE) were intended inactive/hidden. A later parallel insertion reversed the flags on SPARKX i7, HALOT-MAGE S 14K and HALOT-R6. Restored canonical standard-package products and evidence to active, duplicates and duplicate evidence to inactive/hidden. Also deactivated extra TEST parallel evidence f73c9d20...611/612/613. No records deleted.

Shared 208 product identities now have exact matching master metadata. TEST retains one extra inactive/hidden Ender-3 V3 Neo / Printer only duplicate for audit.

Active evidence reconciled from LIVE to TEST. Seven equivalent TEST rows updated to matching LIVE keys/values, 21 missing active rows inserted, and seven older source-key observations added as distinct records. No LIVE evidence changed; no evidence deleted. Active evidence sets now match by product/source/source key: 260 each (239 UK new, 21 UK used). Three small note differences remain because TEST notes are more descriptive; retained. Both have 0 active products missing evidence, 0 invalid active evidence, 0 duplicate active source keys.

Final counts: LIVE 208 products (201 active/visible, 7 inactive), TEST 209 (201 active/visible, 8 inactive); 2 branches and 18 manufacturers each. Inactive evidence history LIVE 17, TEST 21; extra TEST audit history retained. Used evidence is reference-only.

Gemma gate: PR #300 remains draft/open, not merged. CI 54/54 passed but Research PC installation and Ollama structured-output acceptance are unverified. No worker started/restarted or task queued. Complete remaining category and source-selection reconciliation before updating all Gemma workers/agents and running full research.
