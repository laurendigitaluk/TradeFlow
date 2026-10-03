# TradeFlow Internal Backend & Owner Dashboard Manual

**Purpose:** authoritative operational guide to the TradeFlow subscriber/business backend.  
**Audience:** TradeFlow Platform Owner/admin operators who require internal backend, security and Owner Dashboard reference. This is an internal operational/technical manual and is not part of the subscriber-facing workflow.  
**Subscriber-facing documentation:** normal subscriber operation belongs in `subscriber-website-manual.html` and `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`.\n\n**Owner Dashboard:** `platform-owner-dashboard.html` is the restricted Platform Owner entry point. The Backend Manual link is available from that Owner Dashboard and is intentionally not exposed in the subscriber dashboard. This document retains deeper backend, security, workflow and implementation reference for owner/admin continuity and internal maintenance. Subscriber users do not need this manual; it is linked from the restricted Platform Owner Dashboard only.

## 1. What TradeFlow is

TradeFlow is a multi-tenant buying, valuation, purchasing, inventory, selling, retail-order, fulfilment and returns platform. Each subscriber business operates inside its own tenant boundary.

The public website is the customer-facing entry point. The backend is where the subscriber operates the business after a customer submits a request or a stock item enters the business.

The authoritative operational chain is:

**Buying → Valuation → Offer → Customer response → Shipping/receipt → Inspection → Final offer → Payment → Inventory → Selling/Listing → Retail Order → Fulfilment → Returns.**

A separate direct-stock route can enter at **Category → Product → Properties → Photographs → Inventory → Listing → Customer Shop** without going through Buying.

## 2. TEST and LIVE

TradeFlow has two permanent environments.

| Layer | TEST | LIVE |
|---|---|---|
| GitHub | `cloudflare-test` for current TEST Cloudflare work; `production` for LIVE | `production` |
| Supabase | `twfbmjwwqzxdxvclxbun` | Separate production project |
| Data | Test data | Real business data |
| Purpose | Build, repair, test | Operate the live business |

Never experiment in LIVE. Never copy TEST customer or transaction data into LIVE.

The release path is:

1. Make the change in a feature/checkpoint branch or the active TEST branch (`cloudflare-test` for the current Cloudflare deployment).
2. Deploy/test against TEST.
3. Verify browser behaviour and database state.
4. Record a release checkpoint.
5. Promote the approved commit to `production`.
6. Apply the version-controlled migrations/functions/configuration to LIVE.
7. Run a clean LIVE smoke test.

## 3. Authentication and tenant boundary

TradeFlow separates Platform Owner, subscriber business users and customers.

### Subscriber roles

The tenant roles are:

- **Owner** — business owner and highest tenant-level operational role.
- **Admin** — authorised business administrator.
- **Staff** — operational worker with the permissions granted to the role.

A subscriber session establishes the tenant context. Backend queries and workflow RPCs must remain tenant-scoped.

### Customer accounts

Customers use the customer portal. Customer authentication is separate from subscriber authentication. A customer account is linked to the relevant tenant and must not expose another tenant's customer, buying, order, address, bank or return data.

### Platform Owner

Platform Owner controls the TradeFlow SaaS layer, including commercial plan configuration and platform-level settings. Platform Owner is not a substitute for a subscriber tenant role.

## 4. Main backend areas

The subscriber backend is organised around these operating areas:

- Dashboard
- Buying
- Inventory
- Selling
- Orders
- Fulfilment
- Returns
- Customers
- Business/Website settings
- Shipping Settings
- Sales Channels
- account/settings controls

The exact navigation shown to a user depends on the current entitlement, role and enabled modules.

## 5. Dashboard

The Business Dashboard is the operational overview.

It shows live workflow counts for core areas including:

- Buying
- Inventory
- Selling
- Orders
- Fulfilment
- Returns

It also provides attention/workflow information for work that needs action.

The dashboard counts must come from the authoritative tenant-scoped workflow/read boundaries rather than legacy order resources. A zero count is not proof that no work exists if the underlying query failed; runtime errors must be investigated.

## 6. Buying

Buying is the customer-to-business acquisition journey.

A customer submits a selling/buying request through the public site. The request is linked to the subscriber tenant and, where applicable, to the exact active catalogue product selected by the customer.

The backend stores the customer submission, product/category context, condition, photographs and other structured information.

### Buying stages

The operational stages include, depending on the journey:

1. New/request received.
2. Valuation required or automatically valued.
3. Initial offer ready/sent.
4. Customer accepts or refuses.
5. Shipping hand-off.
6. Item sent.
7. Item received.
8. Inspection.
9. Testing/repair where required.
10. Final offer required/sent.
11. Customer accepts/refuses final offer.
12. Payment required.
13. Payment completed.
14. Purchased/closed.

Closed/refused/returned work must not continue to appear as active work requiring staff action.

## 7. Catalogue and automatic valuation

The Buying catalogue is subscriber-specific but based on TradeFlow's master catalogue/product structure.

When the public customer journey selects a catalogue product, the request should carry the exact subscriber buying-product identity rather than relying on a loose product name.

Automatic valuation uses the current supported research basis documented in the system:

- UK New research is the automatic calculation basis.
- The research must match the subscriber's exact product context.
- UK Used evidence may be displayed as market evidence but is not the automatic calculation basis.
- If the required automatic research/rule is not available, the request remains a manual valuation workflow.

Automatic valuation is idempotent. Re-running the check must not create duplicate valuations or offers.

### Manual override

A subscriber can manually override an automatic valuation where the workflow permits it. The manual approved valuation/offer becomes authoritative over the previous automatic value.

Do not manually alter database stages to bypass the valuation workflow.

