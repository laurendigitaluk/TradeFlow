# Project memory — Gemma post-route-merge review enrichment and telemetry identity

Date: 7 November 2026 (UTC)
Scope: TradeFlow LIVE 3D Printers only (3d-printers-equipment / 3d-printers).

PR #278 merged to production as fece19063a4101b449fa3cc120a652c9acd66d15; PR #281 merged as bae3c4145bc0fd78de9ac803e81cd9077ba0c930. Production now includes lane isolation, expanded route handling, and verified 3DFLO, iDig3DPrinting, 123-3D and ELEGOO UK route definitions. The Research PC has not yet been updated, so a new LIVE run would not yet prove those new routes work on the local worker.

Latest genuine 3D run: owner-3d-printers-controlled-rerun-20261107-2225 completed 8/8 at 22:54:46 UTC: 31 searches, 13 pages discovered, 8 fetched, 5 extraction calls, 2 failures, 8 captures, 8 duplicate skips, 0 new queue rows. Previous run: 123 searches, 83 discovered, 51 fetched, 27 extraction calls, 20 failures, 51 captures, 15 duplicate skips, 36 unique rows staged.

LIVE queue is 40 rows: 30 uk_new, 6 uk_used, 4 uk_both; 3 have top-level prices, 1 typed evidence, 1 reviewed marker, 0 approved/imported/enriched.

Schema correction: LIVE platform_catalogue_research_queue has reviewed_by, reviewed_at, approved_at and imported_at, but no approved_by or imported_by. Original PR #282 used nonexistent columns in its SELECT/PATCH filters and must not be merged unchanged. Replacement PR #284 uses only actual columns, performs append-only unverified enrichment for exact matching unreviewed needs_research captures, preserves top-level price/evidence/review fields, and applies optimistic concurrency. It separates new vs enriched staged counts and propagates task keys.

Telemetry identity finding: a Sigma lens task with category_slug=lenses and branch_slug=photography-lenses incorrectly carried agent_key=3d-printers-equipment. Two lens subtasks were attributed to the 3D row, taking its counter from 49 to 51. PR #284 remaps only this mismatched key to the explicit non-3D category. Historical counters are not rewritten. The last 3D status heartbeat at 23:31:38 UTC was written by the lens task; the worker only reports periodic status heartbeat during active claims, not idle polling, so this timestamp cannot establish current PC process liveness.

No task was queued; no queue/source/catalogue rows were changed; no approvals/imports, TEST/LIVE crossover, secret changes, Research PC update, restart, merge or deployment. Preserve the local .env and TRADEFLOW_GEMMA_ENV_FILE.