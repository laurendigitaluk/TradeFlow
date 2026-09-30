# CHECKPOINT — 2026-09-30 — Duplicate Inventory Serial Warning

## Environment
- Environment: TEST
- Supabase project: twfbmjwwqzxdxvclxbun
- GitHub repository: laurendigitaluk/TradeFlow
- Branch: main
- LIVE/production: untouched

## Change
TradeFlow Selling now treats duplicate inventory serial numbers as a warning/review condition rather than a database uniqueness violation.

The previous unique partial index inventory_assets_tenant_serial_idx has been replaced with a normal partial lookup index. Duplicate serials are therefore permitted within a tenant, while the Selling UI checks for an existing matching serial and requires explicit confirmation before continuing.

## Database
Migration applied in TEST:
20260930232732_allow_duplicate_inventory_serial_numbers_with_warning

Current migration history:
- 20260930215656_remote_schema
- 20260930232732_allow_duplicate_inventory_serial_numbers_with_warning

Current index:
CREATE INDEX inventory_assets_tenant_serial_idx ON public.inventory_assets (tenant_id, serial_number) WHERE (serial_number IS NOT NULL)

Existing TEST data was checked and currently has no duplicate tenant/serial groups.

## UI
- Selling JS commit: 5889991fe480d7ad287613ec20c6b62ab9db966a
- Selling HTML/cache commit: 82587c3384eecb3ed89c62afab4cb59aab2e0456
- JS cache: v69
- Warning requires an explicit CONTINUE WITH SERIAL NUMBER action.
- Changing the serial number clears the previous confirmation.

## Browser verification required
The next browser test should deliberately use a serial already assigned to another inventory asset. Confirm warning → explicit continuation → successful save. Then test that changing the serial resets the confirmation.

## Safety boundary
Do not change LIVE/production or the production branch for this TEST repair.
