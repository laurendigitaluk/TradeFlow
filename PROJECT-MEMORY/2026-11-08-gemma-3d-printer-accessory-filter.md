# Project Memory — Gemma 3D Printer Accessory Page Filtering

Date: 8 November 2026 UTC  
Scope: TradeFlow LIVE, `3d-printers-equipment` / `3d-printers` only.

The LIVE task `owner-3d-printers-speed-benchmark-20261108-1645` exposed a false positive: Amazon UK YIBEICO screw set for Bambu Lab A1 AMS Lite was accepted as a printer Combo because its title/path included both A1 and AMS Lite. The current 3D-printer matcher already rejects many accessories, but its title/path pattern omitted screw sets, clamps and stiffeners. The page was staged only as an unverified `needs_research` capture, with no observed printer price or evidence type; no approval/import occurred.

Branch `fix/gemma-3d-printer-accessory-page-filter-20261108` adds `screw set|screw kit|clamp|stiffener` to the 3D-printer-only accessory exclusion and a regression test for the exact page, while retaining a positive genuine A1 AMS Lite Combo case. GitHub Actions run 42505871429 (#216) passed 53/53 tests. Local runtime acceptance is pending. No task was queued, no database rows were changed, and no worker update/deployment occurred.

PR #296 already covers Amazon UK direct-ASIN tracking-path canonicalisation; PR #300 covers structured Gemma JSON reliability. Do not duplicate those changes. Preserve all review gates, raw captures, secrets and TEST/LIVE separation.
