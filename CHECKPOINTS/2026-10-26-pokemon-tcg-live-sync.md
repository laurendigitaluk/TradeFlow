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
- 58 LIVE-only cards remain in `asia:BW:path:BW8a`; the TEST database does not contain that set key. Do not delete or merge until the path-based and non-path set records are compared.
- The LIVE master catalogue has 327 products under `Pokémon Trading Cards`, all `customer_visible=false`, with no duplicate package keys. Keep the collector database separate from ordinary buying/valuation and do not bulk-create 42k master products.
- 23,604 LIVE cards have null `card_category`; source payloads often contain only set-summary information. Treat them as incomplete for card-type classification and do not guess.
- No prices or market evidence were imported. No valuation logic or tenant/customer data was changed.

## Next actions
1. Retrieve full source detail for cards with missing card type, then update only evidence-backed classifications.
2. Investigate the 58 path-based LIVE-only cards for overlap with `asia:BW:BW8a`.
3. Continue set-level source count reconciliation and record unresolved gaps.
4. Re-run key coverage and duplicate checks after each future import.
