# TradeFlow LIVE — 3D-printer UK Used evidence review 05

- Date: 14 November 2026
- Branch: `production` (LIVE)
- Supabase project: `gxsrajtqzdjvmceqcpgv`
- Candidate review: 25 active/customer-visible 3D-printer product/package gaps; two qualifying UK Used observations imported and read back.

## Imports

| Product / package | Price | Source / status | Evidence ID |
|---|---:|---|---|
| Bambu Lab P1S — AMS Combo | £210.00 | Gumtree UK active today; Middlesbrough, North Yorkshire; as good as new | `6c59ff0d-584a-41d4-b0b9-c6ebd945f753` |
| ELEGOO Saturn 3 — Standard Resin Printer | £160.00 | Gumtree UK listing; Margate, Kent; good condition; minor Z-axis crack disclosed | `0f6c6c19-e0fe-43f4-8e22-00f99823003e` |

## Source details and qualifications

- P1S AMS Combo: https://www.gumtree.com/p/printers-scanners/bambu-lab-p1s-3d-printer-ams-with-spares-and-filaments/1804880292 — seller reports great working order and use only a few times. Spare parts, new nozzles, tools, several filament rolls and silica gel desiccant are extras beyond standard AMS Combo contents; not separately valued. £210 asking price; offers enabled; not a completed sale.
- Saturn 3: https://www.gumtree.com/p/hobbies-collectibles/saturn-3-elegoo-resin-printer-/1801602052 — seller reports it works perfectly; minor crack at top of Z-axis said not to affect function. Power lead only; resin and tools not included. £160 asking price; posted 71 days before review.

## Held findings

- Bambu P1S Standard listing with about 1,162 hours and removed/clogged hotend returned HTTP 410.
- Bambu A1 listing with 28 hours and Flashforge Creator 5 listing with 131 hours returned HTTP 410.
- Other listing candidates lacked an exact active/customer-visible master product/package match or included non-standard bundles not mapped to master packages.
- Brand-new/unused listings were not substituted for UK Used evidence.

## LIVE coverage snapshot

Active + customer-visible 3D scope:
- 199 products
- 198 with UK New
- 31 with UK Used
- 168 UK New only
- 1 UK Used only
- 0 neither
- 168 missing UK Used

Snapshot may include parallel worker activity.

## Rules and change boundary

UK Used remains inspection/reference only and never affects automatic valuation; UK New remains the only automatic valuation evidence. UK GBP and UK sources only. Exact product/package matching; disclose condition, location, print hours, extras, missing accessories, asking-versus-sold status and caveats. No catalogue master rows, valuation logic, schema, RLS, RPCs, Edge Functions, TEST, LIVE Stripe or deployments changed.

## Structured memory

LIVE project-memory message: `cdd9e032-81f6-4dcf-bc09-2b6dbd3388ee`, thread `tradeflow-research`.
