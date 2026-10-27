# Lauren Digital Deployment Architecture and Release Policy

**Status:** Working baseline  
**Last reviewed:** 27 October 2026  
**Purpose:** A durable plan for independently developing, testing and releasing TradeFlow, PageFlow/BusinessFlow, StudioFlow and the central Lauren Digital owner dashboard without products or environments overwriting one another.

## 1. Executive decision

Keep product codebases and deployment pipelines separate. Integrate them through a central Lauren Digital owner dashboard and explicitly defined, authenticated interfaces—not by combining all application code into one repository. Each product must be independently developable, testable, deployable and recoverable. A release for one product must not automatically deploy the others.

## 2. Product map

| Product | Purpose | Repository / codebase | TEST | LIVE |
|---|---|---|---|---|
| TradeFlow | Buying, valuation, inventory, sales, subscriber operations | `laurendigitaluk/TradeFlow` | `tradeflow-test` Worker + TradeFlow TEST Supabase | `tradeflow` Worker + TradeFlow LIVE Supabase |
| PageFlow (historically BusinessFlow) | Website builder and subscriber websites | `laurendigitaluk/BusinessFlow` until deliberately renamed | `businessflow-test` Worker and isolated test data | `pageflow` Worker and intended live data |
| StudioFlow | Specialist website builder for studios, salons, halls and venues | Separate repository/codebase when created | StudioFlow TEST Worker + test data | StudioFlow LIVE Worker + live data |
| Lauren Digital | Parent brand, product cards, owner controls | Central owner experience integrated into TradeFlow initially | Build and verify in TradeFlow TEST first | Promote only after approval and verification |

**Naming note:** PageFlow is the selected product name, while the repository is currently named BusinessFlow. Do not rename repositories, Workers, domains, database objects or secrets as part of an unrelated fix. Treat naming changes as a separate reviewed migration.

## 3. Intended architecture

```text
Lauren Digital parent brand
└── Central platform owner dashboard
    ├── Product visibility / public product cards
    ├── TradeFlow settings (authorised TradeFlow service)
    ├── PageFlow settings (authorised PageFlow service)
    └── StudioFlow settings (authorised StudioFlow service)

Independent product systems
├── TradeFlow
│   ├── TEST Worker → TradeFlow TEST Supabase
│   └── LIVE Worker → TradeFlow LIVE Supabase
├── PageFlow / BusinessFlow
│   ├── TEST Worker → PageFlow TEST data/services
│   └── LIVE Worker → PageFlow LIVE data/services
└── StudioFlow
    ├── TEST Worker → StudioFlow TEST data/services
    └── LIVE Worker → StudioFlow LIVE data/services
```

The owner dashboard is an administration surface, not a shared database for all customer activity. Each product owns its subscriber records, site content, product data and operational workflows. The dashboard calls narrowly scoped authenticated APIs; platform-owner authorisation must be enforced server-side.

### Owner dashboard responsibilities

- Manage Lauren Digital product cards and visibility.
- Show product readiness/status and link to the correct administration surface.
- Manage existing TradeFlow owner functions: tenant/subscriber management, complimentary subscriber flow, domain request review, plans, email settings, AI settings and manuals.
- Manage PageFlow and StudioFlow settings only through their authorised services and own data stores.
- Clearly distinguish product settings from subscriber operational data.
- Do not expose server secrets or give one product's owner session unrestricted access to another product.

## 4. Non-negotiable safety rules

1. **No blind branch merges.** TradeFlow `main`, `production` and TEST branches have diverged. Never merge wholesale without file-level review, a tested merge plan and a checkpoint.
2. **No blind environment copying.** Never copy LIVE customer records, subscriber ownership, auth users, domain ownership/custom-domain verification or LIVE Stripe settings into TEST.
3. **No TEST-to-LIVE data promotion by default.** Promote reviewed code and schema migrations separately. Catalogue imports/evidence use their own explicit, idempotent workflow.
4. **No production route changes during diagnosis.** Do not change Cloudflare custom domains, routes, DNS, Worker names, build settings or traffic allocation until the current route and rollback plan are recorded.
5. **One writer per deployment configuration.** One named person/agent owns changes to a Worker configuration, release branch and route at a time. Other agents must not edit the same files until hand-off.
6. **Database agents remain scoped.** Catalogue agents may continue approved product/evidence reconciliation in assigned tables. They must not alter Worker routing, deployment config, auth, Stripe, tenant ownership or unrelated schema without coordination.
7. **Never put secrets in frontend code or Markdown.** Service-role keys, Stripe secret keys, tokens and credentials stay in protected server-side secrets.
8. **Every change needs a checkpoint.** Record commit SHA, target Worker/environment, database project, tests and rollback method.
9. **A successful build is not a successful release.** Verify the deployed URL and real user journey after deployment.
10. **Keep LIVE available.** A failed TEST release must not alter the current LIVE Worker/configuration.

