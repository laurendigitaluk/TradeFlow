# Xbox Console Catalogue — Evidence Continuation and Environment Correction

Date: 30 October 2026

## Environment authority
- TEST branch: `cloudflare-test`; TEST Supabase: `nnsshnfkjcflucjrftzi`.
- LIVE branch: `production`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- Retired TEST Supabase `twfbmjwwqzxdxvclxbun` must never be used.
- Shared catalogue/evidence is mirrored by stable product identity with environment-specific UUIDs. Tenant, customer, transaction, domain, storefront and payment data remain isolated.

## Catalogue state
13 Microsoft Xbox product/package variants exist in both TEST and LIVE. Latest per-product readback showed matching active evidence counts:
- Xbox 360 250GB: 2; 4GB: 2; 500GB: 1.
- Xbox One 1TB: 1; 500GB: 2.
- Xbox One S 1TB: 2; 500GB: 2.
- Xbox One S All-Digital 1TB: 2 after the 30 October £40 completed-sale record was inserted and read back in both environments.
- Xbox One X 1TB: 2.
- Xbox Series S 1TB Carbon Black: 2; 512GB: 3.
- Xbox Series X 1TB Disc: 2.
- Xbox Series X Digital Edition 1TB: 1 at last database readback.

The earlier provisional Xbox Series S 512GB reference (eBay item 227560758629; storage not explicit in listing title) remains subject to item-specifics review. Do not treat it as a firm capacity-specific benchmark until confirmed.

