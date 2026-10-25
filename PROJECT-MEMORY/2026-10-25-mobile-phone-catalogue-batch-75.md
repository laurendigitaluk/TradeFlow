# Project Memory — Mobile Phone Catalogue Batch 75
Date: 25 October 2026

Batch 75 added two UK eBay used/sold observations for Samsung Galaxy S25 Ultra 256GB to TEST and LIVE using exact active master matches. Exact URLs and stable keys were clear before insertion. TEST rows were inserted and read back before LIVE inserts; LIVE read-backs were also verified. No existing rows or product masters were changed.

- Titanium Black, boxed/great condition: eBay item 137643944477, sold 21 Aug 2026 09:37 BST, displayed buyer-facing total £572.95 including £17.95 Buyer Protection. Seller proceeds unconfirmed. TEST evidence 974e9083-f2e2-4d91-b8e4-a7d7cc3f21dd; LIVE evidence 6a720308-c47f-4dcb-8e6d-e7f5a39ce464. Stable key `mobile-used-sold-galaxys25ultra-256gb-titanium-black-ebay-137643944477-20260821`.
- Titanium White, factory unlocked/dual SIM, no charger: eBay item 168615919758, sold 16 Aug 2026 11:23 BST, displayed buyer-facing total £516.84 including £16.84 Buyer Protection. Seller proceeds unconfirmed. TEST evidence 54b6d3bd-53ff-4263-87b5-9eb4b583d4f0; LIVE evidence cca87524-34bf-4355-a4c1-d94f3e3b836a. Stable key `mobile-used-sold-galaxys25ultra-256gb-titanium-white-ebay-168615919758-20260816`.

Verified Mobile Phones category counts after Batch 75: TEST 244 active evidence / 150 active `uk_used` + sold; LIVE 242 / 148. The two-row difference persists. Global active duplicate-key aggregation is still outstanding.

Candidate safeguards: Pixel 10 Pro 256GB item 307091345876 was already active in both databases and was not duplicated. Pixel 10 Pro 128GB opened-never-used and Pixel 10 Pro Fold 256GB were skipped because no matching active master existed in both environments. Samsung S25 Ultra item 168204541224 was skipped due to inconsistent sold result versus relisted page price.

See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-75.md`. Continue TEST-first with exact master/URL/key preflight and read-back; do not create master products as part of evidence ingestion. Keep Buyer Protection and Best Offer caveats explicit.
