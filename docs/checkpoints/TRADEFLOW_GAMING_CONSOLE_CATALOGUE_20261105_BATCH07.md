# TradeFlow gaming console catalogue checkpoint — 5 November 2026, batch 07

## Environment and method
- Repository: laurendigitaluk/TradeFlow; LIVE branch production; TEST branch cloudflare-test.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv; TEST Supabase: nnsshnfkjcflucjrftzi.
- TEST-first: records were inserted and read back in TEST, then inserted independently in LIVE using exact model/package matching. No environment-specific UUID was copied across.

## Work completed
Four new active UK-new GBP retail observations were added to existing console masters:

| Product | Retailer | Price | URL |
|---|---|---:|---|
| Xbox Series S 512GB Standard Console | Argos UK | £429.00 | https://www.argos.co.uk/product/5812657 |
| Xbox Series S 512GB Standard Console | Currys UK | £429.00 | https://www.currys.co.uk/products/microsoft-xbox-series-s-512-gb-ssd-10205195.html |
| Xbox Series X 1TB Disc Edition Console | Argos UK | £669.99 | https://www.argos.co.uk/product/4881139 |
| Xbox Series X 1TB Disc Edition Console | Smyths Toys UK | £669.99 | https://www.smythstoys.com/uk/en-gb/gaming-and-tech/xbox-series-x-s/xbox-series-x-s-consoles/xbox-series-x-1tb-console/p/192012 |

All observations are dated 5 November 2026, evidence_type uk_new, GBP, item condition New, availability listed, and carry distinct stable source_record_key values.

### TEST IDs
- Xbox Series S / Argos: product 52683334-09d7-4f86-8b8b-d3732694720a, evidence 9b48d535-fe7f-4fde-83fa-b3442c139202.
- Xbox Series S / Currys: same product, evidence 1398c15d-85f0-4661-9334-2e9ef52d4a8c.
- Xbox Series X / Argos: product e133d717-90ce-4bc9-9a33-914e143bed44, evidence d375b578-8396-4135-85f8-e190f65f5f3b.
- Xbox Series X / Smyths: same product, evidence 4e55d92b-3701-4620-bc21-da35836822f5.

### LIVE IDs
- Xbox Series S / Argos: product 297d57d6-5739-4ed8-aeca-6820f6049159, evidence 0085700e-20b1-423b-bc43-0d622cd31b60.
- Xbox Series S / Currys: same product, evidence 8c5eee05-af3b-464a-86af-5343618af7ae.
- Xbox Series X / Argos: product b842fa3b-b1ab-417a-95f5-608bac8bb86d, evidence ed8db4e0-8351-4a40-a3ad-a426178446a9.
- Xbox Series X / Smyths: same product, evidence 805e0908-530a-4871-8541-b2800fd2b329.

## Verification
Both databases independently report:
- 285 active gaming products; 277 customer-visible.
- 413 active evidence rows: 248 UK-new and 165 UK-used.
- 0 visible products with no active evidence.
- 81 visible products without UK-new evidence; 182 without UK-used evidence.
- 0 active evidence integrity failures; 0 duplicate active source keys.
- All 20 gaming branches match in active and visible product counts.

## Boundaries
No new product masters or schema changes. No RLS, RPC, Edge Function, valuation, customer, tenant, order, payment, Stripe, subscription, domain, application code or Worker changes. No deployment. UK-used evidence remains reference-only and does not feed automated valuation. Continue with verified exact-model retailer/second-hand research, retaining separate package and hardware variants.