## Documentation correction
On TEST, the following four documents were updated with a dated authoritative environment block at the top. Older project-ID mentions are explicitly classified as historical only:
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`

The correct current TEST and LIVE project IDs are stated above. No retired project was queried or written to.

## Additional researched candidates — not yet inserted
- Xbox Series X Digital Edition 1TB, used, eBay UK item 318636321021, £310.58, sold 27 July 2026; item specifics confirm 1TB, white digital console. Source: https://www.ebay.co.uk/itm/318636321021
- Xbox Series X Digital Edition 1TB, used, eBay UK item 168372673741, £329.99, sold 25 June 2026; listing text and item specifics identify white 1TB digital console. Source: https://www.ebay.co.uk/itm/168372673741
- Xbox Series X Digital Edition 1TB, opened-never-used, item 168537550244, £387.62, sold 2 August 2026; condition is not Used, so keep separate from used evidence or exclude from the used-price set.
- Xbox Series X Digital Edition 1TB, new, item 318609528914, £380, sold 1 August 2026; exclude from used evidence.
- Xbox Series X Digital Edition 1TB, item 128030039173, £463.08, sold 28 August 2026; listing says Used and 1TB, but very high outlier; do not use without further comparison/condition scrutiny.

## Database write status / safeguards
The £40 Xbox One S All-Digital evidence record was successfully inserted and read back in TEST and LIVE:
- key: `ebayuk-336604763656-xboxones-all-digital-1tb-20260812`
- price £40.00, sold 12 August 2026, eBay UK item 336604763656.

A later attempt to insert two researched references (Xbox One 1TB item 188496733818 and Xbox Series X Digital item 137590211396) was blocked by the database tool safety layer. No successful write or readback was obtained; do not count these records as added. Retry one statement at a time, check source_record_key first, then insert in TEST and mirror to LIVE only after TEST readback.

## Remaining work
1. Reconcile and correct documentation in LIVE after verifying production branch current content and preserving production-only edits.
2. Add a further verified Xbox Series X Digital Edition 1TB used sale, e.g. item 318636321021 (£310.58) or 168372673741 (£329.99), only after checking duplicate source keys in TEST; then mirror to LIVE using LIVE product ID `bd71b9e9-50fb-4e2a-9226-92dc38fd21eb`.
3. Find exact standard Xbox 360 500GB and Xbox One 1TB sales. Avoid special editions, bundles, and capacity-ambiguous listings.
4. Recheck provisional Xbox Series S 512GB item 227560758629.
5. Maintain TEST/LIVE shared evidence parity and do not merge divergent branches wholesale.


## Subsequent verified TEST/LIVE evidence inserts — 30 October 2026
Two additional exact UK completed-sale records have now been inserted separately into TEST and LIVE and read back successfully in both databases:
- Xbox One 1TB: £52.54, sold 20 July 2026, eBay item 188496733818; key `ebayuk-188496733818-xboxone-1tb-20260720`. TEST product `781b9bbc-8b73-412c-919d-d68d979e10d8`; LIVE product `e419eb99-c430-4af7-893e-0e997514e337`. Source: https://www.ebay.co.uk/itm/188496733818
- Xbox Series X Digital Edition 1TB: £329.99, sold 25 June 2026, eBay item 168372673741; key `ebayuk-168372673741-xboxseriesx-digital-1tb-20260625`. TEST product `5fc70dc3-5bf9-4e26-b888-abae5b12c8c8`; LIVE product `bd71b9e9-50fb-4e2a-9226-92dc38fd21eb`. Source: https://www.ebay.co.uk/itm/168372673741

The Xbox One 1TB and Xbox Series X Digital Edition 1TB now each have two active evidence rows in both environments. The All-Digital Xbox One S 1TB has two active evidence rows in both environments following its earlier £40.00 record. TEST/LIVE parity for these added records is confirmed by source key, price, date, active status and mapped product identity.

The database has no public-schema table with a name containing `memory` or `checkpoint`; structured project memory/checkpoint is therefore maintained in GitHub `PROJECT-MEMORY/` and `CHECKPOINTS/`, not by inventing a Supabase table.


## Latest read-after-write audit
The following four product variants were rechecked after the additional inserts. TEST and LIVE counts match exactly:
- Xbox 360 500GB Standard Console: 1 active reference (eBay item 147564021425, £64.46, sold 12 September 2026). Do not add the £83.25 listing with 20 games or the £155.58 special-edition blue bundle as standard-console evidence.
- Xbox One 1TB Standard Console: 2 active references, including item 188496733818 (£52.54, sold 20 July 2026).
- Xbox One S All-Digital Edition 1TB: 2 active references, including item 336604763656 (£40.00, sold 12 August 2026).
- Xbox Series X Digital Edition 1TB: 2 active references, including item 168372673741 (£329.99, sold 25 June 2026).

The four manual files have been updated on both `cloudflare-test` and `production` with the same authoritative environment correction block. The TEST documentation and GitHub project-memory/checkpoint files were read back after commits. LIVE AI manual readback also confirms the new block. These are documentation commits only; no Worker deployment or code deployment was made.

No exact additional standard Xbox 360 500GB completed sale was found in the latest search. Current candidate listings were active/unsold, ended in error, or special-edition/game bundles, so they were excluded.


## Reconciliation update — 30 October 2026, latest TEST/LIVE database readback
The previous count summary above contained stale counts for Xbox One 1TB and Xbox Series X Digital Edition 1TB. A fresh grouped query of all 13 mapped product IDs in both authoritative databases confirms the same current counts in TEST and LIVE:
- Xbox 360 4GB: 2; 250GB: 2; 500GB: 1.
- Xbox One 500GB: 2; 1TB: 2.
- Xbox One S 500GB: 2; 1TB: 2; All-Digital 1TB: 2.
- Xbox One X 1TB: 2.
- Xbox Series S 512GB: 3; 1TB Carbon Black: 2.
- Xbox Series X 1TB Disc: 2; Digital Edition 1TB: 2.
Total: 26 active evidence rows per environment. All 13 mapped products have matching TEST/LIVE counts. The earlier 1-count statements are superseded by this readback.

The Xbox 360 500GB gap was rechecked directly in both databases. Each environment has exactly one active record: item 147564021425, £64.46, sold 12 September 2026. New search results were reviewed:
- Item 398177369875 (£207.25) and item 298730185866 (£155.58) are blue special-edition consoles; excluded from standard black-console evidence.
- Item 318411489205 (£199.99) is a blue limited-edition bundle with 2 controllers and 25 games; excluded.
- Item 137465583667 (£196.91) is a blue special-edition bundle; excluded.
- Item 398220373589 (£83.24) is a 250GB console with six games, not a 500GB match; excluded.
- Item 377594714464 (£72.92) has no explicit storage capacity in the surfaced item specifics and indicates a best-offer sale; excluded as capacity-ambiguous.
- Item 840049098248 (£83.25) is a 20-game bundle; excluded.
- Item 137360485686 (£60) was ended by the seller due to a listing error, not sold; excluded.
No second clean standard Xbox 360 500GB completed sale was found. Do not insert any of these candidates.

Latest GitHub branch heads checked before this update: TEST `cloudflare-test` at `38c91b9ae7549f030bb73ea209eb308bea58ec28`; LIVE `production` at `1e094ea2b6f8783b1d4b319e2e58448bad1756ad`. No database rows were written and no application code or Worker was deployed during this continuation.


## Further Xbox 360 500GB search — 30 October 2026
A further targeted UK eBay sold-listing search returned no new clean standard-console reference:
- The only clean black 500GB console-only result remains item 147564021425 at £64.46, sold 11/12 September 2026.
- Item 398220373589 is titled 500GB but item specifics say 250GB and it includes six games; reject.
- Item 840049098248 is 500GB but includes 20 games; reject as a bundle.
- Item 298730185866 is a blue special-edition 500GB model; reject for the standard black model.
- PriceCharting search surfaced US-dollar sales, not UK GBP references, so these were not imported.
No new evidence was inserted. The TEST/LIVE counts remain 26 active rows each, with Xbox 360 500GB at one row per environment. Source URLs reviewed:
https://www.ebay.co.uk/itm/147564021425
https://www.ebay.co.uk/itm/398220373589
https://www.ebay.co.uk/itm/840049098248
https://www.ebay.co.uk/itm/298730185866
