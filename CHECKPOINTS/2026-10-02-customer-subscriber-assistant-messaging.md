# Checkpoint — 2026-10-02 — Customer-to-Subscriber Assistant Messaging

## Purpose
Provide a real customer-to-business messaging path inside the existing provider-neutral TradeFlow Assistant architecture.

## Verified implementation
- Supabase TEST project: `twfbmjwwqzxdxvclxbun`.
- Added `assistant_conversations` and `assistant_messages`.
- Added controlled RPCs for customer conversation access/send and subscriber conversation list/read/reply/close.
- Customer access is tied to `customers.auth_user_id = auth.uid()` and the requested tenant.
- Subscriber access is tied to an active `tenant_memberships` row with owner/admin/staff role.
- Direct client access to the two messaging tables is revoked; messaging is performed through security-definer RPCs.
- Customer Assistant now loads its conversation and can send an unanswered question to the business.
- Subscriber TradeFlow Assistant now includes a Customer Questions queue and reply/close controls.
- The existing provider-neutral AI gateway remains unchanged: AI providers are optional and owner-controlled.
- Customer/subscriber message polling refreshes the conversation every 15 seconds while open.

## GitHub TEST branch changes
Branch: `cloudflare-test`
- `customer-assistant.js`
- `customer-assistant.html`
- `assistant.js`
- `assistant.html`

## Important test sequence
1. Sign into a customer account for a TEST subscriber tenant.
2. Open Customer Assistant.
3. Ask a question that has no approved knowledge answer.
4. Click **Send this question to the business**.
5. Sign into the subscriber account for the same tenant.
6. Open **TradeFlow Assistant → Customer Questions**.
7. Open the customer conversation.
8. Reply.
9. Return to the customer account and confirm the reply appears in the Customer Assistant.
10. Close the conversation from the subscriber side and confirm it leaves the open queue.

## Not yet claimed
Browser end-to-end testing has not yet been performed in this chat. This checkpoint records implementation, not a passed live test.
