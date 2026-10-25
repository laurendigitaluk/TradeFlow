# TradeFlow AI Operating Manual — Mobile Phone Catalogue Addendum
Updated: 25 October 2026

This addendum supplements `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`. The main AI operating manual is unusually large, so this batch note is maintained separately rather than risking a destructive rewrite of the full file.

## Batch 75 — 25 October 2026
Added two UK eBay completed-sale observations for the active Samsung Galaxy S25 Ultra 256GB master product in TEST and LIVE.

- **Titanium Black:** item 137643944477, sold 21 August 2026 at 09:37 BST. Displayed buyer-facing total £572.95 including £17.95 Buyer Protection; seller proceeds unconfirmed. TEST evidence `974e9083-f2e2-4d91-b8e4-a7d7cc3f21dd`; LIVE evidence `6a720308-c47f-4dcb-8e6d-e7f5a39ce464`.
- **Titanium White:** item 168615919758, sold 16 August 2026 at 11:23 BST. Displayed buyer-facing total £516.84 including £16.84 Buyer Protection; no charger included; seller proceeds unconfirmed. TEST evidence `54b6d3bd-53ff-4263-87b5-9eb4b583d4f0`; LIVE evidence `cca87524-34bf-4355-a4c1-d94f3e3b836a`.

TEST URL/key preflight and insertion/read-back completed before LIVE insertion/read-back. No existing rows were modified and no master product was created.

Verified Mobile Phones category counts: TEST 244 active evidence / 150 active `uk_used` + sold; LIVE 242 / 148. The two-row difference persists. Global active duplicate-key aggregation remains outstanding.

Continue the controlled workflow: exact active master match in both environments; exact source URL and stable-key preflight; insert and read back TEST; only then insert and read back LIVE. Keep Buyer Protection and Best Offer caveats explicit. Do not create a master product as part of evidence ingestion.

Full checkpoint: `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-75.md`.

## Batch 76 — 25 October 2026
Added two UK eBay completed-sale observations for Samsung Galaxy S25 Ultra 256GB to TEST and LIVE. Item 137804587290 (Silver SM-S938U1) sold 4 Oct 2026; current original listing page displayed £570.15 including £17.90 Buyer Protection, with Best Offer context and accepted proceeds unconfirmed. Item 278429059814 (Titanium Blue, unlocked/excellent condition) sold 3 Oct 2026; current original listing page displayed £594.85 including £18.09 Buyer Protection. Original page prices differed from search-index snippets; the currently viewable original-page amounts were recorded and the discrepancy documented. TEST insert/read-back preceded LIVE insertion/read-back. Counts: TEST 246 active phone evidence / 152 active uk_used+sold; LIVE 244 / 150. Global active duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

## Batch 76 follow-up — third observation
Added Galaxy S25 Ultra 256GB Titanium Silverblue, eBay item 227413483025, sold 4 Jul 2026 at 15:40 BST. Original listing page displayed £589.15 including £18.27 Buyer Protection; Best Offer enabled, accepted price/proceeds unconfirmed. Seller in Blackburn, UK. Original page differed from search index; page display recorded with discrepancy note. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Counts now TEST 247 active phone evidence / 153 used-sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

## Batch 77 — 25 October 2026
Added two Google Pixel 10 Pro 256GB Obsidian UK eBay new/sealed completed-sale observations. Item 117212924862 sold 5 Jul 2026, displayed £691.83 including £16.83 Buyer Protection. Item 236875676375 sold 25 Jun 2026, displayed £605.42 including £15.42 Buyer Protection. Seller proceeds not independently confirmed. Exact active master and URL/key preflight clear; TEST insert/read-back preceded LIVE insert/read-back. Counts: TEST 249 active phone evidence / 153 uk_used+sold / 2 uk_new+sold; LIVE 247 / 151 / 2. Global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-77.md`.

## Batch 78 — 25 October 2026
Added Samsung Galaxy S25 Ultra 256GB Black used-sale evidence from eBay item 128026023099. Sold 17 Aug 2026 at 08:44 BST; displayed £399.99 with Buyer Protection included. Listing title disclosed chipped corner and visible scratches; seller proceeds not confirmed. Exact active master and URL/key preflight clear; TEST insert/read-back preceded LIVE insert/read-back. Counts: TEST 250 active phone evidence / 154 uk_used+sold / 2 uk_new+sold; LIVE 248 / 152 / 2. Two-row TEST/LIVE difference and global duplicate-key aggregation remain outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-78.md`.