## 8. Refusing a valuation or offer

A subscriber can refuse a valuation where the UI provides the refusal action.

The refusal is a workflow state, not merely a deleted record. The customer must receive the appropriate status/notification, and the item must leave the active workflow when the refusal rules say it is closed.

Customer refusal of an initial offer similarly closes the relevant buying item according to the current workflow rules.

Do not revive refused work by changing a stage directly in the database.

## 9. Shipping hand-off

TradeFlow's shipping model is **manual**.

The subscriber does not use the retired Parcel2Go API/checkout flow.

The subscriber configures preferred shipping services under:

**Settings → Shipping Settings**

The business can maintain shipping-service links and choose which services are presented for its workflow.

When an accepted offer requires the customer to send an item, the subscriber prepares the shipping instructions/label.

### Customer shipping responsibility

The customer pays for their own shipping. TradeFlow does not collect or process the customer's shipping cost as part of the buying workflow.

### Label

The current manual label requirement is:

- 6 × 4 inch portrait layout for a ZDesigner GK420 label printer.
- Printable at the top-left of an A4 sheet.
- The label artwork should fill the intended label area without unnecessary extra options.

The customer portal can display the shipping information and provide the relevant label/file access.

## 10. Shipping status and receipt

The shipping stage records the available shipping information, including:

- date shipped;
- service;
- tracking number;
- label where supplied.

When the subscriber receives the item, the authoritative **Confirm item received** action moves the acquisition/buying workflow into the received/inspection state.

The customer sees a corresponding status such as:

**Item received by subscriber — inspection next.**

The subscriber backend shows the item as received and exposes the inspection action.

## 11. Inspection

Inspection is an internal subscriber workflow.

The inspection workspace is opened from the Buying workflow.

The purpose is to compare the received item against the customer's submission and the agreed buying conditions.

Inspection can capture the condition and inspection outcome. Where the item does not match the agreed condition, the current refusal/return rules can require a condition mismatch before the item is refused.

An inspection refusal can initiate the buying-item return-to-customer workflow.

An item that passes inspection continues to the final-offer/payment stages.

## 12. Final offer

After inspection, the subscriber can issue the final offer where required.

The customer receives the final offer and can accept or refuse it.

The internal wording should use the current workflow terminology, including **Final offer received** where that is the customer-facing state.

If the customer accepts the final offer, the workflow moves to payment.

## 13. Customer bank details and payment

For a purchase that requires bank payment, TradeFlow checks whether the customer has bank details recorded.

The customer can provide/update bank details through the customer account where the workflow requires them.

TradeFlow does not perform the external bank transfer itself.

The correct operational sequence is:

1. Customer accepts the final offer.
2. Customer bank details are available.
3. Staff make the actual bank transfer externally.
4. Staff enter the payment/bank reference in TradeFlow.
5. Staff use the payment completion action.
6. The authoritative purchase-completion transaction creates the downstream purchase/acquisition/inventory records.

The **Confirm Payment Sent / Complete Purchase** action must not be used as a substitute for actually making the external bank transfer.

## 14. When an item becomes Inventory

Inventory is created as part of the authoritative purchase-completion transaction.

Before payment completion, the item remains a Buying/pre-acquisition workflow item.

After successful purchase completion:

- the purchase is recorded;
- internal acquisition/audit records are created;
- the inventory asset is created;
- the inventory asset is prepared for sale according to the current workflow.

The old Acquisitions screen is not the operational hand-off. Acquisitions remain internal accounting/audit records.

## 15. Inventory

Inventory is the master operational stock record after purchase.

The inventory workspace contains the information needed to prepare the physical item for sale.

Staff should:

1. Open the purchased inventory asset.
2. Review the supplied customer and inspection information.
3. Check photographs and product details.
4. Complete the required inventory information.
5. Use **REVIEW & COMPLETE**.
6. Only after the completion gate is satisfied, use **SEND TO SALES**.

The same inventory asset must not be sent into Sales repeatedly to create duplicate listings.

### Condition terminology

The current business condition vocabulary is:

- Poor
- Good
- Very Good
- Excellent
- Opened
- Never Used
- Sealed

Use the current UI/database terminology rather than recreating the retired A/B/C/D condition system.

## 16. Selling

Selling is where an inventory asset is prepared as a retail listing.

Selling receives the selected inventory asset and carries forward the relevant source information.

The listing preparation can include:

- title;
- description;
- asking price;
- condition;
- postage/dispatch information;
- photographs;
- sales channel.

The original buying category/branch should be carried forward where the item originated from Buying. Sales staff should not have to invent a new unrelated classification.

### Sales Channels

The current channel model includes destinations such as:

- Website
- eBay
- Amazon
- Other

A channel can be enabled/disabled and can contain setup instructions. A marketplace connection must not be invented merely because a channel exists.

The physical inventory item remains the master record. Listings are channel-specific representations of that inventory.

## 17. Public shop and listing lifecycle

A listing can move through states such as:

- draft;
- ready;
- published;
- reserved;
- sold;
- delisted.

When a listing is sold, the sale is recorded against the retail order/listing history.

A product sold on one sales channel must not remain incorrectly available on another channel if the channel-specific delisting rule applies.

Editing an existing listing updates that listing; it must not create a duplicate listing.

Public product pages read the published listing information through the authorised published-store data boundary.

## 18. Retail Orders

Retail checkout is intentionally separated from Buying.

A customer shopping for an inventory item uses the retail basket/checkout journey.

A pre-payment basket is not the same as a completed order.

The system should not create a completed customer order merely because a product was placed in a basket or a payment attempt was started.

After successful payment, the authoritative retail-order lifecycle takes over.

