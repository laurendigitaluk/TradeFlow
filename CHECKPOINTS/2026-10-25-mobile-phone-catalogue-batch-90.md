# Mobile Phone Catalogue Research — Batch 90
Date: 25 October 2026

## Scope
Research batch covering 20 mobile phone variants. Priority remained current UK new-price evidence, using eBay UK completed sales where the original item page showed a completed sale, exact model/storage, and new condition. Do not create master products during evidence ingestion.

## Added to TEST first, then LIVE
Three observations were inserted into `public.shared_market_evidence` after exact master and URL/stable-key preflight. TEST rows were read back before LIVE insertion; LIVE rows were then read back. No master products were created or modified.

1. **Samsung Galaxy S26 256GB, unlocked, new/sealed** — eBay item [227435267689](https://www.ebay.co.uk/itm/227435267689), sold 4 Aug 2026 at 10:35 BST, displayed £560 including Buyer Protection (fee not separately shown). UK business seller in Abertillery, 18,756 feedback, 100% positive. TEST evidence `86e2ab49-bb91-4605-851e-1293d1a3625c`; LIVE `ddc828fe-57ef-4ffc-a71a-837506665038`. Stable key: `mobile-new-sold-galaxys26-256gb-ebay-227435267689-20260804`.
2. **Apple iPhone 17 Pro Max 256GB Silver, new/sealed** — eBay item [820035575474](https://www.ebay.co.uk/itm/820035575474), sold 27 Aug 2026 at 16:35 BST, displayed £1,079 including Buyer Protection (fee not separately shown). UK business seller PFH UK in Boston, 1,096 feedback, 100% positive; listing states 12-month warranty. TEST evidence `a7882cd9-d48e-4863-8360-a99fe4b26442`; LIVE `4eb3c7f3-e4e1-4db2-a466-9380cdd1767d`. Stable key: `mobile-new-sold-iphone17promax-256gb-silver-ebay-820035575474-20260827`.
3. **Apple iPhone 17 256GB Black, unlocked, new/sealed** — eBay item [327314918719](https://www.ebay.co.uk/itm/327314918719), sold 19 Aug 2026 at 08:45 BST, displayed £678.33 including £18.24 Buyer Protection. UK private seller in Wotton-under-Edge, 478 feedback, 100% positive. The page showed a Best Offer option but no accepted-offer notice; retained with explicit caveat rather than treating the displayed amount as confirmed seller proceeds. TEST evidence `87e9746b-7456-4acc-8cb4-4cf8b5797163`; LIVE `e33c0b50-d579-481c-a361-4a2ac206927b`. Stable key: `mobile-new-sold-iphone17-256gb-black-ebay-327314918719-20260819`.

All recorded prices are buyer-facing displayed totals and must not be interpreted as seller proceeds or guaranteed TradeFlow buying offers.

## Candidates not ingested
- Samsung Galaxy S26 Ultra 256GB item 257698046241: search snippet and opened original page displayed different totals/fee breakdowns; excluded pending reconciliation.
- Samsung Galaxy S26 Ultra 512GB item 377337959960: search snippet and original page displayed different totals/fee breakdowns; excluded pending reconciliation.
- Apple iPhone 17 Pro 512GB item 298717513949: low seller feedback (39); another candidate, item 168558423665, showed conflicting price/fee captures. Neither ingested.
- Google Pixel 10 256GB item 157437867418: original page currently presents an out-of-stock listing rather than a clear historical sale-time capture; not ingested as a completed-sale observation.
- Apple iPhone 16 128GB item 377414850708 redirected to a generic product page; not ingested.
- Apple iPhone 17 256GB item 287552430016 excluded due low seller feedback (87.5% positive) despite completed-sale page.
- Other queried variants (Galaxy S25 128GB, Galaxy S25 Ultra 256GB, iPhone 16 256GB, iPhone 16 Plus 128GB, iPhone 16 Pro 256GB, iPhone 16e 128GB, iPhone 17 Pro 256GB, iPhone 17 Pro Max 512GB, Galaxy S25+ 256GB, Galaxy S25 256GB, Pixel 9 Pro 256GB and Pixel 8 128GB) were not added in this batch because this search pass did not yield a clean, exact-variant, non-duplicate original sold page suitable for ingestion. Continue research rather than infer no market evidence exists.

## Coverage snapshot after insertion
LIVE: 130 active Mobile Phones masters; 75 with active UK-new evidence; 66 with active UK-used evidence; 264 active evidence rows; 8 active eBay UK new-sold rows and 17 active eBay UK used-sold rows under the current source-name counting rule.
TEST: 133 active Mobile Phones masters; 75 with active UK-new evidence; 68 with active UK-used evidence; 266 active evidence rows; 8 active eBay UK new-sold rows and 17 active eBay UK used-sold rows under the current source-name counting rule.
Counts are point-in-time snapshots and can change as other catalogue agents work. The TEST/LIVE master-count discrepancy remains open.

## Outstanding issues
- Reconcile the historic iPhone 15 128GB Pink item 307244687330 discrepancy: historic row £292 including £12 Buyer Protection versus fresh capture £289.92 including £9.92. Do not overwrite the historic row.
- Global active duplicate-key audit remains open.
- TEST/LIVE master discrepancy remains open.
- Continue new-price research for active variants lacking adequate evidence; after current-new availability is ruled out and manufacturer lifecycle status is checked, prioritise UK second-hand completed sales.
- Do not deactivate master products or add an ad hoc discontinued field. LIVE has no dedicated discontinued field; use dated source-linked notes and keep masters active for valuation.
