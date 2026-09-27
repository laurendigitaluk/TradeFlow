# Checkpoint — 2026-09-27 — Customer Bank Details Hover Display

## Finding
The customer bank details are present in the live `customer_bank_details` record and the existing `subscriber_get_buying_item_payment_details` RPC already returns:
- account holder name
- bank name
- sort code
- account number

The previous Buying payment UI did retrieve those fields, but displayed them as ordinary fields rather than the requested compact hover interaction.

## Repair
The payment section now shows a compact:
**Customer bank details available ⓘ**

Hovering over it, or focusing it with the keyboard, opens a secure-looking information card containing:
- Account holder
- Bank name
- Sort code
- Account number

The payment method and payment reference controls remain below it.

No database values or permissions were changed.

Buying dashboard cache bumped from v46 to v47.

Commits:
- `38d47f6eb3b17c592e88d8ad3f9d6546147bd99d` — hover bank details UI
- `d55326891160646c851c09970edace1af11df1ff` — hover styling
- `c017dc997db3350784d7eb6d2e4c343504eaee01` — cache v47

## Test
After GitHub Pages publishes v47:
1. Hard refresh Buying dashboard.
2. Open the Canon EOS C70 payment section.
3. Hover over **Customer bank details available**.
4. The bank details card should appear.
5. Move the pointer away; it should close.
6. Payment reference and Confirm payment sent remain unchanged.

Do not alter shipping, customer authentication, or Test Two data.
