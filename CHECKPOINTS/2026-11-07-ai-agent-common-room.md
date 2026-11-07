# Checkpoint — AI Agent Common Room — 7 November 2026

## Branch
`feature/ai-agent-common-room-20261107`, based on current `production`.

## User intent
Provide a shared persistent workspace for Platform Owner, ChatGPT supervisory work and Gemma specialist research agents to exchange instructions, handovers, findings, questions, learning notes and status messages. Owner must be able to inspect the same conversation/history and post instructions.

## Implemented in this branch
- Added `public.platform_ai_agent_messages` migration with RLS enabled and direct anon/authenticated table grants revoked.
- Added owner-authenticated list/post RPCs protected by active `platform_memberships`.
- Added service-role-only agent list/post RPCs. Agents cannot post the `instruction` type; instructions are owner-authored.
- Added Owner Dashboard Common Room section with thread/category/recipient filters, message history and owner compose.
- Added Research PC worker integration: startup status, task status, handover, completion/failure posts and shared message/instruction reads.
- Updated System, Human, Backend User, AI Operating and Subscriber manuals; Backend Operations Manual; Gemma research diagnostic roadmap.
- Added documentation that How It Works is source-managed rather than edited via the dashboard CMS. Examples remains dashboard-editable.
- Updated Owner Dashboard manual links and Common Room navigation.

## LIVE migration
Migration `20261107190000_platform_ai_agent_common_room.sql` applied successfully to LIVE project `gxsrajtqzdjvmceqcpgv`.

Read-only checks:
- messages table exists.
- RLS enabled and no direct anon/authenticated policies.
- anonymous cannot execute owner or agent RPCs.
- authenticated can execute owner list RPC, which validates active platform membership.
- authenticated cannot execute agent RPCs.
- service_role can execute agent list/post RPCs.
- No message rows were seeded; no TEST business data copied.

## Safety boundaries
- Common Room messages are not research queue tasks, product evidence, evidence approvals, imports, valuation inputs or subscriber/customer messages.
- Research findings remain staged for owner/ChatGPT validation; no automatic catalogue/evidence write is introduced.
- Service-role key is used only by the Research PC/server process and must never be exposed to dashboard/browser code.
- Preserve the Research PC's dedicated `.env` and original `TRADEFLOW_GEMMA_ENV_FILE` path during its update.
- TEST Supabase is `nnsshnfkjcflucjrftzi`; LIVE is `gxsrajtqzdjvmceqcpgv`. Retired TEST project `twfbmjwwqzxdxvclxbun` is forbidden.

## Not yet completed / release gates
- PR not yet merged/released.
- Cloudflare production dashboard asset deployment not yet verified.
- Research PC has not been updated or restarted with the new worker code.
- Owner instruction → worker read → worker handover → owner-visible message round-trip not yet tested.
- No desktop/mobile authenticated browser acceptance.
- Do not describe Common Room as fully operational until the round-trip passes.

## Next actions
1. Review and merge the feature PR.
2. Confirm Cloudflare LIVE worker serves current dashboard HTML/CSS/JS.
3. Update Research PC code only, preserving local environment configuration.
4. Restart the persistent worker; confirm fresh LIVE telemetry.
5. Post a limited owner instruction and verify worker read and handover post.
6. Confirm owner dashboard can read the returned message.
7. Run one small research batch and confirm existing candidate review gate is unchanged.
