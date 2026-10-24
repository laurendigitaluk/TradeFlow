# Mobile phone catalogue — Batch 56 (24 October 2026)

See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-56.md`.

- Resolved the previously uncertain LIVE status for iPhone 14 128GB eBay item 366661027705: active at £188.66 in both TEST and LIVE.
- Added and verified in both environments two Pixel 8 128GB UK eBay sales: item 267790609007 at £159.95 (Buyer Protection included; fee breakdown not captured) and item 188937928681 at £179.99 (Good cosmetic condition, no accessories).
- Two iPhone 16 128GB candidates were already active in both environments and were not duplicated.
- Post-batch counts: TEST 218 active phone evidence / 124 active UK used sold; LIVE 216 / 122. Duplicate active source-key groups: zero in both. The two-row environment difference remains.
- A multi-row write for additional candidates was blocked; those candidates are not claimed as inserted. Continue with global key/URL preflight, TEST-first insertion, and LIVE read-after-write verification. Keep condition caveats and buyer-facing Buyer Protection totals explicit.
