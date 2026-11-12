# Broadcast equipment RED VERIFY follow-up — 12 November 2026

**Environment:** TradeFlow LIVE only  
**Products checked:** Sony HDC-5500, Sony XVS-G1, Sony HDC-3000  
**Status:** Further source evidence gathered; no database writes due authenticated-owner gate

## Sony HDC-5500

Existing LIVE master:
- UUID: `75fabe8a-7cd8-4419-9cc3-235443d881a3`
- Model: HDC-5500
- Package: Standard
- Existing evidence: none

### Camera-head retail offer — comparison candidate
Visuals UK exact SKU HDC-5500//U: £60,036.00 inc VAT (£50,030.00 ex VAT), 3+ in stock. The source result states that the in-box items are cable clamp belt, two screws and attached label. This is the camera head package, not a complete channel. Direct product page: https://www.visuals.co.uk/sony-hdc-5500.html (click-through returned cache miss during this check). Keep RED VERIFY until the page/checkout and the catalogue meaning of Standard are confirmed.

### Complete used channel — package mismatch
KitPlus UK listing ID 33631, £54,000.00, used, published 24 February 2025, seller Visual Impact Group Premium Dealer. Search result details:
- HDC-5500 camera head with installed HZC-PRV50, HZC-UHD50 and HZC-HFR50 options
- HDCU-5500 CCU with installed ember+ licence and HKCU-SFP50 ST 2110 IP interface
- Sony 50-25 pin adapter, touchdown and breakout cables
- RCP-1500
- HDVF-L10 and HDVF-EL75 viewfinders
- VCT-14, rain cover and two flight cases

Seller terms state all prices exclude VAT unless otherwise stated. The KitPlus page itself returned 403; availability must be confirmed with seller. This is a complete channel package, not the bare camera-head Standard offer. Keep comparison-only and do not attach to the Standard master.

Listing: https://kitplus.com/for-sale/cameras-and-accessories-1/sony/hdc-5500/33631

Finepoint UK hire page independently lists a complete channel comprising HDCU-5500, RCP-3500, headset, monocular VF and HDVF-EL75 OLED in two cases, plus rain cover, HDLA ears, VCT-14, comms breakout, RCP control and touchdown cables. This is hire inventory, not a sale price: https://www.finepoint.co.uk/hire-cameras/sony-hdc-5500

## Sony XVS-G1

- ProAV direct product page: GBP selected, no price shown, Cat 44234 / SKU XVS-G1. Page labels availability “In stock” but also “Backorder — order now; delivery when in stock, usually within 10 working days.” Configuration and price are not confirmed. https://proav.co.uk/sony-xvs-g1-live-production-switcher
- C2S Media search result: £20,765.70. It describes the XVS-G1 base unit with configurable 4M/E/44-input/24-output or 2M/E/24-input/12-output options; actual included I/O boards/configuration and VAT basis are not established. Comparison-only, not importable. https://c2s-media.com/product/sony-xvs-g1/
- Sony UK support page confirms exact XVS-G1 model and documentation but no sale price: https://www.sony.co.uk/electronics/support/switchers-and-live-systems-switchers/xvs-g1

## Sony HDC-3000

No exact sellable Sony model named HDC-3000 was verified. Sony support/product naming points to HDC-3500, HDC-3200, HDC-P50, HDC-3100 and related models. Do not substitute HDC-3500, HDC-3200, HSC-300 or CCU prices.

## Authorization and safeguards

LIVE SQL returned `auth.uid() = NULL` with database role `postgres`. The current project checkpoint requires an authenticated user and successful platform-owner check before writing. No Supabase write was attempted. No dashboard notification was posted.

Cumulative evidence remains 236 GBP observations: 232 active (127 UK New, 105 UK Used), four inactive. No TEST, Stripe, schema, master-product, tenant/customer or valuation changes were made.
