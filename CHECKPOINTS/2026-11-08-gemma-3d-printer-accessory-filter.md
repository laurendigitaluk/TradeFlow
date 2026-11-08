# Gemma 3D Printer Accessory Filter Checkpoint

Date: 8 November 2026 UTC  
Scope: TradeFlow LIVE review-capture pipeline, category `3d-printers-equipment`, branch `3d-printers`.

## Finding
LIVE task `owner-3d-printers-speed-benchmark-20261108-1645` fetched and staged an Amazon UK accessory-only page as a Bambu Lab A1 / AMS Lite Combo candidate:
- Title: YIBEICO Screw Set For Bambu Lab A1 AMS lite and Stiffener C Clamp
- URL: https://www.amazon.co.uk/YIBEICO-Screw-Bambu-Stiffener-Clamp/dp/B0D6VQWVJ1
- It contains model token A1 and package marker AMS Lite, so the current identity matcher passed it.
- Existing accessory exclusions did not include screw set, screw kit, clamp or stiffener.
- The page remained an unverified `needs_research` capture with no printer observed price/evidence type; no approval/import.

## Proposed change
Branch: `fix/gemma-3d-printer-accessory-page-filter-20261108`
- Extend only the 3D-printer title/path accessory pattern with `screw set`, `screw kit`, `clamp`, `stiffener`.
- Add a regression test using the exact captured title/URL.
- Keep the positive genuine Bambu A1 AMS Lite Combo test.
- No source registry, task, queue, price, approval or import changes.

## Verification
GitHub CI pending. Not merged, not installed on the Research PC, and not deployed. No LIVE runtime retest was queued. Expected replay effect: exclude one accessory-only page from the five fetched Bambu A1 Combo candidates; this is not yet a measured production result.

## Related fixes
PR #296 separately handles Amazon UK ASIN URLs with tracking-path suffixes; do not duplicate its canonicalisation change. PR #300 separately addresses Gemma structured-output reliability. Preserve the private Research PC .env and `TRADEFLOW_GEMMA_ENV_FILE`, TEST/LIVE separation, full raw page retention and owner/ChatGPT review gate.
