# Checkpoint — Manual AI research evidence review (AKASO 360)

Date: 10 November 2026
Repository: `laurendigitaluk/TradeFlow`
Branch: `production`
Target: TradeFlow LIVE Supabase project `gxsrajtqzdjvmceqcpgv`
Scope: Manual AI Research evidence review only. No TEST work.

## Pre-change checks
- Inspected current production `platform-owner-dashboard.js`, `platform-owner-dashboard.html`, AI Operating Manual, Human User Manual, Backend User Manual, recent research documentation/checkpoints and LIVE migration history.
- Inspected LIVE master catalogue, manual research batches/prompts, research queue, shared evidence schema/constraints, RLS/table grants, relevant RPC definitions and triggers.
- Confirmed no LIVE tables named for project memory/checkpoints; repository checkpoint is the durable record.
- No code or database changes were made during the review.

## Retrieved submission
- Completed batch: `1b46e2ba-75ae-499f-83c5-05a07695edba` (Claude).
- Prompt: `3e633e82-d5c1-4804-b6e3-2b37f1ec83fc`.
- Selected product: AKASO 360 Cycling Combo, product UUID `b162fdc0-2b9b-4e6b-9a7a-5e3c9280c0aa`.
- Submitted: 10 November 2026 23:30:19 UTC.
- The complete original prompt, product snapshot, assistant report and source URLs remain saved unchanged in LIVE.
- Three other batches remain ready/unsubmitted: one ChatGPT prompt and two Google Gemini prompts. They have no saved response and no review candidates; left untouched.

## Candidate-by-candidate assessment

