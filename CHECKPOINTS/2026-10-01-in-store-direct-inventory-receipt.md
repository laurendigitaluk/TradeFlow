# Checkpoint — 2026-10-01 In-Store Direct Inventory and Receipt

## Purpose
Separate the physical in-store valuation workflow from the online Buying / Internet Offers queue and add a printable purchase quote/receipt.

## Database
- TEST Supabase: twfbmjwwqzxdxvclxbun
- New migration: `in_store_workflow_separation` (recorded as version `20261001172553`)
- `subscriber_get_business_workflow` now excludes `buying_items.metadata.source = 'in_store'`.
- `subscriber_complete_in_store_purchase` still moves an accepted in-store item directly to `purchase_stage='purchased'` and creates Inventory with `metadata.source='in_store'`.
- The completion RPC now also returns the buying item reference and purchase timestamp for receipt use.

## Verified existing purchase
The latest in-store test purchase is already in Inventory:
- Buying item: `BI-FF757B999F`
- Inventory asset: `IA-D0D6AE74E2`
- Purchase price: £45.00
- Inventory status: `ready_for_sale`
- Source: `in_store`

The same buying item was appearing in the online Buying workflow because the workflow query did not previously exclude the in-store source. The database separation fix addresses that without changing the normal internet buying workflow.

## Frontend
- `in-store-valuation.js` now creates a **Print Quote / Receipt** button after an in-store purchase is accepted.
- Receipt includes business name/logo, customer details, transaction reference, inventory reference, item/category/type/manufacturer/model/package, serial number where applicable, condition, missing items, ID type and copied-ID confirmation, legal right to sell, staff/valuation notes, purchase price and date/time.
- Receipt opens in a print-friendly window and calls the browser print dialog.
- `in-store-valuation.html` cache-bust version updated to `in-store-valuation.js?v=5`.

## Next test
1. Reload the in-store valuation page.
2. Complete a fresh counter valuation.
3. Accept the purchase.
4. Confirm it creates Inventory as ready for sale.
5. Confirm it does NOT appear in the online Buying / Internet Offers queue.
6. Click **Print Quote / Receipt** and verify all customer and purchase details print correctly.
