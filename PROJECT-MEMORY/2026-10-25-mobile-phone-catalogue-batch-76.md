# Project Memory — Mobile Phone Catalogue Batch 76
Date: 25 October 2026

Batch 76 added two UK eBay used/sold observations for Samsung Galaxy S25 Ultra 256GB to TEST and LIVE using the existing active master. Exact URL/key preflight was clear. TEST inserts and read-backs preceded LIVE insertion/read-backs; no existing records were changed.

- Silver (SM-S938U1), eBay item 137804587290, sold 4 Oct 2026 at 14:25 BST. Current original listing page displays £570.15 including £17.90 Buyer Protection; an offer option was present, so accepted sale amount/proceeds unconfirmed. Seller in Glasgow, UK. Search index showed a different price; current page display recorded and discrepancy noted. TEST evidence 68dfb55c-a351-4227-a8a0-af3128bc8dd9; LIVE evidence 62b58127-e0e3-4427-a276-a04fc63f6590. Stable key `mobile-used-sold-galaxys25ultra-256gb-silverbar-ebay-137804587290-20261004`.
- Titanium Blue, eBay item 278429059814, sold 3 Oct 2026 at 13:00 BST. Current original listing page displays £594.85 including £18.09 Buyer Protection; seller proceeds unconfirmed. Unlocked, excellent condition/free postage, seller in Leicester, UK. Search index showed a different price; current page display recorded and discrepancy noted. TEST evidence 8a5b3a09-e29a-420c-8c00-5d19120383df; LIVE evidence 226598aa-9f2d-4db1-9dd9-f2dfba0429de. Stable key `mobile-used-sold-galaxys25ultra-256gb-titaniumblue-ebay-278429059814-20261003`.

Verified Mobile Phones category counts after Batch 76: TEST 246 active evidence / 152 active `uk_used` + sold; LIVE 244 / 150. Two-row difference persists. Global active duplicate-key aggregation remains outstanding.

Other candidate safeguards: item 800756844624 was already active in both environments; item 137433982809 was opened-never-used and not added as ordinary used; item 168204541224 had conflicting price context and was excluded. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

Continue TEST-first with exact master/URL/key preflight and read-back. Do not create master products as part of evidence ingestion. Keep Buyer Protection and Best Offer uncertainty explicit.

## Batch 76 follow-up — third observation
Added Samsung Galaxy S25 Ultra 256GB Titanium Silverblue, eBay item 227413483025, sold 4 July 2026 at 15:40 BST. The original listing page displays £589.15 including £18.27 Buyer Protection; Best Offer was enabled, so accepted sale amount and seller proceeds are unconfirmed. Seller located in Blackburn, UK. Search-index amount differed from the original page; the original page display was recorded and the discrepancy noted. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Verified counts after this addition: TEST 247 active phone evidence / 153 active uk_used+sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding.

## Additional Batch 76 observation
Samsung Galaxy S25 Ultra 256GB Titanium Silverblue, eBay item 227413483025, sold 4 July 2026 at 15:40 BST. Original listing page displays £589.15 including £18.27 Buyer Protection; Best Offer was enabled, so accepted sale amount/proceeds are unconfirmed. Seller located in Blackburn, UK. Search-index amount differed from original page; original-page value recorded and discrepancy noted. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Updated counts: TEST 247 active phone evidence / 153 active uk_used+sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding.
