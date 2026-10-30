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
