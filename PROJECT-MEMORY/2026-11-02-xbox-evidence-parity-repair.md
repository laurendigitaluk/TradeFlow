# TradeFlow Xbox Evidence Parity Repair — 2 November 2026

## Environment
- LIVE branch: `production`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- TEST branch: `cloudflare-test`; TEST Supabase: `nnsshnfkjcflucjrftzi`.
- Retired TEST project `twfbmjwwqzxdxvclxbun` remains prohibited.

## Verified repair


## Xbox One X 1TB evidence parity repair — 2 November 2026

- TEST source key `ebayuk-178294853613-xboxonex-1tb-20260708` was confirmed active at £57.02 GBP (Used, sold), TEST product `4b12312f-59e6-4d56-bf4b-c4fab935a9fa`.
- LIVE had no matching key before the repair. The row was added through Supabase `apply_migration`, the established privileged migration route. No RLS or table grants were changed.
- LIVE read-after-write confirmed active ID `e3498deb-5606-4965-80ab-d9d5951467b3`, product `ce5e59d6-5ff8-4bd3-983f-63d1bf4b8e3a`, price £57.02 GBP, Used, eBay UK, sold, observed 2026-07-08 22:08 UTC, URL https://www.ebay.co.uk/itm/178294853613.
- Displayed total £59.50 included £2.48 Buyer Protection fee; stored item price excludes the fee.
- Data-only shared evidence repair. No app code, valuation logic, tenant/customer/payment data, or Worker deployment changed.

## Import procedure finding
Previous successful evidence population used privileged Supabase database migrations. Direct `execute_sql` INSERT attempts can be blocked by the connector safety layer; that is not proof of a database/RLS failure. Continue to use the established migration route for trusted shared-evidence imports. Do not weaken RLS or grants and do not create a new public ingestion function for this issue.


## Xbox One X 1TB evidence batch — 2 November 2026

- Added TEST-first and mirrored to LIVE two UK used completed sales: item 397946718089 at £70.99 underlying price (sold 2 Aug 2026; £73.94 display included £2.95 Buyer Protection fee) and item 178527813316 at £63.83 underlying price (sold 5 Oct 2026; £66.54 display included £2.71 fee).
- Source keys: `ebayuk-397946718089-xboxonex-1tb-20260802`; `ebayuk-178527813316-xboxonex-1tb-20261005`.
- TEST evidence IDs: `2c0dd7c3-6873-49df-a78c-37400bff6666`; `f753badd-83ec-4ed3-8b24-31386dcbfc4c`. LIVE IDs: `ff030633-5649-435e-a3f9-35aa8a3088e5`; `d76f6d1d-19f6-473e-be56-62f3bc6787f3`.
- Both rows active and read back in both environments. Each environment now has five active Xbox One X 1TB evidence rows.
- Existing 13 Sep fee-inclusive £59.50 and 16 Sep £134.92 rows remain unchanged for separate audit.
- A migration attempt using `ON CONFLICT(source_record_key)` failed because there is no matching unique constraint; no data was written by that attempt. Successful insertion used `WHERE NOT EXISTS`.
- No app code, valuation logic, RLS/grants, tenant/customer/payment data or Worker deployments changed.


## Xbox One X evidence quality corrections — 2 November 2026

- eBay item 168682015736: £59.50 display included £2.48 Buyer Protection fee. Corrected stored price to £57.02 GBP in TEST and LIVE; valid used 1TB black console-only sale, no controller; key `ebayuk-168682015736-xboxonex-1tb-20260913`.
- eBay item 336746788067: bundle includes Elite controller, free stand, PUBG, other games and play/charge kit. Retired from standard-console evidence (`is_active=false`) in both TEST and LIVE, preserving row; key `ebayuk-336746788067-xboxonex-1tb-20260916`.
- Read-after-write confirms both environments match. Four active standard-console rows remain from five Xbox One X 1TB evidence rows in each environment. No valuation logic, RLS/grants, application code or Worker deployment changed.


## Xbox 360 500GB fee correction and parity audit — 2 November 2026

