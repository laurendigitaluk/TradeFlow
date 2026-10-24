# Mobile Phone Catalogue — Batch 41 — 24 October 2026

Three completed UK eBay sale observations were added TEST-first, promoted to LIVE, and read-back verified:
- Galaxy S24 128GB Marble Grey, unlocked, dual SIM: £249.99; sold 17 Sep 2026; https://www.ebay.co.uk/itm/800671014611.
- Pixel 9 128GB Porcelain, unlocked: £315.67 including £10.67 Buyer Protection; Best Offer accepted; sold 5 Oct 2026; https://www.ebay.co.uk/itm/128115577878.
- iPhone 16 128GB Ultramarine: £381.75 including £11.75 Buyer Protection; Best Offer accepted; sold 16 Sep 2026; https://www.ebay.co.uk/itm/318875321713.

Keys: `mobile-used-sold-galaxy-s24-128gb-ebay-800671014611-20260917`, `mobile-used-sold-pixel9-128gb-ebay-128115577878-20261005`, `mobile-used-sold-iphone16-128gb-ebay-318875321713-20260916`.

Post-batch counts: TEST 130 active visible variants, 173 active phone evidence rows, 79 active UK used sold rows. LIVE 128 active visible variants, 171 active phone evidence rows, 77 active UK used sold rows. Both: zero visible active variants missing evidence, zero phone-scoped integrity failures, zero duplicate active keys. Whole-table scan also surfaced unrelated overseas USD evidence (TEST 1, LIVE 2); not changed.

Keep Buyer Protection fees distinct from seller proceeds, note Best Offer caveats, and preserve historical evidence if current listing totals change. Continue TEST-first then prompt LIVE promotion after validation. Checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-41.md`.