# TradeFlow Checkpoint — 27 September 2026 — Restore payment bank details layout

## Root cause

The customer bank-detail data is present in the live tenant and all four fields are populated. The issue shown in the browser was frontend layout, not missing data.

The post-inspection payment renderer had been repeatedly changed from the original structured field layout into hover/disclosure/direct-inline variants. The latest screenshot showed the payment method and reference controls compressed onto the same line and the bank values not presented as the expected customer-detail fields.

## Repair

Restored the post-inspection payment section to a simple structured layout:

- Customer bank details heading
- Account holder field
- Bank name field
- Sort code field
- Account number field
- Separate Payment method field
- Separate Payment reference field
- Confirm payment sent button

The existing `subscriber_get_buying_item_payment_details` RPC remains the data source.

No hover, disclosure control, new database function, RLS change, permission change, payment RPC change, shipping change or authentication change was made.

Cache version advanced from v50 to v51.

## Commits

- `9f3aec5b9890c85c89631a57510c94b7c4806936` — restore payment bank details layout
- `ac4fa45c584b6b5887b3c78bf6fe1fe6540b0945` — cache v51

## Verification

Live database verification confirms account holder, bank name, sort code and account number are all populated for the current tenant's latest customer bank-detail record.

Browser verification of v51 is pending.
