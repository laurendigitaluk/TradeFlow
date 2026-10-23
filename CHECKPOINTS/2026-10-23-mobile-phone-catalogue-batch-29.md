# Mobile Phone Catalogue — Batch 29 Checkpoint
Date: 2026-10-23

## Scope
Added three UK eBay completed-sale evidence records to existing exact phone variants in TEST and LIVE.

| Variant | Displayed sold total | Condition / sale details | Source |
|---|---:|---|---|
| HONOR 600 5G 8GB/256GB Orange, unlocked UK model | £379.35 | New/sealed; sold 23 Aug 2026; seller in Southampton, UK; includes £14.35 Buyer Protection fee | https://www.ebay.co.uk/itm/147513305896 |
| Samsung Galaxy Z Flip8 12GB/256GB Pink, factory unlocked | £749.99 | Opened – never used; sold 16 Oct 2026; Sunderland UK business seller, 100% positive feedback; includes Buyer Protection, fee not shown | https://www.ebay.co.uk/itm/198710105189 |
| Apple iPhone 17e 256GB Black | £450.87 | Used; auction sold 23 Aug 2026 with four bids; seller in Longhope, UK; includes £15.28 Buyer Protection fee | https://www.ebay.co.uk/itm/188802102477 |

Stable source keys:
- `mobile-used-ebay-honor600-256gb-147513305896-20261023`
- `mobile-used-ebay-samsung-galaxy-zflip8-256gb-198710105189-20261023`
- `mobile-used-ebay-iphone17e-256gb-188802102477-20261023`

These are buyer-facing totals including Buyer Protection where stated, not seller proceeds or guaranteed buying offers. HONOR's item was sold in New/sealed condition through eBay, so it remains secondary-market sale evidence rather than manufacturer RRP.

## Verified current database snapshot
Counts use distinct active customer-visible product IDs, not joined evidence rows:
- TEST: 128 active visible variants; 137 evidence rows total, 132 active and 5 inactive; 64 active UK used completed-sale rows; zero visible variants missing active evidence.
- LIVE: 126 active visible variants; 132 evidence rows total, 130 active and 2 inactive; 62 active UK used completed-sale rows and 3 active UK used/listed rows; zero visible variants missing active evidence.
- LIVE active evidence integrity failures: 0.

These fresh counts supersede earlier batch snapshots; product visibility can change between checks, so always re-query before promotion.

## Next
Continue adding UK completed-sale records in larger batches for active variants without a sold comparable. Keep model/storage exact, seller UK location confirmed, and fees/Best Offer caveats explicit.
