# TradeFlow Multi-Agent Shared Memory and Coordination
Last updated: 2026-10-22
Repository: https://github.com/laurendigitaluk/TradeFlow
Branch: coordination/shared-ai-memory-20261022

## Purpose
This is the shared handover point for ChatGPT agents working on TradeFlow at the same time. Read this file before making changes and update it after meaningful progress. It is a repository-backed coordination note, not a live messaging channel: agents cannot directly message each other through this file. The user can pass the link or copy the latest section between chats.

## Environment rules
- LIVE / production is the user's working environment. TEST is reference-only unless the user explicitly changes that instruction.
- Do not assume TEST and LIVE use separate Supabase projects; previous project notes say they may share a database. Verify the target before any write.
- Do not make database schema/data changes without first inspecting current schema, RLS, existing data, and recent commits.
- Never commit secrets, API keys, credentials, customer personal data, or tokens to this file.
- Do not import any historical GearCashOut research/evidence unless each record has been validated and explicitly approved.
- Preserve existing tenant data and other agent's work. Make narrow, isolated changes; avoid simultaneous edits to the same files/tables.
- Before any deployment, test the changes, review the diff, document the result, and obtain the user's direction if production impact is material.

## Active workstreams (2026-10-22)

### Agent A — pricing and evidence workflow (this chat)
Goal: simplify TradeFlow subscriber pricing and evidence capture while enforcing the existing valuation policy.
- Verified UK new-price evidence in GBP may drive automatic offers, using the subscriber's configured condition percentage.
- UK used-price evidence is reference-only, including AI-generated used evidence; it must never affect automatic offers.
- Overseas prices are excluded from subscriber pricing.
- Subscriber-owned evidence remains private and tenant-scoped.
- “Use shared TradeFlow evidence — Yes/No” should govern use of shared platform evidence without preventing the subscriber from adding private evidence.
- Preserve manual offers and condition-specific overrides.
- Current findings: Research Centre copy conflicts with valuation logic. It currently implies UK Used evidence feeds some condition prices, while the valuation function was reported to calculate from UK New evidence for all automatic conditions. Business Settings has no shared-evidence preference. The actual pricing pages, schema, RPCs, and shared-vs-private evidence sources still need verification.
- No code changes, database writes, evidence imports, or deployments have been made by this agent for this workstream yet.
- Immediate next steps: inspect pricing/catalogue/valuation code and relevant schema/RLS read-only; then propose minimal coordinated changes and test before merge/deploy.

### Agent B — product database update (other ChatGPT agent)
- User reports this agent is currently updating the product database.
- Exact files, tables, intended data changes, and current progress are not yet known to Agent A.
- Agent B: please add a short update below stating your target environment/project, tables/files being changed, goal, whether writes have started, last verified checkpoint/commit, and any locks or conflicts. Do not include credentials or customer personal data.
- Until Agent B's scope is recorded, Agent A will avoid product catalogue/master-product database writes and avoid editing product-database ingestion/migration code. Agent A may perform read-only inspection where necessary.

## Shared change log
### 2026-10-22 — Agent A
- Created this coordination checkpoint on isolated branch `coordination/shared-ai-memory-20261022`, based on `main`.
- This is not merged into the default or production branch and has not been deployed.
- Known boundary: Agent A is working on subscriber pricing/evidence workflow; Agent B is working on product database updates. Keep database writes and overlapping files paused until scopes are documented.

## Update template (copy for each agent)
```md
### YYYY-MM-DD — Agent [A/B]
- Workstream:
- Target branch / Supabase project ID (ID only; no keys):
- Files/tables/functions affected:
- Changes made:
- Tests / verification:
- Commit / checkpoint:
- Open risks or conflicts:
- Next action:
```

## Handoff protocol
1. Each agent reads this file and the latest repository commits before working.
2. Each agent records intended files/tables and planned writes before making material changes.
3. If work overlaps, stop and coordinate through the user before editing.
4. After changes, record commit/checkpoint, test results, and whether anything was deployed.
5. Never describe a change as live/deployed unless deployment and live verification were actually confirmed.
