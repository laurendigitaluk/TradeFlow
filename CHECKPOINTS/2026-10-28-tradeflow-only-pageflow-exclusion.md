# TradeFlow-only scope and PageFlow exclusion — 28 October 2026

## Binding product boundary
TradeFlow is the only product in this repository's website and customer-facing runtime. PageFlow (previously BusinessFlow) has been removed completely from the TradeFlow site. Do not restore it, re-integrate it, or route its data into TradeFlow.

The user confirmed on 27 October 2026:
- Remove PageFlow/BusinessFlow entirely from this system and restore the last working TradeFlow-only state.
- Keep TradeFlow LIVE and TEST closely aligned while pre-release, with environment-specific data isolated.
- PageFlow/BusinessFlow may remain in its own GitHub/Supabase history/resources, but it must not appear in the TradeFlow UI, navigation, public website, subscriber dashboard, customer portal, deployment bundle, runtime configuration, or TradeFlow database flows.
- Any future separate product must use its own repository, Worker/deployment and database, linked from TradeFlow only by a plain hyperlink if explicitly requested. Do not share tenants, customer records, domains, ownership, Stripe configuration, or product-specific tables.

## Required checks before accepting any branch or deployment
1. Scan all deployed TradeFlow HTML, JS, CSS, Worker code, configuration, navigation and public-page links for PageFlow/BusinessFlow routes, imports, script references, API endpoints, branding, tenant identifiers and cross-product data reads/writes.
2. Confirm Test and Live Worker deployments serve TradeFlow-only assets. Never infer deployment from a Git commit alone.
3. Inspect TEST and LIVE Supabase schemas, Edge Functions, triggers, views, RPCs, grants and environment variables for cross-product coupling. Report legacy PageFlow/BusinessFlow objects, but do not drop tables, delete records, or remove project resources without a separately scoped migration and backup plan.
4. Keep legacy PageFlow/BusinessFlow code/data that is still present in GitHub/Supabase inert and disconnected from the TradeFlow runtime. Do not copy it into the TradeFlow release branch or deployment package.
5. Confirm the Test Worker uses only TEST Supabase for all customer/subscriber operations; LIVE Worker uses LIVE Supabase. Never test with LIVE customer data or write test records to LIVE.
6. Continue the one-branch workflow: `cloudflare-test` is the intended Test branch. Verify Cloudflare's actual Git integration/deployed commit before assuming it is current. Promote only accepted TradeFlow-only changes to the confirmed LIVE deployment source.

## Current known environment identifiers
- Test Worker: `tradeflow-test.leannelaurenlowe.workers.dev`.
- Live Worker: `tradeflow.leannelaurenlowe.workers.dev`.
- Current Test Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- Legacy Test project references may still exist in historical/local code: `twfbmjwwqzxdxvclxbun`. Do not let these fallbacks route current Test or LIVE traffic to the wrong project.

## Deployment status at checkpoint
- Recent commits to `cloudflare-test` align Worker asset-routing configuration and harden the Test customers page's fallback Supabase URL.
- Cloudflare deployment source and deployed commit are not yet verified in this workflow.
- Multi-item customer valuation still requires real-browser end-to-end acceptance in TEST.
- No PageFlow/BusinessFlow data should be migrated into TradeFlow. Legacy product data may remain in its separate resources, but must be disconnected from TradeFlow.
