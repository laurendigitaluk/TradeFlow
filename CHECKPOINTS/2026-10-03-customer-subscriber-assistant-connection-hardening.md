# Checkpoint — 2026-10-03 — Customer–Subscriber Assistant Connection Hardening

## Purpose
Complete the dashboard-based customer-to-subscriber Assistant handoff without making email a dependency.

## LIVE verified backend state
- LIVE Supabase: gxsrajtqzdjvmceqcpgv.
- assistant_conversations and assistant_messages exist.
- LIVE contains no customer assistant conversations or messages at this checkpoint.
- Messaging remains tenant-isolated through security-definer RPCs.
- Migration applied by Supabase as 20261003004315_assistant_connection_hardening.

## Changes
- Customer Assistant conversation read now returns an empty result when no open conversation exists; opening the page no longer creates an empty subscriber-visible conversation.
- Customer message send remains the operation that creates the open conversation.
- Subscriber Customer Questions queue now shows only open conversations containing at least one message.
- Customer Assistant polls the conversation every 15 seconds so subscriber replies appear without a page reload.
- Email is not required for this customer/subscriber messaging path.
- Provider-neutral AI gateway remains unchanged and optional.

## Production code
- Customer frontend commit: 551559d8a1b7f74384cf4ac8d847852f4ebe9448.
- Assistant hardening migration committed as supabase/migrations/20261003004315_assistant_connection_hardening.sql.

## Remaining verification
Browser E2E still needs to be performed on LIVE:
1. Customer signs in.
2. Customer opens Assistant; no empty Customer Question should appear for subscriber.
3. Customer asks a question with no approved knowledge answer.
4. Customer sends it to the business.
5. Subscriber opens TradeFlow Assistant → Customer Questions and sees the conversation.
6. Subscriber replies.
7. Customer sees the reply without reloading, within the polling interval.
8. Subscriber closes the conversation and it leaves the active Customer Questions queue.

Do not claim browser E2E passed until these steps are actually observed.
