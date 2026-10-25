# TradeFlow Mobile Phone Catalogue — Batch 80
Date: 25 October 2026

## Summary
Added one UK eBay used completed-sale observation for Google Pixel 10 Pro XL 256GB Moonstone, factory unlocked. Exact active master match and exact source URL/stable-key preflight were clear in TEST and LIVE. TEST insert/read-back completed before LIVE insertion/read-back. No master product was created and no existing evidence was overwritten.

## Record added
- URL: https://www.ebay.co.uk/itm/278176799541
- Sold: 18 July 2026 at 17:50 BST / 16:50 UTC
- Displayed total: £620.00; search result labelled it including Buyer Protection, but fee amount was not displayed in captured result.
- Condition: Used. Listing specifies no charger included.
- Original page offered Best Offer but did not display a “Best offer accepted” notice. Price is retained as displayed on the sold result, with uncertainty explicitly recorded; seller proceeds not independently confirmed.
- Stable key: `mobile-used-sold-pixel10proxl-256gb-moonstone-ebay-278176799541-20260718`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `abe2acc1-68f1-4a92-a471-30999fdf7710`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `2de6f8ea-8266-4950-a824-0ca342999cb6`

## Counts verified after Batch 80
- TEST: 252 active phone evidence; 156 active `uk_used` + sold; 2 active `uk_new` + sold.
- LIVE: 250 active phone evidence; 154 active `uk_used` + sold; 2 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Candidates excluded
- Pixel 10 Pro XL item 307032982149: listing explicitly says Best Offer accepted; actual accepted price is not disclosed.
- Pixel 10 Pro XL item 178380435775: Best Offer accepted; actual accepted price not disclosed.
- Pixel 10 Pro XL item 278210429467: new item, but check exact master and URL/key before any possible ingestion; not added in this batch.
- Pixel 10 Pro Fold candidates remain deferred because no active exact master exists in either environment.

## Existing source discrepancy still outstanding
Batch 78 item 128026023099 remains recorded at £399.99 while a later search result displays £479.99 incl Buyer Protection. Preserve history; investigate possible relisting/current-price drift or capture discrepancy before correction.

## Next
Continue UK completed-sale research. Confirm exact active master and source URL/key in both environments; insert TEST and read back before LIVE. Keep offer ambiguity and price discrepancies documented.
