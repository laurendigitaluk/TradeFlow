# TradeFlow Inventory Catalogue Architecture Fix — 25 September 2026

## Scope
Camerashack tenant: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`

Repository: `laurendigitaluk/TradeFlow`

Branch: `main`

## Root cause

The Inventory Add Product UI had been incrementally changed to read from the Buying catalogue implementation:

- `tenant_buying_products`
- Buying-oriented `categories`
- Buying-oriented manufacturer/category/branch filtering

This was the wrong architectural boundary for direct Inventory stock entry.

The project documentation already defines a separate direct product path:

**Category → Product → Properties → Photographs → Inventory lifecycle → Listing → Customer Shop**

The database also contained a master catalogue and tenant catalogue-selection layer, but Inventory was not using it.

A second architectural mismatch was found in the database guard:

`guard_inventory_creation_boundary()` rejected every Inventory asset without an `acquisition_item_id`, even though the documented Inventory model supports direct/manual stock entry.

## Complete correction

### Database

Added:

- `inventory_assets.catalogue_product_id` → `catalogue_master_products.id`
- index on tenant/catalogue product
- `get_inventory_product_catalogue(uuid)` RPC

The RPC reads the tenant's selected master catalogue through `tenant_catalogue_selections`, joins the master catalogue, and returns the tenant's mapped category/branch IDs.

The Inventory creation guard now has two explicit paths:

1. **Acquisition path** — unchanged completed-purchase requirements.
2. **Manual Inventory path** — requires:
   - `metadata.source = 'manual_inventory'`
   - authenticated creator matching `created_by`
   - `module.inventory`
   - `inventory.manage`
   - a catalogue product

Unmarked direct creation remains rejected.

### Frontend

Rebuilt the Add Product catalogue flow around:

**Manufacturer → Category → Product**

The product determines the branch/product type automatically.

The UI no longer loads Inventory's product choices from `tenant_buying_products`.

The selected master catalogue product is stored on the Inventory asset as `catalogue_product_id`.

## Live database evidence

Camerashack currently has:

- 261 active tenant catalogue selections
- 3 manufacturers
- 1 tenant category
- 1 active product branch

The new Inventory catalogue RPC returns all 261 products for an authenticated authorised tenant context.

Nikon COOLPIX P1100 is present in the master catalogue and maps to Camerashack's Camera / Photography Cameras taxonomy.

The existing Nikon inventory asset has been linked to the corresponding master catalogue product. No inventory/listing record was deleted.

## Security verification

Authenticated rollback test:

- explicit `manual_inventory` creation: accepted by the Inventory creation boundary
- unmarked direct creation: rejected by the Inventory creation boundary

Both tests were rolled back, so no test inventory row was left behind.

No RLS policy was weakened.

## GitHub commits

- `d819d67238e1b797b9ee8527f6a3e47023fcef35` — rebuilt Inventory product selection around master catalogue
- `872b228b7af2de415246bf92cd116d8bf3cbb986` — completed manual Inventory creation path
- `2d08f82ee92cd78255106c7c79af3cd11069e2b6` — published rebuilt Inventory UI and cache v25
- `00952101880a1762c17474c87c3d3b84769aa99c` — roadmap update
- `e626f126c1338ef73f38a8d18a3331f4c698a442` — AI manual update
- `295d217062f4f3ab5d6421d43f563f1985b2f66e` — human manual update
- `5e680dad5701063d9d82409fefb5121873a62ed4` — diagnostic roadmap update

## Supabase

Migration applied:

`inventory_catalogue_architecture_fix`

Migration applied:

`allow_authorised_manual_inventory_creation`

## Next verification

Browser test the live Inventory page after GitHub Pages has deployed:

1. Open Inventory.
2. Open **Add product**.
3. Confirm Manufacturer contains the catalogue manufacturers.
4. Select **Nikon**.
5. Confirm Category populates.
6. Select **Camera**.
7. Confirm Product populates.
8. Select **Nikon COOLPIX P1100**.
9. Confirm product type/branch is filled automatically.
10. Confirm title is pre-filled.
11. Complete the minimum inventory fields and click Add product.
12. Confirm the new row is created in Inventory.
13. Confirm it is a manual Inventory asset, not a Buying request.
14. Do not alter or recreate Test One.

## Verification state

**Implemented in GitHub:** Yes

**Live DB verified:** Yes

**Browser verified:** Pending this final live test.


## Post-deployment defect found and corrected

The first browser deployment of the rebuilt Inventory UI exposed a separate JavaScript initialisation defect: `load()` called `waitForSubscriber()` but the function had not been defined in the rebuilt script. The screenshot showed the exact runtime error `waitForSubscriber is not defined`, leaving the Manufacturer selector at `Loading catalogue…`. This was not a catalogue or Supabase failure.

The missing function has now been implemented. It waits for the existing subscriber authentication and tenant-context promises, obtains the authenticated subscriber session/key/tenant, and only then calls the dedicated Inventory catalogue RPC. Inventory script cache was bumped from v25 to v26.

Correction commit: `131f09d261cbbe43aaa346ba0037a67f7b061ddb`

Cache publication commit: `9611d096e0f2b03ef183104fee9d0087490d9bdf`

The architecture remains unchanged: Inventory uses the master catalogue, not Buying catalogue data.