Cancelled pre-payment activity must not remain as a completed order.

## 19. Fulfilment

Fulfilment operates after a paid retail order.

The subscriber prepares the item for dispatch and records the shipping hand-off.

The current customer-shipping model is manual. The subscriber supplies the relevant label/QR/tracking information where required.

The customer can see shipment/tracking information in My Orders when that information is available.

TradeFlow does not assume that a shipping API is required to complete the fulfilment workflow.

## 20. Returns

There are separate return contexts, including customer retail returns and buying-item returns.

### Retail customer return

A customer can request a return after the applicable delivery stage.

The subscriber can accept or refuse the return.

The Selling/Sold history can show the return decision without changing the fact that the original listing was sold.

Current sold-status presentation includes states such as:

- **CLOSED — RETURN REFUSED**
- **RETURN ACCEPTED — AWAITING RETURN**
- **RETURN REQUEST — AWAITING DECISION**

A denied return remains part of transaction history.

### Buying-item return

A customer may be returned an item from the Buying workflow after an applicable refusal/inspection decision.

Return shipping label information is optional where the current workflow permits it.

Adding return tracking information does not by itself create an unrelated workflow transition.

A completed return must leave the active workflow while remaining available as historical evidence.

## 21. Customer portal relationship

The customer portal is the customer-side view of the same tenant-scoped business transaction.

Customers can see relevant:

- selling/buying requests;
- offers;
- shipping instructions/status;
- order information;
- tracking;
- payment status;
- returns;
- addresses;
- bank details where required.

Internal subscriber terminology should not be exposed unnecessarily to customers.

The customer portal must never be used to bypass subscriber workflow permissions.

## 22. Website Builder versus backend

The public subscriber website is controlled through the Website Builder, but its published content and the business backend are separate concerns.

The Website Builder manages presentation/content such as:

- templates;
- branding;
- business identity;
- colours/backgrounds;
- homepage sections;
- buying/selling calls to action;
- website media;
- domain information;
- public shop presentation.

The backend manages the actual business records and workflow.

For example, changing a public website button does not itself purchase an item, change an offer or mark inventory as sold. The button must lead into the authorised workflow.

The separate `subscriber-website-manual.html` explains the website-building controls. This backend manual explains what happens after those public-site journeys enter TradeFlow.

## 23. Security and permissions

Security is enforced at several layers:

1. Authentication establishes the user identity.
2. Tenant context establishes which business the user belongs to.
3. Role/permission checks determine what the user can do.
4. RLS and tenant-scoped queries prevent cross-tenant data access.
5. Authoritative workflow functions enforce valid state transitions.
6. Sensitive operations are not exposed as unrestricted anonymous database functions.

The current security release candidate also restricts anonymous/public execution of SECURITY DEFINER functions except for deliberate public-read/media helpers.

Do not solve a permission error by granting broad database access. Find the correct permission, RLS policy or authoritative RPC boundary.

## 24. Database and code rules

The repository is the source of truth for reproducible application/database changes.

Database changes must be timestamped migrations under:

`supabase/migrations/`

Edge Functions are under:

`supabase/functions/`

Frontend controllers and pages are versioned in the repository.

After a material repair:

1. verify the actual code path;
2. verify the database function/table/policy;
3. test the browser journey;
4. record the result;
5. update the AI/manual documentation;
6. create/update the checkpoint.

## 25. Troubleshooting method

When a backend action fails:

1. Identify the exact page/button/action.
2. Identify the authenticated user and tenant.
3. Check the browser console/network response.
4. Identify the first failing RPC/API/storage request.
5. Inspect the current GitHub implementation.
6. Inspect the current Supabase function/table/policy.
7. Compare against the latest checkpoint.
8. Repair the smallest authoritative layer.
9. Re-test from the beginning of the affected journey.
10. Verify the database state after the action.
11. Update documentation and checkpoint.

Do not patch only the visible error message if the underlying workflow boundary is wrong.

## 26. Production release control

The `production` branch is not a development branch.

A release must have:

- approved Git commit SHA;
- migration state;
- Edge Function versions where applicable;
- configuration/secrets confirmed without placing secrets in Git;
- TEST browser verification;
- production smoke-test result;
- rollback/checkpoint reference.

Production database changes should be delivered from version-controlled migrations rather than ad-hoc SQL.

## 27. Shipping architecture rule

The following are retired and must not be reintroduced into the current workflow:

- Parcel2Go API quote creation;
- Parcel2Go checkout;
- Parcel2Go payment links;
- automatic Parcel2Go order creation;
- customer shipping payment through TradeFlow.

Current model:

**Subscriber configures shipping services → subscriber supplies/records label where required → customer ships item → customer/subscriber records tracking → subscriber confirms receipt → inspection continues.**

## 28. Quick operating map

**Customer sells an item to the business**

Public site → customer account/request → Buying → valuation → offer → customer accepts → shipping → item received → inspection → final offer → bank details → external bank payment → payment reference → purchase complete → Inventory → Review & Complete → Sales → listing → customer shop.

**Customer buys an item from the business**

Customer shop → product → basket → checkout/payment → completed retail order → fulfilment → dispatch/tracking → delivery → possible return → return decision/completion.

**Business develops a new feature**

GitHub feature/checkpoint branch → `main` → TEST Supabase → browser/database verification → checkpoint → `production` → LIVE Supabase → production smoke test.

## 29. Related manuals

- **Backend User Manual:** this document.
- **AI Operating Manual:** `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- **System/Developer Handbook:** `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- **Live Launch Runbook:** `docs/TRADEFLOW-LIVE-LAUNCH-RUNBOOK.md`
- **Subscriber Website Manual:** `subscriber-website-manual.html` — public/site-building controls, not backend operations.
- **Human User Manual:** `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`

