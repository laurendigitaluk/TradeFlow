# In-Store Valuation — Online Catalogue Parity Checkpoint
Date: 2026-10-01
Environment: TEST / `main`

## Purpose
The In-Store Valuation page is a staff-assisted version of the existing online selling journey. It must use the same tenant buying catalogue and the existing `calculate_buying_item_valuation` engine.

## Changes
- Replaced the old inventory-catalogue selector with the same hierarchy used by the online selling journey:
  1. Category
  2. Product type
  3. Manufacturer
  4. Model
  5. Package / version where applicable
  6. Condition
  7. Missing items
  8. Legal right to sell
- The selected product now uses the `tenant_buying_products.id` required by the existing valuation engine.
- Removed item photographs from In-Store Valuation.
- Added customer ID type and required "ID produced and copied" confirmation.
- Added required legal-right-to-sell confirmation and stored the check in the buying item metadata.
- Added business-logo/header presentation using the tenant public profile logo where available.
- Corrected the inventory transition so the tenant buying product is resolved back to its master catalogue product when creating Inventory.
- TEST migration applied as `20261001143750_in_store_valuation`.

## Intended flow
In-Store Valuation → Calculate Valuation → Customer Accepts → Purchased → Inventory

Accepted in-store purchases bypass customer shipping and later inspection because the staff member has inspected the item at the counter.

## Current test status
Not yet user-verified after this repair.

## Next test
1. Open In-Store Valuation from Buying.
2. Confirm the business logo/header appears.
3. Select a category and verify Product type → Manufacturer → Model → Package filters correctly.
4. Enter customer details.
5. Select ID type, tick ID produced and copied, and select Legal right to sell = Yes.
6. Select condition and missing-items response.
7. Calculate valuation.
8. Confirm the returned value is produced by the existing valuation engine.
9. Accept the purchase.
10. Verify the item appears in Inventory as ready for sale.
11. Verify the physical item remains one master Inventory asset and the online valuation flow is unchanged.
