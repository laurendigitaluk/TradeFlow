# Project memory — LIVE category research controls

As of 7 November 2026, user wants all changes built directly into TradeFlow production, not left on a separate feature branch.

LIVE canonical 3D category is 3d-printers-equipment. The apparent second 3D printer card was a second telemetry agent record (3d-printers), not a second master category. The dashboard now groups those records in one 3D Printers & Equipment card without deleting telemetry history.

Pokémon Trading Cards (pokemon-trading-cards) already exists in LIVE master categories. It is reserved in the AI Research Centre but has no Gemma researcher/source assignment. Do not link it to research until explicitly requested.

Category-specific websites are stored in platform_research_sources.category_slugs. Amazon UK and eBay UK are universal * sources. New owner-authenticated RPCs list sources for a category, add an HTTPS source, and toggle a source's category assignment. Universal sources cannot be removed through category controls. The dashboard exposes this source manager from each category card.

Subscriber-supplied AI is already rejected by LIVE platform_owner_update_ai_settings and LIVE config false. Dashboard option has been removed; frontend save sends p_subscriber_provider_enabled=false.

How It Works editor nested groups and arrays are now collapsed by default. Browser acceptance and Cloudflare static deployment still need confirmation.
