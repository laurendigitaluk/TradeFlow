# TradeFlow Backend User Manual

**Purpose:** authoritative operational guide to the TradeFlow subscriber/business backend.  
**Audience:** business owner, administrator, staff and anyone operating the TradeFlow backend.  
**Not this manual:** this is not the customer-facing website manual. The public/subscriber website-building guide remains `subscriber-website-manual.html`.

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
| GitHub | `main` | `production` |
| Supabase | `twfbmjwwqzxdxvclxbun` | Separate production project |
| Data | Test data | Real business data |
| Purpose | Build, repair, test | Operate the live business |

Never experiment in LIVE. Never copy TEST customer or transaction data into LIVE.

The release path is:

1. Make the change in a feature/checkpoint branch or `main`.
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


## 22A. Customer-owned domain connection — Platform Owner procedure

The approved domain model is now:

**Subscriber buys and owns the domain → subscriber submits the domain in TradeFlow → Platform Owner receives an action request → Platform Owner prepares the connection → subscriber applies the supplied DNS records → TradeFlow verifies DNS/SSL → domain becomes active.**

TradeFlow does **not** purchase the subscriber's domain and does not require the subscriber's registrar password.

### 1. Receive the request

When a subscriber enters a domain under **Website → Website URL** and saves it, TradeFlow must create a domain-connection request for the Platform Owner.

The request should contain, at minimum:

- subscriber business name;
- tenant ID internally;
- domain hostname;
- domain record ID;
- date/time requested;
- current domain status;
- requested action.

The Platform Owner notification should be clearly marked:

**DOMAIN CONNECTION REQUIRED**

The notification is an internal owner action and must never expose another tenant's information.

### 2. Review the domain

Open the domain request and confirm:

1. The subscriber/business is the correct tenant.
2. The hostname is correctly entered.
3. The domain is intended to be the subscriber's primary website address.
4. There is no conflicting active domain already using the requested hostname.
5. The request is not a duplicate of an existing open domain request.

Do not ask the subscriber for their registrar password.

### 3. Prepare the TradeFlow connection

The Platform Owner prepares the custom-domain connection using the approved TradeFlow/Cloudflare hosting architecture.

**Do not invent DNS targets.**

Do **not** tell the subscriber to change nameservers unless the actual hosting architecture requires it.

The exact DNS records supplied to the subscriber must come from the current TradeFlow connection service/configuration.

Update the request to indicate that owner action is in progress.

### 4. Give the subscriber the DNS instructions

The subscriber should receive concise instructions containing:

- hostname/type of each required DNS record;
- exact target/value;
- whether an existing record must be replaced;
- any TTL guidance if applicable;
- the registrar/DNS management area they need to open;
- a warning not to change unrelated email records.

The Platform Owner must not request registrar credentials.

### 5. Verify DNS

After the subscriber has made the DNS changes:

1. Check the expected DNS record.
2. Confirm that the record resolves to the approved TradeFlow/Cloudflare target.
3. Confirm that the hostname belongs to the requesting tenant.
4. Continue to secure-hostname/SSL verification.

DNS propagation can take time. Do not mark the domain active merely because the subscriber says the record was added.

### 6. Verify SSL and activate

Once the custom hostname is accepted by the hosting/Cloudflare layer:

1. Confirm the secure hostname is provisioned.
2. Confirm HTTPS works.
3. Confirm the hostname routes to the correct tenant's published website.
4. Confirm the published site is the correct subscriber website.
5. Mark the domain active.
6. Set it as the tenant's primary domain where that was the requested action.
7. Record the activation timestamp.

The final verification must prove tenant routing. A domain resolving to a generic TradeFlow page is not sufficient.

### 7. Completion

The owner action is complete only when:

- DNS is verified;
- SSL/HTTPS is verified;
- the correct subscriber website loads on the custom hostname;
- the domain record is active;
- the primary-domain setting is correct;
- the outstanding owner notification/action is closed.

### 8. Failure handling

If DNS or SSL verification fails:

- keep the domain in its current non-active status;
- record the actual failure;
- do not mark the domain active manually;
- tell the subscriber exactly what needs correcting;
- allow the owner action to remain open until the problem is resolved.

Do not delete and recreate the domain record simply to clear an error.

### 9. Domain ownership and renewal

The subscriber owns the registrar account and the domain.

TradeFlow is responsible for the website connection, not the subscriber's registrar account.

The subscriber remains responsible for:

- registrar renewal;
- registrar billing;
- registrar account security;
- accurate registrant/contact details;
- any registrar-specific domain verification.

TradeFlow must not imply that a domain purchased by the subscriber is registered to Lauren Digital.


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


## 2026-10-06 — customer-owned domain action implementation

The TEST implementation now creates a Platform Owner domain-connection action when a subscriber requests a customer-owned domain from Website URL. The Platform Owner dashboard exposes the open action, allows the owner to record notes and exact approved DNS records, and controls the action state. Completion is blocked until the domain is already active and has both DNS verification and activation timestamps. The actual hosting/Cloudflare provisioning and DNS/SSL verification layer remains a separate implementation stage and must not be replaced by manual activation.



