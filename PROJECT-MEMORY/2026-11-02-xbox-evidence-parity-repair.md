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
