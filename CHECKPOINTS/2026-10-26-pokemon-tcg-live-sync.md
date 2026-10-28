# Checkpoint — Pokémon TCG LIVE sync — 26 October 2026

## Status
A reconciliation batch was completed against the current LIVE and TEST Supabase projects. This checkpoint records actual database results, not a claim that the full source catalogue is complete.

## Supabase results
- LIVE project: `gxsrajtqzdjvmceqcpgv`
- TEST project: `nnsshnfkjcflucjrftzi`
- Categories: LIVE 39, TEST 39
- Sets: LIVE 574, TEST 569
- Cards: LIVE 42,453, TEST 42,395
- Variants: LIVE 1,895, TEST 1,071
- LIVE sets without category: 0
- TEST card keys missing from LIVE after sync: 0
- TEST variant key pairs missing from LIVE after sync: 0

## Batch applied
- Added 5 set metadata records absent from LIVE.
- Added 10,583 card records absent from LIVE by stable `card_key`.
- Added 528 variant records absent from LIVE by `card_key + variant_key`.
- Used idempotent inserts and remapped set/card foreign keys by stable source keys. Existing LIVE records were not overwritten or deleted.

## Preserve and investigate
- 58 LIVE-only cards remain in `asia:BW:path:BW8a`; all 58 exactly duplicate records in `asia:BW:BW8a` by collector number, name, language, source path and blob SHA. They were retained. Do not delete or merge without a separately approved, reversible cleanup.
- The LIVE master catalogue has 327 products under `Pokémon Trading Cards`, all `customer_visible=false`, with no duplicate package keys. Keep the collector database separate from ordinary buying/valuation and do not bulk-create 42k master products.
- 23,604 LIVE cards have null `card_category`; source payloads often contain only set-summary information. Treat them as incomplete for card-type classification and do not guess.
- No prices or market evidence were imported. No valuation logic or tenant/customer data was changed.

## Next actions
1. Retrieve full source detail for cards with missing card type, then update only evidence-backed classifications.
2. Investigate the 58 path-based LIVE-only cards for overlap with `asia:BW:BW8a`.
3. Continue set-level source count reconciliation and record unresolved gaps.
4. Re-run key coverage and duplicate checks after each future import.


## 2026-10-27 continuation — Buying Catalogue and automatic cash/trade-in pricing

Current production source HEAD at the start of this work was `3cbba7add8a406c7c03cd0660ba3a3c80ea50742`; PR #186 was merged at `ff68b656c1e523d1144ff6c02fcef8fd3239d178`. LIVE project `gxsrajtqzdjvmceqcpgv` and TEST project `nnsshnfkjcflucjrftzi` are both ACTIVE_HEALTHY.

### Confirmed current database state
- Both LIVE and TEST expose `configure_master_catalogue_buying_product_pricing` with five trade-in percentage and five trade-in manual-price parameters.
- Both expose `calculate_buying_item_valuation`, which selects UK-new GBP evidence, uses cash percentages and separate trade-in percentages, returns `amount` and `trade_in_amount`, and returns the manual workflow reason `no_research_for_uk_new` when suitable evidence is absent.
- Both expose `get_tenant_buying_catalogue_facets`; that subscriber-specific path filters to active, buying-enabled selections that map to an active tenant buying product.
- Both expose `customer_get_offers_v2` with cash/trade-in price columns and `customer_accept_offer_choice`, which records the selected offer mode and corresponding price.
- Bulk add RPCs take the existing five common condition cash percentages only. Do not silently use those percentages for trade-in; separate trade-in settings are per-product pricing-editor inputs.
- Shared Pokémon master catalogue has 23,780 active products in both projects. Do not run select-all-matching against this entire category or automatically configure all cards.
- TEST currently has 2 tenants and 52 tenant buying products; LIVE has 1 tenant and 243 tenant buying products. This environment-specific tenant data must not be copied between projects.

### Guardrails and previous fixes
- `CHECKPOINTS/2026-09-30-customer-automatic-valuation-linkage.md` remains authoritative: valuation must use the exact tenant-owned `buying_product_id`; no matching evidence means manual workflow; never use another tenant's research.
- `subscriber_credit_trade_in` must continue to require an accepted trade-in initial offer and `purchase_stage='final_offer_required'`. Do not weaken it.
- Inspection stores inspected condition in `buying_item_inspections.condition_grade`; inventory creation reads that field. Pokémon-specific condition work requires an explicit category-aware vocabulary and mapping, without changing other categories.
- Current catalogue code already uses `get_tenant_buying_catalogue_facets` for My Buying Catalogue and `get_master_buying_catalogue_facets` for shared browsing. Pokémon filter isolation uses `isPokemonCatalogue()`, hides regular branch/manufacturer/model filters, and maps the card expansion filter to `p_set_name` for master browsing.

