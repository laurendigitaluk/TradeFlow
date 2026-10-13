# Documentation Retirement Audit — Environment Decision Reset

**Date:** 13 October 2026  
**Repository:** `laurendigitaluk/TradeFlow`  
**Branch:** `docs/authoritative-environment-reset-20261013`  
**Scope:** AI Operating Manual, System Handbook, Backend User Manual, Human User Manual, Live Launch Runbook, repository README.

## User-confirmed operating decision

The previous TEST-first release workflow is superseded. The user stopped using the former TEST environment for active work and built/tested the intended LIVE environment, with the plan to preserve that validated environment as the new TEST copy and create a separate LIVE environment from it.

Required sequence:
1. Establish the real current state of GitHub, deployed Cloudflare Worker/assets and Supabase project(s) independently.
2. Diagnose and repair the current SceneSource customer-login fault based on the actual deployed request path.
3. Verify the repaired build and key workflows against observed evidence.
4. Preserve the validated environment as the new TEST copy.
5. Create a separate LIVE environment from that baseline.
6. Verify hard separation of deployment, runtime config, Supabase, auth, data, domains and secrets; run role-specific login/session acceptance tests.

Do not infer environment identity from branch names, old project labels or manuals. Do not merge/force-sync divergent branches. A commit is not proof of deployment.

## Documentation changes on this branch

- Added the 13 October authoritative environment decision at the top of the AI Operating Manual, System Handbook, Backend User Manual and Human User Manual. It explicitly supersedes conflicting 9 October audit notes and old TEST-first instructions.
- Replaced the obsolete Live Launch Runbook body with a retirement notice. Its prior content remains available in Git history, not as current instructions.
- Replaced the README's obsolete Customer Test Lab startup directions with links to the authoritative manuals and current environment decision.
- The subscriber-facing `subscriber-website-manual.html` was reviewed at its opening section; it documents subscriber website operation and contains no TEST-first environment/release instructions in the inspected section. It was not changed.
- Historical dated checkpoints and pasted/library prompts were not deleted because they are audit history and may preserve evidence of earlier states. They must not be treated as current instructions where they conflict with the 13 October decision. A separate inventory is still needed for any standalone Library files outside the repository.

## Login fault: evidence and next diagnostic steps

The observed SceneSource browser request previously returned HTTP 400 with `No API key found in request`. A later attempt showed “Invalid login credentials”, but the exact request for that later message was not independently established. Logs with referer `tradeflow.leannelaurenlowe.workers.dev` are not evidence for the SceneSource request.

Next:
1. Compare the currently served `customer-auth.js?v=21` and customer dashboard HTML against this branch's production source.
2. Establish which Cloudflare Worker deployment and environment variables actually serve `www.scenesource.co.uk`.
3. In a controlled browser test, capture the exact SceneSource token request's URL/host, headers presence (never expose the key), status and response.
4. Correlate that exact attempt with LIVE Supabase Auth logs by time/path/status.
5. Fix the proven cause in code/config, verify deployment, and repeat login/session tests.

Do not reset passwords, create/delete accounts, change customer records or mutate LIVE Supabase during diagnosis without explicit user approval.

## Status

Documentation edits are staged on an isolated branch for review. They are not yet merged into `production`. No application runtime, Cloudflare deployment, Supabase data/configuration, user account, DNS or published site was changed by this documentation audit.