## 5. Repository, branch and Worker rules

### TradeFlow

Known repository: `laurendigitaluk/TradeFlow`.

Branches observed:
- `main` — Cloudflare `tradeflow` LIVE Worker recently built from this branch.
- `production` — contains the Lauren Digital-branded owner dashboard HTML.
- `test/stripe-connect-test-mode-repair-20261020` — branch associated with the `tradeflow-test` Worker in the observed deployment history.
- `feature-laurendigital-parent-home-20261020` — central dashboard feature and route fixes.

These branches are not interchangeable. A prior comparison showed major divergence between `main` and the TEST branch. That may include unrelated history; do not merge whole branch histories merely to align commit counts.

Required approach:
1. Identify last known-good LIVE and TEST commit SHAs.
2. Compare actual application files and their history.
3. Create a narrow release branch from the correct base.
4. Cherry-pick or re-apply only reviewed changes needed for TEST.
5. Preserve TEST environment variables and Stripe test mode.
6. Build/test in TEST and record deployed SHA.
7. Promote the same reviewed application change to LIVE only after approval; leave LIVE secrets and data bindings unchanged.

### PageFlow / BusinessFlow

Known repository: `laurendigitaluk/BusinessFlow`. Cloudflare showed separate `pageflow` and `businessflow-test` Workers.

A configuration mismatch was observed: `pageflow/deployment-config` has a Wrangler configuration naming the Worker `businessflow-test`, while Cloudflare shows a separate `pageflow` Worker. Reconcile the repository configuration with the actual Worker before changing names or deploying.

Required approach:
1. Record repository branch and commit deployed by each Worker.
2. Document which branch is TEST and which is LIVE.
3. Ensure TEST uses only PageFlow TEST services/data; LIVE uses only PageFlow LIVE services/data.
4. Verify editor, authentication, draft save, image upload, preview, publishing controls and subscriber isolation.
5. Treat Worker-name/domain renames as separate reviewed migrations.

### StudioFlow

When implementation begins:
- Create its own repository and Worker configurations, or explicitly approve another isolated approach.
- Provide separate TEST and LIVE service/data configuration.
- Do not copy PageFlow subscriber/site data into StudioFlow.
- Reuse shared UI components only through a deliberate, versioned interface/package.
- Do not mark it production-ready until its test journey passes.

## 6. Environment boundaries

| Concern | TEST rule | LIVE rule |
|---|---|---|
| Supabase | TEST project URL/key only | LIVE project URL/key only |
| Service credentials | TEST secrets only | LIVE secrets only |
| Stripe | Test mode/test products and prices | Existing LIVE Stripe config unchanged |
| Users/subscribers | Synthetic/test accounts | Real accounts |
| Domains | Test domains or isolated test records | Production domains/ownership |
| Site content | Test drafts and media | Approved production content |
| Deployments | Frequent, reversible | Verified releases only |
| Catalogue data | Approved idempotent reconciliation | Never overwritten from TEST |

Known TradeFlow Supabase IDs from the audit:
- LIVE: `gxsrajtqzdjvmceqcpgv`
- TEST: `nnsshnfkjcflucjrftzi`

Known PageFlow project ID from prior project records: `ktvvtdrdwlazfsgkfedo`. This ID alone does not prove whether it is TEST or LIVE. Confirm its intended role and bindings before deploying. Do not infer environment identity from project name alone.

## 7. Stop-overwrite / change ownership protocol

Until deployment alignment is restored, use a short freeze for infrastructure/routing—not a blanket freeze on all work.

### May continue
- Pokémon catalogue agent: approved catalogue reconciliation.
- PlayStation catalogue agent: approved product/evidence reconciliation.
- Other catalogue imports may continue if idempotent, table-scoped and not changing deployment/configuration/auth/tenant ownership.

### Must pause until hand-off
- Any agent changing Cloudflare Worker routes, custom domains, build settings, deployment branch configuration, `wrangler.jsonc` or Worker entry-point routing.
- Any agent merging `main`, `production`, TEST or feature branches wholesale.
- Any agent editing shared owner dashboard files (`platform-owner-dashboard.html`, `.js`, `.css`) while another agent integrates that dashboard.
- Any agent changing Stripe LIVE settings, LIVE authentication, tenant ownership or cross-product access policy.

