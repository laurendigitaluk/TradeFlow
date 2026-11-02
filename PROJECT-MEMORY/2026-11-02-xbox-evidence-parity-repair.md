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
