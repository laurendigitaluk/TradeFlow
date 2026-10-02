# TradeFlow checkpoint — 2 October 2026

## Subscriber Assistant provider-neutral completion

TEST branch: `cloudflare-test`
TEST Supabase: `twfbmjwwqzxdxvclxbun`

### Completed
- Added `platform_ai_settings` with owner-controlled active provider and allowed-provider flags.
- Added owner-only RPCs `platform_owner_get_ai_settings` and `platform_owner_update_ai_settings`.
- Added AI provider controls to the Platform Owner Dashboard.
- Supported provider options remain: None, Gemma, OpenAI, Anthropic, Google, Subscriber.
- Default remains None / knowledge-only.
- Updated the Subscriber Assistant response handling so knowledge-only responses are displayed cleanly and provider availability is reported.
- Deployed `tradeflow-assistant` Edge Function version 12 with the provider-neutral architecture intact.

### Deliberate non-decisions
- No Gemma PC/server connection has been made.
- No OpenAI/Anthropic/Google API credentials have been added.
- No subscriber AI credential storage has been introduced yet.
- No provider is forced on the production architecture.
- Product Research approval rules remain unchanged.

### Next step
Browser-test the Owner Dashboard AI settings and Subscriber Assistant in TEST. If that passes, checkpoint the release and continue the planned TEST → LIVE promotion. Do not reopen old Camera Shack TEST URL work unless a genuine LIVE architecture dependency is found.

## Release safety
Do not modify LIVE directly. Any defect is repaired in TEST, verified, documented and then promoted deliberately.


### Security verification
The AI settings RPCs are owner-checked and anonymous EXECUTE access has been revoked. The Edge Function reads the platform AI setting through the owner-controlled configuration path; the legacy `TRADEFLOW_AI_CONFIG` environment reader is no longer used.