Every agent hand-off must state:
- Repository and branch
- Files changed
- Commit SHA
- Intended Worker/environment
- Database project and tables touched
- Tests and result
- Whether deployment was triggered
- Conflicts or unfinished work

One agent owns shared deployment files at a time. Others wait until the owner hands them back.

## 8. Release process

### Phase A — Stabilise and inventory
1. Freeze route/build configuration edits.
2. Record current Worker routes, custom domains, deployment branches, active deployment SHAs and Supabase bindings.
3. Record the known-good LIVE deployment and rollback target.
4. Identify pending feature work before creating release branches.
5. Confirm catalogue agents' table scopes.

### Phase B — Repair TradeFlow TEST
1. Verify TEST build settings and source branch.
2. Establish a narrow TEST release branch from the appropriate code base.
3. Bring across only needed, reviewed changes.
4. Confirm TEST Worker uses TEST Supabase and Stripe test mode.
5. Deploy to TEST only.
6. Test owner login, tenant/subscriber controls, catalogue search, valuation, buying, inventory/sales, domain settings and dashboard settings as applicable.
7. Record deployed SHA and checkpoint.

### Phase C — Repair PageFlow TEST
1. Resolve the `pageflow` vs `businessflow-test` Wrangler Worker-name mismatch.
2. Confirm branch-to-Worker mapping.
3. Verify TEST service/data bindings and authentication.
4. Test editor loading, text/image editing, draft save, preview and publishing protections.
5. Record deployed SHA and checkpoint.

### Phase D — Central owner dashboard
1. Integrate in TradeFlow TEST first.
2. Preserve existing TradeFlow owner features.
3. Add PageFlow settings through a secure, narrowly scoped integration.
4. Show StudioFlow as unavailable/not-ready until its services exist.
5. Test permissions, navigation, settings persistence and cross-product data isolation.
6. Promote verified dashboard to LIVE as a separate release.

### Phase E — Independent product releases
For each future change: commit to that product's development branch; review diff/tests; deploy that product to TEST; run acceptance checks; promote only verified changes to LIVE; verify production URL/critical journeys; record release and rollback details.

## 9. Acceptance checklist

### Deployment
- [ ] Repository and branch for each Worker documented.
- [ ] Active deployed commit SHA known.
- [ ] TEST changes deploy without requiring an unrelated product release.
- [ ] Failed builds do not alter active LIVE traffic.
- [ ] Rollback target known.

### Data and security
- [ ] TEST/LIVE Supabase bindings correct.
- [ ] TEST/LIVE Stripe modes correct.
- [ ] No customer, subscriber, domain-owner or auth records copied between environments.
- [ ] No service-role or secret keys exposed to browser.
- [ ] Owner permissions enforced server-side.
- [ ] PageFlow and StudioFlow data isolated from TradeFlow tenant data.

### Lauren Digital owner dashboard
- [ ] Owner login works and rejects non-owner users.
- [ ] Existing TradeFlow owner features still work.
- [ ] Product cards/visibility save correctly.
- [ ] PageFlow settings are served/saved through PageFlow's authorised service.
- [ ] StudioFlow is marked not ready until implemented.
- [ ] Product links and manuals point to the correct environment.

### Product journeys
- [ ] TradeFlow buying/valuation and inventory/sales journeys pass.
- [ ] PageFlow editor, draft save, images, preview and publishing controls pass.
- [ ] StudioFlow critical journeys pass before being marked ready.

## 10. Rollback procedure

If a release fails:
1. Stop further deployments and announce the affected Worker.
2. Do not make unrelated database changes to compensate for a code problem.
3. Restore the previous known-good Worker deployment or redeploy its recorded commit through the established process.
4. Confirm custom domains/routes and traffic remain correct.
5. Run a smoke test against the rollback.
6. Record failing SHA, error, rollback SHA and follow-up issue.
7. Do not promote the same change to LIVE until failure is understood and retested.

## 11. Audit observations (27 October 2026)

