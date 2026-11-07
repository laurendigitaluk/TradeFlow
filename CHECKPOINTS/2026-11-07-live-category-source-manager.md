# Checkpoint — Category source manager and owner dashboard usability

Date: 7 November 2026
Target: production / LIVE

## User decisions
- Category cards should open a per-category website list; owner can add websites and enable/disable category assignments.
- eBay UK and Amazon UK remain universal.
- Merge 3D printer agent cards into one category view.
- Pokémon category should exist but remain unlinked from Gemma research.
- Remove subscriber-owned AI provider option.
- Make How It Works editor content collapsible.

## Findings
- LIVE master category 3d-printers-equipment already exists; there is not a duplicate master category.
- Duplicate-looking 3D cards came from two telemetry records: 3d-printers and 3d-printers-equipment.
- LIVE pokemon-trading-cards master category already exists. No source registry rows are scoped to it.
- LIVE source registry contains universal Amazon UK and eBay UK.
- LIVE AI settings already have subscriber_provider_enabled=false; update RPC rejects enabling it.
- Owner page content editor renders deeply nested JSON as expanded fieldsets; it is now collapsed per group/item.

## Implemented on production
- LIVE owner RPCs for category source listing, adding a source and toggling source/category assignment.
- Dashboard category cards now group 3D agent records and open the category source manager.
- Pokémon is shown as a reserved category with no research agents or sources.
- Owner dashboard no longer offers subscriber-supplied AI option and submits false.
- How It Works public-page editor now uses collapsible nested groups and repeated items.
- Both manuals and diagnostic roadmap updated.

## Safeguards
- Universal * sources cannot be removed through per-category source toggles.
- Source changes require active platform membership.
- Source homepage must be HTTPS; category must exist and be active.
- No TEST catalogue or tenant data changed.
- No Pokémon research agent or source assignment created.

## Acceptance outstanding
- Confirm Cloudflare deployment of latest production static assets.
- In owner dashboard, open 3D Printers & Equipment, verify Amazon/eBay universal and 3D specialist websites listed.
- Add one test source or toggle a non-universal source and verify only the chosen category changes.
- Open How It Works and verify sections collapse/expand and save/publish still works.
- Inspect subscriber dashboard to confirm no subscriber-owned AI provider UI is exposed.
