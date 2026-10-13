# TradeFlow

TradeFlow is a multi-tenant buying, valuation, purchasing, inventory, selling, retail-order, fulfilment and returns platform.

## Current project operating authority

Read the **Authoritative Environment Decision — 13 October 2026** at the top of `docs/TRADEFLOW-AI-OPERATING-MANUAL.md` before performing development, testing, deployment, or environment changes.

The former TEST-first release plan is retired. The agreed sequence is to verify and repair the environment that was being built as LIVE, preserve the validated environment as the new TEST copy, then create a separate LIVE environment from the validated baseline.

## Manuals

- AI continuity and operating rules: `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- System and architecture: `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- Internal backend / Platform Owner: `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- Human user guide: `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- Subscriber website guide: `subscriber-website-manual.html`

## Safety

A branch commit is not proof of deployment. Verify the deployed Worker, served assets, runtime configuration and Supabase project independently. Do not use the temporary Customer Test Lab instructions from older repository history as the current operating procedure. Do not change LIVE accounts or data while diagnosing authentication without explicit approval.
