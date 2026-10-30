# Project Memory — Mobile Phone Catalogue Batch 96

Date: 30 October 2026
Status: Ten targets reviewed; three valid new evidence records inserted into both TEST and LIVE; one invalid buyback record deactivated in both environments. No master products or schema changed.

## Supabase environments
- TEST project: `nnsshnfkjcflucjrftzi`
- LIVE project: `gxsrajtqzdjvmceqcpgv`
- All writes used each environment's own master product ID.

## Ten targets reviewed
Apple iPhone Duo 256GB, 512GB, 1TB and 2TB; Motorola Edge 70 Plus 256GB; Nothing Phone (4b) 128GB; OPPO Find X10 256GB; OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB; Samsung Galaxy A18 4G 128GB.

## Inserts confirmed in both environments

| Product | Source | GBP | Condition | Availability |
|---|---|---:|---|---|
| Apple iPhone Duo 256GB | The Big Phone Store | £1,789.99 | Refurbished - Like New | listed |
| Nothing Phone (4b) 128GB | PriceSpy UK | £270.00 | Used | listed |
| Samsung Galaxy A18 4G 128GB | eBay UK item 287674257213 | £182.99 | Pristine - Used | listed |

TEST evidence IDs:
- iPhone Duo 256GB: `ab070bf1-6512-44a6-a003-4afc467e61a6` (master `b62f9aae-4285-4185-9c90-19f3c91add36`)
- Nothing Phone (4b) 128GB: `22e8eb65-6e42-465c-b42a-d3611f71e8b2` (master `d31d491b-a5ab-440f-880a-fc84a185000c`)
- Samsung Galaxy A18 4G 128GB: `a299288d-2595-46b8-b24c-c1712481852d` (master `113793f7-4be2-4234-8e31-0b4520bbc805`)

LIVE evidence IDs:
- iPhone Duo 256GB: `986c2e44-955e-4975-bbd2-5194cd63f294` (master `e40feac3-7861-45fc-867c-14194155e272`)
- Nothing Phone (4b) 128GB: `9cd28747-e5f9-4825-82a4-44dbd977bf24` (master `9ea16e96-f9da-49fc-baa6-8c498af007f9`)
- Samsung Galaxy A18 4G 128GB: `057f2d57-24b1-434b-996b-0625f6a2344a` (master `b6e7f56b-6f49-42f9-a274-86b23af9c62a`)

Stable keys: `bigphonestore-iphone-duo-256gb-20261030`, `pricespy-nothing-phone-4b-128gb-used-20261030`, `ebay-uk-287674257213`.

## Invalid row deactivated
The SellMyMobile UK £800 iPhone Duo 256GB quote was a buyback/trade-in value, not a used resale asking price. Deactivated and retained for audit in TEST (`12aaec46-7a25-4973-9a3a-eb3bf1670873`) and LIVE (`57f21093-6d1d-4222-87ff-4e8e43024522`). Replaced by the Big Phone Store refurbished listing above.

## Exclusions
- iPhone Duo 512GB eBay used £2,440.90 and 1TB eBay used £2,939.27 were above the corresponding new Apple UK prices; excluded as anomalous used-market comparables. Existing iOutlet refs were out of stock.
- iPhone Duo 2TB Reboxed £3,199 page was sold out; eBay results were new/sealed.
- Motorola Edge 70 Plus 256GB: only new UK offers found.
- OPPO Find X10 256GB: no qualifying used listing; current results new/launch listings.
- OPPO Find X10 Pro Max 512GB: eBay pre-owned £1,244.82 candidate lacked independently verified UK seller location.
- OPPO Reno16 F 5G 256GB: no qualifying used listing found.

## Verified current counts
| Measure | TEST | LIVE |
|---|---:|---:|
| Mobile master rows | 160 | 156 |
| Active mobile masters | 159 | 156 |
| Customer-visible active masters | 156 | 154 |
| Active mobile evidence rows | 543 | 537 |
| Active `uk_used` rows | 276 | 274 |
| Active listed `uk_used` rows | 81 | 81 |
| Active products with any active `uk_used` | 154/159 | 152/156 |
| Active products missing active `uk_used` | 5 | 4 |
| Customer-visible products missing active `uk_used` | 4 | 3 |

The previous continuation figures (134/130 mobile products and 15/13 missing) are stale. Current queries supersede them.

## Remaining active-product gaps
TEST: Apple iPhone 18 256GB (customer-hidden), Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB (customer-hidden), OPPO Find X10 Pro Max 512GB, OPPO Reno16 F 5G 256GB.

LIVE: Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB (customer-hidden), OPPO Find X10 Pro Max 512GB, OPPO Reno16 F 5G 256GB.

## Rules / next actions
Continue fresh queries before each batch. Do not reuse TEST IDs in LIVE. Asking prices remain `availability='listed'`; completed sales remain `sold`. Reject buyback quotes, new/overseas/wrong-variant offers, out-of-stock pages and unverified sellers. No master product, visibility, lifecycle, valuation, schema, RPC or Edge Function changes were made. The two Supabase projects expose no matching structured project-memory/checkpoint tables; GitHub project-memory/checkpoint files are the current structured record.
