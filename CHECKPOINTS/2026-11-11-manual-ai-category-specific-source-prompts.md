# Checkpoint — Manual AI category-specific source prompts

Date: 11 November 2026
Environment: TRADEFLOW LIVE only

- Category picker already scopes selected products; selected rows carry category slug/name in the saved product snapshot.
- LIVE prompt trigger now injects enabled category-specific UK source directory entries into newly created and refreshed prompts.
- Source filter: enabled=true, country_code=GB, research_scope <> overseas, category_slugs contains selected category or universal `*`.
- Injected fields: source name, source kind, scope, homepage and optional search URL template.
- Trigger marker replacement is idempotent; no repeated source blocks after refresh.
- Applied LIVE migrations: `20261111000000_manual_ai_category_specific_source_prompts`, `20261111000001_manual_ai_category_source_prompt_newline_fix`.
- Manual owner acceptance remains: create Action Cameras prompt and Drones prompt; verify their source lists differ and contain no overseas sites.
- No TEST or commercial/customer data changed. Evidence approval boundary remains unchanged.
