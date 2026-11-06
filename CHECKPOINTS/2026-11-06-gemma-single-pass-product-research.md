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

## GBP prefilter regression (6 November 2026)

- The pre-Gemma page gate `hasVisibleUkPrice` rejected a valid Unicode pound-sign price even though the isolated matcher accepted it. This is an application-side defect: Gemma's extraction instructions cannot compensate for a page rejected before inference.
- The repair builds the pound-symbol matcher from Unicode code point 163, supports GBP text, normalizes non-breaking spaces, and retains the positive numeric price requirement.
- Regression coverage includes pound prices, comma-separated amounts, non-breaking spaces, no-price pages and zero-price rejection.
- HTML price entities are normalized by the page extractor to a GBP marker before the prefilter.
- CI passed for the initial PR revision (run 42211820540); a further non-breaking-space test and normalization correction were pushed afterwards. The latest revision still requires its own CI confirmation.
- Do not merge or update the Research PC until the latest revision's CI is green. Local attempted edits were restored from the pre-repair backup; no `.env`, GearCashOut config, TEST/LIVE data or deployments were changed.
