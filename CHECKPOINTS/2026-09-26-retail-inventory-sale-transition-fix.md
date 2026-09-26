# Retail inventory sale transition fix — 26 September 2026

## Root cause
Paid retail orders were marking the listing as sold, but the inventory asset update only allowed assets already in listed or reserved. The EOS R1 asset was still received because earlier testing left the inventory lifecycle out of sync with the published listing.

## Repair
- Updated customer_pay_retail_order_with_credit so a paid retail order can synchronise the associated inventory asset to sold from valid pre-sale states.
- Updated process_external_payment_event with the same inventory-sale transition boundary.
- Synchronised the current EOS R1 asset 5b00c294-b28d-4bf3-b06a-58b4c3cc482a to sold.
- Current order ORD-20260926-71DCBDEC remains paid / fulfilment and its listing is sold.
- Cancelled historical test orders remain cancelled/unpaid and do not drive the current inventory state.

## Verification
Current EOS R1 inventory status: sold.
Current order: paid / fulfilment.
Current listing: sold.

The Inventory dashboard should therefore show the EOS R1 as completed rather than action required after refresh.
