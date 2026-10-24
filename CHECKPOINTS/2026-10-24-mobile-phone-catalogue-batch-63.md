# Mobile phone catalogue — Batch 63
Date: 24 October 2026

## Evidence added
Added one UK eBay completed-sale observation for Google Pixel 9 128GB with GrapheneOS:
- Listing: https://www.ebay.co.uk/itm/267700928563
- Sold: 15 July 2026
- Displayed price: £299.00; source result did not show a Buyer Protection amount, and seller net proceeds are not confirmed.
- Listing describes a de-Googled GrapheneOS device in cosmetic B condition, with minor casing marks and small screen scratches difficult to see when powered on. Keep this separate from ordinary stock-OS Pixel 9 comparisons.
- Evidence type: `uk_used`; condition: `Used`; availability: `sold`; currency: GBP; active: true.
- Stable key: `mobile-used-sold-pixel9-128gb-grapheneos-ebay-267700928563-20260715`.
- TEST master: `dcbdbf35-a1b7-468a-8e62-4a52668b2c79`; evidence row: `cf4d8cc8-c85f-49cb-805e-e93489c14d3d`.
- LIVE master: `fc040883-912e-4820-9f99-4aa616ddf7b5`; evidence row: `4d12bc86-52e6-45e2-b1d3-7a94694033b9`.
- Exact URL and stable-key preflight were empty in both environments. Insert results and subsequent stable-key read-back confirmed one active row in each.

## Current counts (refreshed after insertion)
- TEST: 227 active phone evidence; 133 active `uk_used` + `sold` rows.
- LIVE: 225 active phone evidence; 131 active `uk_used` + `sold` rows.
- The two-row environment difference persists. The `uk_used` + `sold` subtotal includes parts/repair evidence and is not working-only.
- Stable-key aggregate audit last found zero duplicate active non-null source-record keys in both environments. URL-level duplicates are not treated as global duplicates because generic catalogue pages can legitimately support multiple products.

## Follow-up
Continue researching UK completed sales, exact URL/key preflight, TEST-first, LIVE second, and read-after-write verification. Preserve custom-OS and condition caveats.
