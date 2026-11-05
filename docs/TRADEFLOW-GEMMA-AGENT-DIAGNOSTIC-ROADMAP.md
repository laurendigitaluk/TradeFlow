# TradeFlow Gemma Local Research Agent — Developer Diagnostic Roadmap

**Version:** 0.1  
**Date:** 5 November 2026  
**Status:** Foundation in feature branch; not yet installed or verified on the Research PC.

## Purpose and boundaries

Map the local TradeFlow-first Gemma workflow. This is not a copy of the code and is not the subscriber-facing AI assistant. Do not reuse the retired GearCashOut agent, its scripts, configuration or database endpoints.

## User action and entry point

1. Operator creates or edits a research task JSON file.
2. Operator runs `npm start -- tasks/example.json` from `tools/tradeflow-gemma-agent/`.
3. `src/index.mjs` reads local `.env`, loads the task file and starts a bounded worker pool.
4. Default mode is dry-run. Operator must explicitly add `--apply` after reviewing the candidate output.

Research PC installation, a Windows service/Power-shell launcher and owner-facing control panel are **not yet implemented**. Do not invent their paths or claim they are running.

## Current code map

| Responsibility | Current path | Behaviour |
|---|---|---|
| CLI/coordinator | `tools/tradeflow-gemma-agent/src/index.mjs` | Loads environment/task JSON; bounds worker concurrency; reports failed-closed tasks |
| Research, extraction, validation and DB adapter | `tools/tradeflow-gemma-agent/src/agent.mjs` | Brave Search → direct page fetch → Ollama/Gemma JSON extraction → deterministic checks → independent TEST/LIVE product lookup → duplicate-safe evidence write |
| Runtime/dependencies | `tools/tradeflow-gemma-agent/package.json` | Node.js 22+; no npm runtime dependencies |
| Local configuration template | `tools/tradeflow-gemma-agent/.env.example` | Ollama, Brave Search and separate Supabase TEST/LIVE keys; real `.env` is gitignored |
| Example task | `tools/tradeflow-gemma-agent/tasks/example.json` | Existing Creality K1 master, UK-new and UK-used research roles |
| Tests | `tools/tradeflow-gemma-agent/test/agent.test.mjs` | Deterministic source-key and evidence rejection checks |

## Data flow

`Task JSON → Coordinator → Brave Search API → direct UK source page → Ollama gemma3:4b → structured evidence candidate → deterministic validation → exact master-product resolution in TEST and LIVE → duplicate preflight → shared_market_evidence insert`.

The source page is untrusted data. Instructions embedded in source content must never be followed. Gemma is an extractor, not an authority for inventing missing prices, condition, location, product identity or URLs.

## Verified backend contract — 5 November 2026

The following objects and columns were inspected in both TradeFlow projects:

- `catalogue_master_categories`: `id`, `name`, `slug`, `active`.
- `catalogue_master_branches`: `id`, `category_id`, `name`, `slug`, `active`.
- `catalogue_master_manufacturers`: `id`, `name`, `active`.
- `catalogue_master_products`: `id`, `category_id`, `branch_id`, `manufacturer_id`, `model`, `package_key`, `package_name`, `active`, `customer_visible`.
- `shared_market_evidence`: `master_product_id`, `evidence_type`, `source_name`, `source_url`, `observed_price`, `price_currency`, `item_condition`, `sales_channel`, `availability`, `observed_at`, `notes`, `is_active`, `source_record_key`.

Important constraints:

- Product uniqueness: `(category_id, branch_id, manufacturer_id, model, package_key)`.
- Evidence type check currently permits `uk_new`, `uk_used`, `overseas`; Gemma foundation deliberately permits only `uk_new` and `uk_used`.
- Evidence uniqueness: `(source_name, source_record_key)`.
- `shared_market_evidence.master_product_id` references `catalogue_master_products.id`.
- Direct client writes to shared catalogue products are denied by RLS; authenticated evidence policy is read-only for active rows. The local service-role credential is therefore restricted to the Research PC and must never be committed or used in browser code.

## Environment boundaries

- TEST Supabase: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- The code checks both project hostnames and resolves category, branch, manufacturer and exact product independently in each database. UUIDs must never be copied between environments.
- TEST and LIVE must both resolve the exact product before either environment is written.
- A missing or ambiguous product causes a fail-closed task. Foundation 0.1 does not create catalogue masters.
- No Edge Function, Worker, schema migration or RLS change is required for this local evidence-only stage.

## Separate research stores

- `shared_market_evidence` is the shared master-catalogue evidence store used by this local agent.
- `tenant_buying_research` is tenant-scoped Research Centre data. It is not the master catalogue evidence target and must retain its tenant/RLS boundary.
- `platform_ai_settings.gemma_enabled` controls the platform/subscriber AI provider configuration, not local Ollama Gemma. It was false in both projects at the time of inspection and was not changed.

## Guardrails and failure points

1. **No search key:** stop; never invent source URLs.
2. **Non-UK or redirected source:** reject.
3. **Search/category URL:** reject; require direct product/listing page.
4. **Price not visible as GBP on the page:** reject.
5. **Wrong evidence type/condition:** reject. Opened-never-used and sealed are not used evidence.
6. **Manufacturer/model tokens absent from page:** reject.
7. **Category/branch/manufacturer/product missing or ambiguous in either DB:** fail closed; no write.
8. **Duplicate source key:** skip existing row.
9. **One side insert fails after the other succeeds:** retry is idempotent through duplicate preflight; inspect both DBs before manual repair.
10. **UK-used evidence:** reference-only; do not connect it to automatic valuation.

## Known fix history and exclusions

- Old GearCashOut/Action Buyer code is not a source of truth and is not imported.
- Do not toggle `platform_ai_settings` to make local Gemma run.
- Do not create an Edge Function or Cloudflare Worker for this local workload.
- Do not create product masters in 0.1; that is a later, separately verified increment.
- No database or application-code deployment has been performed.

## Next safe actions

1. Install the feature-branch folder on the Research PC and confirm Node/Ollama model availability.
2. Configure local `.env` with a search key and separate TEST/LIVE service-role credentials; do not send credentials in chat.
3. Run tests on the Research PC.
4. Run the example task in dry-run mode and inspect every source/candidate.
5. Test duplicate handling and mirrored write behaviour on one preselected exact product before enabling larger batches.
6. Build the next increment for safe manufacturer/product creation and package-variant reconciliation.
7. Only after successful Research PC tests, merge feature branch to `main` and follow the existing TEST → verified release → `production` → LIVE process.
