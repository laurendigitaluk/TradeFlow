# Gemma single-pass research checkpoint

Date: 2026-11-06
Branch: fix/gemma-single-pass-research-handoff-20261106

- UK-new and UK-used tasks for the same product/package are consolidated into one product task.
- One search and one batched Gemma extraction now classify sources as uk_new or uk_used. Ambiguous condition is excluded.
- UK source, visible GBP price, exact model and condition validation remain in place.
- Research handoff remains TEST-only for owner review when explicitly enqueued.
- Research no longer queries the TEST/LIVE master catalogue. Exact product checks and evidence insertion remain downstream in the approved importer.
- No catalogue/database data, schema, RLS, RPCs, tenants, customers, Stripe or deployments were changed.
- GitHub Actions passed: https://github.com/laurendigitaluk/TradeFlow/actions/runs/42210738184
- Research PC dry-run and elapsed-time comparison are still required. CPU-only inference remains unchanged.

Next: pull the branch after checking local uncommitted changes; run npm test; perform one dry-run and confirm one Gemma call per product; only approved evidence proceeds to the separate importer.