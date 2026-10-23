# Mobile Phone Catalogue Checkpoint — Batch 30
Date: 2026-10-23
Repository: laurendigitaluk/TradeFlow, branch main.
Process: verify exact variant in TEST, then apply same evidence to LIVE. LIVE is production; TEST is reference/staging.

## Evidence added to TEST and LIVE
1. **Apple iPhone 18 Pro 256GB** — £1,199, EE SIM-free, in stock, free standard delivery in 1–3 working days.
   - Source: https://ee.co.uk/products/iphone-18-pro-sim-free
   - Stable key: `mobile-new-iphone18pro-256gb-ee-simfree-20261023`
2. **Google Pixel 11 256GB / 12GB RAM** — £879, EE SIM-free, in stock, free standard delivery in 1–3 working days.
   - Source: https://ee.co.uk/products/google-pixel-11-sim-free
   - Stable key: `mobile-new-pixel11-256gb-ee-simfree-20261023`
   - EE's temporary tech-voucher promotion ends 31 October 2026. Evidence price is £879 before voucher value.
3. **Google Pixel 11 Pro 256GB / 12GB RAM** — £1,079, EE SIM-free, in stock, free standard delivery in 1–3 working days.
   - Source: https://ee.co.uk/products/google-pixel-11-pro-sim-free
   - Stable key: `mobile-new-pixel11pro-256gb-ee-simfree-20261023`
   - EE's temporary tech-voucher promotion ends 31 October 2026. Evidence price is £1,079 before voucher value.

These are retailer list prices, not completed-sale prices or buying offers.

## Research guardrail
Rechecked eBay listing https://www.ebay.co.uk/itm/257792354372 because its title claims OnePlus 15. Its item specifics identify OnePlus 10 Pro (Snapdragon 8 Gen 1, MPN 5011101954). Rejected as OnePlus 15 evidence.

OnePlus 15 256GB still has only a UK price reference from MyMobiles at £849, availability listed but not confirmed in checkout. Do not mark it in stock without direct confirmation. Source https://www.mymobiles.com/phones/oneplus/15-deals.

Xiaomi 17T 256GB (£549) and Xiaomi 17T Pro 512GB (£699) have official Xiaomi UK autumn-campaign evidence through 27 Oct 2026 or while stocks last. Recheck after expiry; do not treat campaign prices as evergreen RRP. Weaker duplicate rows are inactive audit-only evidence.

## Verified database snapshot after Batch 30
Distinct active customer-visible product variants:
- TEST: 128 variants; 140 evidence rows total; 135 active and 5 inactive.
- LIVE: 126 variants; 135 evidence rows total; 133 active and 2 inactive.
- LIVE active UK used completed-sale evidence: 62 rows.
- LIVE active UK used/listed evidence: 3 rows.
- LIVE visible variants missing active evidence: 0.
- LIVE active evidence integrity failures: 0.

## Next
Continue expanding evidence across exact UK phone variants in large validated batches. Keep UK new prices, promotional prices, used asking prices and completed-sale prices distinct. Promote to LIVE after each checked batch and verify counts. Recheck Xiaomi campaign after 27 October 2026 and EE Pixel voucher after 31 October 2026.
