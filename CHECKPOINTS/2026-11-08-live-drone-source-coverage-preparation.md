# LIVE Drones source coverage and Gemma gate checkpoint

Date: 8 November 2026.
Environment: TradeFlow LIVE gxsrajtqzdjvmceqcpgv.
Category slugs: drones; drone-accessories.

## Operating boundary
The 7 November decision is authoritative: LIVE is the sole catalogue/research queue/evidence environment. TEST is for software development and regression only. Preserve existing TEST data; no routine product/evidence duplication.

## LIVE Drones baseline
- 541 active products, 18 manufacturers, 542 active evidence rows.
- 306 active products lack active evidence; 235 have active evidence.
- No outstanding Drones research queue items.
- Uncovered active products by manufacturer: Skydio 46, Hubsan 44, Potensic 32, Walkera 24, Parrot 21, BetaFPV 20, Holy Stone 18, Autel 16, PowerVision 16, FIMI 15, iFlight 12, Freefly 11, Yuneec 11, GEPRC 5, EMAX 3. CaddxFPV has zero uncovered active products.

## LIVE category source registry changes
Added:
- HOVERAir UK Official Store — uk.hoverair.com, official manufacturer source, drones + drone-accessories.
- Holy Stone UK Distributor — DMTL, dmtl.co.uk, official UK distributor listed by Holy Stone Europe, drones + drone-accessories.
- Flying Tech UK — flyingtech.co.uk, UK FPV retailer; BetaFPV/CaddxFPV/EMAX/GEPRC/iFlight and related equipment, drones + accessories.
- Unmanned Tech UK — unmannedtechshop.co.uk, UK retailer; BetaFPV/Caddx/EMAX/GEPRC/Hubsan/iFlight, drones + accessories.
- IT Drone Services UK — itdroneservices.co.uk, UK FIMI store, drones + accessories.
- Wilko UK — wilko.com, Potensic Atom 2 listings, drones.
- Aetha UK — aetha.global, Skydio X10D UK exclusive drone solutions service provider; source_kind other, quote-only pricing must not be inferred.
Updated existing CameraWorld UK source assignment to include drones and drone-accessories. Existing DJI UK, Heliguy, HobbyRC, DJI Retail UK, DJI Store and MPB UK source assignments remain. Amazon UK and eBay UK remain universal.

## Exclusions / gaps
- Autel UK is automotive diagnostics, not Autel Robotics drone sales.
- Parrot official reseller finder currently shows a German reseller, not a UK reseller.
- Yuneec UK service closed; web orders only for spare parts.
- No verified UK public pricing source found for Freefly, PowerVision or Walkera.
- Potensic official authorised-dealer page did not show a UK authorised dealer; CameraWorld/Wilko are retailer sources only.
Do not label general retailers as manufacturer-authorised.

## Source filtering
Production agent source routing in tools/tradeflow-gemma-agent/src/agent.mjs has isCategoryAllowedSource and isResearchTypeAllowedSource, applied by isApprovedSourceForTask before source probing. Category assignments are scoped; Amazon/eBay universal sources remain. Research PC local runtime still has not been updated/accepted.

## Gemma readiness
- PR #312 open/ready for review, not merged; CI 73/73 passed; 3D printer structured GBP extraction.
- PR #300 draft/open, not merged; CI 54/54 passed.
- Research PC update, Ollama structured-output acceptance, authenticated LIVE batch browser check and end-to-end task verification outstanding.
No research tasks queued and no worker restarted.
