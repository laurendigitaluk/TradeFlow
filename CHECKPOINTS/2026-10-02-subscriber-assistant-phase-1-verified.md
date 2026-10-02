# CHECKPOINT — 2026-10-02 TradeFlow Subscriber Assistant Phase 1

## Environment
- Repository: laurendigitaluk/TradeFlow
- Active Cloudflare TEST branch: cloudflare-test
- TEST Supabase: twfbmjwwqzxdxvclxbun
- LIVE Supabase: gxsrajtqzdjvmceqcpgv
- Cloudflare TEST Worker: tradeflow-test
- LIVE remains untouched.

## Verified milestone
The Subscriber Assistant is now browser-verified through:

Cloudflare TEST Worker → correct TEST runtime detection → subscriber authentication → Camerashack tenant context → tradeflow-assistant Edge Function → tenant membership verification → approved knowledge retrieval → provider=none/read-only response.

## Root cause repaired
The Cloudflare Worker hostname was not recognised as TEST by subscriber-auth.js. The runtime therefore selected the wrong environment configuration, causing the password-token request to use the publishable key and return 401 Invalid API key. The TEST hostname is now explicitly recognised.

Relevant repair commit:
- 6824930cabc16573c5336c06ab053fb1cf5e60c0 — Fix TEST runtime detection on Cloudflare Worker.

Earlier cache-busting commits remain part of the audit history but are not the root-cause fix.

## Knowledge layer
Approved assistant knowledge was expanded to cover:
- subscriber settings
- offers and payment
- customer portal boundaries
- selling workflow
- published subscriber website

Knowledge remains static approved guidance. It does not grant unrestricted SQL/database access.

Knowledge commit:
- 94b59c9ea288e5a7ce0c7d06629679d65568c1d8

## Current provider state
- TRADEFLOW_AI_CONFIG provider: none
- No external AI provider is connected.
- Gary's personal Gemma research system remains completely separate.
- Do not enable a paid provider solely to test the gateway.

## Next stage
1. Browser-test the newly expanded knowledge topics.
2. Implement the controlled Product Research evidence workflow:
   research exact product → present evidence/sources → subscriber approval → save approved evidence to existing tenant_buying_research → allow existing buying calculation to use approved evidence.
3. Do not allow AI to silently change buying prices.
4. After Product Research is proven, build the customer read-only assistant with strict tenant/customer scoping.
5. Only then evaluate a TradeFlow-managed or subscriber-owned AI provider adapter.

## Documentation updated
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- docs/TRADEFLOW-BACKEND-USER-MANUAL.md
- docs/TRADEFLOW-HUMAN-USER-MANUAL.md
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- TRADEFLOW-MASTER-ROADMAP.md

## Safety boundary
Do not modify LIVE, do not connect personal Gemma, do not grant unrestricted database access, do not introduce automatic buying-price changes, and do not revive retired Parcel2Go API shipping architecture.
