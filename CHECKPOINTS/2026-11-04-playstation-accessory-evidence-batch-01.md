# Checkpoint — PlayStation accessory evidence batch — 4 November 2026

Repository: laurendigitaluk/TradeFlow  
TEST Supabase: nnsshnfkjcflucjrftzi  
LIVE Supabase: gxsrajtqzdjvmceqcpgv  
TEST branch: cloudflare-test  
LIVE branch: production

## Scope
Added three UK-new market-evidence observations to existing gaming master products. TEST was written first, then LIVE was updated using its own environment-specific product UUIDs. No master products were added and no tenant, customer, transaction, domain, storefront, Stripe, subscription, application code or Worker deployment data was changed.

## Evidence inserted
All rows use evidence_type uk_new, GBP, condition new, sales_channel retail, availability listed, exact source URLs, observation date 2026-11-04, and stable source keys. Prices are retailer listing prices, not completed sales.

| Product | Source | Price | Source URL | Stable key |
|---|---|---:|---|---|
| DualSense Charging Station | PlayStation UK | £24.99 | https://www.playstation.com/en-gb/accessories/dualsense-charging-station/ | ps-uk-dualsense-charging-station-20261104 |
| PlayStation Portal Remote Player | Currys UK | £219.00 | https://www.currys.co.uk/products/sony-playstation-portal-remote-player-10257483.html | currys-playstation-portal-10257483-20261104 |
| PlayStation VR2 | Smyths Toys UK | £399.99 | https://www.smythstoys.com/uk/en-gb/gaming-and-tech/virtual-reality/playstation-vr2/playstation-vr2-headsets/playstation-vr2/p/225323 | smyths-playstation-vr2-225323-20261104 |

## TEST IDs
- DualSense Charging Station product 7cad3b4c-1b97-4715-a15f-c6c47411d97e; evidence 1423522d-6d47-4cd0-b647-20508ab5f968.
- PlayStation Portal product 5e701d30-e238-4807-ae05-6aeeef1acf46; evidence 153d65aa-d721-454f-a309-2b6fd0f2fce3.
- PlayStation VR2 product 2dcfdf09-f096-4ccf-998d-251458c5b1c5; evidence 354d9afe-73e7-4440-8556-0907f983aa06.

## LIVE IDs
- DualSense Charging Station product 240adf4e-630b-46f7-8e03-71d4b3309712; evidence f2038306-ff3b-4dd8-b479-a00abe459b3d.
- PlayStation Portal product b2da3766-77fe-4329-8c91-d712f7dd4146; evidence c7b5f07b-8512-4b18-8e92-1251d168c50e.
- PlayStation VR2 product 40fa18d5-a59d-488d-9674-37883658a180; evidence 8ff07860-832d-4cbf-93d5-01f54c1a7cb1.

## Read-after-write verification
Both TEST and LIVE: 113 gaming master products; 184 active evidence rows (59 UK new / 125 UK used); zero malformed active evidence rows under the URL/key/GBP/positive-price/availability check. Source-key parity was confirmed: exactly one active copy of each new key in each environment. One visible product remains without active evidence: WD_BLACK C50 512GB Expansion Card for Xbox Series X|S. Do not fabricate a price; add evidence only after an exact UK listing is verified.

## Guardrails
- Market evidence is research reference only and must not alter automatic buying valuations.
- Keep TEST and LIVE product/evidence UUIDs separate.
- Do not copy operational tenant/customer/transaction/domain/Stripe/subscription data.
- Database-only catalogue changes do not require Cloudflare Worker deployments.
