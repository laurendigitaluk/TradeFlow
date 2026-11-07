# TradeFlow Gemma Research Pipeline — Diagnostic Roadmap

Updated: 7 November 2026

## Operating boundary
- LIVE project gxsrajtqzdjvmceqcpgv is the only authoritative research task and evidence-review queue.
- TEST project nnsshnfkjcflucjrftzi remains for software development, migrations and regression fixtures. Existing TEST data remains untouched.
- Gemma discovers candidate UK market evidence. Owner/ChatGPT verifies; no autonomous approval or master catalogue/evidence write is permitted.

## Dashboard entry points
- Platform Owner dashboard: platform-owner-dashboard.html.
- Category research team cards: platform-owner-dashboard.js → renderGemmaResearcherCards.
- Category source manager: loadGemmaSources / addGemmaResearchSource.
- Owner source RPCs: platform_owner_list_research_sources(text), platform_owner_add_research_source(text,text,text,text,text,text), platform_owner_set_research_source_category(uuid,text,boolean).
- How It Works / Examples editor: platform-public-pages-editor.js → node/render/save.
- Platform AI provider settings: platform-owner-dashboard.html / platform-owner-dashboard.js → platform_owner_get_ai_settings and platform_owner_update_ai_settings.

## Category and source model
- Canonical LIVE 3D category is 3d-printers-equipment / “3D Printers & Equipment”.
- Two existing telemetry agent keys (3d-printers, 3d-printers-equipment) are grouped into one UI team card. Both records and their history are preserved.
- Pokémon master category already exists as pokemon-trading-cards. It is displayed as a reserved category but has no source assignment or research agent linkage.
- Category sources live in platform_research_sources.category_slugs. * means universal; current Amazon UK and eBay UK remain universal.
- Owner source RPCs validate active platform membership and active category. Universal sources are read-only from category-specific toggles.
- Research worker continues to filter enabled sources by category slug and manufacturer; no matching approved sources means fail closed.

## How It Works editor
- Nested objects and arrays in public-page draft JSON are rendered as collapsed details sections, expanded individually by the owner.
- Save/publish RPCs and existing draft/published workflow remain unchanged.

## AI provider boundary
- Subscribers cannot supply their own AI provider.
- Owner dashboard no longer exposes a subscriber-provider option. Its save call always sends p_subscriber_provider_enabled=false.
- LIVE update RPC already rejects subscriber-supplied providers and persists false.

## Verification and known limitations
- LIVE category/source table and telemetry inspected before change.
- LIVE owner source RPC migration applied; verify RPC signatures and category source data after deployment.
- The browser owner dashboard must be refreshed after the Cloudflare static asset deployment.
- Pokémon has no category-specific sources and is not to be dispatched.
- LIVE laptops agent status exists but its master category was previously missing; don't attach laptop sources until master category reconciliation.
- Full browser acceptance for adding/toggling a source, collapsible editor interactions and public publish workflow remains required.