Last updated: 30 September 2026.


## 2026-10-01 — ResellerClub domain integration boundary

The TradeFlow registrar provider is now ResellerClub. The provider-neutral domain schema remains authoritative and is not to be replaced. The first backend integration boundary is the TEST Edge Function `resellerclub-domain-availability`, which keeps the ResellerClub API key server-side, verifies the subscriber JWT and active tenant membership, and returns normalised availability states.

TEST ResellerClub configuration uses `RESELLERCLUB_API_KEY`, `RESELLERCLUB_X_USER_ID` and `RESELLERCLUB_API_BASE_URL`. Secrets belong in Supabase Edge Function Secrets, never browser code or GitHub. The Sandbox API was independently verified with 200 responses for Country and TLD APIs and a successful documented .com availability request. A .co.uk request returned provider status `unknown`, so that state remains non-purchasable until a definitive registry response is available.

Do not add registration, customer/contact creation, Stripe domain payment, DNS/hosting provisioning or renewal code until the availability boundary has been browser-tested in TEST. LIVE and `production` remain untouched.


---

# DOMAIN REGISTRATION HANDOVER — 2026-10-02

## Verified current TEST state

TradeFlow's domain-purchase flow has now reached the end of the payment and registrant-information stages in TEST/STAGING.

Environment:
- GitHub TEST/STAGING branch: `main`
- TEST Supabase project: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- LIVE has not been changed during this domain-registration work.
- Current tested registrar: Porkbun.
- Porkbun TEST credentials are sandbox credentials. Real registrar registration must remain disabled until TEST is fully verified.

Verified sequence:
1. Subscriber searches for a domain.
2. Porkbun availability is checked server-side.
3. TradeFlow calculates the customer price in GBP using the stored USD→GBP FX rate and platform markup.
4. Subscriber chooses an available domain.
5. TradeFlow creates a domain order and Stripe Checkout session.
6. Stripe TEST payment was successfully completed for `camerashack.co.uk` at £5.27 GBP.
7. Stripe webhook changed the domain order to `payment_confirmed`.
8. Subscriber was returned to the domain registrant page.
9. Registrant information was submitted and saved.
10. The order is now `registrant_details_saved`.
11. The TEST UI provides the next controlled step: Porkbun sandbox validation. The sandbox validation has been shown as passed in the UI.

Current test order:
- hostname: `camerashack.co.uk`
- retail amount: £5.27 GBP
- status: `registrant_details_saved`
- Stripe Checkout/payment reference is stored.
- A linked `tenant_domain_registrants` record exists.

## Domain registrant architecture

New TEST table:
- `public.tenant_domain_registrants`
- One-to-one with `tenant_domain_orders`.
- Stores registrant name, organisation, address, city, region, postcode, country code, email and telephone.
- Tenant RLS is enabled.
- Tenant members can read their tenant's registrant record.
- Website managers/editors can insert/update it.

New domain-order status:
- `registrant_details_saved`

New TEST Edge Function:
- `save-domain-registrant`
- JWT protected.
- Verifies the authenticated user and tenant membership.
- Validates required registrant fields.
- Saves the registrant record.
- Moves the order from `payment_confirmed` to `registrant_details_saved`.

New TEST frontend:
- `domain-registrant.html`
- `domain-registrant.js`

The existing provider-neutral domain foundation remains in place and must not be rebuilt.

## Domain payment architecture

`create-domain-checkout-session` remains a TEST Edge Function. It:
- authenticates the subscriber;
- verifies tenant membership;
- rechecks Porkbun availability server-side;
- reads trusted platform pricing settings;
- calculates the GBP retail price;
- snapshots registrar USD cost, FX rate, markup and pricing period;
- creates/reuses Stripe Checkout;
- stores the Stripe Checkout session reference;
- returns the customer to the registrant-details stage after successful payment.

The existing Stripe webhook recognises domain payments through domain-order metadata and moves the order to `payment_confirmed`.

Actual Porkbun registration has NOT been enabled.

## Immediate next stage

The next development/test stage is **Porkbun Sandbox Registration**:

1. Use the saved registrant details for the paid TEST order.
2. Perform a Porkbun `dryRun: true` registration validation first.
3. Confirm the dry-run succeeds without making a real registration.
4. Perform the isolated Porkbun sandbox registration.
5. Record the provider domain ID and registration/expiry information.
6. Reconcile the successful sandbox registration into the existing `tenant_domains` provider-neutral table.
7. Test the existing domain connection/DNS/website-routing foundation against the newly registered sandbox domain.
8. Verify renewal/expiry fields and ownership/contact synchronisation.
9. Only after the entire TEST sequence is verified should LIVE registration be considered.

Do not:
- touch LIVE;
- make a real Porkbun registration request;
- revive Parcel2Go API work;
- switch back to ResellerClub;
- delete/rebuild the existing domain connection foundation;
- connect the Choose button directly to registrar registration;
- assume a sandbox registration is a real production domain.

## Working rule for the next chat

Before changing code:
1. Read this handover and the latest domain checkpoint.
2. Inspect current GitHub `main`.
3. Inspect current TEST Supabase schema/functions/state.
4. Identify the first unverified step.
5. Make the smallest change necessary.
6. Test in TEST.
7. Verify database state.
8. Update this documentation/checkpoint before moving to the next stage.


# 2026-10-02 — DOMAIN REGISTRATION CURRENT-STATE OVERRIDE

This section is authoritative for the current domain-registration work and supersedes any earlier registrar-provider description in this manual.

## Current environment

