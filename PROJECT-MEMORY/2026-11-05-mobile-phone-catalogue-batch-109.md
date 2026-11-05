# TradeFlow Mobile Phone Catalogue — Batch 109 (5 November 2026)

## Work completed

Added three new UK used/refurbished market-evidence observations for the existing Samsung Galaxy A57 5G 128GB package, independently in TEST and LIVE.

| Source | Price | Condition | Verified package/details |
|---|---:|---|---|
| refurbed UK | £272.00 | Premium refurbished | 8GB RAM / 128GB / Dual-SIM / Awesome Gray; UK domestic dispatch; 12-month seller warranty; 30-day returns |
| Cash Converters, Levenshulme | £269.99 | Good / signs of previous use | Unlocked 128GB Grey; 12-month warranty; accessory wording conflicts, so accessory inclusion is not valuation evidence |
| Cash Converters, Lewisham | £299.99 | Very minor cosmetic wear | Unlocked 128GB Blue; 12-month warranty |

All three source records are independently inserted in both environments. Stable source record keys:
- `mobile-used-galaxy-a57-5g-128gb-refurbed-premium-20261105`
- `mobile-used-galaxy-a57-5g-128gb-cashconverters-020300170726-20261105`
- `mobile-used-galaxy-a57-5g-128gb-cashconverters-046100185367-20261105`

## Product and evidence IDs

Product ID is already established in each environment:
- TEST product: `508145af-1115-4e56-b912-f4247f9a855f`
- LIVE product: `c5e25787-79af-44bb-b932-916dd25c3fba`

Evidence IDs:
| Evidence | TEST ID | LIVE ID |
|---|---|---|
| refurbed £272 | `4766da5e-2676-4e9e-b97b-e549668b8b22` | `cea68cef-d386-4731-b451-f581a91b5f8c` |
| Cash Converters £269.99 | `afd3e6be-0ef7-447d-a4a2-4f89a1d4939f` | `0916279c-1c9b-40f9-b249-59f34e50ab1e` |
| Cash Converters £299.99 | `bb1e6d30-f84d-4415-96f5-8ba088646bc2` | `342dba2f-f803-4826-add8-d4c5dfe489f4` |

## Post-write verification

| Measure | TEST | LIVE |
|---|---:|---:|
| Mobile product rows | 160 | 158 |
| Active product rows | 159 | 158 |
| Active customer-visible product keys | 156 | 156 |
| Mobile evidence rows | 574 | 568 |
| Active mobile evidence rows | 558 | 555 |
| Batch 109 new evidence | 3 | 3 |

The active customer-visible product business-key set remains aligned. TEST's two extra product rows are hidden/retired audit records and are intentionally not copied to LIVE.

Samsung Galaxy A57 5G 128GB now has four active UK-used evidence observations in each environment.

## Remaining exact UK-used evidence gaps

The same three customer-visible packages have no active UK-used evidence in either environment:

1. Motorola Edge 70 Plus 256GB — no credible exact UK used/refurb offer found. Current MSE results are new retail only.
2. OPPO Reno16 F 5G 256GB — the eBay certified-refurbished result shows free international postage; UK domestic dispatch is unverified, so excluded.
3. OPPO Find X10 Pro Max 512GB — surfaced exact UK eBay offers are new/sealed; overseas/international offers excluded.

No substitute model or inappropriate evidence was inserted.

## Deployment and isolation

Data-only catalogue change. No code, schema, RLS, valuation rules, Edge Functions, Worker deployment, Stripe, tenant, customer, transaction, subscription, domain, ownership or published-content changes.
