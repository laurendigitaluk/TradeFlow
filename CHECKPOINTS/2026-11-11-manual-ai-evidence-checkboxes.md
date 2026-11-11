# Checkpoint — Manual AI Research simple evidence checkboxes

Date: 11 November 2026
Environment: LIVE only

- Evidence dropdown replaced with three checkboxes: no used evidence, no new evidence, no evidence at all.
- No boxes checked = all products. Multiple boxes = any selected condition (OR).
- No evidence at all = zero active UK new AND zero active UK used records.
- No new / no used filters each test the respective evidence count independently.
- Updated RPC accepts all, no_evidence, missing_new, missing_used, missing_any.
- Dashboard script cache version v55.
- Test counts on Cameras → Photography Cameras → Nikon: all 205; no evidence 109; missing new 189; missing used 111; missing either 191.
- SQL verification rolled back; no product/evidence rows modified.
- GitHub commits: JS 586699546619529d639cba90ed780ff0340d5fa3; HTML 2778be40500d2918fc39d35135baf66fb6fa863a; cache bump 6766c7a4cde67bf157b8dcd73d083b8b04db17e1.
- Confirm Worker deployment completion before describing the frontend as deployed.
