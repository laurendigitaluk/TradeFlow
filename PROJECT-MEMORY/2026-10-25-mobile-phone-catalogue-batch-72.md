# Mobile Phone Catalogue — Batch 72 (25 October 2026)

Added one UK eBay completed-sale observation for Apple iPhone 16 Pro Max 256GB Black, item 128132786202, sold 19 October 2026 at 16:10 BST. Displayed buyer-facing total £527.16 includes £14.13 Buyer Protection. Listing disclosure says the back was replaced; seller proceeds were not independently confirmed.

- TEST master: 284a24c2-9ae0-468c-b6ac-80e2044f4516
- LIVE master: b9d4b016-a231-4dcf-bd31-3f3777a8ba19
- TEST evidence: c58bffec-0820-4548-869c-93356aa261d2
- LIVE evidence: 5df1e96b-f62f-410d-9bdd-5ad82e3bc4aa
- Stable key: mobile-used-sold-iphone16promax-256gb-black-ebay-128132786202-20261019

Exact URL/key preflight was clear in both environments. TEST was inserted and read back before LIVE was inserted; LIVE also received a separate read-back. No existing evidence was changed. A broad duplicate-key audit was blocked by the tool safety layer, so it remains outstanding.

Prior Batch 71 baseline was TEST 237 active phone evidence / 143 active uk_used+sold and LIVE 235 / 141. Adding one verified active used/sold observation to each implies TEST 238 / 144 and LIVE 236 / 142; these totals should be rechecked with the next full aggregate audit. See CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-72.md.
