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

## Batch 79 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB used-sale evidence from eBay item 227413880546. Sold 8 Jul 2026 at 19:00 BST; buyer-facing total £507.44 incl £13.81 Buyer Protection; no charger included. TEST evidence 753183e6-5091-4186-90ca-a85e3c188488; LIVE evidence 53d8d266-7ce4-40d4-ab8a-7be66131a644. Counts TEST 251/155 used-sold/2 new-sold; LIVE 249/153/2. Two-row difference and global duplicate-key aggregation remain outstanding.

Critical source audit flag: Batch 78 item 128026023099 is recorded as £399.99 but a later search result now shows £479.99 incl Buyer Protection. Preserve history; investigate potential relisting/current price drift or capture discrepancy before correction. Pixel 10 Pro Fold 256GB candidates were deferred because no active exact master exists in either environment; do not create masters during evidence ingestion.

## Batch 80 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB Moonstone used-sale evidence, eBay item 278176799541. Sold 18 Jul 2026 at 17:50 BST; search result £620 incl Buyer Protection (fee amount not displayed), used, no charger included. Best Offer option appeared but no explicit accepted-offer notice; price uncertainty recorded. TEST evidence abe2acc1-68f1-4a92-a471-30999fdf7710; LIVE evidence 2de6f8ea-8266-4950-a824-0ca342999cb6. Counts TEST 252/156 used-sold/2 new-sold; LIVE 250/154/2. Two-row difference and global duplicate-key audit remain outstanding. Batch 78 source-price discrepancy remains unresolved. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-80.md`.

## Batch 81 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB Obsidian used-sale evidence from eBay item 257522963688. Sold 20 Jul 2026 at 15:55 BST; original item page £578.85 incl £17.77 Buyer Protection; search index £576.01 incl £14.93. Original page used as source-of-record capture and discrepancy documented. TEST evidence 743ca969-f948-4f4a-b7eb-345c4ba8fb4a; LIVE evidence cb456f2b-635b-44e2-882f-fb7a1623ea1c. Counts TEST 253/157 used-sold/2 new-sold; LIVE 251/155/2. Two-row difference and global duplicate-key audit remain outstanding; Batch 78 source discrepancy also remains pending.


## Batch 82 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB Porcelain/white “Opened – never used” completed-sale evidence from eBay item 178468385751. Sold 11 Sep 2026 at 21:06 BST. Original page displayed £649.14 including £19.14 Buyer Protection; search index displayed £646.08 including £16.08. Original-page capture retained with discrepancy documented. Best Offer option existed, but no accepted-offer notice was visible in the captured page; seller proceeds unconfirmed. TEST evidence 0bc38469-6a22-4613-8554-0608991d0456; LIVE evidence 5594202c-993b-45fd-988a-98fdeb4beff6. Counts TEST 254/158 used-sold/2 new-sold; LIVE 252/156/2. The two-row difference and global active duplicate-key audit remain outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-82.md`.


## Batch 83 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB Black, condition New, from eBay item 178516971817. Sold 22 Sep 2026 at 20:43 BST. Original eBay page displayed £656.73 including £16.26 Buyer Protection; seller located in Luton, UK. No Best Offer option or accepted-offer notice appeared on captured page; seller proceeds unconfirmed. TEST evidence 4e0f3332-7bc3-467a-9dc6-18a2845da52a; LIVE evidence a32bb8b5-0b1f-45da-be8d-b8c48571a242. Counts TEST 255/158 used-sold/3 new-sold; LIVE 253/156/3. The two-row difference and global active duplicate-key audit remain outstanding. Source-price audit flags from Batches 78, 81 and 82 remain open. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-83.md`.


## Batch 84 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB Obsidian, condition New, from eBay item 278210429467. Sold 24 Jul 2026 at 14:36 BST. Listing displayed £674.99 and indicated two sold; no separate Buyer Protection fee or Best Offer option appeared. Factory unlocked, 2-year manufacturer warranty, no charger included; seller is a London UK business. Seller proceeds unconfirmed. TEST evidence 2cdf6b7f-fd39-4553-953f-812c44ccef5e; LIVE evidence 47292b1b-a783-47c1-bfdb-d6ecd59bd2e1. Counts TEST 256/158 used-sold/4 new-sold; LIVE 254/156/4. The two-row difference and global active duplicate-key audit remain outstanding. Source-price audit flags from Batches 78, 81 and 82 remain open. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-84.md`.