Observations from screenshots and source files; they do not prove every live user journey has been tested:
- Cloudflare showed separate `tradeflow`, `tradeflow-test`, `pageflow` and `businessflow-test` Workers.
- `tradeflow` LIVE had recent successful builds from `main`.
- `tradeflow-test` showed an older active deployment associated with `test/stripe-connect-test-mode-repair-20261020`, with no recent builds in the displayed window.
- TradeFlow owner dashboard HTML on `main` was older TradeFlow-branded UI; `production` had Lauren Digital branding; the central dashboard feature branch had route/build fixes.
- TradeFlow branch histories were substantially diverged, so wholesale merging is unsafe.
- BusinessFlow's `pageflow/deployment-config` Wrangler file declared `name: "businessflow-test"`, while Cloudflare showed a separate `pageflow` Worker. Verify and correct the mapping deliberately.
- Cloudflare showed recent activity for `pageflow` and `businessflow-test`, but this does not establish that both websites' full journeys pass.
- Catalogue agents are independently reconciling Pokémon and PlayStation data. Keep that work scoped to catalogue records/evidence while deployment files are stabilised.

## 12. Decisions to confirm during implementation

- [ ] Confirm intended TradeFlow TEST branch and configure its release pipeline accordingly.
- [ ] Confirm PageFlow LIVE branch and PageFlow TEST branch.
- [ ] Confirm whether `pageflow` is public LIVE and `businessflow-test` is TEST, and document intended domains.
- [ ] Confirm PageFlow TEST/LIVE Supabase bindings; do not assume the known project ID's role.
- [ ] Confirm first dashboard scope: product cards, TradeFlow controls, PageFlow settings, StudioFlow placeholder.
- [ ] Record final branch names, deployment SHAs and checkpoints after verification.

## Change log

- **2026-10-27:** Initial architecture and release policy created from Cloudflare screenshots, GitHub branch/config inspection and known project boundaries. No Worker routes, deployment settings, Supabase records or Stripe settings were changed to create this document.


## 12. Follow-up source inspection (27 October 2026)

- TradeFlow TEST's `wrangler.jsonc` names the Worker `tradeflow-test` and sets `TRADEFLOW_ENV: "test"`. Its configured TEST Supabase URL/key point to project `nnsshnfkjcflucjrftzi`; the LIVE variables are also present for the Worker-side transformation mechanism.
- TradeFlow LIVE's `main/wrangler.jsonc` names the Worker `tradeflow` and sets `TRADEFLOW_ENV: "production"`. Both environment configurations must remain paired with the correct Worker and branch.
- TradeFlow TEST and `production` currently have identical dashboard HTML, CSS and JavaScript blob SHAs in the inspected files. The dashboard JavaScript source itself contains LIVE Supabase constants. The TEST Worker source includes JavaScript asset rewriting based on `TRADEFLOW_ENV`, intended to replace the embedded LIVE URL/key with TEST values when serving JavaScript assets. This is safety-critical and must be verified in the deployed TEST response and browser network requests before using owner controls in TEST.
- The inspected TradeFlow TEST Worker source has route handling and subscriber-domain behaviour that are not identical to `main`. Do not replace the TEST Worker entry point with `main` wholesale; preserve and review TEST-specific behaviour first.
- The BusinessFlow repository contains two Wrangler configurations: `wrangler.jsonc` names `businessflow-test`, while `wrangler.pageflow.jsonc` names `pageflow`. This appears to be the intended separation. Cloudflare build configuration must explicitly select the correct config for each Worker.
- The BusinessFlow `pageflow/deployment-config` worker entry point currently connects to Supabase project `ktvvtdrdwlazfsgkfedo`. Its TEST/LIVE role must be confirmed before using this source for both environments.

### Immediate verification sequence

1. In Cloudflare, open the `tradeflow-test` Worker and confirm its active deployment is built from `test/stripe-connect-test-mode-repair-20261020` and uses `worker/index.js`.
2. Visit the TEST dashboard URL and inspect browser Network requests. Dashboard requests must go to `nnsshnfkjcflucjrftzi.supabase.co`, not `gxsrajtqzdjvmceqcpgv.supabase.co`. Do not submit administrative forms until this passes.
3. Confirm the active TEST Worker has `TRADEFLOW_ENV=test` and the TEST Supabase URL/key variables. Do not expose or share secret values.
4. For PageFlow, verify Cloudflare selects `wrangler.pageflow.jsonc` for the `pageflow` Worker and `wrangler.jsonc` for `businessflow-test`. Confirm actual database bindings before testing writes.
5. Only after these checks pass should a narrow TEST release branch be prepared. Review changed files and preserve TEST-specific routes and environment boundaries; no wholesale branch merge.

No Cloudflare routes, deployment settings, Supabase data, or Stripe settings were changed during this follow-up inspection.
