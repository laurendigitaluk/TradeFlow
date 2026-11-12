# Checkpoint — ChatGPT research updates in TradeFlow LIVE

**Date:** 12 November 2026  
**Environment:** LIVE only  
**Repository:** `laurendigitaluk/TradeFlow`  
**Branch:** `production`

## Change

Added a ChatGPT research status panel to the existing Owner Dashboard AI Research Centre. The panel reads the existing `tradeflow-research` thread using the existing owner-authenticated `platform_owner_list_ai_agent_messages` RPC and filters for ChatGPT supervisor messages. It loads at owner sign-in, supports manual refresh, and refreshes every 30 seconds while an owner session is active.

## Existing data path reused

- Table: `public.platform_ai_agent_messages`
- Read RPC: `public.platform_owner_list_ai_agent_messages`
- Thread: `tradeflow-research`
- ChatGPT sender identity: `sender_kind=chatgpt_supervisor`, `sender_key=chatgpt`, `sender_name=ChatGPT`
- Recipient: `platform_owner`
- Message type: `status_update`

No new table, queue, importer, API key, provider or Edge Function was created. The existing manual AI research intake and catalogue evidence review/import process is unchanged. Dashboard messages are status communications only; they do not themselves import evidence.

## Files committed to production

- `platform-owner-dashboard.html` — added ChatGPT research updates panel; cache version bumped to 59.
- `platform-owner-dashboard.js` — loads messages through the existing RPC and refreshes every 30 seconds.
- `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-MANUAL-AI-RESEARCH.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

## LIVE verification

Inserted and read back the initial status notice:
- Message ID: `f273893d-a387-443f-8a95-1a93e90caca0`
- Title: ChatGPT research updates are now available
- Thread: `tradeflow-research`
- Sender: `chatgpt_supervisor / chatgpt`
- Created: `2026-11-12 12:51:17 UTC`

GitHub production read-back confirmed the panel, RPC call, refresh control, 30-second refresh and cache-busted script reference are present.

## Boundaries and next steps

- TEST was not modified.
- No tenant, customer, Stripe, subscription or published subscriber-site data was changed.
- Do not mark research batches complete until the corresponding LIVE evidence rows have been read back and reconciled.
- Future ChatGPT progress/completion messages must state batch scope, verified LIVE imports, comparison-only references retained and unresolved findings.
- Continue using the existing manual research intake/review and authorised evidence-import path. This notification panel is not a replacement for that workflow.
- Browser-level production rendering has not yet been independently confirmed in this checkpoint; confirm the live owner dashboard displays the panel after deployment/cache refresh.
