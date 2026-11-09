# 2026-11-09 — Anycubic UK five-product discovery failure and route repair

Environment: TradeFlow LIVE. Worker DESKTOP-LVASEUB-129576. Batch owner-3d-printers-equipment-1794259145802 submitted 21:19:05 UTC; worker started 21:19:18, completed 21:21:16 UTC.

Products: Anycubic Kobra 3 Max V2 4-Color Combo, Kobra 3 Max V2 Standard, Kobra 4 Standard, Kobra 4 ACE 2 Pro Combo, Kobra S1 4-Color Combo. Only Kobra 4 Standard queued one raw capture; extraction timed out ~45s. Other four had zero captures. Task completion does not imply evidence success.

Verified UK URLs:
- https://uk.anycubic3d.com/products/kobra-3-max-v2-3d-printer
- https://uk.anycubic3d.com/products/kobra-3-max-v2-ace-2-pro-combo
- https://uk.anycubic3d.com/products/kobra-4-3d-printer
- https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo
- https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo-3d-printer

Changes in this branch: verified direct routes in source-playbooks.mjs; matching route regression expectations in source-playbooks.test.mjs; updated AI manual, handbook and diagnostic roadmap. Scope is deliberately limited to 3D printer website routing. No database/worker/production changes made. Existing 20-link cap, model/variant matcher strictness and Gemma timeout require separate verification and likely follow-up fixes.

Next: run node --test tools/tradeflow-gemma-agent/src/source-playbooks.test.mjs in CI or development checkout; review and merge only after passing. Update existing Research PC from production (do not reinstall or modify .env), restart 3D printer specialist, run one controlled LIVE five-item batch. Verify exact source URL, page captures, package-specific GBP price, queue handoff and dashboard status. Do not alter Gaming, Stripe or tenant data.
