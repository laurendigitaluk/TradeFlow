# TradeFlow Checkpoint — Shipping Provider Self-Service Catalogue

Date: 22 September 2026

## Purpose

TradeFlow Shipping Settings is now being structured as a self-service shipping integration centre. A subscriber can browse shipping platforms and direct couriers, open provider setup instructions, enter the credentials/configuration the provider requires, and save the connection securely without needing TradeFlow staff to manually configure the account.

## Provider model

Providers are stored in `public.shipping_provider_catalog` rather than being hard-coded into the Settings page.

Current catalogue includes:

- Parcel2Go
- Sendcloud
- Shippo
- Shiptheory
- Scurri
- Metapack
- Linnworks
- Royal Mail
- Evri
- Yodel
- DPD
- DHL eCommerce UK
- Parcelforce
- UPS
- FedEx
- DX
- APC
- InPost
- Whistl
- Amazon Shipping

The catalogue distinguishes multi-carrier platforms from direct couriers/carriers and records the expected connection method, setup instructions, provider documentation, required fields and capabilities.

## Settings experience

Shipping Settings now provides:

- provider search
- filter for multi-carrier platforms or direct couriers
- connection status
- provider-specific setup instructions
- direct provider setup/documentation links
- provider-specific credential fields
- secure connection saving
- environment selection
- clear distinction between active adapters and providers whose connection framework is ready but whose TradeFlow adapter is not yet active.

## Security

A new `shipping_provider_catalog` table contains non-secret provider configuration.

`shipping_provider_connections` now has `credentials_vault_id` for generic provider credentials.

New SECURITY DEFINER RPC:

`subscriber_save_shipping_provider_connection(...)`

stores submitted credentials in Supabase Vault and never stores the credential JSON in the browser or ordinary connection metadata.

New service-only RPC:

`shipping_provider_credentials_for_service(connection_id)`

allows future server-side provider adapters to retrieve the decrypted credential payload. Execution is revoked from public, anon and authenticated and granted only to service_role.

The existing Parcel2Go secure connection path remains authoritative for the active Parcel2Go adapter.

## Current adapter status

- Parcel2Go: active secure connection/test path.
- Sendcloud: catalogue/setup information present; OAuth adapter not yet active.
- Shippo: catalogue/setup information present; OAuth adapter not yet active.
- Shiptheory, Scurri, Metapack, Linnworks and direct courier connections: self-service configuration framework present; provider-specific production adapters still need to be implemented and tested before they can appear as usable integrated shipping options.

A provider must not be presented as an active integrated shipping option merely because credentials have been saved.

## Accepted-sale workflow

The existing accepted-offer flow remains unchanged:

1. Send shipping label.
2. Choose Send a manual label OR Use integrated shipping.
3. Manual mode exposes label, QR, tracking and service controls.
4. Integrated mode exposes only connected/active shipping services.
5. Customer remains responsible for arranging and paying shipping.
6. TradeFlow does not collect, pay or reimburse customer shipping costs.

## Official provider research used for this catalogue

- Royal Mail API onboarding uses an API account, registered application, client ID/client secret and API subscription; some APIs require approval.
- Yodel provides a public API Developer Portal where users create accounts, applications and select API plans; some plans may require access approval.
- DHL eCommerce UK requires an active customer account and uses OAuth 2.0 Client ID/Client Secret credentials for UAT/production.
- UPS direct API integration uses OAuth 2.0 Client ID/Client Secret credentials.
- FedEx uses API Key/Secret Key with OAuth 2.0 and may require additional customer credentials depending on integration.
- Shiptheory and Scurri provide multi-carrier integration models covering multiple UK couriers.

## Repository changes

Branch: `feature/shipping-provider-catalogue`

Migration:
`supabase/migrations/20260922190657_shipping_provider_catalogue_and_self_service_connections.sql`

Settings:
- `settings.html` cache buster v8
- `settings.js` updated to v8
- settings provider catalogue is data-driven rather than hard-coded to Parcel2Go/Sendcloud/Shippo.

## Next implementation stage

Implement provider adapters one at a time, starting with the highest-value UK services and multi-carrier platforms. Each adapter must have:

- official authentication method
- secure credential/OAuth handling
- connection test
- quote/service retrieval where supported
- shipment creation
- label retrieval
- tracking
- webhook/status synchronisation where supported
- customer-paid shipping preserved
- no provider credentials exposed to customers or browser code.
