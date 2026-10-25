# TradeFlow Mobile Phone Catalogue — Batch 72
Date: 25 October 2026

## Change
Added one UK eBay completed-sale observation for Apple iPhone 16 Pro Max 256GB Black, item 128132786202.

- Listing: https://www.ebay.co.uk/itm/128132786202
- Sold: 19 October 2026 at 16:10 BST (15:10 UTC)
- Displayed buyer-facing total: £527.16, including £14.13 eBay Buyer Protection
- Condition: Used
- Listing disclosure: back replaced
- Seller proceeds: not independently confirmed
- Stable key: `mobile-used-sold-iphone16promax-256gb-black-ebay-128132786202-20261019`
- TEST evidence ID: `c58bffec-0820-4548-869c-93356aa261d2`
- LIVE evidence ID: `5df1e96b-f62f-410d-9bdd-5ad82e3bc4aa`
- TEST master product: `284a24c2-9ae0-468c-b6ac-80e2044f4516`
- LIVE master product: `b9d4b016-a231-4dcf-bd31-3f3777a8ba19`

## Verification
- Exact URL and stable-key preflight returned no rows in TEST or LIVE.
- Confirmed the active iPhone 16 Pro Max 256GB master product exists in both environments.
- Inserted TEST first and read the inserted row back, including price, timestamp, notes, active flag and stable key.
- Inserted LIVE only after TEST verification; LIVE insert returned the expected record and a separate read-back confirmed it.
- No existing observations were updated or deactivated.
- The note preserves the replaced-back disclosure so this sale is not interpreted as an ordinary undamaged handset.
- A broader duplicate-key audit was attempted but blocked by the tool safety layer; do not claim a full post-Batch-72 duplicate audit was completed.

## Counts
Prior Batch 71 baseline: TEST 237 active phone evidence / 143 active `uk_used` + sold; LIVE 235 / 141. With this one active phone used/sold observation added to each environment, expected counts are TEST 238 / 144 and LIVE 236 / 142. These are derived from the prior verified baseline plus the single verified insertion; re-run the full aggregate count audit when the query path is available. The two-row TEST/LIVE difference remains.

## Next steps
Continue searching UK completed sales, preflight exact URLs and stable keys in both environments, confirm exact active master model/storage matches, insert TEST then read back, then insert LIVE and read back. Preserve historic observations and distinguish buyer-facing totals from seller proceeds. Keep repaired/parts-condition disclosures explicit. Re-run the full active duplicate-key and category-specific count audit when supported.
