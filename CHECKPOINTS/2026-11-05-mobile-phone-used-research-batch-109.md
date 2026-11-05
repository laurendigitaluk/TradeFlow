# Mobile Phone Used-Evidence Research — Batch 109
Date: 5 November 2026

## Preflight database state
Requeried the live and test mobile category before research. Both environments currently have 562 active evidence rows (266 UK-new / 296 UK-used), 154 active products with UK-used evidence and 156 customer-visible active products.
- LIVE: 158 active products; 4 active products missing UK-used evidence; 0 missing all evidence.
- TEST: 159 active products; 5 active products missing UK-used evidence; 1 missing all evidence.
The four common UK-used gaps are Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB, OPPO Find X10 Pro Max 512GB and OPPO Reno16 F 5G 256GB.
The additional TEST-only product is hidden and has no evidence: iPhone 18 256GB. It remains unverified and must not be copied, activated, published, deactivated or deleted without a separate verification/decision.

## New research leads — held, not imported
### OPPO Reno16 F 5G 256GB
eBay UK search results surfaced an exact 8+256GB listing described as Certified - Refurbished at £379.99 from seller fistech_uk (99.6% positive feedback). Search result: https://www.ebay.co.uk/shop/oppo-reno-5g?_nkw=oppo+reno+5g
The accessible seller store page was checked: https://www.ebay.co.uk/str/fistechuk . The specific Reno16 F listing was not present in the accessible store listing. Direct item URL, seller dispatch location and detailed condition could not be independently verified. Hold this candidate; do not use a category/search URL as an item-specific evidence source.
iD Mobile product page confirms exact 256GB variant and refurbished grades (Excellent / Very Good / Good) with a 12-month warranty, but the visible £479 is a new price, not a refurbished quote: https://www.idmobile.co.uk/sim-free-phones/oppo-reno-16f-5g

### OPPO Find X10 Pro Max 512GB
eBay UK search results surfaced a Pre-owned offer titled “Oppo Find X10 Pro Max 512GB 12GB RAM Grey UK Version BARGAIN” at £1,073.08 plus £11.95 postage. Search result: https://www.ebay.co.uk/b/bn_74893092
Direct item URL, seller identity and detailed condition were not verified. Hold; do not import a category-page result.

### OPPO Find X10 256GB
Search results continued to show Brand new and Opened – never used listings, not qualifying used evidence. No used record accepted.

### Motorola Edge 70 Plus 256GB
No qualifying UK used listing found. UK new prices are not used evidence: Argos £499.99 https://www.argos.co.uk/product/9654763 ; MoneySavingExpert price-comparison page £529.99 https://www.moneysavingexpert.com/cheap-mobile-finder/sim-free/motorola/edge-70-plus/ . The latter shows the model released September 2026, likely limiting second-hand stock at present.

## Decision
No evidence rows were inserted or changed in this pass. Do not relax evidence requirements to fill gaps. Require exact model/storage, UK market/seller, GBP price, correct used/refurbished condition, observed date and direct item-level source URL. Separate certified refurbished retail from private used listings and completed-sale evidence.

## Change boundary
No database writes in this batch. No code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. UK-used evidence remains reference-only and must not feed automatic valuation.

## Next action
Continue finding and validating direct item URLs for the four shared used-evidence gaps. If a valid exact-variant candidate is verified, preflight source-key uniqueness and exact product IDs separately in LIVE and TEST, insert only the evidence row into each matching shared master, and read back both environments.
