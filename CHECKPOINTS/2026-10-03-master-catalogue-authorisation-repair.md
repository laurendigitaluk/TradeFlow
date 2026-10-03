# TradeFlow LIVE Master Catalogue Authorisation Repair — 3 October 2026

## Failure
LIVE Master Catalogue reached `get_master_buying_catalogue_facets` but returned HTTP 400: Tenant user is not authorised to view catalogue.

## Root cause
LIVE had no platform authorization seed data: 0 roles, 0 permissions and 0 role-permission mappings. LIVE also had 0 plan_features. The active Enhanced subscription therefore lacked the capability records required by the catalogue RPC.

## Repair
Migration `20261003213000_restore_platform_authorization_entitlements.sql` was generated from verified TEST configuration using natural keys. TEST was repaired/verified first: 3 roles, 35 permissions, 91 mappings, and 20 Enhanced plan features. The migration was then promoted to production and applied to LIVE.

LIVE verification confirms the Adventure Outpost owner has `categories.view`, and the Enhanced subscription has `module.buying` and `catalogue.pre_filled` enabled.

No tenant/customer/transaction data was copied.

## Next step
Browser verification only: refresh LIVE Master Catalogue and select a manufacturer. Do not make further database changes unless the new browser result identifies another specific failure.