## Batch 85 — 25 October 2026
Added Google Pixel 10 Pro XL 256GB Green, condition Used, from eBay item 178236367409. Sold 29 Jun 2026 at 16:58 BST. Listing displayed £589.99 with postage separately shown at £9.99; no separate Buyer Protection fee or Best Offer accepted notice appeared. UK business seller in Tyne and Wear; seller proceeds unconfirmed. TEST evidence d46b4081-09f0-4562-acf3-5b18d9a7ded3; LIVE evidence 9fe9a33e-9ab0-41df-bbc6-08c25d1607e6. Counts TEST 257/159 used-sold/4 new-sold; LIVE 255/157/4. The two-row difference and global active duplicate-key audit remain outstanding. Source-price audit flags from Batches 78, 81 and 82 remain open. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-85.md`.


## Batch 86 — 25 October 2026
Added Samsung Galaxy S25 256GB Silver, New/sealed, from eBay item 286331524320. Sold 15 Aug 2026 at 15:32 BST. Original page displayed £629 including Buyer Protection; separate fee amount not shown. No charger included; listing showed out of stock / 4 sold. UK business seller in Warminster, Wiltshire; seller proceeds unconfirmed. TEST evidence 861bb4af-4259-44be-9651-e73e4c69c898; LIVE evidence c04445ad-bbd0-4587-a055-371898e2b199. LIVE coverage 130 active products / 70 with new / 66 with used / 60 missing new / 64 missing used / 0 missing both. TEST coverage 134 products / 133 active / 70 with new / 68 with used / 64 missing new / 66 missing used / 2 missing both. The TEST/LIVE master discrepancy, global duplicate-key audit and historic source-price audit remain outstanding. LIVE has no dedicated discontinued field; note-text search does not establish authoritative status. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-86.md`.


## Batch 87 — 25 October 2026
Added two UK eBay new-condition completed-sale observations to existing masters in TEST and LIVE. iPhone 17 Pro 256GB Orange, item 820214209970, displayed £890 including Buyer Protection; TEST evidence 0163611d-87fc-43fc-be59-da26c924edcb, LIVE b2db7455-c13d-4cf7-ba58-349d86575333. iPhone 17 Pro Max 512GB Orange, item 407282798006, displayed £1,006.52 including £26.52 Buyer Protection; TEST evidence 29465532-c8b2-4cf6-b225-c561a2286ef7, LIVE afd58902-207a-48ba-9e46-81f5dc858042. Neither page showed a Best Offer acceptance notice. These are buyer-facing totals, not seller proceeds. TEST-first insertion and read-back preceded LIVE; no master products created.

Coverage: LIVE 130 active products / 72 with new / 66 with used / 0 missing both / 258 active evidence rows / 7 new-sold / 157 used-sold. TEST 133 active products / 72 with new / 68 with used / 1 missing both / 260 active evidence rows / 7 new-sold / 159 used-sold. Master discrepancy, global duplicate-key audit and historic source-price audit remain open.

## Lifecycle decision rule
Continue seeking new-price evidence for every variant. When no new evidence is found, verify discontinued status from official manufacturer/current-range sources; absence of marketplace listings alone is not enough. The LIVE master table has no dedicated discontinued field, so document the evidence source/date in notes and keep the master active for second-hand valuation. Once discontinuation is verified, prioritise UK second-hand completed-sale evidence and do not treat historical launch pricing as current new pricing. Do not alter schema or deactivate masters as an ad hoc ingestion step.


