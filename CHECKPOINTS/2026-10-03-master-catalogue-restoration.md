# TradeFlow Master Catalogue Restoration — 3 October 2026

## Objective
Restore the LIVE Master Catalogue without copying tenant/test transaction data and without rebuilding the catalogue architecture.

## Evidence
TEST master catalogue counts before release: 32 categories, 177 branches, 73 manufacturers, 3,845 master products, 108 product identifiers and 3,822 active/customer-visible products.

LIVE before repair had the catalogue tables and RPCs but zero master catalogue rows. LIVE buying-catalogue.js also used an incomplete Supabase URL.

## Repair
Created version-controlled system-data migrations using natural keys:
- 20261003210000_restore_master_catalogue_metadata.sql
- 20261003210001 through 20261003210008 product snapshot migrations
- 20261003210009_restore_master_catalogue_identifiers.sql

The migrations were applied to TEST first. TEST remained at 32 / 177 / 73 / 3,845 / 108, confirming idempotent restoration against the already-populated development catalogue.

The same migrations were then applied to LIVE. LIVE buying-catalogue.js was corrected to the full LIVE Supabase URL.

## Data boundary
Only TradeFlow-owned master catalogue data was promoted. No Camerashack/Test customers, subscribers, orders, inventory, returns, Stripe transactions, subscriptions or other tenant records were copied.

## Architectural confirmation
Master Catalogue is the source structure for subscriber catalogue activation. A purchased product retains its category/branch/product identity into Inventory and Selling; the retail selling category is derived from the same subscriber catalogue structure rather than a disconnected second taxonomy.

## Current status
- TEST database restoration: VERIFIED
- LIVE database restoration: APPLIED
- LIVE frontend endpoint correction: APPLIED
- LIVE browser Master Catalogue verification: PENDING

Next browser test: open LIVE Master Catalogue → Add Products, refresh, select a manufacturer, confirm products load, then confirm one product can be added to the subscriber Buying Catalogue without Failed to fetch.
