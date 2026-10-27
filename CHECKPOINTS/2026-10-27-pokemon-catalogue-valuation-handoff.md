# Pokémon Trading Card Catalogue — Handoff (2026-10-27)

## Main objective
Finish the TradeFlow Pokémon Trading Card database and make it usable through the existing customer valuation journey. Continue the work directly; avoid repeating broad audits or comparing totals endlessly. Do not break the existing valuation system.

## User's non-negotiable rule
**Do not break the valuation system.** Pokémon may need its own card-specific dropdown fields, but must connect into the existing valuation request, customer journey, and inspection workflow. Preserve working categories and product flows for cameras, drones, phones, consoles, and other catalogue types. Do not claim end-to-end completion until a real customer journey is tested.

## Environments and repository
- Repository: `laurendigitaluk/TradeFlow`
- TEST/Sandbox Supabase project: `nnsshnfkjcflucjrftzi`, connector link `link_6a8b3c7f2f208191851663ebc14853ab`
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`, connector link `link_6ad13c4afe848191899041a0a95b487d`
- Recent code changes were made on GitHub `main`. Treat TEST/main as the working reference for catalogue/code changes and deploy to LIVE only after safe checks. Keep tenant/customer/order/payment/domain ownership data separated; do not copy TEST business data into LIVE.

## Recent verified database findings
- TEST `pokemon_tcg_cards`: 42,395 rows; 42,395 distinct card_key values.
- LIVE `pokemon_tcg_cards`: 42,453 rows; 42,453 distinct card_key values.
- LIVE has 42,780 master products under `catalogue_category='Pokémon Trading Cards'`.
- TEST has 42,395 master products under that category.
- LIVE card language breakdown: English 23,780; Japanese 13,036; Traditional Chinese 3,901; Indonesian 1,016; Thai 579; French 93; Simplified Chinese 48.
- LIVE records have 10,394 distinct lowercased card names across all languages. The 42k total is database records/unique keys, **not verified distinct physical cards**. Need investigate aliases, variants, language editions, and true duplicates; do not advertise 42k as unique different cards without qualification.
- LIVE `pokemon_tcg_sets`: 574 sets; TEST: 569.
- LIVE `pokemon_tcg_card_variants`: 1,895; TEST: 1,071.
- Earlier category reconciliation filled missing `card_category` values in LIVE. Follow-up checks reported zero mismatches where source category was present and zero card-to-master category mismatches for matched card/master keys. There are 327 LIVE master products without exact matching card keys, which still require key reconciliation. Avoid destructive deletes until investigated.
- Pokémon master products were changed in both TEST and LIVE to `customer_visible=true` for active products. Verification: TEST 42,395 active+visible; LIVE 42,780 active+visible.
- LIVE currently had zero tenant catalogue selections for Pokémon cards. Master product visibility alone does not put them on a subscriber's customer-facing website. Need configure tenant buying selections and customer flow safely.

## Valuation safety findings
- Existing master catalogue configuration RPC `configure_master_catalogue_buying_product` checks that `p.active AND p.customer_visible`; it creates tenant category/branch/manufacturer and links master products to `tenant_catalogue_selections` and `tenant_buying_products`, then creates manual or automatic pricing. This is the existing path that should be reused.
- `get_public_buying_catalogue(p_tenant_id)` filters by active tenant, category active/buying-enabled, selection active/buying-enabled/website_visible, active tenant_buying_products, and active/customer_visible master product. Do not bypass these safeguards or alter valuation math.
- `buying-catalogue.js` implements the subscriber Master Catalogue add flow, including manual valuation or automatic pricing. It is static JS (not React/Vite).
- Pokémon-specific fields likely needed for a customer valuation form: card/set name, collector number, language, rarity, condition, edition/printing and optional photo. These should be extra inputs within the existing request path, not a separate valuation engine. Confirm actual customer valuation schema and workflow before implementing.

## Latest code change (TEST/main)
- File: `buying-catalogue.js`
- Commit: `d87e90abbaaf4faf82eebef5c221952e7976946a`
- URL: https://github.com/laurendigitaluk/TradeFlow/commit/d87e90abbaaf4faf82eebef5c221952e7976946a
- Purpose: hide long raw Pokémon import-provenance notes from product rows and show concise product type, language and rarity when extractable. Non-Pokémon rows unchanged. Valuation functions were not modified.
- This change is **not yet browser-verified or confirmed deployed to LIVE**.
- Current implementation extracts language/rarity from `p.notes` with regexes; set and collector number are not yet shown as explicit fields. Improve it so relevant details are clear, correct and robust, without breaking other catalogue rows.
- Screenshot from 2026-10-26 showed Master Catalogue rows with long text such as “Imported from Pokémon TCG collector database. Card key: …; language: …; rarity: … Collector/research record; not enabled for customer-facing catalogue by default.” User asked to tidy this to only relevant card details.
- User also supplied Google screenshot suggesting roughly 18,000–20,000 unique English Pokémon cards (sources vary). Use a defensible method and credible sources; distinguish English cards, all-language card printings, sets, and database rows.

## Next tasks (in order)
1. Continue the card identity audit efficiently. Compare stable keys across TEST/LIVE, identify exact/near duplicate card records, alias keys, and true card variants. Produce counts by language and type; do not delete records without a safe backup and clear evidence.
2. Improve display fields: card name; set name; collector number; language; rarity. Keep raw source key, import path, payload and provenance in admin/research detail, not in the ordinary product row. If a field is missing, omit it rather than inventing it.
3. Ensure Pokémon is discoverable in the subscriber Master Catalogue with card-specific filtering/selection. Reuse existing add/configure RPC and current buying valuation rules.
4. Inspect actual customer valuation request form and schema. Add Pokémon-specific card details as conditional fields only where relevant, while passing through the existing valuation/request workflow.
5. Ensure selection -> customer valuation submission -> staff inspection -> offer works with no regressions. Do not change the existing valuation calculations.
6. Keep TEST and LIVE catalogues aligned after verified changes, without copying tenant/customer/order/payment/domain records.
7. Only claim complete after verifying database state, relevant UI code and a real signed-in customer flow. If browser interaction is unavailable, say that clearly.

## Working style
User is frustrated by repeated audits and wants direct progress. Work in small, concrete batches. Do not repeatedly ask for confirmation of the already-given valuation safety rule. Do not claim deployment or browser tests that did not occur.