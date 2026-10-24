# Mobile phone catalogue — Batch 59
Date: 24 October 2026

## Scope
Added one UK eBay completed-sale observation for Apple iPhone 15 Pro 128GB Black to the mobile phone category. Followed TEST-first, then LIVE, with separate global exact-URL and stable-key preflights in each environment.

## Evidence added
- Model: Apple iPhone 15 Pro, 128GB, Black
- eBay item: [206515412317](https://www.ebay.co.uk/itm/206515412317)
- Observed sale date: 1 September 2026
- Displayed buyer-facing total: £302.94, including £10.34 Buyer Protection
- Seller proceeds: not independently confirmed; do not interpret the displayed total as seller net proceeds.
- Evidence type: `uk_used`; condition: `Used`; availability: `sold`; currency: GBP; active: true
- Stable key: `mobile-used-sold-iphone15pro-128gb-black-ebay-206515412317-20260901`
- TEST master: `0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe`
- TEST evidence row: `0e31cf7b-1d70-4080-9d48-79db2e757653`
- LIVE master: `8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16`
- LIVE evidence row: `5f5db16e-11e2-4599-ad17-166047c7364d`
- Exact source URL and stable-key preflights were empty in both environments before insertion. Insert result and subsequent exact-URL read-back confirmed one active row in each environment.

## Duplicate handling
The iPhone 15 Plus 128GB Blue candidate, eBay item `800655157429`, was already present in both environments and was not duplicated.

## Counts and outstanding checks
- TEST active phone evidence: 222
- LIVE active phone evidence: 220
- Difference remains: 2 active rows.
- Last confirmed active UK used/sold counts before this batch: TEST 126; LIVE 124. The Batch 58 recount had been blocked; these subtotals were not refreshed in Batch 59.
- Full aggregate duplicate-key audit remains outstanding. Only this candidate's exact URL and stable-key preflights are confirmed.
- Continue source-by-source global URL/key preflight, TEST-first writes, LIVE second, and read-after-write verification. Do not claim the environments are fully synchronized while counts differ.

## Documentation
Batch 58 aggregate catalogue memory and AI, backend, and human manuals were updated before this batch. Batch 59 checkpoint and batch memory record this insertion.
