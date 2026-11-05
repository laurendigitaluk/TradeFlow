# TradeFlow Mobile Phone Catalogue — Batch 110 (5 November 2026)

## Direct database work

Five UK refurbished retail observations were inserted independently in TEST and LIVE for Apple iPhone 13 128GB. The product package already existed in both environments; no product rows were added or copied.

| Retailer | Price | Grade | Exact package / caveat |
|---|---:|---|---|
| giffgaff UK | £209.00 | Good | 128GB Midnight; in stock; 12-month warranty |
| The Big Phone Store UK | £199.99 | Good | 128GB Midnight; in stock; minimum 85% battery |
| Reboxed UK | £189.00 | Good | 128GB Midnight, standard battery; TechCheck 70-point; min 80% battery; 12-month warranty; preparing/refurbishing 4–6 days; checkout fee may apply |
| Furbishmarket UK | £191.99 | Good | 128GB Starlight unlocked; 10 in stock; min 85% battery; 12-month warranty; free UK delivery |
| Tech Market UK | £199.99 | Good | 128GB Midnight; listed on retailer homepage; stock quantity not confirmed; one-year warranty and 30-day returns advertised |

All observations are uk_used, GBP, retailer refurbished offers, and carry stable source record keys under mobile-used-iphone13-128gb-...-20261105.

## IDs

Product IDs:
- TEST: `d5a0a2ac-b9d1-4926-94e6-71e6f78622e7`
- LIVE: `1f615e60-984a-415d-ab7c-9e4034dbe532`

Evidence IDs:

| Retailer | TEST evidence ID | LIVE evidence ID |
|---|---|---|
| giffgaff | `1614b1e7-270e-4433-ab07-1d41280ddb75` | `0bdc069b-1788-4405-b77d-bb9168785533` |
| The Big Phone Store | `dd6363fb-4e5f-4ed2-aeef-675f3ca7325c` | `de224b5c-d731-458c-898c-b046bb60d253` |
| Reboxed | `787375c5-1d2b-4e9a-babd-8e0feb6c1b42` | `31aabfca-46f6-4cb1-9524-6e4a3bec119c` |
| Furbishmarket | `cfc549f8-848e-4ce4-bfb3-315e1e139110` | `98e5233a-1fd8-47cc-8b0d-7cb41053d390` |
| Tech Market | `54c19578-a88c-488b-b1f4-a9219941ba9c` | `3cfc5e90-66b3-43a6-a068-46ff7d888a7c` |

## Post-write verification

| Measure | TEST | LIVE |
|---|---:|---:|
| Mobile product rows | 160 | 158 |
| Active mobile product rows | 159 | 158 |
| Active customer-visible product keys | 156 | 156 |
| Mobile evidence rows | 579 | 573 |
| Active mobile evidence rows | 563 | 560 |
| iPhone 13 128GB active UK-used evidence | 6 | 6 |

The product-key comparison returned 156 keys in each environment, with no missing keys in either direction.

## Remaining UK-used evidence gaps

Three exact active customer-visible packages remain without active UK-used evidence in both environments:
- Motorola Edge 70 Plus 256GB
- OPPO Find X10 Pro Max 512GB
- OPPO Reno16 F 5G 256GB

The current surfaced offers failed exact UK-used eligibility checks (new/sealed rather than used, or international dispatch without UK origin verification). Do not fill these gaps with new retail prices, imports, adjacent models or unverified seller listings.

## Change scope

Data-only catalogue/evidence update. No schema, app code, valuation rules, RLS, Edge Functions, Worker deployments, Stripe or tenant/customer/transaction/subscription/domain/ownership/published-content data changed.