## Batch 49 — 24 October 2026
Added three fresh UK eBay used-phone completed-sale observations, checked the stable source keys absent in TEST and LIVE before insertion, inserted to TEST first, then promoted the same observations to LIVE.

1. Apple iPhone 15 128GB Blue, factory unlocked — £269.25 displayed buyer total, including £9.25 Buyer Protection; sold 23 Sep 2026. The item price/seller proceeds are not separately captured. https://www.ebay.co.uk/itm/398420637687. Key: `mobile-used-sold-iphone15-128gb-ebay-398420637687-20260923`.
2. Apple iPhone 15 128GB Black — £265.99 displayed buyer total, including £10.99 Buyer Protection; Best Offer accepted; sold 27 Sep 2026. The accepted item price/seller proceeds are not separately shown. https://www.ebay.co.uk/itm/188991253809. Key: `mobile-used-sold-iphone15-128gb-ebay-188991253809-20260927`.
3. Apple iPhone 16 128GB Green, locked to Sky Mobile — £391.92 displayed buyer total, including £11.92 Buyer Protection; sold 22 Aug 2026. Keep the network-lock caveat; this is not directly comparable with unlocked devices. https://www.ebay.co.uk/itm/800546931991. Key: `mobile-used-sold-iphone16-128gb-ebay-800546931991-20260822`.

