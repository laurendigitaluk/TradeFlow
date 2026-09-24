# TradeFlow Checkpoint — 21 September 2026 — Shipping Provider Connections

## Requirement
Subscribers connect their own multi-carrier shipping account. Their provider account remains responsible for courier billing and payment. TradeFlow stores operational shipment and tracking data only.

## Provider decision — 24 September 2026
The active integrated provider for the current TradeFlow build is **Parcel2Go only**. Parcel2Go is the single multi-carrier connection; individual Royal Mail, Evri, Yodel, DPD, DHL, Parcelforce, UPS and FedEx connections are not exposed in the current shipping settings UI. Manual label/QR handoff remains the fallback.

Parcel2Go's API documentation confirms OAuth2 client-credentials authentication, quotes, orders, labels and tracking. Sandbox and Live use separate credentials and endpoints. citeturn0search0

## Live database foundation
Added public.shipping_provider_connections with one connection per tenant/provider and tenant-scoped RLS.

Added acquisition fields:
- shipping_provider
- shipping_provider_connection_id
- shipping_provider_shipment_id
- shipping_tracking_url
- shipping_status
- shipping_status_updated_at

No provider API secret is stored in the business connection table. Secrets remain server-side in Supabase Vault. Supabase documents Vault as encrypted secret storage and supports updating an existing secret by UUID. citeturn1search0turn3search0

## Business boundary
TradeFlow does not collect, pay, reimburse or add customer shipping charges to acquisition financials. The connected provider/account owns shipping billing. Existing manual label/QR override remains the fallback.

## 24 September 2026 — Parcel2Go connection-save repair
The first live connection attempt exposed a Vault error:

`duplicate key value violates unique constraint "secrets_name_idx"`

Root cause: the earlier Parcel2Go connection RPC called vault.create_secret() with a deterministic secret name every time. Supabase Vault secret names are unique, so a retry could collide with an existing secret. The failed attempt left an orphaned Vault secret with the expected tenant/provider name but no shipping_provider_connections row.

The Parcel2Go connection flow has now been repaired:
- reuses the existing connection's Vault secret when present;
- reuses the known tenant/provider Vault secret if it exists without a connection;
- otherwise creates the secret once;
- updates the existing Vault secret rather than creating another copy on subsequent saves;
- stores the Parcel2Go Client ID in api_client_id;
- stores the same Vault secret ID in api_client_secret_vault_id and credentials_vault_id;
- resets the connection to pending when credentials/environment are changed;
- clears the previous connection/test timestamps when credentials are replaced.

The Shipping Settings page now uses the dedicated Parcel2Go connection RPC rather than the generic provider-catalogue save path. **Save and test connection** securely saves the Client ID/Secret and then calls the existing shipping-provider-test Edge Function. The test performs only Parcel2Go OAuth authentication; it does not create or purchase a shipment. A successful test marks the connection connected.

GitHub source changes:
- shipping-settings.js commit 0fcd65fa973197a99ba6c35ee0863eb30b1eace4
- shipping-settings.html cache refresh commit 635d9856b69a8e304545e1726f2121ad5b765785
- migration source supabase/migrations/20260924210000_repair_parcel2go_connection_save.sql commit cbc884ff3498227a994f4bf8dc5d312abe6073cb

The database migration is **applied live** to Supabase project twfbmjwwqzxdxvclxbun.

The existing shipping-provider-test Edge Function is active and already uses the correct Parcel2Go OAuth endpoints based on the stored connection environment.

## Verification state
**Implemented in GitHub:** yes.  
**Live DB repair:** yes.  
**Browser verification of the repaired save/test flow:** pending.

## Next implementation phase
Once the Parcel2Go connection test succeeds, add server-side shipment/rate/label creation and tracking updates without replacing the existing acquisition workflow. Do not put provider secrets in browser JavaScript or public database columns.

## 24 September 2026 — Parcel2Go connection is browser verified

The intended subscriber setup is now confirmed as:

Parcel2Go Client ID + Client Secret → Save and test connection → Connected.

TradeFlow uses Parcel2Go as the single integrated multi-carrier provider. Direct carrier credential setup is not exposed. Manual label/QR shipping remains the fallback path.

Browser verification completed on 24 September 2026 using the Camerashack test subscriber's Parcel2Go Live credentials. Shipping Settings displayed Connected and: Connected successfully to Parcel2Go Live. Authentication passed; no shipment was created.

The Vault reader repair was applied live after the initial test exposed a service-only credential-read failure. The shipping-provider-test Edge Function is active and includes CORS handling plus tenant authorization. The connection test performs OAuth authentication only; it does not create or pay for a shipment.

The Buying dashboard's integrated shipping helper has also been simplified so Parcel2Go is the fixed integrated provider rather than a selectable list of direct providers.

Parcel2Go's official API documents OAuth2 client credentials, separate sandbox/live credentials, live quoting, order creation, payment, labels and tracking. citeturn2view0turn3view0

Verification state:
- GitHub implementation: verified.
- Live Supabase connection/test path: verified.
- Browser connection test: verified.
- Actual shipment/label purchase: not yet tested or created.

Next phase: implement the server-side Parcel2Go quote/service-selection flow in Buying. Obtain a live quote from the connected subscriber account using the shipment's collection/delivery details and parcel dimensions/weight, present the returned services, and only create/pay for a shipment after an explicit subscriber action. Do not put provider secrets in browser JavaScript.


## 24 September 2026 — Buying valuation/manual-offer UI simplified

The Buying dashboard manual valuation/offer area has been consolidated into one **Valuation & manual offer** box. The separate confidence field and separate Offer box have been removed from the subscriber UI.

The single box now contains:
- Manual buyer offer (cash)
- Manual trade-in offer
- Send manual offer to customer

Research evidence remains directly below this workflow so the subscriber can compare evidence before entering the manual values.

Automatic catalogue pricing remains authoritative. When an approved automatic valuation exists, the manual buyer/trade-in inputs are disabled and manual initial offers are blocked. When manual pricing is used, sending the manual offer creates and approves one manual valuation and publishes one initial offer record linked to that valuation; the record carries the cash/trade-in choices together.

GitHub implementation commit: f8665ea638780850c9d69ddb796c54b8a9500418 (with the preceding workflow simplification commit 7e52ea833bdfde1a190596dafc161f1eeec45958).


## 24 September 2026 — Unified initial offer record and shipping-label state

The manual initial offer is now one published offer record linked to one valuation. The valuation carries both cash and trade-in values, and the customer chooses either option from the same customer-facing offer. The selected option is recorded when the customer accepts it; a second simultaneous published initial offer is not created.

After initial acceptance, the customer remains in the receipt workflow. If no shipping label/QR has been created yet, the customer presentation is **Shipping label required — not ready to send**. The existing database purchase stage remains `awaiting_item` so established transitions are not changed. Once a valid label/QR handoff exists, the presentation becomes **Shipping instructions sent — ready to send**.

The Buying dashboard also now includes the shared `money()` formatter required by the financial/offer rendering path, preventing the previous `money is not defined` browser error.