- TEST/STAGING GitHub branch: `main`
- LIVE GitHub branch: `production`
- TEST Supabase: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- LIVE has remained untouched during this domain-registration work.
- Current tested registrar provider: **Porkbun**.
- Porkbun TEST credentials are sandbox credentials.
- **ResellerClub is not the active registrar provider. Do not continue or extend the ResellerClub integration.**
- GoDaddy is not part of the TradeFlow registrar workflow.
- Manual shipping remains the final shipping architecture; do not revive Parcel2Go API integration.

## Verified TEST domain sequence

The following stages have been completed in TEST:

1. Porkbun availability search.
2. GBP customer pricing using the trusted stored FX rate and 25% markup.
3. Domain selection.
4. Stripe TEST Checkout.
5. Successful TEST payment for `camerashack.co.uk` — **£5.27 GBP**.
6. Stripe webhook confirmation — order became `payment_confirmed`.
7. Return to TradeFlow registrant-details page.
8. Registrant details submitted and saved.
9. Order became `registrant_details_saved`.
10. TEST UI currently reports that Porkbun sandbox validation passed.

The domain has **not** been registered with the real registrar. No LIVE domain registration has been performed.

## Current database/business state

The paid test order is for `camerashack.co.uk` at £5.27 GBP and is at `registrant_details_saved`. A one-to-one `tenant_domain_registrants` record is associated with the order.

The existing provider-neutral domain architecture remains authoritative:
`domain_tld_catalog`, `tenant_domain_orders`, `tenant_domains`, `published_site_index`, and `tenant_site_state`.

## Next development stage

The next stage is **Porkbun TEST sandbox registration**, not another payment test.

Work in this exact order:

1. Inspect current GitHub `main`, TEST Supabase schema/functions and the paid test order.
2. Inspect/confirm Porkbun registration requirements for the domain TLD.
3. Implement a TEST-only, JWT-protected dry-run registration validation using the saved registrant record.
4. Confirm `dryRun: true` succeeds without creating a real registration.
5. Perform the isolated Porkbun sandbox registration using sandbox credentials.
6. Capture provider domain ID and registration/expiry information.
7. Reconcile the result into the existing `tenant_domains` table.
8. Move the order through `registering` to `registered` only after successful reconciliation.
9. Test the existing domain connection/DNS/website-routing architecture.
10. Update all relevant documentation and the checkpoint after successful verification.

Do not touch LIVE, do not use real registrar credentials, do not revive Parcel2Go or ResellerClub, and do not rebuild the existing domain foundation.



## 2026-10-02 Domain registration backend state

The current TEST backend supports the sequence registrant_details_saved -> registering -> registered. Porkbun registration creates the domain using the account registration contact, so the implementation validates and applies the TradeFlow-saved registrant through Porkbun's updateContacts API before final reconciliation. For .co.uk, Porkbun performs address validation on registrant changes. The Porkbun order ID is stored as provider_order_id; no synthetic domain ID is created.


## 2026-10-02 Domain registration backend repair

The first sandbox registration created provider order 9913828. The subsequent updateContacts call failed because the previous payload specified only registrant and relied on existing admin contact data. The implementation now sends the saved contact as Porkbun's singular contact payload, which applies it to all four contact roles. A failed sandbox order with a recorded provider order is now treated as a reconciliation retry rather than a new registration attempt.


## 2026-10-02 Porkbun TEST sandbox registration — verified state

The TEST registration path now reaches registered using existing provider order 9913828 and creates the active tenant_domains row with acquisition source purchased. Version 5 corrected .co.uk TLD normalization so the sandbox contact-defer branch is reached; version 6 corrected the reconciliation value to match the database tenant_domains_acquisition_source_chk constraint. No second Porkbun registration is created on retry.

For the isolated .co.uk sandbox test, contact synchronisation is recorded as deferred rather than repeatedly calling updateContacts, avoiding the V096/new-registrant email loop. Expiry capture remains unverified: current TEST database expires_at and porkbun_expire_date are null.



## 2026-10-02 — Porkbun TEST registration expiry reconciliation

The Porkbun TEST registration path is now idempotent after a successful sandbox registration. For an already-registered sandbox order with a stored provider order ID, the registration function performs provider reconciliation only and does not create another registration.

Expiry handling uses the provider's domain lookup and, when the direct lookup does not expose `expireDate` or `createDate`, falls back to Porkbun `/domain/listAll` and matches the exact hostname. TradeFlow stores the provider-returned expiry in both the domain-order and tenant-domain records. It must never invent an expiry date.

Current TEST Edge Function version: 7. Current sandbox provider order: 9913828. The next manual test is to use **Refresh provider registration details** once and then verify the two SQL `expires_at` fields and the stored Porkbun expiry metadata. Only after that verification should provider-neutral website hostname routing be tested.


## 2026-10-02 — Porkbun TEST registration and expiry VERIFIED

The Porkbun sandbox registration stage is now verified in TEST for `camerashack.co.uk`.

- Provider order: `9913828`.
- TradeFlow order status: `registered`.
- `tenant_domain_orders.expires_at`: 2027-10-02 12:01:45 UTC.
- The reconciled `tenant_domains` row is `active`, with `acquisition_source=purchased` and `registrar_provider=porkbun`.
- `tenant_domains.expires_at`: 2027-10-02 12:01:45 UTC.
- Provider expiry metadata is populated.
- No second sandbox registration was created during reconciliation.

The TEST Edge Function is version 9. The .co.uk sandbox reconciliation now uses the shared Porkbun provider lookup and its `/domain/listAll` fallback when the direct domain lookup lacks lifecycle dates. Expiry is persisted only when returned by the provider.

