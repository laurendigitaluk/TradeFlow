# Gemma 3D printer evidence prompt checkpoint

Date: 7 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: production
Merge commit: 7a906f696d0e25f4d977efd755234eed67e8ee6d
PR: https://github.com/laurendigitaluk/TradeFlow/pull/274

## User goal
Improve the first Gemma research agent so it explores the assigned 3D printer products deeply and returns as much useful UK new/used market evidence as possible for ChatGPT to inspect. Gemma is a collector and extractor, not the final evidence approver. No automatic catalogue/evidence imports.

## Implemented
- Expanded the extraction prompt in tools/tradeflow-gemma-agent/src/agent.mjs.
- Exact manufacturer/model/variant/package identity is authoritative. Keep printer-only and Combo/bundle products distinct.
- UK GBP-only evidence; preserve seller condition wording for new, used, refurbished, reconditioned, ex-demo, open-box and opened-never-used.
- Contradictory availability/structured data and missing fields go to borderline review, not silent rejection.
- Three page excerpts per Ollama request, up to 2,600 characters each; existing num_ctx remains 4,096; num_predict is 1,024.
- If a fetched direct page matches the exact task model but Gemma omits it, retain it as a borderline ChatGPT-inspection lead.
- Added prompt and Ollama-options regression tests in source-playbooks.test.mjs.

## Validation
- GitHub Actions run 42407437564: successful.
- Node syntax check passed.
- Gemma task-group and website-playbook test suites passed.
- LIVE Supabase read-only check: required research tables exist; one existing 3D printer / 3d-printers branch candidate remains in needs_research.
- No Supabase schema/data writes, no task enqueue, no catalogue approval/import, no TEST/LIVE data sync.

## Deployment status
The merge is in GitHub production only. Research PC worker update/restart and live Gemma runtime acceptance are still pending. Do not claim the new prompt is active on the Research PC until the updater has run and the running worker version is verified. Preserve the dedicated local .env, all credentials, and TRADEFLOW_GEMMA_ENV_FILE.

## Next controlled test
1. Update the Research PC worker from production using the existing updater; do not overwrite its local environment file.
2. Verify the worker process starts and reports the expected production revision.
3. Dispatch only a small 3D printer batch covering more than one manufacturer and both machine-only and bundle/package examples.
4. Inspect fetched-page count, Ollama batch count, verified evidence, borderline leads, source failures and duplicate handling.
5. ChatGPT manually verifies every candidate before any catalogue/evidence import.
6. If results are satisfactory, expand coverage within the 3D printer branch only. Do not start other agent categories yet.

## Known limits
- The crawler discovers and fetches pages; Gemma only extracts from the supplied page excerpts. Prompt changes cannot repair a blocked/404/timeout website route. Source-playbook and fetch failures must be diagnosed separately.
- Three-page batching increases Ollama calls; monitor total runtime and local PC load.
- The fail-safe borderline retention depends on the crawler having already discovered and fetched a direct page whose title/URL matches the exact model. It does not create new website navigation paths.
