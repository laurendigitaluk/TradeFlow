# TradeFlow Checkpoint — 2026-09-21 — Parcel2Go Customer-Paid Shipping Flow

## Live scope
- Added shipping_quote_sessions for tenant/customer/acquisition shipping quote state.
- Added acquisition fields for Parcel2Go order/payment state and parcel dimensions.
- Added secure Edge Function parcel2go-customer-shipping.
- Customer Portal can request Parcel2Go quotes, select a service and create an unpaid Parcel2Go order.
- Parcel2Go returns its own payment/deeplink URL; the customer pays Parcel2Go directly.
- TradeFlow does not collect, pay or reimburse shipping costs.
- Subscriber Buying can select Use connected shipping service — Parcel2Go once the subscriber account is connected and tested in Settings.
- Manual label/QR override remains available.

## Provider basis
Parcel2Go's current API documents OAuth2, quotes, order creation, customer payment/deeplink, labels and tracking. The current implementation uses the subscriber-owned connection and server-side Vault credential reader.

## Current flow
1. Subscriber connects and tests Parcel2Go in Settings.
2. Subscriber opens an accepted acquisition in Buying.
3. Subscriber selects connected Parcel2Go shipping and publishes the connected shipping method.
4. Customer Portal shows Parcel2Go quote controls.
5. Customer selects their delivery address and enters parcel weight/dimensions.
6. TradeFlow requests a live Parcel2Go quote server-side.
7. Customer selects a quoted service.
8. TradeFlow creates an unpaid Parcel2Go order.
9. Customer is sent to Parcel2Go's payment/booking page.
10. Shipping payment remains outside TradeFlow.

## Not yet complete
- Parcel2Go webhook endpoint and signed event verification.
- Automatic post-payment label retrieval/storage in TradeFlow.
- Automatic tracking/status synchronisation back into the Customer Portal and subscriber Acquisition workspace.
- Live sandbox end-to-end test requires valid Parcel2Go sandbox credentials and a complete customer address/parcel specification.

## Security
- Parcel2Go API secret remains in Supabase Vault.
- Customer shipping actions are authenticated through the Edge Function.
- Quote/order records are service-managed; authenticated users receive read-only access according to tenant/customer ownership policies.
