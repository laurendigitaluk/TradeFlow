# TradeFlow — Retired Test/Production Runbook

> **RETIRED 13 OCTOBER 2026 — DO NOT FOLLOW AS AN ACTIVE RELEASE PLAN**

This runbook described the previous TEST-first workflow and is no longer authoritative. It is replaced by the **Authoritative Environment Decision** at the top of:
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`

The user's current decision is to finish and verify the environment that was being built as LIVE, preserve that validated environment as the new TEST copy, and create a separate LIVE environment from the validated baseline. Do not assume old TEST-first branch/project mappings are still the operating plan. First establish the actual deployed Worker, served assets, GitHub branch state and Supabase project identity independently.

The old runbook text is retained in Git history for audit purposes, not as instructions. No runtime code, accounts, database records, DNS or Cloudflare settings are changed by this documentation retirement.
