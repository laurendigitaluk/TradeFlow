# TradeFlow Checkpoint — 21 September 2026 — Shipping Provider Connections

## Requirement
Subscribers connect their own multi-carrier shipping account. Their provider account remains responsible for courier billing and payment. TradeFlow stores operational shipment and tracking data only.

## Provider research
Initial supported connection types are Parcel2Go, Sendcloud and Shippo.

- Parcel2Go documents OAuth2, quotes, orders, labels, normalised tracking, webhooks and a checkout deeplink.
- Sendcloud documents API-key authentication; OAuth2 is currently limited beta. Carrier contracts can be connected in the subscriber's Sendcloud account.
- Shippo supports connected carrier accounts and OAuth2 for carriers that support it.

## Live database foundation
Added public.shipping_provider_connections with one connection per tenant/provider and tenant-scoped RLS.

Added acquisition fields:
- shipping_provider
- shipping_provider_connection_id
- shipping_provider_shipment_id
- shipping_tracking_url
- shipping_status
- shipping_status_updated_at

No provider API secret is stored in this table. Secrets must remain server-side.

## Business boundary
TradeFlow does not collect, pay, reimburse or add customer shipping charges to acquisition financials. The connected provider/account owns shipping billing. Existing manual label/QR override remains the fallback.

## Next implementation phase
Add server-side provider adapters and secure credential/OAuth connection flows. Do not put provider secrets in browser JavaScript or public database columns. Once a real provider account is connected, add shipment creation/rate retrieval and webhook-driven tracking updates without replacing the existing acquisition workflow.
