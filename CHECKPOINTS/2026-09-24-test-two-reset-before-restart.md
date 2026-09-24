# Test Two Reset — Clean Start

Date: 24 September 2026

## Reset performed

The current Test Two transaction data for tenant `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9` was removed so the buying/purchase workflow can be retested from a clean state.

Removed for the Test Two customer/request:
- Buying request `BR-E46C8F392E`
- Its buying item
- Trading valuation records
- Offers and offer events
- Buying item shipping data
- Buying item inspections
- Buying item media records
- Buying item field values
- Trade-in transaction records associated with the test
- Acquisition-related records associated with the test, if present
- Inventory asset records associated with the test, if present
- Shipping quote sessions associated with the test customer
- Customer payment/delivery addresses for the test customer

The customer account itself was retained so the same customer login can be used for a fresh test.

## Verification

After the reset:
- Test Two request count: 0
- Test Two item count: 0
- Test Two valuation count: 0
- Test Two offer count: 0
- Test Two customer-address count: 0

No database schema was changed.

## Preserved

Test One data was not touched.

## Next test

Start again from the customer portal with a fresh buying submission. Do not reuse the previous Test Two request or valuation records.