## Batch 88 — 25 October 2026: lifecycle review and used evidence
Lifecycle-review notes were added to active variants without active UK new-price evidence in Apple iPhone 13/14/15, Google Pixel 8/9 and Samsung Galaxy S22/S23/S24 families, based on official/current UK line-up pages. This confirms current retail-line-up status or previous-generation status, not manufacturing cessation. Keep masters active; no schema change. Once no current new evidence is available and lifecycle status is verified, prioritise UK second-hand completed-sale evidence.
Added iPhone 15 128GB Pink used/sold eBay item 307244687330, sold 23 Oct 2026 at 11:07 BST. Displayed £292 including £12 Buyer Protection; Best Offer option shown, no explicit accepted notice. TEST evidence 49c7213e-c63b-43a8-99d7-aa14d371983e; LIVE ed16e210-e9fb-416b-b7c0-b450d4c36c1a; stable key `mobile-used-sold-iphone15-128gb-pink-ebay-307244687330-20261023`. LIVE coverage 130 active products / 72 new / 66 used / 0 missing both / 259 active rows / 158 used-sold; TEST 133 / 72 / 68 / 1 missing both / 261 active rows / 160 used-sold. Master discrepancy, duplicate-key audit and historic source-price audit remain open. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-88.md`.


## Batch 89 — 25 October 2026
Added two UK eBay new/sealed completed-sale observations for iPhone 16 Pro Max 256GB. Black Titanium item 176644847651 displayed £999, sold 24 Jul 2026; TEST evidence 946c5046-d88a-43fa-a347-a3ac0112ceca, LIVE 30a3ea72-3b36-4f2f-a6c9-10e5b3a65404. Natural Titanium item 256779530734 displayed £1,149, sold 10 Jul 2026; TEST evidence e11f823f-7b8a-4f0b-a5c4-f56255e0b91d, LIVE 08b4be71-0a8c-410a-b7d7-125acea2ee31. Both listings identify 256GB and new/sealed condition. Fee breakdowns were not shown separately; displayed prices are not seller proceeds. TEST-first then LIVE, URL/key preflight clear, no master products created. Coverage LIVE 130/73 new/66 used/0 missing both/261 rows/9 new-sold/158 used-sold; TEST 133/73/68/1 missing both/263 rows/9 new-sold/160 used-sold. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-89.md`.


## Batch 90 — 25 October 2026
Researched 20 phone variants. Added Galaxy S26 256GB new/sealed sale item 227435267689 (£560 incl. Buyer Protection; TEST 86e2ab49-bb91-4605-851e-1293d1a3625c; LIVE ddc828fe-57ef-4ffc-a71a-837506665038), iPhone 17 Pro Max 256GB Silver new/sealed item 820035575474 (£1,079 incl. Buyer Protection; TEST a7882cd9-d48e-4863-8360-a99fe4b26442; LIVE 4eb3c7f3-e4e1-4db2-a466-9380cdd1767d), and iPhone 17 256GB Black new/sealed item 327314918719 (£678.33 incl. £18.24 Buyer Protection; TEST 87e9746b-7456-4acc-8cb4-4cf8b5797163; LIVE e33c0b50-d579-481c-a361-4a2ac206927b). For the iPhone 17 listing, a Best Offer option was shown without an accepted-offer notice; preserve the caveat. Displayed totals are buyer-facing, not seller proceeds. No masters created/modified. Candidate exclusions and source notes: `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-90.md`. Coverage snapshot LIVE 130/75 new/66 used/264 active rows; TEST 133/75/68/266. iPhone 15 Pink item 307244687330 discrepancy (£292 incl. £12 historic vs £289.92 incl. £9.92 fresh capture) remains open; do not overwrite. TEST/LIVE master-count mismatch and global duplicate-key audit remain open.

## Batch 91 — 25 October 2026
Researched 20 mobile variants and added three new/sealed completed-sale observations: Galaxy S26 Ultra 256GB Black item 227316346801 (£799 displayed, Buyer Protection indicated but fee not separately shown; TEST 50175068-0a95-473c-87ba-025467f723b9; LIVE c7e79f31-5cef-494b-9d1d-ccc52ebaedd4); iPhone 17 Pro Max 512GB Silver item 128022793235 (£1,047.87 including £22.67 Buyer Protection; TEST 9a84dae0-855f-40d0-8e8b-9257ed1296dd; LIVE 038a3bb9-f983-4230-8ae1-5b8b98d22358); iPhone 17 Pro 256GB Cosmic Orange item 237066171400 (£949 displayed, Buyer Protection indicated but fee not separately shown; TEST 1cecc234-1cb8-4fab-8cb0-2370245f0d68; LIVE dc12f565-72ec-48b3-8834-816d1b98082a). Prices are buyer-facing totals, not seller proceeds. No master products created/modified. Exclusions and verification details: `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-91.md`. Coverage snapshot LIVE 130/76 new/66 used/267 active rows; TEST 133/76/68/269. Historic iPhone 15 Pink discrepancy, TEST/LIVE master-count mismatch, and duplicate-key audit remain open.