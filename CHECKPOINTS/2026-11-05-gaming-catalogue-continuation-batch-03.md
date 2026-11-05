# Gaming catalogue continuation — batch 03

Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
Scope: shared gaming catalogue and UK-new evidence only; TEST written and verified before LIVE.

## Changes

Added one new master product: Nintendo Switch 2 AC Adapter, black single-adapter package (single-ac-adapter-black) in Nintendo Accessories. Four active UK-new GBP observations:
- Smyths Toys UK £21.99 — https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-ac-adapter/p/249615
- Currys UK £21.99 — https://www.currys.co.uk/products/nintendo-switch-2-ac-adapter-10281817.html
- EE UK £19.99 — https://ee.co.uk/products/nintendo-switch-2-ac-adapter
- Argos UK £24.99 — https://www.argos.co.uk/product/7624812/

Added Smyths UK-new evidence to existing Joy-Con 2 Charging Grip (£29.99) and Joy-Con 2 Wheel Pair (£14.99) records in both Nintendo Accessories and Nintendo Controllers branches. No duplicate masters created. Smyths listing: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203. Grip is sold without Joy-Con controllers; wheel pair includes two magnetic wheel adapters and does not include Joy-Con controllers.

## IDs

| Record | TEST ID | LIVE ID |
|---|---|---|
| AC Adapter product | e54ae54b-1e58-4be5-9b0a-56142d941244 | 26987446-1a04-4f2a-8970-72079a0a583f |
| AC Adapter / Smyths evidence | 4dd4eac2-de01-4d1f-82dc-2d42ae9678fa | 1884d558-e2f7-4add-8ca3-088ed1bf9796 |
| AC Adapter / Currys evidence | 1b9462ae-807d-4e4a-81d6-5221d92b37ff | 41b8ab83-e760-49a9-a4f1-72dee2a14738 |
| AC Adapter / EE evidence | a334b8de-de3b-4350-8de4-d9231f536798 | 101751bd-efb4-4d66-abb9-94c8650aec83 |
| AC Adapter / Argos evidence | 5c20cf58-b9dd-482e-9329-a3ef1f89fee9 | 31f2a943-8fa3-414d-8cf0-9a439b9b461f |
| Charging Grip / Accessories evidence | d8669b3f-4552-4780-a6ba-ef2cd8b11604 | 3d4156cf-edf7-4148-b10c-f17fcc92cc5a |
| Charging Grip / Controllers evidence | f133249c-ab0d-4f20-9331-052271a61f83 | f04cb182-882c-45d1-a712-a70119478300 |
| Wheel Pair / Accessories evidence | 9239582f-f8ce-4c63-ba8f-61e045134884 | c319a31e-0382-4397-9c2e-93a78c094690 |
| Wheel Pair / Controllers evidence | 75b5641d-a89c-4f6d-880b-3e81f3afa745 | 2381ed36-361c-4ef3-a2fa-88b48a533d7b |

## Verification

| Metric | LIVE | TEST |
|---|---:|---:|
| Active gaming products | 284 | 284 |
| Active customer-visible products | 276 | 276 |
| Active evidence rows | 396 | 396 |
| UK-new evidence | 231 | 231 |
| UK-used evidence | 165 | 165 |
| Visible products missing all evidence | 0 | 0 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

All 20 gaming branches match. Nintendo Accessories: 10 products / 10 visible / 16 evidence. Nintendo Controllers: 105 / 105 / 119. Eight evidence rows and one product master added in each environment. Existing evidence retained.

## Boundaries

UK-new/UK-used classifications remain separate. UK-used is reference-only and does not affect automatic buying valuation. No app code, schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. TEST and LIVE records were created independently; no tenant or customer data was copied.