Post-batch integrity checks (phone category joined through each environment's own category ID):
- TEST: 197 active phone evidence rows; 103 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.
- LIVE: 195 active phone evidence rows; 101 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.

The integrity check intentionally tests URL presence/HTTP format rather than restricting all existing evidence to eBay URLs, since the phone catalogue includes other valid source types. Preserve Buyer Protection totals as buyer-facing totals, not seller proceeds. Continue TEST-first and promote validated evidence promptly.


## Mobile phone catalogue — Batch 50 (24 October 2026)

Added three fresh UK eBay iPhone 15 128GB completed-sale observations. Stable keys were checked absent in both environments before insertion; records were inserted into TEST first and then promoted to LIVE.

1. iPhone 15 128GB White, unlocked — £217.58 displayed buyer total including £7.58 Buyer Protection; sold 11 Sep 2026. Listing title says “Read Description”; underlying caveat is not fully established in the captured extract, so retain this caveat-bearing observation and do not assume typical working condition. https://www.ebay.co.uk/itm/278364248917. Key: `mobile-used-sold-iphone15-128gb-ebay-278364248917-20260911`.
2. iPhone 15 128GB Black with box — £258.92 displayed buyer total including £8.92 Buyer Protection; Best Offer accepted; sold 22 Sep 2026. Listing says seller relisted this item or one like it, so preserve this observation separately from other records. https://www.ebay.co.uk/itm/318900425831. Key: `mobile-used-sold-iphone15-128gb-ebay-318900425831-20260922`.
3. iPhone 15 128GB White — £207.25 displayed buyer total including £7.25 Buyer Protection; Best Offer accepted; sold 2 Aug 2026. Explicitly marked “For parts or not working”; do not use as a typical working-phone benchmark. https://www.ebay.co.uk/itm/366574722022. Key: `mobile-used-sold-iphone15-128gb-ebay-366574722022-20260802`.

Post-batch checks using each environment's own phone-category ID:
- TEST: 200 active phone evidence rows; 106 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.
- LIVE: 198 active phone evidence rows; 104 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.

Buyer Protection totals are buyer-facing totals, not seller proceeds. Keep “Read Description”, relisting and non-working caveats explicit. Continue TEST-first, promote validated evidence promptly, and avoid overwriting historical listing observations.


## Catalogue evidence checkpoint — Batch 51 (24 October 2026)
Two new UK eBay iPhone 15 128GB completed-sale evidence rows were inserted into TEST first and then LIVE. Post-write phone-category integrity checks: TEST 202 active phone evidence rows / 108 active UK used sold; LIVE 200 / 106; zero basic URL/key/positive GBP price/currency failures and zero duplicate active source-key groups in both environments. Batch keys active in both. Retain the explicit “For parts or not working” condition and do not use that observation as a typical working-phone comparable. Buyer Protection totals are buyer-facing totals, not seller proceeds. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-51.md`.


## Catalogue evidence checkpoint — Batch 52 (24 October 2026)
Two UK eBay phone-sale evidence rows were inserted TEST first, then LIVE. Post-write phone-category checks: TEST 204 active phone evidence / 110 active UK used sold; LIVE 202 / 108; zero basic URL/key/positive GBP price/currency failures and zero duplicate active source-key groups. Both Batch 52 keys are active in both environments. Preserve the Galaxy S24 “For parts or not working” condition and exclude it from typical working-phone comparables. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-52.md`.


## Catalogue evidence checkpoint — Batch 53 (24 October 2026)
Two Pixel 9 128GB UK eBay sale rows were inserted into TEST and then LIVE. Existing Galaxy S24 evidence was confirmed already active in both environments and not duplicated. Post-write checks: TEST 206 active phone evidence / 112 active UK used sold; LIVE 204 / 110; zero basic URL/key/positive GBP price/currency failures and zero duplicate active source-key groups. Since the source key is globally unique, check it globally before insertion; URL-only/category-only preflight can miss an existing record. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-53.md`.


## Catalogue evidence checkpoint — Batch 54 (24 October 2026)
Two Pixel 9 128GB Porcelain eBay sale rows were inserted into TEST and then LIVE. Read-after-write verified both keys active in each environment. Post-write counts: TEST 208 active phone evidence / 114 active UK used sold; LIVE 206 / 112. One record is ordinary Used and one is Opened - never used; keep the latter separate from typical used-phone comparisons. A false-positive phone-case result was not inserted. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-54.md`.


## Catalogue evidence checkpoint — Batch 55 (24 October 2026)
Seven new iPhone 14 128GB and Pixel 8 128GB UK eBay sale rows were inserted into TEST then LIVE and read-after-write verified. TEST: 215 active phone evidence / 121 active UK used sold; LIVE: 213 / 119. Basic integrity failures and duplicate active source-key groups: zero in both. A previously existing iPhone 14 row was reconciled without duplication. Galaxy A15/A16 candidates were not inserted because their master products do not exist. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-55.md`.


## Catalogue evidence checkpoint — Batch 56 (24 October 2026)
Confirmed the previously uncertain LIVE row for iPhone 14 128GB item 366661027705 (£188.66) and added two Pixel 8 128GB eBay sales (£159.95 and £179.99). All three records are active and read-back verified in both environments. TEST: 218 active phone evidence / 124 active UK used sold; LIVE: 216 / 122. Duplicate active source-key groups: zero in both, but a two-row difference remains. Two iPhone 16 candidates were already present. Additional candidates whose insert was blocked are not claimed as written. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-56.md`.


## Catalogue evidence checkpoint — Batch 57 (24 October 2026)
Two UK eBay sold observations were added and verified active in both TEST and LIVE: iPhone 15 128GB Black, 82% battery health (£238.25 displayed), and Galaxy S22 128GB (£80.00 displayed, Best Offer accepted; accepted proceeds not confirmed). Existing iPhone 15 candidates were not duplicated. TEST: 220 active phone evidence / 126 active UK used sold; LIVE: 218 / 124. The full duplicate-key aggregate query was blocked in this run; new URLs/keys were preflighted empty in both environments. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-57.md`.


## Catalogue evidence checkpoint — Batch 58 (24 October 2026)
Added and verified in both TEST and LIVE the iPhone 15 Pro 128GB Natural Titanium UK eBay sale, item 227530529279, displayed £402.08 including £12.08 Buyer Protection. The listing described the phone as immaculate and included the original box. The iPhone 15 Plus 128GB Blue candidate (item 800655157429) already existed in both environments and was not duplicated. TEST: 221 active phone evidence rows; LIVE: 219. UK used/sold subtotals were not refreshed in Batch 58; last confirmed values remain TEST 126 and LIVE 124. Full duplicate-key aggregate audit remains outstanding. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-58.md`.


## Catalogue evidence checkpoint — Batch 59 (24 October 2026)
One UK eBay completed-sale observation was added for iPhone 15 Pro 128GB Black, item 206515412317, displayed £302.94 including £10.34 Buyer Protection. Seller proceeds are not independently confirmed. TEST and LIVE exact URL/key preflights were empty; insertions were performed TEST-first and then LIVE, and exact-URL read-back confirmed one active row in each. TEST active phone evidence: 222; LIVE: 220. UK used/sold subtotals were not refreshed and remain last confirmed at TEST 126 / LIVE 124. Full duplicate-key aggregate audit remains outstanding. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-59.md`.


## Catalogue evidence checkpoint — Batch 60 (24 October 2026)
Two iPhone 15 Pro 128GB Black Titanium records were inserted TEST-first and then LIVE after URL/key preflight. Item 206070231627 is a working device in fair cosmetic condition, 90% battery health, displayed £379.99 including Buyer Protection; read-back verified both environments. Item 206112400829 is a separate parts/repair observation at displayed £199.99 including Buyer Protection (shattered rear glass and faulty non-genuine replacement screen). Both insert responses confirmed active rows; TEST read-back succeeded, while LIVE read-back was blocked. TEST active phone evidence: 224; LIVE: 222. UK used/sold subtotals were not refreshed; last confirmed TEST 126 / LIVE 124. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-60.md`.


## Catalogue evidence count refresh — 24 October 2026
After Batch 60, active phone evidence counts are TEST 224 and LIVE 222. Active records with `evidence_type='uk_used'` and `availability='sold'` are TEST 130 and LIVE 128. This query includes the parts/repair row because it uses the same evidence type; it is not a working-only count. Full duplicate-key aggregate audit remains outstanding and the environment difference is two rows.

Stable-key aggregate audit refresh (24 October 2026): zero duplicate active non-null source-record-key groups across shared evidence in TEST and LIVE. This does not establish unique URLs; shared category/catalogue pages can legitimately recur across product evidence.


## Catalogue evidence checkpoint — Batch 61 (24 October 2026)
Added and verified iPhone 15 Pro 128GB Black Titanium eBay sale item 900018786339 in TEST and LIVE. Displayed buyer-facing total £404.50 includes £14.50 Buyer Protection; seller proceeds unconfirmed. Listing title states mint condition, 100% battery health, no charger. TEST active phone evidence count: 225; LIVE: 223. Last refreshed active `uk_used` + `sold` counts remain TEST 130 / LIVE 128. Pixel 9 item 820179580133 was already present in both and was not duplicated. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-61.md`.


## Catalogue evidence checkpoint — Batch 62 (24 October 2026)
Added and verified Google Pixel 9 128GB Obsidian eBay sale item 147349812276 in TEST and LIVE. Displayed £243.42 includes £8.42 Buyer Protection; listing title says acceptable condition, 99% battery health and warranty to 27 November 2027. TEST active phone evidence count: 226; LIVE: 224. Active `uk_used` + `sold` subtotals were not refreshed and remain last confirmed at TEST 130 / LIVE 128. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-62.md`.


## Catalogue evidence checkpoint — Batch 63 (24 October 2026)
Added one Google Pixel 9 128GB GrapheneOS sale observation, item 267700928563, displayed £299.00, sold 15 July 2026. Exact URL and stable-key preflight were empty in both environments; insertion and stable-key read-back confirmed active rows in TEST and LIVE. TEST: 227 active phone evidence / 133 active `uk_used` + `sold`; LIVE: 225 / 131. The latter count includes parts/repair rows and is not working-only. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-63.md`.


## Catalogue evidence checkpoint — Batch 64 (24 October 2026)
Added Google Pixel 9 128GB Obsidian completed-sale evidence from eBay item 407029495464 (£272.00 displayed, sold 29 June 2026). URL/key preflight was empty and stable-key read-back confirmed active records in TEST and LIVE. Listing described the device as unlocked and in “Great” condition; seller was London-based, but international postage options were shown, so UK destination is unconfirmed. Counts: TEST 228 active phone evidence / 134 `uk_used` + `sold`; LIVE 226 / 132. The subtotal includes parts/repair rows. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-64.md`.


## Catalogue evidence checkpoint — Batch 65 (24 October 2026)
Added and verified in both TEST and LIVE two iPhone 15 128GB parts/repair sales: item 267734454669 (Black, £192.00 displayed) and item 267749501196 (Blue, £157.00 displayed). Both are explicitly classified For parts or not working; displayed prices include Buyer Protection, with seller net proceeds unconfirmed. Exact URL and stable-key preflight was clear before insertions. TEST active phone evidence: 230; LIVE: 228. Active uk_used + sold counts are 136 and 134 respectively and include parts/repair records. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-65.md`.


## Catalogue evidence checkpoint — Batch 66 (24 October 2026)
Added one verified iPhone 15 Pro 128GB Blue Titanium UK eBay completed sale, item 298501695479, displayed £360.72 including £11.41 Buyer Protection. Listing describes a working, factory-reset device with original box and missing accessories. Exact URL/key preflight was clear; TEST then LIVE insertion and read-back were confirmed. TEST active phone evidence: 231; LIVE: 229. Active uk_used + sold counts are 137 and 135 and include parts/repair rows. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-66.md`.


## Catalogue evidence checkpoint — Batch 68 (24 October 2026)
Added and verified in both TEST and LIVE one iPhone 15 Pro Max 256GB Natural Titanium completed-sale record, item 128012606222, displayed £399.88 including £14.29 Buyer Protection. Three bids. Listing title says Excellent condition while the eBay condition field says Used; preserve the distinction. Counts: TEST 233 active phone evidence / 139 active uk_used + sold; LIVE 231 / 137. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-68.md`.


## Catalogue evidence checkpoint — Batch 69 (24 October 2026)
Added two iPhone 15 Pro Max 256GB UK eBay sold observations, both verified active in TEST and LIVE: Grey with retail box (item 298621751352, £444.64 displayed) and Silver (item 327278174330, £439.66 displayed). Buyer Protection fees are included in both displayed totals; seller proceeds unconfirmed. The Silver listing notes seller relisting this item or one like it, so uniqueness is not established. Counts: TEST 235 active phone evidence / 141 active uk_used + sold; LIVE 233 / 139. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-69.md`.


## Catalogue evidence checkpoint — Batch 70 (24 October 2026)
Added one iPhone 15 Pro Max 256GB unlocked UK eBay sale observation, item 298539408905, displayed £463.08 including £13.08 Buyer Protection. Two bids; listing condition Used. TEST and LIVE rows were inserted and read-back verified after clean URL/key preflight. Counts: TEST 236 active phone evidence / 142 active uk_used + sold; LIVE 234 / 140. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-70.md`.


## Catalogue evidence checkpoint — Batch 71 (24 October 2026)
Added one iPhone 16 Pro 256GB Desert Titanium UK eBay sale observation, item 820212891404, displayed £567.85 including £17.85 Buyer Protection. Best Offer was enabled and seller proceeds are unconfirmed. TEST and LIVE rows were inserted and exact read-back verified after URL/key preflight. Counts: TEST 237 active phone evidence / 143 active uk_used + sold; LIVE 235 / 141. Used/sold counts include parts/repair records. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-71.md`.


## Catalogue evidence checkpoint — Batch 72 (25 October 2026)
Added one iPhone 16 Pro Max 256GB Black UK eBay sale observation, item 128132786202, displayed £527.16 including £14.13 Buyer Protection. Listing disclosed the back was replaced. TEST and LIVE insertions and read-backs were verified after clean URL/key preflight. Derived active phone evidence totals are TEST 238 and LIVE 236; derived active uk_used + sold totals are 144 and 142, pending full recount. Full duplicate-key audit remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-72.md`.


## Catalogue evidence checkpoint — Batch 73 (25 October 2026)
Three Samsung Galaxy S25 UK eBay used/sold observations were added and verified in TEST and LIVE after exact URL/key preflight: item 158245363724 (£345 displayed, 128GB Grey); item 206384194701 (£389.99 displayed, 256GB, Best Offer accepted); item 128101722692 (£347.18 including £11.18 Buyer Protection, 128GB, Best Offer accepted). TEST read-backs were completed before LIVE inserts, followed by LIVE read-backs. Direct Mobile Phones category counts are TEST 241 active / 147 used-sold and LIVE 239 / 145. Full global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-73.md`.


## Catalogue evidence checkpoint — Batch 74 (25 October 2026)
Added one Google Pixel 10 Pro 256GB Porcelain used-sale observation, eBay item 336731607825, displayed £498.67 including £13.67 Buyer Protection. TEST insert/read-back completed before LIVE insert/read-back; exact URL/key preflight was clear. Direct Mobile Phones category counts are TEST 242 active / 148 used-sold and LIVE 240 / 146. Global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-74.md`.

## Catalogue evidence checkpoint — Batch 75 (25 October 2026)
Two Samsung Galaxy S25 Ultra 256GB UK eBay used/sold observations were added to TEST and LIVE after exact active master matching and URL/key preflight. Titanium Black item 137643944477: £572.95 displayed including £17.95 Buyer Protection. Titanium White item 168615919758: £516.84 displayed including £16.84 Buyer Protection; no charger included. Seller proceeds unconfirmed. TEST rows were read back before LIVE insertion; LIVE rows were read back afterward. Direct Mobile Phones category counts: TEST 244 active / 150 used-sold; LIVE 242 / 148. The two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-75.md`.

## Catalogue evidence checkpoint — Batch 76 (25 October 2026)
Two Samsung Galaxy S25 Ultra 256GB UK eBay used/sold observations were added to TEST and LIVE after exact master matching and URL/key preflight. Item 137804587290 (Silver) displayed £570.15 including £17.90 Buyer Protection with Best Offer context; item 278429059814 (Titanium Blue, unlocked/excellent condition) displayed £594.85 including £18.09 Buyer Protection. Original listing pages differed from search-index amounts, so the currently viewable page values and discrepancy notes were recorded. TEST read-backs preceded LIVE insertion and LIVE read-backs verified both rows. Direct Mobile Phones counts: TEST 246 active / 152 used-sold; LIVE 244 / 150. The two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

## Batch 76 follow-up — third observation
Added Samsung Galaxy S25 Ultra 256GB Titanium Silverblue, eBay item 227413483025, sold 4 July 2026 at 15:40 BST. The original listing page displays £589.15 including £18.27 Buyer Protection; Best Offer was enabled, so accepted sale amount and seller proceeds are unconfirmed. Seller located in Blackburn, UK. Search-index amount differed from the original page; the original page display was recorded and the discrepancy noted. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Verified counts after this addition: TEST 247 active phone evidence / 153 active uk_used+sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding.

## Batch 76 follow-up — third observation
Added Galaxy S25 Ultra 256GB Titanium Silverblue, eBay item 227413483025, sold 4 Jul 2026 at 15:40 BST. Original listing page displayed £589.15 including £18.27 Buyer Protection; Best Offer enabled, accepted price/proceeds unconfirmed. Seller in Blackburn, UK. Original page differed from search index; page display recorded with discrepancy note. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Counts now TEST 247 active phone evidence / 153 used-sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

## Catalogue evidence checkpoint — Batch 77 (25 October 2026)
Two Google Pixel 10 Pro 256GB Obsidian UK eBay new/sealed completed-sale observations were added to TEST and LIVE. Item 117212924862 displayed £691.83 including £16.83 Buyer Protection; item 236875676375 displayed £605.42 including £15.42 Buyer Protection. Seller proceeds not independently confirmed. TEST inserts/read-backs preceded LIVE insertion/read-backs. Counts: TEST 249 active phone evidence / 153 used-sold / 2 new-sold; LIVE 247 / 151 / 2. Two-row TEST/LIVE difference remains; global duplicate-key aggregation outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-77.md`.

## Catalogue evidence checkpoint — Batch 78 (25 October 2026)
One Samsung Galaxy S25 Ultra 256GB Black used-sale observation was added to TEST and LIVE. eBay item 128026023099 sold 17 Aug 2026; displayed buyer-facing total £399.99 with Buyer Protection included. Listing title disclosed a chipped corner and visible scratches. Separate fee and seller proceeds were not confirmed. Counts: TEST 250 active phone evidence / 154 used-sold / 2 new-sold; LIVE 248 / 152 / 2. Two-row TEST/LIVE difference and global duplicate-key aggregation audit remain outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-78.md`.

## Catalogue evidence checkpoint — Batch 79 (25 October 2026)
Added Google Pixel 10 Pro XL 256GB used-sale observation from eBay item 227413880546, sold 8 July 2026 at 19:00 BST. Displayed buyer-facing total £507.44 including £13.81 Buyer Protection; listing says no charger included. TEST 251 active phone evidence / 155 used-sold / 2 new-sold; LIVE 249 / 153 / 2. Two-row environment difference and global duplicate-key audit remain outstanding.

Source discrepancy for audit: Batch 78 item 128026023099 was captured at £399.99, but a later search result displays £479.99 incl Buyer Protection. Do not overwrite historical observation without a documented source audit. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-79.md`.

## Catalogue evidence checkpoint — Batch 80 (25 October 2026)
Added Google Pixel 10 Pro XL 256GB Moonstone used-sale observation from eBay item 278176799541, sold 18 July 2026 at 17:50 BST. Search result showed £620.00 including Buyer Protection; fee amount not displayed. Used; no charger included. Original page had a Best Offer option without explicit accepted-offer notice; price uncertainty noted. Counts: TEST 252 active phone evidence / 156 used-sold / 2 new-sold; LIVE 250 / 154 / 2. Two-row difference and global duplicate-key audit remain outstanding. Batch 78 item 128026023099 price discrepancy (£399.99 recorded vs later £479.99 result) remains pending audit. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-80.md`.

## Catalogue evidence checkpoint — Batch 81 (25 October 2026)
Added Google Pixel 10 Pro XL 256GB Obsidian used-sale observation from eBay item 257522963688, sold 20 July 2026 at 15:55 BST. Original item page displayed £578.85 including £17.77 Buyer Protection; search index displayed £576.01 including £14.93 fee. Original page used as source-of-record capture; discrepancy recorded. Counts: TEST 253 active phone evidence / 157 used-sold / 2 new-sold; LIVE 251 / 155 / 2. Two-row difference and global duplicate-key audit remain outstanding. Batch 78 item 128026023099 discrepancy remains pending. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-81.md`.


## Mobile phone catalogue evidence ingestion — Batch 82 (25 October 2026)
A UK eBay completed-sale observation for Google Pixel 10 Pro XL 256GB Porcelain/white, “Opened – never used”, was added to the existing active master in TEST and LIVE. Stable key: `mobile-opened-sold-pixel10proxl-256gb-white-ebay-178468385751-20260911`. Source page displayed £649.14 incl £19.14 Buyer Protection; search index displayed £646.08 incl £16.08. The discrepancy is documented; seller proceeds are not confirmed and Best Offer acceptance is not explicit. Verified counts: TEST 254 active Mobile Phones evidence / 158 used-sold / 2 new-sold; LIVE 252 / 156 / 2. Do not treat buyer-facing totals as seller proceeds or guaranteed acquisition offers. Global duplicate-key audit and the two-row TEST/LIVE difference remain outstanding.


## Mobile phone catalogue evidence ingestion — Batch 83 (25 October 2026)
A UK eBay new-condition completed-sale observation for Google Pixel 10 Pro XL 256GB Black was added to the existing active master in TEST and LIVE. Stable key: `mobile-new-sold-pixel10proxl-256gb-black-ebay-178516971817-20260922`. Source page displayed £656.73 including £16.26 Buyer Protection; seller location Luton, UK. Seller proceeds are not confirmed. Verified counts: TEST 255 active Mobile Phones evidence / 158 used-sold / 3 new-sold; LIVE 253 / 156 / 3. Buyer-facing totals must not be treated as seller proceeds or guaranteed acquisition offers. Global duplicate-key audit and the two-row TEST/LIVE difference remain outstanding.


## Mobile phone catalogue evidence ingestion — Batch 84 (25 October 2026)
A UK eBay new-condition completed-sale observation for Google Pixel 10 Pro XL 256GB Obsidian was added to the existing active master in TEST and LIVE. Stable key: `mobile-new-sold-pixel10proxl-256gb-obsidian-ebay-278210429467-20260724`. Listing displayed £674.99 and indicated two sold; no separate Buyer Protection fee was displayed. Seller is a London UK business; seller proceeds are not confirmed. Verified counts: TEST 256 active Mobile Phones evidence / 158 used-sold / 4 new-sold; LIVE 254 / 156 / 4. Buyer-facing/listing prices must not be treated as seller proceeds or guaranteed acquisition offers. Global duplicate-key audit and the two-row TEST/LIVE difference remain outstanding.


## Mobile phone catalogue evidence ingestion — Batch 85 (25 October 2026)
A UK eBay used-condition completed-sale observation for Google Pixel 10 Pro XL 256GB Green was added to the existing active master in TEST and LIVE. Stable key: `mobile-used-sold-pixel10proxl-256gb-green-ebay-178236367409-20260629`. Listing displayed £589.99 with £9.99 postage separately; no separate Buyer Protection fee was displayed. Seller is a UK business in Tyne and Wear; seller proceeds are not confirmed. Verified counts: TEST 257 active Mobile Phones evidence / 159 used-sold / 4 new-sold; LIVE 255 / 157 / 4. Listing prices must not be treated as seller proceeds or guaranteed acquisition offers. Global duplicate-key audit and the two-row TEST/LIVE difference remain outstanding.


## Mobile phone catalogue evidence ingestion — Batch 86 (25 October 2026)
A UK eBay new-condition completed-sale observation for Samsung Galaxy S25 256GB Silver was added to the existing master in TEST and LIVE. Stable key: `mobile-new-sold-galaxys25-256gb-silver-ebay-286331524320-20260815`. Listing displayed £629 including Buyer Protection; the fee amount was not shown. No charger included. Seller is a UK business in Warminster, Wiltshire; seller proceeds are not confirmed. LIVE phone coverage now stands at 130 active products, 70 with new evidence and 66 with used evidence; 60 lack new evidence, 64 lack used evidence, none lack both. TEST/LIVE master-product mismatch remains under investigation. No dedicated discontinued field exists in the LIVE master table; note-text searching is not an authoritative lifecycle status.


## Mobile phone catalogue evidence ingestion — Batch 87 (25 October 2026)
Added two UK eBay new-condition completed-sale observations to existing exact masters, TEST-first then LIVE: iPhone 17 Pro 256GB Orange (item 820214209970; £890 buyer-facing total including Buyer Protection; TEST evidence 0163611d-87fc-43fc-be59-da26c924edcb; LIVE b2db7455-c13d-4cf7-ba58-349d86575333) and iPhone 17 Pro Max 512GB Orange (item 407282798006; £1,006.52 including £26.52 Buyer Protection; TEST evidence 29465532-c8b2-4cf6-b225-c561a2286ef7; LIVE afd58902-207a-48ba-9e46-81f5dc858042). No Best Offer acceptance notice was shown. These are buyer-facing totals, not seller proceeds. No master products were created.

Verified coverage: LIVE 130 active phone products, 72 with new evidence, 66 with used evidence, none missing both; 258 active evidence rows (7 new/sold, 157 used/sold). TEST 133 active products, 72 with new, 68 with used, one missing both; 260 active evidence rows (7 new/sold, 159 used/sold). TEST/LIVE master discrepancy, duplicate-key aggregation and historic price-source audits remain open.

Lifecycle workflow: search official manufacturer/current range evidence before marking a variant discontinued. A lack of new listings alone is insufficient. The LIVE master schema has no dedicated discontinued field; preserve the master as active for valuation and record lifecycle source/date in notes until a proper field is introduced through reviewed migration. Once discontinued is verified, stop treating launch/RRP prices as current new evidence and prioritise UK second-hand completed sales. Preserve condition distinctions and historical evidence.


## Mobile phone catalogue evidence ingestion — Batch 88 (25 October 2026)
Lifecycle review notes were appended to active variants without active UK new-price evidence in these older families: iPhone 13/14/15, Pixel 8/9, Galaxy S22/S23/S24. Sources checked: Apple UK buy page (https://www.apple.com/uk/shop/buy-iphone), Google Store UK phone line-up (https://store.google.com/gb/category/phones?hl=en-GB), and Samsung UK S-series guide (https://www.samsung.com/uk/mobile-phone-buying-guide/best-samsung-s-series-phone/). These sources support absence from the current manufacturer UK retail line-up or previous-generation status, but do not independently prove manufacturing has ceased. Notes were updated in TEST and LIVE; masters remain active for valuation and no schema change was made.
Added UK used/sold evidence for iPhone 15 128GB Pink, item 307244687330, sold 23 Oct 2026 at 11:07 BST. Displayed £292 including £12 Buyer Protection; Best Offer option present but no explicit acceptance notice. TEST evidence 49c7213e-c63b-43a8-99d7-aa14d371983e; LIVE ed16e210-e9fb-416b-b7c0-b450d4c36c1a. Stable key `mobile-used-sold-iphone15-128gb-pink-ebay-307244687330-20261023`. Buyer-facing total only, not seller proceeds. Coverage: LIVE 130 active products / 72 new / 66 used / 0 missing both / 259 active rows / 158 used-sold; TEST 133 / 72 / 68 / 1 missing both / 261 active rows / 160 used-sold. Product-master discrepancy, duplicate-key aggregation and historical source-price audits remain open.


## Mobile phone catalogue evidence ingestion — Batch 89 (25 October 2026)
Added two UK eBay new/sealed completed-sale observations to the existing iPhone 16 Pro Max 256GB master, TEST-first then LIVE. Black Titanium item 176644847651 sold 24 Jul 2026 at 14:17 BST for displayed £999 (TEST evidence 946c5046-d88a-43fa-a347-a3ac0112ceca; LIVE 30a3ea72-3b36-4f2f-a6c9-10e5b3a65404). Natural Titanium item 256779530734 sold 10 Jul 2026 at 07:27 BST for displayed £1,149 (TEST evidence e11f823f-7b8a-4f0b-a5c4-f56255e0b91d; LIVE 08b4be71-0a8c-410a-b7d7-125acea2ee31). Both pages specify 256GB and new/sealed condition. Separate fee breakdowns were not shown on original pages; prices are buyer-facing listing values, not seller proceeds. No master products were created. Verified counts: LIVE 130 active products / 73 with new / 66 with used / 0 missing both / 261 active rows / 9 new-sold / 158 used-sold; TEST 133 / 73 / 68 / 1 missing both / 263 active rows / 9 new-sold / 160 used-sold. Master discrepancy, duplicate-key aggregation and historic source-price audits remain open.


## Additional historical source-price audit flag — 25 October 2026
A fresh capture of eBay item 307244687330 (iPhone 15 128GB Pink, Batch 88) displayed £289.92 including £9.92 Buyer Protection, but the stored evidence row records £292.00 including £12.00. Preserve the historic row until the sale-time source capture is reconciled; do not silently overwrite. Candidate item 178318053825 (iPhone 16e) was excluded from ingestion due to poor seller feedback and conflicting captured prices (£258.92 versus £260.61).

### Mobile Phone Catalogue Research — Batch 90 (25 October 2026)
Three new/sealed UK eBay completed-sale observations were added to existing mobile-phone masters after TEST-first insert/read-back and LIVE preflight. Galaxy S26 256GB item 227435267689 displayed £560 including Buyer Protection; iPhone 17 Pro Max 256GB Silver item 820035575474 displayed £1,079 including Buyer Protection; iPhone 17 256GB Black item 327314918719 displayed £678.33 including £18.24 Buyer Protection. The last listing showed a Best Offer option but no accepted-offer notice; the evidence note retains this caveat. These are buyer-facing totals, not seller proceeds. No master products were created or modified. Candidates with conflicting page/search prices, poor seller feedback, or pages redirected to generic product pages were excluded. Full checkpoint: `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-90.md`. The historic iPhone 15 Pink source-price discrepancy remains open and must not be overwritten.

### Mobile Phone Catalogue Research — Batch 91 (25 October 2026)
Three new/sealed UK eBay completed-sale observations were added to existing masters after TEST-first insertion and read-back, followed by LIVE insertion and verification: Galaxy S26 Ultra 256GB Black item 227316346801 (displayed £799; Buyer Protection indicated, fee not separately shown); iPhone 17 Pro Max 512GB Silver item 128022793235 (£1,047.87 including £22.67 Buyer Protection); and iPhone 17 Pro 256GB Cosmic Orange item 237066171400 (displayed £949; Buyer Protection indicated, fee not separately shown). These are buyer-facing totals, not seller proceeds or guaranteed buying offers. No masters were created or modified. Candidates with current-product redirects, active rather than completed listings, low seller feedback, or conflicting price captures were excluded. Checkpoint: `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-91.md`. The historic iPhone 15 Pink price discrepancy and TEST/LIVE master-count mismatch remain open.

### Mobile Phone Catalogue Research — Batch 92 (25 October 2026)
Twenty variants were reviewed. No market observations were ingested because candidates failed source consistency or comparability checks: Galaxy S26 Ultra 512GB item 366668980137 and iPhone 17e 256GB item 188802102477 had conflicting original-page/search price captures; iPhone 17e item 800339607149 and Pixel 10 Pro item 377061374527 were marked sold in search but currently rendered active; Pixel seller feedback was only three entries; two iPhone 16 Pro candidates were damaged units. No masters or valuation logic were changed and no TEST/LIVE writes occurred. Batch 91 remains the latest successful ingestion. Do not treat Buyer Protection totals as seller proceeds or overwrite historic evidence to reconcile source discrepancies.