### Source branch changes started
Branch: `fix/automatic-tradein-pokemon-condition-20261027`.
- Documented the intended dual-price contract next to the initial-offer creation code in `buying-dashboard.js`.
- Customer dashboard now prefers a current published/accepted offer over a stale offer row for the same buying item. Its script cache advanced from v152 to v153.
- Buying dashboard script cache advanced from v78 to v79.
- Buying Catalogue script cache advanced from v58 to v59 initially, then to v60 for Pokémon grade-specific pricing labels.
- These remain branch-only until the PR is reviewed, merged, and Cloudflare deployment is confirmed.

### Still unverified
- Fresh browser submission and acceptance of both cash and trade-in using a safe TEST-only item.
- Separate trade-in values surviving pricing save/reload through an authorized browser session on both environments.
- A bounded, specific Pokémon card being added to the correct TEST tenant and appearing in My Buying Catalogue.
- Pokémon-specific condition choices and valuation-slot mapping are implemented in the branch and TEST. A signed-in TEST flow is still required to verify persistence through inspection → inventory → sales; standard electronics conditions must remain unchanged.
- Current Cloudflare deployment of latest production and TEST builds.

### Follow-on work completed in TEST (2026-10-27)
- Updated the Buying Catalogue pricing editor to label the five existing per-product rule slots as **Near Mint, Lightly Played, Moderately Played, Heavily Played, Damaged** for Pokémon Trading Cards only. Standard categories retain Sealed, Opened, Excellent, Good and Poor. The Catalogue script cache is now v60.
- Added `supabase/migrations/20261027140000_pokemon_grade_valuation_mapping.sql`. Applied to TEST. Canonical submitted values `near_mint`, `lightly_played`, `moderately_played`, and `heavily_played` map to the five per-product pricing slots; `damaged` uses the final slot. The original canonical item condition remains on the buying item/inspection record; only the pricing lookup uses the mapped slot.
- Added `supabase/migrations/20261027143000_subscriber_catalogue_independent_of_storefront_visibility.sql`. Applied to TEST. Internal master-product configure/add and My Buying Catalogue page/facets no longer reject products solely because `customer_visible=false`. Public storefront visibility checks were not changed.
- Read-only TEST verification confirms the valuation function contains the Pokémon grade mapping and the four internal configure/add/My Buying Catalogue functions no longer contain the `p.active and p.customer_visible` predicate.
- Migration ledger alignment: TEST records these migrations as versions `20261027234948` (`pokemon_grade_valuation_mapping`), `20261027234958` (`subscriber_catalogue_independent_of_storefront_visibility`), and `20261027235403` (`preserve_pokemon_condition_in_valuation`); the branch filenames now use those exact versions. The redundant earlier `20261027230000_allow_master_buying_invisible_products.sql` draft was removed because its configure/add changes are covered by the later visibility migration. Recheck the remote/local migration ledger before any future CLI deployment.

### Remaining before promotion
- Run a signed-in TEST browser flow for one bounded Pokémon card: select/add it to the correct TEST tenant, verify it appears in My Buying Catalogue, save/reload cash and trade-in percentages, submit a valuation, inspect, and confirm the grade remains visible through inventory.
- Verify standard electronics still price exactly as before and customer offer-choice/credit guards remain unchanged.
- Confirm the migration ledger and actual TEST/Cloudflare runtime deployment. Do not merge or touch LIVE until these checks pass.
- Never use bulk select-all across the entire Pokémon category; the master catalogue contains 23,780 active Pokémon products.


### Independent cash/trade-in calculation fix (2026-10-27)
- TEST migration ledger includes `20261027235942_independent_cash_tradein_condition_overrides`; matching migration file is `supabase/migrations/20261027235942_independent_cash_tradein_condition_overrides.sql`.
- Fixed the early-return bug where a per-condition cash manual override prevented the separately configured trade-in percentage from being calculated. With UK New GBP evidence, each side is now calculated independently: a cash override wins for cash while trade-in uses its own percentage (or its own manual override); conversely a trade-in manual override does not erase an available cash percentage calculation.
- If UK New evidence is unavailable, configured manual prices remain usable and any percentage-based side without a research basis stays manual. Existing no-research fallback remains in place.
- Read-only TEST function verification confirms original Pokémon grade preservation, independent cash calculation, independent trade-in calculation and manual fallback are present.
- End-to-end signed-in TEST browser workflow, standard electronics regression and Cloudflare runtime deployment are still unverified. LIVE has not been changed.

- TEST evidence check: the active English Pokémon master catalogue has 23,780 cards, but there are currently zero active shared-market-evidence rows for Pokémon and zero Pokémon buying products configured for the selected TEST tenant. Therefore, percentage-based Pokémon valuation will correctly remain on manual fallback until valid UK New GBP evidence exists; do not insert guessed prices or treat collector metadata as pricing evidence.
