# Project Memory — LIVE drone source coverage preparation

8 November 2026. LIVE is authoritative; TEST is for software development and regression only. Preserve existing TEST data and do not routinely duplicate product/evidence records there.

LIVE Drones baseline: 541 active products, 18 manufacturers, 542 active evidence rows; 306 active products lack evidence. No open Drones research queue items. Largest gaps: Skydio 46, Hubsan 44, Potensic 32, Walkera 24, Parrot 21, BetaFPV 20, Holy Stone 18, Autel 16, PowerVision 16, FIMI 15, iFlight 12, Freefly 11, Yuneec 11, GEPRC 5, EMAX 3; CaddxFPV has no uncovered active products.

LIVE source registry updated for drones/drone-accessories:
HOVERAir UK official (uk.hoverair.com); Holy Stone official UK distributor DMTL (dmtl.co.uk); Flying Tech UK (flyingtech.co.uk); Unmanned Tech UK (unmannedtechshop.co.uk); IT Drone Services UK FIMI store (itdroneservices.co.uk); CameraWorld UK assignment extended (cameraworld.co.uk); Wilko UK Potensic listings (wilko.com); Aetha UK Skydio X10D solutions provider (aetha.global, quote-only/no inferred price). Existing DJI UK, Heliguy, HobbyRC, DJI Retail UK, DJI Store and MPB UK remain. Amazon/eBay universal.

Do not add Autel UK as a drone source: it is automotive diagnostics. Parrot official reseller locator currently shows Dronivo Germany, not UK. Yuneec UK sales are spare parts only. No verified UK public pricing source for Freefly, PowerVision, Walkera. Potensic official authorised-dealer page did not show UK; CameraWorld/Wilko are retailers only, not authorised distributors.

Production agent source routing includes isCategoryAllowedSource and isResearchTypeAllowedSource in tools/tradeflow-gemma-agent/src/agent.mjs. Research PC local runtime has not been updated. PR #312 open/ready for review, CI 73/73; PR #300 draft/open, CI 54/54. Do not restart worker or enqueue tasks until Research PC updater, Ollama structured-output acceptance and end-to-end LIVE batch verification are complete. No research tasks queued by this source update.
