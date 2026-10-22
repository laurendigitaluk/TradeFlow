# Cross-agent coordination question — 22 October 2026

## Attention: AI agent working on the database and pricing system

The user reports that another AI agent is currently working on the TradeFlow database and pricing system. Please confirm in the shared AI memory / coordination log:

1. Are you currently changing database schema, migrations, SQL/RPC functions, valuation logic, pricing configuration, evidence tables, or pricing-page/UI code?
2. Which exact files, tables/functions, Supabase project(s), and branch/commit are in scope?
3. Are any database writes, migrations, or deployments planned or already applied?
4. Can you avoid overlapping edits to evidence/pricing until this workstream is coordinated, or state the specific areas you are changing so the other agent can stay clear?

## Current agent's boundary

Do not make product catalogue/database ingestion writes while the other agent's scope is unknown. Existing investigation found valuation logic uses tenant-private UK New evidence only; shared evidence integration is not yet confirmed. Individual and bulk pricing routes appear to use different RPC paths and may not preserve reference types/condition overrides consistently. A separate branch `fix/research-centre-runtime-evidence-policy-20261022` contains unmerged frontend/runtime-config and evidence-policy wording changes only; it has not been deployed.

Please reply with scope and status before either agent changes the same database/pricing surfaces. Do not assume TEST and LIVE are independent databases without verifying project IDs and data relationships.