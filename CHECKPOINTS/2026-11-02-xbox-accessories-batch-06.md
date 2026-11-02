# Xbox controllers and accessories — Batch 6 checkpoint
Date: 2 November 2026
Repository: laurendigitaluk/TradeFlow

## Scope and controls
- TEST Supabase: nnsshnfkjcflucjrftzi.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv.
- TEST and LIVE were written independently. Product and evidence UUIDs differ between environments.
- No tenant, customer, transaction, payment, Stripe, valuation logic, application code or Worker deployment was changed.
- All market evidence is GBP, UK source, `availability=listed`, and is retailer asking price rather than completed-sale data unless explicitly stated otherwise.
- Used evidence is reference only and must not feed automatic buying valuations.

## Branches created independently
LIVE:
- Xbox Controllers: cc81ef06-cf05-4c2b-ae5c-9fab63951f47
- Xbox Gaming Headsets: 4c6ce716-3c30-4c24-a6a1-eb6a6cfd347b
- Xbox Accessories: 95738cbd-3596-46ae-8114-34a324df3ccb

TEST:
- Xbox Controllers: d32c2e10-75e1-464d-bc53-add5c3446725
- Xbox Gaming Headsets: a9ac6522-63ea-4d17-8163-f12374a2db23
- Xbox Accessories: 640617be-fd08-450e-8958-cf9d4a2b9759

## Product and evidence records

### Xbox Wireless Controller — Carbon Black Series X|S
- LIVE product: a8f6d4a3-b1d6-4bf0-a2fe-bc0763dfdc1f
  - Microsoft Store UK new £54.99; evidence 2ddf0050-76f9-491e-ae98-e3df22bf386f.
  - Cash Converters UK used £39.99; evidence c3b96c80-8257-428d-874b-33b6c238231a.
- TEST product: 180c7add-6d8d-4c1c-b7bd-57c441c6ad83
  - Microsoft Store UK new £54.99; evidence inserted and verified.
  - Cash Converters UK used £39.99; evidence inserted and verified.
- Sources: https://www.microsoft.com/en-gb/store/collections/xboxconsoleaccessories ; https://www.cashconverters.co.uk/shop/gaming/gaming-peripherals/game-controllers/xbox-controller/059600008927

### Xbox Elite Wireless Controller Series 2
- LIVE product: 8d1fec5e-aa42-4637-8a44-5661f50aceaa
  - Microsoft Store UK new £159.99; evidence bc83dcd6-cf9b-45b7-bca3-c44eea24637f.
  - Cash Converters UK used £89.99; evidence fd276434-1f9f-4977-a0b0-98da93fcdd34.
- TEST product: 15160e5e-b4c5-47ac-b10a-7458c987bddf
  - Microsoft Store UK new £159.99; evidence bfb59dc4-0756-4301-a725-a265bc9232ed.
  - Cash Converters UK used £89.99; evidence b378f4f7-c5a4-42d1-981b-be1e54a20a8e.
- Used source: https://www.cashconverters.co.uk/shop/gaming/gaming-peripherals/game-controllers/xbox-controller/045700042720

### Xbox Elite Wireless Controller Series 2 Core
- LIVE product: 72d1caad-4af8-48fa-a83c-17379251e487; new £109.99 evidence 4a61756f-2b9e-4fb1-b14a-1c6f34749ddb.
- TEST product: 49a5647a-320a-40c1-989e-8d3c5f11d3c0; new £109.99 evidence 138bfecc-4eea-4963-8970-04866d8ed285.
- Official source: https://www.microsoft.com/en-gb/store/collections/xboxconsoleaccessories

### Xbox Wireless Headset
- LIVE product: 25cd5188-eab2-4b45-b301-00f588512510
  - Xbox UK new £99.99; evidence b51c3b68-9ebc-44a0-8423-f2ba143d5a25.
  - Cash Converters UK used £49.99; evidence 0e8e6db9-38ee-4655-b844-af520e5accca.
- TEST product: 033abd7f-b9c9-40ee-9de5-c4d3347535d6
  - Xbox UK new £99.99; evidence 01ff8f96-2946-416b-96a8-265d0cd2200b.
  - Cash Converters UK used £49.99; evidence 0c907a75-80fc-438c-a58c-d8e9768901cb.
- Sources: https://www.xbox.com/en-GB/accessories ; https://www.cashconverters.co.uk/shop/gaming/gaming-peripherals/game-controllers/gaming-headset/048100226913

### Xbox Stereo Headset
- LIVE product: aad2ec54-74c9-4354-99ca-24fb2ae48d2d; Microsoft Store UK new £49.99 evidence 5ad2b975-238a-46b1-a4f3-29880f6a079a.
- TEST product: 71e5fe5a-e622-4d2a-866a-82c589055b90; new £49.99 evidence 78a4f189-4863-43cc-9670-0fe6cc0bdf7f.
- Source: https://www.microsoft.com/en-gb/store/collections/xboxconsoleaccessories

### Xbox Rechargeable Battery and USB-C Cable
- LIVE product: a105cac8-d94b-4633-9e2e-7ce5d3cc0059; Microsoft Store UK new £19.99 evidence f66a8d92-58de-4b7e-99ce-efca0fc013b4.
- TEST product: 5040d5b0-98f5-4c32-b0c5-58825c1aabb0; new £19.99 evidence 966fc104-56c2-45fc-9544-1c916ce5cb3b.
- Source: https://www.microsoft.com/en-gb/store/collections/xboxconsoleaccessories
- No used battery evidence was added because a suitable verified UK used listing was not established.

## Verification
Both TEST and LIVE independently returned:
- 6 active customer-visible Xbox accessory products in this batch (including the previously existing/added standard controller).
- 9 active evidence rows: 6 UK new GBP and 3 UK used GBP.
- Every row is active and linked to the intended product.
- No cross-environment UUID reuse.

## Known limitation / next work
- Stereo headset and rechargeable battery currently have new-price evidence only.
- Expand used evidence only when an exact UK listing can be checked for model, condition, price and URL.
- Continue with Xbox storage expansion, charging docks, controller accessories, adaptive accessories and other exact package variants.
- Do not treat eBay asking prices as completed sales; record retailer listings as `listed`.
