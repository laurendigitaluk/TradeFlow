# Project Memory — LIVE drone source coverage preparation

8 November 2026. LIVE is authoritative; TEST is for software development and regression only. Preserve existing TEST data and do not routinely duplicate product/evidence records there.

LIVE Drones baseline: 541 active products, 18 manufacturers, 542 active evidence rows; 306 active products lack evidence. No open Drones research queue items. Largest gaps: Skydio 46, Hubsan 44, Potensic 32, Walkera 24, Parrot 21, BetaFPV 20, Holy Stone 18, Autel 16, PowerVision 16, FIMI 15, iFlight 12, Freefly 11, Yuneec 11, GEPRC 5, EMAX 3; CaddxFPV has no uncovered active products.

LIVE source registry updated for drones/drone-accessories:
HOVERAir UK official (uk.hoverair.com); Holy Stone official UK distributor DMTL (dmtl.co.uk); Flying Tech UK (flyingtech.co.uk); Unmanned Tech UK (unmannedtechshop.co.uk); IT Drone Services UK FIMI store (itdroneservices.co.uk); CameraWorld UK assignment extended (cameraworld.co.uk); Wilko UK Potensic listings (wilko.com); Aetha UK Skydio X10D solutions provider (aetha.global, quote-only/no inferred price). Existing DJI UK, Heliguy, HobbyRC, DJI Retail UK, DJI Store and MPB UK remain. Amazon/eBay universal.

Do not add Autel UK as a drone source: it is automotive diagnostics. Parrot official reseller locator currently shows Dronivo Germany, not UK. Yuneec UK sales are spare parts only. No verified UK public pricing source for Freefly, PowerVision, Walkera. Potensic official authorised-dealer page did not show UK; CameraWorld/Wilko are retailers only, not authorised distributors.

Production agent source routing includes isCategoryAllowedSource and isResearchTypeAllowedSource in tools/tradeflow-gemma-agent/src/agent.mjs. Research PC local runtime has not been updated. PR #312 open/ready for review, CI 73/73; PR #300 draft/open, CI 54/54. Do not restart worker or enqueue tasks until Research PC updater, Ollama structured-output acceptance and end-to-end LIVE batch verification are complete. No research tasks queued by this source update.

## 13 November 2026 — second-pass Batch 18 and supplemental follow-up

LIVE remains authoritative for drone evidence; TEST remains untouched. Second-pass Batch 18 reviewed 20 previously unreviewed active products, excluding product IDs already reviewed in Batches 16 and 17. Four active GBP observations were added across three existing products: GEPRC Cinelog30 V3 O4 Pro ELRS (£337.80 HobbyRC UK; £345.90 Whoop Store UK), GEPRC CineLog35 V2 Analog (£239.95 Unmanned Tech UK), and Holy Stone HS180 (£15.01 completed eBay UK used sale, including Buyer Protection). Seventeen were held for no exact qualifying UK GBP source, active-only private listings, seller location/reliability, or package mismatch.

Separate supplemental follow-up rows (not counted in Batch 18): BetaFPV Cetus X HD FPV Kit £649.00 and BetaFPV Pavo35 £189.99, both Unmanned Tech UK, UK New, sold out. These were previously held in Batches 16/17 and are recorded as follow-up observations.

LIVE post-write: 541 active visible Drone products; 186 with no active evidence; 308 missing UK New; 351 missing UK Used; 68 with both. Global evidence 4,955 total / 4,893 active (2,405 UK New / 2,488 UK Used). Zero Drone evidence integrity failures; zero duplicate active source-key groups. TEST read-back found none of the six LIVE source keys. No catalogue masters/packages, TEST data, Stripe, valuation, application code or schema changed.

Dashboard messages: Batch 18 f7fbc94c-b2ee-44c5-a008-bf8e947fecbf; supplemental follow-up c3097a7f-ad04-4913-9b31-543109caa42b.

Next 20-product selection for second-pass Batch 19 (all LIVE products currently have zero active evidence and were not in second-pass Batches 16–18): Holy Stone HS720-4K, HS790, HS800, HS900PRO, T60A; HoverAir X1 PRO Max; Hubsan ACE 2, H107C+, H501S X4 Air Black, H501S X4 Air White, Zino, Zino 2, ZINO MINI PRO 2025, Zino Mini SE; iFlight BOB57 O4, Chimera7 Pro V2 GPS Analog, Chimera7 Pro V2 O4, Defender 20 Lite O4, Nazgul DC5 O4 ECO, Nazgul Evoque F5 V3 O4 Pro.
