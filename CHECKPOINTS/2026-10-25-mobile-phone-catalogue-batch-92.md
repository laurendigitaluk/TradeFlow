# Mobile Phone Catalogue Research — Batch 92
Date: 25 October 2026

## Scope and handling
Researched 20 mobile phone variants, prioritising current UK new-condition completed-sale evidence. Three observations were inserted into existing masters. TEST insertion and read-back completed before LIVE insertion and read-back. No master products were created or modified.

## Added observations

1. **Apple iPhone 16 Pro 256GB Natural Titanium, unlocked, new** — [eBay item 356312645257](https://www.ebay.co.uk/itm/356312645257). Sold 27 Aug 2026 at 20:22 BST. Displayed £979.99; Buyer Protection is indicated, but the separate fee amount is not shown. Tesco business seller, 99.9% positive feedback, Wellingborough, UK. Multi-quantity listing reports 3 sold. TEST evidence `4eb9eed4-edb6-45cb-a803-34af17c2910a`; LIVE `7ac5d442-d783-42cf-a4c2-d4065cce0780`. Stable key `mobile-new-sold-iphone16pro-256gb-natural-tesco-ebay-356312645257-20260827`.
2. **Apple iPhone 17e 256GB Black, new and sealed** — [eBay item 820089159254](https://www.ebay.co.uk/itm/820089159254). Sold 5 Sep 2026 at 16:40 BST. Displayed £503.75 including £13.75 Buyer Protection. UK private seller gra-948997, 98 feedback, 100% positive. Best Offer option is visible but no accepted-offer notice; caveat retained. TEST evidence `bf57b742-09cc-4164-9bb8-0761e112e7e1`; LIVE `fda59deb-e2a6-4c19-9414-811619526b51`. Stable key `mobile-new-sold-iphone17e-256gb-black-ebay-820089159254-20260905`.
3. **Google Pixel 10a 128GB Fog, unlocked, new and sealed** — [eBay item 147450361998](https://www.ebay.co.uk/itm/147450361998). Sold 2 Aug 2026 at 12:18 BST. Displayed £305.42 including £10.42 Buyer Protection. UK private seller yoda791 in Manchester, 103 feedback, 100% positive. Best Offer option visible but no accepted-offer notice; caveat retained. TEST evidence `7ea66ace-992e-431d-a153-8fb3ffff9958`; LIVE `4f86b641-4b42-4acf-bcc0-a4662d46af77`. Stable key `mobile-new-sold-pixel10a-128gb-fog-ebay-147450361998-20260802`.

Prices are buyer-facing displayed totals, not seller proceeds or guaranteed TradeFlow buying offers.

## Reviewed but excluded
- Samsung Galaxy S26 FE 128GB item 206602195192 was ended by the seller because the item was no longer available; it was not a completed sale.
- iPhone 17e item 188866715159 was excluded because search capture showed £547.06 including £14.46 Buyer Protection, while the opened original page showed £550.10 including £17.50; original-page discrepancy must be reconciled before use.
- Google Pixel 10 Pro XL 256GB item 198326408668 was excluded because search capture showed £736.57 including £17.57 Buyer Protection while the opened page showed £740.26 including £21.26; original-page discrepancy remains unresolved.
- Google Pixel 10 256GB item 157437867418 was excluded: search result suggested a sale on 3 Oct, while original page now shows a multi-quantity out-of-stock listing last updated in March. The sale timing cannot be reconciled confidently.
- Google Pixel 10 Pro 256GB item 287449530690 explicitly says Best Offer accepted; exclude because the accepted amount is hidden. Item 267726861652 failed to open as a source page.
- Samsung Galaxy S25 Ultra 256GB item 406942110195 is currently active with 3 available and one sold, so not treated as a completed-sale capture.
- Additional searched candidates were not ingested where the source redirected to a generic product page, was still active, conflicted on price/fees, or did not confirm the exact condition/variant.
- No master products created/modified.

## Coverage
Prior verified snapshot at end of Batch 91 was LIVE 130 active phone masters / 76 with new evidence / 66 with used evidence / 267 active evidence rows, TEST 133 / 76 / 68 / 269. Batch 92 adds 3 active rows to each environment and 3 distinct masters with new evidence. Current expected totals after these insertions: LIVE 270 active phone evidence rows; TEST 272. Product-level coverage after concurrent work was not fully re-counted because the SQL aggregate call was blocked; re-check before quoting updated master coverage.

## Open controls
- Historic iPhone 15 Pink item 307244687330 price discrepancy remains open: stored £292 including £12 Buyer Protection vs fresh capture £289.92 including £9.92. Do not overwrite historic row.
- TEST/LIVE master-count discrepancy and global active duplicate-key audit remain open.
- Keep all master products active; LIVE has no dedicated discontinued field. Record lifecycle status in dated, source-linked notes only.
- Continue current UK new-price evidence first, then check official manufacturer range/status and focus second-hand completed sales where suitable.
