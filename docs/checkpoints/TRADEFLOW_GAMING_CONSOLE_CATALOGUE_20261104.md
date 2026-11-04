# TradeFlow gaming console catalogue checkpoint — 4 November 2026

## Scope
Continued Sega hardware coverage. Added four distinct models to the gaming master catalogue and independently inserted matching UK used-market evidence in TEST and LIVE. No IDs were copied between environments.

## Research evidence
- Sega Mega Drive Mini: £59.99, eBay UK item 168787663741. Listing describes working console, two controllers and built-in games. https://www.ebay.co.uk/itm/168787663741
- Sega Mega Drive Mini 2: £207.25, eBay UK item 137442379300. Listing condition opened-never-used, with two controllers. https://www.ebay.co.uk/itm/137442379300
- Sega Genesis Nomad: £432.58, eBay UK item 147647456905. Distinct Sega Genesis cartridge-compatible handheld, not a Game Gear variant. https://www.ebay.co.uk/itm/147647456905
- Sega Multi-Mega: £839.25, eBay UK item 318173017652. Seller describes tested and working combined Mega Drive/Mega-CD hardware. https://www.ebay.co.uk/itm/318173017652

All four are UK eBay asking prices, not completed-sale prices. Evidence type is `uk_used`, currency GBP, sales channel Marketplace, availability listed. These prices are reference evidence only and do not alter automated valuation logic.

## TEST records
| Model | Product ID | Evidence ID |
|---|---|---|
| Sega Mega Drive Mini | 7ec390dd-a038-4003-9f42-4211c9ccbc18 | 26e6e274-e642-431b-b0e2-8a97d5251164 |
| Sega Mega Drive Mini 2 | f085602d-17a9-4fc8-b642-83a142f5129b | 2fc9b0c1-89a5-4fb0-9256-41d821f84ef1 |
| Sega Genesis Nomad | d5f27b54-32c9-43a3-8654-cd86923fe4a2 | ed0a8740-09a5-49a3-8654-cd86923fe4a2 |
| Sega Multi-Mega | df324bbb-4786-4412-b451-6c4af7c35af1 | 131a0959-3df6-44a8-b537-f49857d92f0c |

## LIVE records
| Model | Product ID | Evidence ID |
|---|---|---|
| Sega Mega Drive Mini | f9362cb3-6af7-48f5-a34e-4d8950c201de | b0c8a9a9-9b08-439a-8511-45d2cc65a53f |
| Sega Mega Drive Mini 2 | e6ec4039-b8aa-4f12-8efc-b954ac27805b | 47f2cdb6-bce1-47fa-b9bf-c5eff74ecff6 |
| Sega Genesis Nomad | c905d7e6-17dd-4e90-a3bc-57bf59f09497 | 98cb4304-9b31-4e90-a3bc-57bf59f09497 |
| Sega Multi-Mega | ac613d4f-453b-4a65-8f60-0966d3b81ee7 | afb57889-5e2b-4478-abdf-8e289a682806 |

## Verification
TEST and LIVE independently verified:
- 139 active gaming products
- 131 active customer-visible gaming products
- 215 active gaming evidence rows
- 59 `uk_new` and 156 `uk_used`
- 0 malformed active evidence rows (URL, source key, positive price, GBP currency and availability checks)

## Operational notes
- TEST and LIVE retain independent category, branch, manufacturer, product and evidence UUIDs.
- Product rows were created first; evidence rows were inserted in a separate SQL statement. The initial combined data-modifying CTE returned no evidence because a sibling base-table scan cannot see newly inserted rows within the same PostgreSQL statement snapshot. The separate evidence inserts succeeded in both projects and were verified in aggregate counts.
- No customer, tenant, transaction, payment, Stripe, subscription or domain data was touched.
- No valuation logic, application code or Worker deployment changed.
- Next research candidates: Sega CDX regional naming is covered by Multi-Mega rather than a duplicate; assess WonderMega variants and remaining historical Sega hardware, validating model identity and UK evidence before adding.


## Further Sega historical systems — same session
Added three more distinct Sega systems to both environments, each with a UK eBay GBP used-market evidence record:
- Sega SG-1000 — £449.00, item 168355445875, London listing, boxed and described as complete/working. TEST product 4812bf9a-c2e7-4816-b1c8-b7476c299347, evidence 9150ba6d-37ed-41c2-b702-465fb4b59bbf. LIVE product a3a44c72-5b00-4376-8f4c-d9eb7e9b44ec, evidence 330d3837-300d-41d4-9f24-1a3c2ec34d15. https://www.ebay.co.uk/itm/168355445875
- Sega Mark III — £173.80, item 318928337003. Seller location Japan; listing is on eBay UK and price displayed in GBP, but international delivery/import terms need checking. TEST product f6365657-eab9-4003-b45a-c78aa940b8eb, evidence add4ea94-7160-41ec-a939-627c886d5111. LIVE product 3917a14e-a664-4aec-8b93-00d023858e9b, evidence a30d8b5a-11ee-4993-a832-1e680e75920f. https://www.ebay.co.uk/itm/318928337003
- Sega Pico — £155.58, item 307149542948, seller in Fareham, includes two games/cables/adaptors; active auction price, not completed sale. TEST product e2ce884b-2f6f-4e0b-858b-985ee32758a3, evidence 0b2b04cb-d390-40f4-a273-9fa42aba825f. LIVE product 4d50ecbf-ad3a-4519-8ff2-6d38d0a6e51a, evidence c8d94b25-4fc5-40ad-89ee-5b36bca28e39. https://www.ebay.co.uk/itm/307149542948

The Mark III remains distinct from the UK Master System models; the SG-1000 is the earlier system; Pico is Sega's separate children's edutainment hardware. All evidence is `uk_used` asking-price reference only and does not influence automated valuations.

## Latest verification after both Sega batches
TEST and LIVE each independently show 142 active gaming products, 134 customer-visible products and 221 active evidence rows (59 `uk_new`, 162 `uk_used`), with zero malformed active evidence rows. IDs are environment-specific. No customer, tenant, transaction, payment, Stripe, subscription or domain data was changed; no application code, valuation logic or Worker deployment changed.
