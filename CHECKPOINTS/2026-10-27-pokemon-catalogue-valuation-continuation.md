# Pokémon TCG Catalogue — Continuation Handover
Date: 2026-10-27

## User's non-negotiable rule
Do not break the existing TradeFlow valuation system. Pokémon cards may need category-specific dropdowns, but must connect to the same established buying, valuation, customer request, inspection and acquisition flow used by other product categories. Do not alter existing valuation formulas/rules or unrelated working categories without proof and a safe test.

## Main objective
Finish the Pokémon Trading Card database and customer-facing workflow. Stop repeatedly auditing the same totals. Make concrete changes, test them, and then align TEST and LIVE. TEST/main is the reference for catalogue/code changes; LIVE should receive the completed, verified equivalent. Never copy TEST customer, tenant, order, payment, website, custom-domain or ownership data into LIVE.

## Latest database findings (Supabase)
- TEST project: `nnsshnfkjcflucjrftzi`, link `link_6a8b3c7f2f208191851663ebc14853ab`.
- LIVE project: `gxsrajtqzdjvmceqcpgv`, link `link_6ad13c4afe848191899041a0a95b487d`.
- Pokémon master products: TEST 42,395; LIVE 42,780. All active.
- Category branches are Pokémon, Trainer Cards, Energy Cards. LIVE master product distribution previously observed: Pokémon 38,915; Trainer 3,325; Energy 540. TEST: Pokémon 34,987; Trainer 6,311; Energy 1,097. Branch counts differ substantially and need proper key-based reconciliation.
- `pokemon_tcg_cards`: TEST 42,395 records; LIVE 42,453 records. Each currently has a unique `card_key`, but unique keys do NOT prove distinct physical cards.
- LIVE language breakdown: English 23,780 records; Japanese 13,036; Traditional Chinese 3,901; Indonesian 1,016; Thai 579; French 93; Simplified Chinese 48.
- LIVE has 10,394 distinct lowercase card names across all languages; English has 4,548 distinct lowercase names. Counts include sets/printings/language variants and may include aliases/duplicates. Do not claim 42,453 genuinely different cards.
- LIVE card categories were corrected to zero null categories; source-backed category mismatch checks returned zero. Category-to-master mismatches for records with matching card keys returned zero. However 327 LIVE master products do not have exact matching card keys and remain to be key-reconciled.
- Sets/variants differ: TEST sets 569, variants 1,071; LIVE sets 574, variants 1,895. Reconcile before claiming database sync complete.
- A previous note identified 58 path-based alias-looking records under `asia:BW:path:BW8a` that resemble `asia:BW:BW8a`; do not delete without checking references and keeping a safe record/backup.
- Pokémon master products had `customer_visible=false`; a change has now set `customer_visible=true` for all active Pokémon Trading Cards master products in BOTH TEST and LIVE. Counts verified: TEST 42,395 visible; LIVE 42,780 visible. This does not itself make them appear on customer websites.
- LIVE currently has zero tenant catalogue selections for Pokémon. Customer-facing website visibility therefore is not configured yet.

## Critical code and recent change
- GitHub repo: `laurendigitaluk/TradeFlow`.
- Main branch is used as TEST/staging reference; production branch is intended for LIVE release, but fetch of `production` returned 404 through the connector. Verify branch existence before assuming deployment.
- File `buying-catalogue.js` on main: prior SHA `d73a2030100a0367b6ae4aac875374b3a9076527`.
- Just committed display tidy-up at commit `d87e90abbaaf4faf82eebef5c221952e7976946a`:
  https://github.com/laurendigitaluk/TradeFlow/commit/d87e90abbaaf4faf82eebef5c221952e7976946a
  It adds `cardDisplayDetails(p)` and suppresses raw `p.notes` text for Pokémon rows, showing product type and language/rarity when parsable. Other categories are unchanged. This has NOT been browser-tested or deployed to LIVE. Current code extracts language/rarity from notes, which is only a partial UI tidy-up; proper explicit set/collector-number fields should be added to the UI from real schema fields where available.
- Screenshot showed technical import text displayed under each Pokémon card, e.g. “Imported from Pokémon TCG collector database. Card key: ... language: ja; rarity: Ultra Rare. Collector/research record; not enabled for customer-facing catalogue by default.” This should be hidden from subscriber-facing product rows; keep provenance in internal research/admin detail only.
- Relevant page uses `buying-catalogue.html` and `buying-catalogue.js`. `buying-catalogue.html` loads JS with `buying-catalogue.js?v=45`; update cache-buster when needed.
- `get_master_buying_catalogue_facets` and `get_master_buying_catalogue_page_filtered` RPCs were changed on both TEST and LIVE to include active internal products without requiring customer_visible. Public RPC `get_public_buying_catalogue` still filters customer-visible products and requires tenant-specific active selections and website_visible.
- `configure_master_catalogue_buying_product` was inspected. It creates tenant category and branch using master category/branch names, inserts tenant selection and tenant buying product, and configures manual or automatic rules. However its product lookup currently requires `p.active AND p.customer_visible`; we have now set Pokémon visible so it should pass, but it must be verified in a test tenant. Existing valuation rules must not be changed.
- Relevant SQL RPCs: `add_master_buying_products_filtered`, `add_master_buying_products_bulk`, `configure_master_catalogue_buying_product`, `get_public_buying_catalogue`, `get_master_buying_catalogue_facets`, `get_master_buying_catalogue_page_filtered`.

## What to do next — in order
1. Inspect the current main version of `buying-catalogue.js` and verify the just-committed display change is present. Improve Pokémon display to show card name, set name, collector number, language, rarity when available, while suppressing raw source provenance. Do not change non-Pokémon rendering.
2. Verify schema fields for `pokemon_tcg_cards` and `pokemon_tcg_sets`; card table has `card_key, set_id, collector_number, name, rarity, card_category, source_language, source_path, source_blob_sha, source_commit_sha, source_payload, verification_status`. Use joins to sets to obtain set name/code.
3. Key reconciliation: compare TEST vs LIVE card keys, set keys and variant identities. Explain count differences by missing/extra keys and alias/duplicate records. Do not delete records solely to make counts equal; retain legitimate language and printing variants. Record backup/archive before any removal.
4. Verify category/branch mapping from stable card keys and correct LIVE to match TEST where exact matching keys prove the mapping. Check the 327 LIVE master products without matching card keys.
5. Safely configure Pokémon cards for a test tenant through the existing add/configure RPCs, using manual valuation first if needed. Confirm they create the correct Pokémon/Trainer/Energy category branches and tenant_buying_products, without bypassing the normal valuation path.
6. Verify the existing valuation path: customer can choose card, submit condition/details, valuation request receives correct product/category/branch and pricing mode, staff can inspect, and item flows through current acquisition workflow. Do not claim this works until tested.
7. Only after TEST passes, port the same code/schema/RPC changes to LIVE. Keep tenant-specific selections/business data separate. Verify customer website selection and valuation on LIVE.
8. Update cache-buster, user manuals and checkpoint only after actual verification. Be direct; user is frustrated by days of audits and wants implementation, not repeated summaries.

## User preference
Professional, English only, no emojis. Concise progress reports, no endless audit loops. Clearly distinguish changes actually made from steps not yet tested. The user's main concern is that Pokémon must work end-to-end through valuation without breaking the existing valuation system.