Contact synchronisation remains deliberately deferred for the sandbox .co.uk path because immediate contact updates produced Nominet V096. This is a separate contact-sync issue and does not invalidate the verified registration/expiry stage.

**Next stage:** inspect and test the existing provider-neutral website/domain connection, website publish flow, `published_site_index` hostname routing and `tenant_site_state`. Do not rebuild the domain foundation, invent a DNS/hosting target, or modify LIVE.

## 2026-10-02 — Chatbot continuity and pre-launch domain sequence

The TradeFlow chatbot is a planned pre-launch component and must be completed and tested before the platform is declared ready for public launch.

### Chatbot architecture already agreed

**Phase 1 — Subscriber read-only assistant**
- Answer how-to and system questions.
- Primary knowledge source: the finalized Subscriber Website/User Manual plus approved TradeFlow documentation.
- May use appropriate authenticated subscriber/tenant context where required to answer the subscriber's own questions.
- Must not make arbitrary database changes.
- Must not have unrestricted SQL/database access.

Examples already agreed include: adding a logo, creating a listing, changing shipping services, buying a domain, understanding “Shipping Required”, understanding what happens after an item is received, and publishing a website.

**Phase 2 — Customer read-only assistant**
- Explain the customer's own item/order status and next steps.
- Explain shipping, returns, orders and other customer-facing workflow states.
- Customer data must remain tenant-scoped.

**Phase 3 — Messaging/enquiries**
- Controlled communication workflows.

**Phase 4 — Controlled actions**
- Only after the read-only phases are proven.
- Any action must have explicit permissions, tenant scoping and auditability.

### Chatbot security boundary

The chatbot must never expose another tenant's customers, orders, inventory, valuations, payments, domains, business information or personal information.

Safe architecture:

Authenticated user → TradeFlow chatbot → verified tenant/user identity → explicitly allowed read-only data → approved documentation/manual knowledge.

Not: chatbot → unrestricted database.

### Chatbot documentation dependency

The manuals must describe the actual current TradeFlow system before they become the chatbot's authoritative knowledge source. Historical sections may be retained for audit continuity but must not be treated as current instructions.

### Agreed pre-launch order

1. Complete and test the chatbot.
2. Audit current GitHub, TEST Supabase, Cloudflare TEST and checkpoints.
3. Choose the permanent Lauren Digital company domain.
4. Purchase the genuine Lauren Digital domain.
5. If required, purchase one inexpensive genuine test domain.
6. Prove real public DNS → Cloudflare → TEST Worker → TEST Supabase → published subscriber website.
7. Configure and verify the permanent Lauren Digital production domain separately.
8. Promote only an approved tested release to Production.
9. Complete final launch testing.

### Real-domain testing boundary

The Porkbun sandbox domain camerashack.co.uk is a simulated registration and cannot prove public DNS/Cloudflare routing. Do not force it through Cloudflare.

A genuine registered test domain is required for the real DNS/Cloudflare test.

### Current Cloudflare TEST state

- Worker: tradeflow-test
- Branch: cloudflare-test
- Worker URL: https://tradeflow-test.leannelaurenlowe.workers.dev
- Custom domains currently attached: none
- TEST Supabase: twfbmjwwqzxdxvclxbun
- LIVE must remain isolated.

### Continuity rule

After every material chatbot or domain change, update the Master Roadmap, System Handbook where appropriate, this AI Operating Manual, the relevant human/subscriber manuals and a checkpoint. Do not claim a feature is verified without browser/database evidence.


## 2026-10-02 — Owner Dashboard documentation boundary

This Backend User Manual is an internal Platform Owner/Owner Dashboard document. Subscribers should not be directed to this manual and do not need to understand TradeFlow's backend implementation.

The restricted `platform-owner-dashboard.html` is the intended entry point and links to this manual. The subscriber Business Dashboard contains normal operational manuals only.

## 2026-10-02 — Subscriber AI rules, usage and cost

TradeFlow AI is a separate subscriber feature and is not connected to Gary's personal Gemma research system. Gemma remains personal Quote System research infrastructure only.

The initial Subscriber Assistant is read-only and uses approved TradeFlow documentation plus only the minimum authenticated tenant information required for the current question. It must not have unrestricted SQL/database access, whole-table dumps or cross-tenant access.

An optional subscriber-owned AI/API connection may be supported. Where a subscriber uses their own provider, that provider's usage charges are the subscriber's responsibility. Provider credentials must be held server-side and must not be exposed to browser code or other tenants. A centrally funded TradeFlow AI option may be introduced later only with explicit commercial limits.

Product Research is a controlled feature: research a specific product, present evidence and sources, obtain subscriber approval, then save approved evidence and allow the existing buying-price calculation to use it. AI must not silently alter buying prices.

AI and research usage must be measurable and controllable by tenant/provider. Final customer-facing pricing, allowances and limits must be documented before public launch; do not invent commercial figures.

The Human User Manual must explain these rules in plain language. The Backend User Manual must document the operational controls and security boundary.


## 2026-10-02 — AI provider control foundation

TradeFlow TEST now has a provider-neutral `tradeflow-assistant` Edge Function. It authenticates the subscriber, verifies active tenant membership and exposes only a read-only assistant boundary.

The platform provider setting is server-side and can select from the reserved provider options `none`, `gemma`, `openai`, `anthropic`, `google` or `subscriber`. Changing the provider configuration does not require a subscriber website or chatbot code change.

Current TEST provider: **none**. No external AI provider is connected.

Gemma remains Gary's separate personal Quote System research system. It must not be connected to the TradeFlow subscriber or customer websites. If Gemma is later selected for TradeFlow, a separate TradeFlow-reachable Gemma instance must be used.

