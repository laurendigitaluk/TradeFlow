# Project Memory — Mobile Phone Catalogue
Updated: 2026-10-23

## Current position
The phone catalogue is being expanded in TradeFlow using a controlled TEST → LIVE process. Validate product identity, exact storage variant, source URL, price type, observed date, availability, currency, and unique source key before promotion. Do not import unvalidated GearCashOut/Action Buyer UK evidence.

## Latest verified batch
See `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-01.md`.

- TEST: 100 Mobile Phones products, 21 linked evidence records.
- LIVE: Mobile Phones taxonomy now exists; this batch contains 5 products and 5 active UK new-price evidence records.
- Batch: Samsung Galaxy A37 5G 128/256 GB and Galaxy A57 5G 128/256/512 GB.
- Evidence is from official Samsung UK product pages; list prices were stored separately from code-based promotional prices.
- No used-market evidence was included in this batch.
- LIVE's missing phone category/branch/manufacturer structure was a genuine promotion blocker. Category and branch IDs differ between TEST and LIVE; never assume cross-environment IDs match. Map by natural keys (slug/name and manufacturer name).

## Operating rules
1. Add products and evidence to TEST first.
2. Evidence must link to the exact product/storage variant and have a meaningful source URL and stable unique key.
3. Distinguish UK new list prices, promotional prices, used asking prices, and completed/sold prices. Do not combine these as equivalent evidence.
4. For current new prices, prefer manufacturer or authorised UK retailer product pages; record availability conservatively.
5. Keep discontinued models in the catalogue for used valuation, but mark lifecycle and do not treat old launch prices as current new prices.
6. Promote each validated batch to LIVE rather than accumulating a large backlog; verify LIVE counts and links after every promotion.
7. Do not bulk-copy the 95 legacy TEST phone seeds without verifying them and their evidence first.