- eBay UK item 147564021425 sold as a used, fully working black Xbox 360 E 500GB console. The displayed £64.46 included a £2.64 Buyer Protection fee; corrected the comparable item price to £61.82 GBP.
- Updated the existing evidence row in TEST and LIVE only when its source key, environment-specific master product ID, active status and old £64.46 value matched. TEST evidence ID: 6146fc0b-8f8c-4422-a153-070f896fe5cc; LIVE evidence ID: b68e7dbd-c3ac-48ac-827b-c85c597c1726. Both read-after-write checks confirm £61.82, active=true, with notes recording the excluded fee.
- Full Xbox catalogue readback shows matching TEST/LIVE evidence content for the 13 mapped variants. Current active counts: Xbox 360 4GB 2; 250GB 2; 500GB 1; Xbox One 500GB 2; 1TB 2; Xbox One S 500GB 2; 1TB 2; All-Digital 1TB 2; Xbox One X 1TB 4; Xbox Series S 512GB 3; 1TB Carbon Black 2; Xbox Series X Disc 1TB 2; Xbox Series X Digital 1TB 3. Total 27 active rows per environment. Retired historical rows remain retained and inactive.
- No new Xbox 360 500GB comp was found: the other surfaced 500GB sold candidates were bundles or special editions. No new evidence row was inserted.
- No application code, valuation logic, tenant/customer/payment data, RLS/grants or Worker deployment changed. This was a shared market-evidence price correction only.


## Xbox One S All-Digital evidence quality update — 2 November 2026

- Retired eBay item 278283038276 from active standard used-price evidence in TEST and LIVE. eBay confirms Best Offer accepted, but the accepted transaction price is not disclosed; displayed £41.92 (including £1.92 Buyer Protection fee) is not a verified sale price. Historical row retained inactive.
- Added verified UK used sale eBay item 178548159734: Xbox One S All-Digital Edition, white, MPN 1681, 1TB, console only, sold 5 October 2026. Displayed £36.75 included £1.75 Buyer Protection fee; stored item price £35.00 GBP. Active row read back in TEST (evidence ID cb1995e7-9511-462b-be20-cfb10585bd2d) and LIVE (542ed2ea-409e-4c74-84b7-1d23819040cf), each mapped to its own product UUID.
- No valuation logic, tenant/customer/payment data, RLS/grants, app code or Worker deployment changed. Shared market evidence only.


## Xbox Series S 512GB evidence expansion and provisional-record retirement — 2 November 2026

- Added four verified UK used completed sales to the Xbox Series S 512GB standard-console product in TEST and mirrored to LIVE using each environment's own product UUID. eBay item 147650120878 sold 25 Oct 2026, displayed £258.21 less £8.89 Buyer Protection fee = stored £249.32; item 327383217934 sold 10 Oct, displayed £238.25 less £8.25 = £230.00; item 137818359559 sold 13 Oct (auction, includes wireless controller), displayed £213.75 less £7.46 = £206.29; item 206610408847 sold 8 Oct, displayed £227.92 less £7.92 = £220.00. All four have explicit 512GB item/title confirmation, UK used condition and sold status. Source keys respectively: ebayuk-147650120878-xboxseriess-512gb-20261025; ebayuk-327383217934-xboxseriess-512gb-20261010; ebayuk-137818359559-xboxseriess-512gb-20261013; ebayuk-206610408847-xboxseriess-512gb-20261008.
- Retired item 227560758629 from active 512GB evidence in both environments. Its sold listing identifies Xbox Series S but does not specify storage capacity in the title or item specifics; retaining it as a 512GB benchmark would be an unsupported assumption. Historical rows retained inactive. TEST evidence ID fef1b21b-9aed-4aef-9456-e82cdcfad080; LIVE ID 9b698812-b6ae-4b92-86a2-afb80ab0350c.
- Read-after-write verified all four new active rows in both environments, and verified the provisional row inactive in both. No tenant/customer/transaction/Stripe data, valuation rules, application code, RLS/grants or Worker deployments changed.