The gateway foundation is implemented; provider adapters, knowledge retrieval, usage accounting and subscriber-facing chat remain to be built and tested.
\n\n## 2026-10-02 — CURRENT TEST OVERRIDE: Subscriber Assistant\n\nThe active Cloudflare TEST branch for the current Assistant workstream is **cloudflare-test**. Historical references to main as TEST are retained for continuity and do not override this current Cloudflare deployment.\n\nThe TEST Subscriber Assistant is now authenticated and tenant-scoped. Its first browser test succeeded with provider=none and approved knowledge retrieval. The assistant remains read-only and does not have unrestricted SQL access.\n\nThe approved knowledge set has been expanded. Product Research remains a separate controlled workflow: research → evidence/sources → explicit subscriber approval → save approved evidence → existing buying calculation.\n

## PLATFORM OWNER — AI PROVIDER CONTROL — 2 OCTOBER 2026

The Owner Dashboard now contains an AI provider control section. It allows the platform owner to enable/disable Gemma, OpenAI, Anthropic, Google and subscriber-supplied AI, and select the active platform provider. `None` remains the default knowledge-only mode.

Provider secrets are not stored in the Owner Dashboard. They must remain server-side. The platform AI setting is stored in `platform_ai_settings` and is accessed through owner-only RPC functions. The `tradeflow-assistant` Edge Function reads the approved platform configuration through the service-role path and continues to enforce subscriber/customer tenant separation.


## Customer ↔ Subscriber Assistant Messaging — 2026-10-02

TradeFlow now supports a provider-neutral customer-to-business assistant handoff.

- Customers use **Customer Assistant** from the customer portal.
- The existing AI/knowledge gateway remains provider-neutral and can continue to operate with no external AI provider.
- If the assistant cannot provide an approved answer, the customer can choose **Send this question to the business**.
- Customer messages are stored in tenant-isolated assistant conversations.
- Subscriber users with an active tenant membership can open **TradeFlow Assistant → Customer Questions**.
- Subscriber owner/admin/staff users can read the conversation, reply to the customer, and close the conversation.
- Customer replies and subscriber replies remain scoped to the same tenant and customer conversation.
- Provider credentials are not stored in the customer or subscriber browser UI.
- The messaging layer does not require Gemma, OpenAI, Anthropic or Google to be enabled; those remain optional provider choices controlled by the platform owner.

Security boundary:
- Customer RPCs verify the authenticated user owns the customer record for the tenant.
- Subscriber RPCs verify an active tenant membership with owner/admin/staff role.
- Assistant conversation/message tables have RLS enabled and direct client table access is revoked; access is through the controlled RPCs.


## LIVE Release Audit — 2026-10-03

TradeFlow now has a separate LIVE Supabase project, `gxsrajtqzdjvmceqcpgv`, in `eu-west-2`. The LIVE release branch is `production`.

The current production code uses hostname-based environment separation and a production Worker configuration. TEST remains on `twfbmjwwqzxdxvclxbun`.

The TEST-only duplicate inventory serial warning migration is deliberately excluded from the LIVE release.

The provider-neutral Assistant architecture is included in the production code:
- owner-controlled provider selection;
- `none`, Gemma, OpenAI, Anthropic, Google and subscriber-provider options;
- Customer Assistant;
- customer-to-subscriber business messaging;
- subscriber Customer Questions/reply workflow.

The customer/subscriber messaging and AI-provider tables/RPCs have been added as version-controlled production migrations. The LIVE database and Edge Function deployment are not marked verified until the LIVE Supabase project can be directly inspected/deployed.

Manual shipping remains the current architecture. Parcel2Go API and ResellerClub are not to be reintroduced.

Verification status must remain explicit:
- GitHub release: **Implemented in GitHub**
- LIVE database: **not yet directly verified in the current tool session**
- Browser: **not yet verified**


## LIVE RELEASE OPERATIONS UPDATE — 3 OCTOBER 2026

The production Worker cache boundary for the protected Platform Owner Dashboard has been hardened.

Production commit: `6c9b061e5a20210aa8b6f416a3f8b68fb6357329`.

Change: `worker/index.js` now special-cases `/platform-owner-dashboard.html` before the normal static-asset early return and sets `Cache-Control: no-store`. The dashboard JavaScript was already served with `no-store`; the missing boundary was the HTML document that selects the JavaScript asset version.

Observed failure evidence before repair:
- clean Incognito browser requested `platform-owner-dashboard.js?v=4` with HTTP 304;
- current production GitHub HTML referenced `platform-owner-dashboard.js?v=6`;
- LIVE Supabase showed no `/auth/v1/token` request during the sign-in attempt;
- LIVE owner auth user exists and has an active `platform_memberships` record.

Operational rule: verify the actual browser asset/version and network request before changing LIVE Auth, owner membership, tenant records or credentials. Cloudflare deployment status and GitHub commit status are implementation evidence; the browser request is required for live serving verification.

No Supabase schema or data change was made for this repair.
\n\n## LIVE authentication audit — 3 October 2026\n\nVerified directly in LIVE Supabase: project \`gxsrajtqzdjvmceqcpgv\` is ACTIVE_HEALTHY; the platform owner auth user exists and is confirmed; one active \`public.platform_memberships\` row exists for that user; and the production branch contains the dedicated owner password recovery flow.\n\nRoot cause of the reported reset failure: Supabase Auth was constructing the recovery redirect from the project's default Site URL, which was still localhost. Supabase documentation confirms that Site URL is the default redirect when no valid \`redirectTo\` is supplied and that password-reset redirect URLs must be on the allowed Redirect URLs list.\n\nCode repair: \`platform-owner-dashboard.js\` now requests recovery with an explicit \`redirect_to=/owner-reset-password\`; \`platform-owner-password-reset.html\` consumes the recovery session, verifies active owner membership, and calls \`updateUser({password})\`; Worker routes the recovery path in both TEST and LIVE configurations. No database schema/data change was required for this repair.\n\nRemaining infrastructure action: configure the LIVE Supabase Auth Site URL and allow-list the exact owner recovery URL. Then perform one fresh end-to-end owner reset test.\n