| Queue ID | Reported package | Type / reported price | Source | Review result |
|---|---|---|---|---|
| `be720c7e-4ac3-4f6d-af43-b14629a22f3f` | Standard camera + microSD/case bundles | New, £178.48–£203.98 | [E-Catalog UK](https://e-catalog.co.uk/AKASO-360.htm) | Opened AKASO 360 aggregator page; package/offer variants visible, but not seller page. Comparison only. |
| `df669454-8f83-45c9-a7b3-45bf4d9a821f` | Creator Combo | New, £428.22 | [PriceSpy UK](https://pricespy.co.uk/c/action-cameras?brand=51042) | Opened category and Creator Combo detail page. Detail page currently showed £269.99 lowest and another offer £433.32; aggregator and reported price mismatch. Comparison only. |
| `601d98e9-8d99-4338-923f-3b517a8272e6` | Standard camera | New, £199.99 (report also said sometimes £169) | [road.cc review](https://road.cc/review_v2/akaso-360-action-camera) | Opened review dated 24 July 2026; £199.99 is editorial review pricing, not a direct offer. Comparison only. |
| `7882944d-d52c-4786-bc66-af162acdacb1` | Motorcycle Combo | New, reported £346.17–£410.80 | [eBay UK item 168576244131](https://www.ebay.co.uk/itm/168576244131) | Search-accessible listing details showed £346.17, New, AKASO 360, Motorcycle Combo + 128GB card, seller in Worksop; listing says it posts to the US. Not UK-deliverable evidence. Potential package is Motorcycle Combo + 128GB MicroSD Card; no mapping applied. |
| `3f4dd01f-1f63-46a3-9573-594f19d727fc` | Standard camera | New, £274.00 | [eBay UK item 205978796719](https://www.ebay.co.uk/itm/205978796719) | Direct page inaccessible; model/package/price not independently verified. |
| `8f40b61d-fc07-4158-8f3b-d11628842094` | AKASO 360 Action Camera, pre-owned | Used, £155.58 + £3.92 delivery | [eBay UK item 257834298627](https://www.ebay.co.uk/itm/257834298627) | Direct page inaccessible; condition/price/model not independently verified. |
| `3e59cb86-c1c2-4ae6-993e-44703072c585` | Creator Combo | New, £584.99–£649.99 | [eBay UK item 820292426482](https://www.ebay.co.uk/itm/820292426482) | Direct page inaccessible; package and price not independently verified. |
| `e85d0abb-b223-41f7-899e-441b8280910e` | AKASO 360 Action Camera, opened but never used | Used/opened, £170.00 | [eBay UK category page](https://www.ebay.co.uk/shop/action-camera-akaso?_nkw=action+camera+akaso) | Opened category page now showed £158.33 + £21.76 postage for seller bargain_hunter_bay, not £170. Individual linked listing URL `https://www.ebay.co.uk/itm/377392114735` could not be opened. Category page is not a direct listing source. Comparison only. |
| `b5e88a64-91c9-4f28-a6ae-ebf02ee25938` | Creator Combo | New, £220.99–£237.99 | [Supersales UK](https://www.supersales.co.uk/sports-outdoors/action-cameras?brand=akaso) | Opened category page showed other AKASO models, not the claimed AKASO 360 offer. Category/aggregator only. |
| `c20f388f-0bcb-46b6-ad52-a1a3cd21f2fe` | Standard camera | New, £209.99 | [Supersales UK](https://www.supersales.co.uk/sports-outdoors/action-cameras?brand=akaso) | Same source URL as previous candidate; page did not show the claimed AKASO 360 offer. Repeated URL flagged, not treated as verified evidence. |
| `253f53db-81b2-450b-8e63-24131be07fc3` | Motorcycle Combo | New, £248.00 | [U-buy UK Motorcycle Combo](https://www.u-buy.co.uk/product/TRNS10U1M-360-camera-motorcycle-combo-with-2-batteries-and-a-charger-bundle) | Direct page inaccessible/cache miss; product, price, stock and UK fulfilment not verified. |
| `0ae9175d-d5d3-4a2a-9bd8-e605a449176c` | Creator Combo | New, £243.00 | [U-buy UK Creator Combo](https://www.u-buy.co.uk/product/TY281VCI0-360-action-camera-creator-combo-with-lens-cap-bundle) | Direct page inaccessible; product, price, stock and UK fulfilment not verified. |
| `a923cb43-489d-4cc9-969d-94d85b6e642a` | Motorcycle Combo | New, £299.99 | [Visordown review](https://www.visordown.com/reviews/akaso-360-review-motorcycle-action-camera-bundle-tested) | Opened review dated 30 June 2026; confirms AKASO 360 and describes Motorcycle Combo contents including 128GB card. Editorial price context, not a direct offer. Comparison only. |

## Catalogue package cross-check
LIVE has seven active AKASO 360 variants:
- Cycling Combo — `b162fdc0-2b9b-4e6b-9a7a-5e3c9280c0aa`
- Drone View Combo — `90b65f3f-85f8-4cad-8618-0b299e3ed772`
- Motorcycle Combo — `a8c5124d-c84d-4c19-8d4f-77bc4e8e9bd0`
- Motorcycle Combo + 128GB MicroSD Card — `be6af9c4-f938-41e1-86bb-061a5137aec1`
- Snow Adventure Combo — `41359541-440d-4984-ac65-24837595a213`
- Creator Combo — `ae1a9089-70b2-45c7-a5eb-ca891bc68546`
- Standard Combo — `bc77e678-cb4d-4b70-9ab3-923f0009b360`

No candidate was mapped because no candidate met the direct source verification standard. The eBay/Visordown Motorcycle Combo with 128GB card points to the 128GB catalogue variant, not the base Motorcycle Combo, but it is not an eligible UK direct retail source. Creator Combo and Standard Combo references remain comparisons pending direct source verification.

## Duplicate and existing-evidence check
- Thirteen candidate rows contain 12 distinct source URLs; the Supersales URL appears twice for two separate claims.
- No exact duplicate product/source/price/type evidence row exists for the candidate set.
- Existing active AKASO 360 evidence includes one UK-used Standard Combo record at £378.72 from eBay item 168353588645; this is a different source and was not changed.
- Same Supersales/PriceSpy category URLs also occur on evidence for other AKASO models, but those rows belong to V50 X/V50 Pro products and are not duplicates for AKASO 360.

## Backend importer and security review
- `platform_owner_review_catalogue_research_item` changes queue status/reviewer metadata only.
- `platform_owner_verify_manual_ai_comparison` stamps `source_verified` after owner checks only; it does not insert evidence.
- Same-model package lookup/matching RPCs exist and enforce identical manufacturer/model/category, but no mapping was applied.
- Current production dashboard JavaScript contains no call to the source-verification RPC and no evidence-import RPC.
- LIVE public function scan found no INSERT into `shared_market_evidence`; no triggers exist on the research queue or shared evidence table to perform the import.
- Authenticated users have SELECT only on `shared_market_evidence`; INSERT is limited to service_role/postgres. No authorised owner importer is present.
- The safe next backend change is a narrow owner-authorised import RPC that requires approved queue state, source_verified=true, exact mapped master product/package, direct source type and URL, GBP price, condition, availability, observed date and excerpt; it must deduplicate and atomically store the evidence ID/import timestamp on the queue row. Used evidence must remain reference-only.

## Totals and outcome
- Candidates reviewed: **13**
- Original distinct source URLs: **12**
- Original source URLs opened: **6**
- Additional linked PriceSpy product page opened: **1**
- Original source pages qualifying as verified direct evidence: **0**
- Evidence records imported: **0**
- Existing evidence duplicates skipped: **0**
- Repeated source URL groups: **1**
- Candidates formally rejected in the queue: **0**
- Candidates eligible for import now: **0**
- Candidates retained pending review/comparison: **13**
- All queue rows remain `pending_review`; no imported timestamp or evidence link is present.

## Changes, tests and deployment
- No GitHub application code changed; no Supabase schema/data changed; no queue status or package mapping changed.
- No code tests were run because no code change was made. Read-only SQL checks confirmed candidate counts/statuses, package variants, evidence rows, grants, policies, functions and absence of import triggers/functions.
- No deployment occurred. No TEST, customer, tenant, subscription, Stripe or published website data was touched.
- Documentation follow-up: AI Operating Manual, Human User Manual and Backend User Manual updated to preserve the import boundary and review outcome.
- Remaining blocker: build, security-review, test and deploy the dedicated owner-authorised importer before these candidates can be imported.
