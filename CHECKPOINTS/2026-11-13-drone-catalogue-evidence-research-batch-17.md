# Checkpoint — Drone catalogue evidence research batch 17

Date: 13 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: production
Target: TradeFlow LIVE (gxsrajtqzdjvmceqcpgv)
Pass: 2
Batch: 17
Scope: 20 active Drone master products with no active evidence, excluding products already reviewed in second-pass batches.

## Verified imports

Two UK New observations were inserted into public.shared_market_evidence and read back:
1. BetaFPV Pavo25 V2 — master product `370100fb-cb2d-4f45-90c2-e9ec81ae4063`; package Pavo25 V2 Brushless Whoop Quadcopter; £188.99 GBP; Unmanned Tech UK; New; out_of_stock; SKU B-PAVO25-V2-PNP. Source: https://www.unmannedtechshop.co.uk/products/betafpv-pavo25-v2-brushless-whoop-quadcopter
2. FIMI X8T V640 — master product `12b9ee53-0c5a-4786-a0db-c8c232101005`; package FIMI X8T V640 Camera Drone; £2,532.60 GBP; IT Drone UK; New; out_of_stock; tax included. Source: https://shop.itdroneservices.co.uk/products/drone-fimi-x8t-v640-4k-drone-lnfrared-thermal-imaging-lens-3-camera-gimbal-system-roklink-5-0-20km-transmission-gps-tx20-remote-control

Both inserts were guarded by exact active master product ID, model and package name. No existing evidence was overwritten. Source record keys:
- `betafpv-pavo25-v2-no-rx-uk-new-unmannedtech-18899-20261113`
- `fimi-x8t-v640-uk-new-itdrone-253260-20261113`

## Reviewed products held without import (18)

BetaFPV Pavo20 Pocket; Pavo30; Pavo35; DJI Matrice 350 RTK; FIMI A3; FIMI X6; FIMI X8 Pro; FIMI X8 SE 2022; Mi Drone 1080P; Mitu Mini Drone; FIMI X8 Mini; FIMI X8 Mini V2; FIMI X8 Pro 2025; FIMI X8 SE; FIMI X8 SE 2022 V2; FIMI X8 Tele; FIMI X8T V384; Freefly Alta X. Rejected leads included receiver/VTX selectors without a confirmed selected variant, package mismatches, outdated/aggregator-only pricing, imported or non-UK sources, and quote-only/no public UK GBP price.

## LIVE verification

- shared_market_evidence: 4,949 total / 4,887 active.
- Active UK New: 2,400.
- Active UK Used: 2,487.
- Active Drone master products: 540.
- Drones missing active UK New: 311.
- Drones missing active UK Used: 351.
- Drones with no active evidence: 190.

UK Used remains reference-only and must not affect automatic valuation. No catalogue master product/package rows changed. TEST and Stripe untouched. Status and reviewed product IDs are recorded in platform_ai_agent_messages, thread_key `tradeflow-research`, pass 2, batch 17.
