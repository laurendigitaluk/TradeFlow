# Mobile Phone Catalogue — Batch 92 Project Memory
Date: 25 October 2026

Batch 92 reviewed 20 exact phone variants and added three UK eBay new-condition completed-sale observations to existing masters. TEST insertion and read-back preceded LIVE insertion and read-back. The database read-backs confirmed the rows are active and match the recorded source URLs, prices, availability and stable keys. No master products, valuation logic, or schema were changed.

1. Apple iPhone 16 Pro 256GB Natural Titanium, item https://www.ebay.co.uk/itm/356312645257, sold 27 Aug 2026 at 20:22 BST, displayed £979.99; Buyer Protection indicated, fee not separately shown. TEST evidence 4eb9eed4-edb6-45cb-a803-34af17c2910a; LIVE evidence 7ac5d442-d783-42cf-a4c2-d4065cce0780. Stable key `mobile-new-sold-iphone16pro-256gb-natural-tesco-ebay-356312645257-20260827`.
2. Apple iPhone 17e 256GB Black, item https://www.ebay.co.uk/itm/820089159254, sold 5 Sep 2026 at 16:40 BST, displayed £503.75 including £13.75 Buyer Protection; Best Offer option present but no accepted-offer notice. TEST evidence bf57b742-09cc-4164-9bb8-0761e112e7e1; LIVE evidence fda59deb-e2a6-4c19-9414-811619526b51. Stable key `mobile-new-sold-iphone17e-256gb-black-ebay-820089159254-20260905`.
3. Google Pixel 10a 128GB Fog, item https://www.ebay.co.uk/itm/147450361998, sold 2 Aug 2026 at 12:18 BST, displayed £305.42 including £10.42 Buyer Protection; Best Offer option present but no accepted-offer notice. TEST evidence 7ea66ace-992e-431d-a153-8fb3ffff9958; LIVE evidence 4f86b641-4b42-4acf-bcc0-a4662d46af77. Stable key `mobile-new-sold-pixel10a-128gb-fog-ebay-147450361998-20260802`.

Buyer Protection-inclusive amounts are buyer-facing totals, not seller proceeds or guaranteed TradeFlow offers. Keep all documented exclusions and source-price discrepancies. The earlier manual/memory statements that Batch 92 had zero inserts were inaccurate and are superseded by the checkpoint and live database verification.

## Controls still open
- TEST/LIVE master-count and evidence-count differences.
- Global active duplicate-key audit.
- Historic iPhone 15 Pink item 307244687330 discrepancy: stored £292 including £12 Buyer Protection versus fresh capture £289.92 including £9.92. Do not overwrite the historic observation.
- Continue checking exact master, source URL and stable key in both environments before any insertion. Never create master products during evidence research.