## LIVE RELEASE OPERATIONS UPDATE — 3 OCTOBER 2026 — OWNER LOGIN VERIFIED

The Cloudflare Git integration was found to have the TradeFlow repository's Production branch set incorrectly to `main`. In the TradeFlow environment model, `main` is TEST and `production` is LIVE.

The Cloudflare Production branch has been corrected to `production`. A documentation-only commit `37b2d2133cf1f2e6d719c114f8d1e1c8fac25f84` triggered a fresh production deployment.

Browser verification then confirmed successful LIVE platform-owner authentication and dashboard loading. The dashboard reported 0 subscriber businesses and 0 active businesses, with no stale TEST/Camerashack businesses visible.

Operational rule: Cloudflare's configured production branch must remain `production`. Before any future LIVE deployment diagnosis, check the Git branch configuration and the actual deployed version before changing Supabase Auth, owner credentials, memberships or tenant data.

No LIVE database change was required for this branch correction or owner-login verification.


## BACKEND DOCUMENTATION AUDIT RULE — 3 OCTOBER 2026

The Backend User Manual is the maintained technical record of how the TradeFlow backend works. It must be kept current rather than treated as a one-time build document.

At each material backend change, update this manual with the affected tables, columns, constraints, indexes, RLS/security-definer RPCs, Edge Functions, storage configuration, environment boundary, deployment dependency and verification result. Record whether the change was verified in LIVE or only in TEST.

During periodic backend audits, compare this manual against the LIVE Supabase project and the production GitHub branch. Check at minimum:
- current public tables and important relationships;
- RLS and security-definer RPC boundaries;
- important unique indexes and constraints;
- deployed Edge Functions and their authentication requirements;
- storage buckets and policies;
- LIVE versus TEST environment boundaries;
- production Worker configuration and routes;
- current AI provider settings and assistant function configuration;
- retired integrations that must not be reintroduced.

The Owner Dashboard provides direct access to this Backend Manual. The manual is internal platform documentation and is not customer-facing documentation.


## 2026-10-03 Assistant Messaging Hardening

The customer/subscriber Assistant messaging layer uses assistant_conversations and assistant_messages with security-definer RPC access. The hardening migration is 20261003004315_assistant_connection_hardening.

customer_get_assistant_conversation is read-only with respect to conversation creation: it returns an existing open conversation or an empty result. A conversation is created when the customer actually sends a message through customer_send_assistant_message.

subscriber_get_assistant_conversations returns only open conversations with at least one message, so closed conversations leave the active Customer Questions queue.

The customer frontend polls the conversation every 15 seconds so subscriber replies appear without requiring a page reload. No email service is required for this path.

LIVE browser E2E verification is still a separate test step and must not be represented as passed until performed.



## 2026-10-03 LIVE Production Boundary Audit

A deep LIVE boundary audit found and repaired unconditional TEST Supabase references in production frontend assets and retired GitHub Pages customer portal URLs in four LIVE notification functions. The affected functions now derive customer portal links from each tenant's active primary domain. The LIVE `create-stripe-checkout-session` Edge Function was also versioned to v2 and no longer contains a GitHub Pages fallback. Targeted LIVE Edge Functions and database routine definitions were re-audited for TEST Supabase, old GitHub Pages, TEST workers.dev, localhost and 127.0.0.1 references. See `CHECKPOINTS/2026-10-03-production-boundary-audit-and-live-url-repair.md`.


## 2026-10-03 LIVE Commercial Subscription Backend

LIVE now has `plans.trial_days`, the `enhanced` TradeFlow plan at £59.99/month with 30 trial days, service-role-only `subscriber_finalize_signup` and `subscriber_sync_subscription`, and `public_get_available_plans()` exposes trial days. The legacy `subscriber_create_business` path is disabled so an unpaid subscriber cannot obtain a tenant. New Edge Functions are `platform-create-stripe-product` (owner-authenticated) and `subscriber-create-checkout-session` (subscriber-authenticated). `stripe-payment-webhook` is v2 and additionally handles subscriber checkout completion and subscription lifecycle events. Full LIVE Stripe browser verification remains outstanding.


---

## 2026-10-03 — LIVE Subscriber Subscription Cancellation Control

TradeFlow LIVE now provides a small **Cancel subscription** control at the bottom of the subscriber dashboard navigation.

Cancellation is deliberately protected by password re-authentication before the cancellation request is accepted. The subscriber's password is verified through Supabase Auth; the password is not stored by TradeFlow.

The cancellation action schedules the connected Stripe subscription to cancel at the end of the current trial or billing period rather than creating a duplicate payment or immediately removing access.

The authenticated `subscriber-cancel-subscription` Edge Function validates:
- the signed-in subscriber identity;
- active membership of the selected tenant;
- the connected Stripe subscription;
- the Stripe customer ID match;
- the Stripe subscription metadata user ID when present.

It then sets Stripe `cancel_at_period_end=true` and synchronises the local TradeFlow subscription record.

The obsolete dashboard note stating that catalogue management will be added when Gemma is ready has been removed. Catalogue/product management remains available through the existing **What We Buy** and **Products & Categories** areas.
