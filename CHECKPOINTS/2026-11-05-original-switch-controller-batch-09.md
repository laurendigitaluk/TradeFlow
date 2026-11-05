# Original Nintendo Switch controller catalogue — Batch 9

Date: 2026-11-05
Repository: laurendigitaluk/TradeFlow (main)

## Scope
Added four distinct original Nintendo Switch-family compatible controllers to the shared Nintendo Controllers branch in LIVE and TEST. Existing PowerA and Turtle Beach manufacturer rows were reused. All additions have active UK-new GBP Argos evidence.

| Product | UK new price | Argos source |
|---|---:|---|
| PowerA Enhanced Switch & PC Wireless Controller — Kirby | £24.99 | https://www.argos.co.uk/product/7868290/ |
| PowerA Enhanced Switch Wireless Controller — Mario Peek A Boo | £29.99 current promotional listing (was £39.99) | https://www.argos.co.uk/product/7570289/ |
| Turtle Beach Rematch Wireless Switch Controller — Mario Bricks | £49.99 | https://www.argos.co.uk/product/7818848/ |
| Turtle Beach Rematch Wireless Switch Controller — Donkey Kong | £49.99 | https://www.argos.co.uk/product/7811089/ |

## LIVE records
| Product | Product UUID | Evidence UUID |
|---|---|---|
| PowerA Kirby | 30238510-619e-407b-92ba-b5fcd95fd2c6 | 6479ab1f-e6e4-431b-8d89-c466f51bc57b |
| PowerA Mario Peek A Boo | 0a1489df-ffd6-40db-8dcb-d29a3cd3baee | 9c138477-bc5c-4b45-a91b-8eb3b1cf8934 |
| Turtle Beach Mario Bricks | b00628c5-e857-49a7-b472-aed136daa631 | bf338556-06aa-461b-909e-a2cf52897a48 |
| Turtle Beach Donkey Kong | d10e9bc8-0591-45ba-b221-e0bbff9ec1cb | 9ee7bd33-a7f5-4f30-9428-c2173ccf1bc8 |

## TEST records
| Product | Product UUID | Evidence UUID |
|---|---|---|
| PowerA Kirby | 8906a8f8-701e-45c6-aed6-9b08e9309e5b | 308cff21-9ee0-49b5-88cf-24bb221a8458 |
| PowerA Mario Peek A Boo | 106dd867-5c63-4d20-b6a4-aa8a777213ca | 8c1a4c6a-d6b0-4ce0-b32c-3ec36a468e0b |
| Turtle Beach Mario Bricks | 5a193149-c3c6-4426-ade9-cdfae5ae5681 | 915a7e31-6c43-40bb-8516-4dbea2636044 |
| Turtle Beach Donkey Kong | 452544ec-d9db-43e1-ab44-ea40047810dd | b1e0a39e-adc1-4075-b17e-96091a01e91c |

## Evidence and verification
All four evidence rows in each environment: evidence_type=uk_new, price_currency=GBP, item_condition=New, sales_channel=Argos, availability=listed, is_active=true, with exact product URL, observed price, observation timestamp and stable source_record_key.

Independent post-insert SQL verification in both environments:
- Active customer-visible Nintendo Controllers products: 65
- Active evidence rows: 68
- Visible active products missing active evidence: 0
- Active evidence integrity exceptions (missing URL/key, non-positive price, non-GBP currency or condition mismatch): 0
- LIVE and TEST product/evidence counts and package keys match; environment-specific UUIDs retained separately.

The four new records increased the previously verified Batch 8 baseline from 61 products / 64 evidence rows to 65 / 68 in both environments. An initial SQL insert attempt failed on UUID/text comparison and committed no rows; the corrected typed insert then succeeded in both environments. A first integrity predicate incorrectly treated the two legitimate existing UK-used rows as invalid; the corrected condition-aware integrity query returned no exceptions.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or custom-domain data changed. No Cloudflare Worker deployment required. Used evidence remains reference-only and does not affect automatic valuation.
