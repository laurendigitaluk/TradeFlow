# TradeFlow Test One Restore Point — 23 September 2026

## Purpose

This checkpoint locks the completed **Test One** state before starting Test Two.

Test One followed a new subscriber and a new subscriber customer through the complete operational path from customer submission/purchase workflow through inspection, payment completion, Inventory, Selling, Sales Channels and the published retail listing.

## GitHub restore point

- Repository: laurendigitaluk/TradeFlow
- Restore branch: checkpoint-test-one-20260923
- Restore branch base/current checkpoint commit: 80c6e20b4fa89b37ed6fab2480fb1eb46293a0d1
- Checkpoint commit includes the editable Sales Channels / Marketplace Management foundation and the corresponding documentation updates.

To restore the application code to this Test One state, use branch `checkpoint-test-one-20260923` or commit `80c6e20b4fa89b37ed6fab2480fb1eb46293a0d1` as the known-good code baseline.

## Live Supabase checkpoint

Project: twfbmjwwqzxdxvclxbun

The live database is the authoritative database state for this checkpoint. Latest verified migrations include:

- 20260923190050 — expose_published_listing_data_for_public_retail_details
- 20260923184427 — publish_store_listing_media_safely
- 20260923183605 — prevent_duplicate_active_listings_and_restore_media_read_access
- 20260923122804 — 20260923000004_sales_channel_inventory_sales_flow
- 20260923114839 — 20260923000003_fix_inventory_payment_link_order
- 20260923001846 — 20260923000002_purchase_payment_completion_and_secure_bank_view
- 20260922234744 — 20260923000001_final_offer_customer_notification

## Test One completion boundary

The following areas are treated as part of the known-good Test One baseline:

- New subscriber/business setup.
- New subscriber customer account and customer relationship.
- Customer selling/request journey.
- Buying and valuation workflow.
- Final offer and customer acceptance flow.
- Customer bank-detail handoff.
- Payment completion and purchase creation.
- Acquisition and Inventory creation at purchase completion.
- Inventory to focused Selling workspace.
- Purchase/source information and photographs carried into Selling.
- Retail condition and listing preparation.
- Website retail listing publication.
- Public retail product page and product photography.
- Sales Channels / Marketplace Management foundation.
- One physical Inventory asset as the stock master record.
- Per-channel listing architecture.
- Editable/add/remove Sales Channels foundation.
- eBay/Amazon setup guidance without pretending either marketplace is connected.

## Intentionally not completed in this checkpoint

- Subscriber payment processing for the subscriber's own website Subscribe/receive-payment flow.
- Real eBay OAuth/API connection.
- Real Amazon SP-API connection.
- Channel-specific marketplace publishing/delisting.
- Authoritative cross-channel sale propagation and automatic DELIST REQUIRED handling.

## Test Two rule

Test Two should begin from this checkpoint without changing the known-good Test One baseline unnecessarily. Any new failure should be diagnosed against this restore point first rather than repaired by overwriting or bypassing existing working behaviour.
