# TradeFlow Human User Manual

## Restore checkpoint — 18 September 2026

This document records the known-good stopping point for continuing TradeFlow development.

### Website Builder
The subscriber Website Builder is a visual, page-first editor with the current expanded template set:

1. Business
2. Premium Marketplace
3. Buy & Sell
4. Services
5. Editorial
6. Minimal
7. Retail
8. Professional
9. Bold
10. Classic
11. Local Business

The Premium Marketplace homepage is designed for a two-sided business and presents:
- professional hero
- buying and selling introduction
- visual What We Buy tiles
- visual What We Sell tiles
- trust information
- connected retail shop below the homepage

Homepage tile choices are 6, 8 or 10. Tiles can have their own title, description and image.

### Branding
Subscriber-controlled website colours are available for:
- Brand/accent
- Text
- Page background
- Header/navigation
- Buying section
- Selling section
- Footer

Quick palettes are available for Professional, Warm, Dark and Clean.

### Social, sharing and reviews
Subscribers can add:
- Facebook
- Instagram
- LinkedIn
- YouTube
- TikTok
- X

Website share buttons can be enabled or disabled.

Up to four review-site links can be added, such as Google Reviews, Trustpilot, Reviews.io or Feefo. TradeFlow displays subscriber-supplied external links; it does not verify third-party review profiles.

### Website workflow
Website content is saved as the existing site JSON within site_revisions. Images use the tenant-scoped tradeflow-site-media Storage bucket. Products remain connected to Inventory → Selling rather than being manually entered into the Website Builder.

The subscriber flow remains:
Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns.

### Subscriber onboarding repair
New subscriber onboarding now creates a 30-day trial window. The repair is migration 065, repair_subscriber_trial_entitlement_window.

The affected test subscriber's live database capability checks were verified for:
- tenant membership
- website.editor
- website.publish

No RLS or tenant security boundary was weakened.

### Restore point
GitHub restore branch:
checkpoint-tradeflow-20260918-premium-builder

Restore branch base:
7f03b3964add0857ebc0ec3bcce2bf0d7113c80c

Live Supabase migration state includes:
repair_subscriber_trial_entitlement_window

### Status
The code and database checkpoint are saved. Browser verification of the newest branding/social/review controls remains the next testing task when development resumes.

Do not modify GearCashOut while working on this TradeFlow checkpoint.


## Website domains and future domain purchasing — 19 September 2026

TradeFlow can already store a custom website address against your business. The current **Website URL** area is for connecting a domain you already own.

A future TradeFlow domain service is now supported by the database design. The intended customer journey is:

1. Open **Website / Domain** in the business dashboard.
2. Search for a domain name.
3. See current availability and price.
4. Choose the domain and registration period.
5. Pay through TradeFlow.
6. TradeFlow registers the domain through its domain provider.
7. TradeFlow connects the domain to the customer's website and enables the required SSL/hosting routing.
8. The domain appears in the business account with its registration and renewal information.

The database now records the information needed for purchased domains, including registration status, provider reference, purchase amount, expiry date and auto-renewal state.

**Important:** the domain-purchase button/search/checkout and automatic DNS/hosting connection are not yet live. The current Website URL page only records a domain as pending for later connection.

Domain availability and prices will be checked with the selected registrar at the time of purchase; the prices stored in TradeFlow's TLD catalogue are configuration/pricing data, not a promise of current availability.




## Website Builder final refinement pass — 19 September 2026

The subscriber Website Builder has now received the agreed refinement pass before final browser review. Added: controlled typography options (font style, hero/section/body/navigation size levels), button styles, header styles, footer styles, optional homepage section visibility, optional second images for the homepage hero and content pages, and cleaner image controls with Add/Replace/Remove behavior. Homepage tiles remain unnumbered and directly editable.

Public rendering now consumes the saved typography, section visibility and multi-image settings. Asset cache versions are refreshed and both Builder and public runtime syntax have been checked. This is **Implemented in GitHub, not yet browser-verified**. Final verification should cover Builder preview, Save Draft, Publish, public site, responsive layout and the new controls.


## Draft preview and can_tenant permission repair — 19 September 2026

Browser verification exposed two separate issues. First, authenticated Website Builder operations were failing with `permission denied for function can_tenant`. The live database had the required RLS policies calling `private.can_tenant(uuid,text,text)`, but EXECUTE was only granted to postgres. Live migration `fix_authenticated_can_tenant_execute` restored EXECUTE to the authenticated role without changing the SECURITY DEFINER function or weakening tenant/feature checks. The migration is recorded in `supabase/migrations/066_fix_authenticated_can_tenant_execute.sql`.

Second, the Builder's previous `Open public website` link attempted to load the published-site path. A newly created subscriber may have a draft but no published revision, so that path correctly reports that no published website exists. The Builder link has therefore been renamed **Preview website** and now opens an authenticated draft-preview mode. The preview reads the signed-in subscriber's draft through existing RLS-protected `tenant_site_state` and `site_revisions` access; it does not expose drafts anonymously. The public site remains the published-site path and will work after the subscriber publishes a revision.

Validation: Builder and public-site JavaScript syntax checked OK; live EXECUTE grant confirmed for authenticated. Browser end-to-end preview verification remains the next user check.


## Website Builder / Subscriber Template Rebuild — 20 September 2026

The subscriber website system has been rebuilt on branch `website-template-unification` so the visual template selected in Website Builder is the same template family rendered by the public subscriber website.

### Customer-facing design rules
- Both sides of the business are first-class: **What We Buy** and **What We Sell**.
- The public header contains a prominent **What We Buy** menu, populated from the subscriber's connected Buying Catalogue.
- The public header contains a direct **What We Sell** link to the retail shop.
- The What We Buy menu expands as new catalogue categories are added; it is not a fixed list of categories.
- Buying category pages show the current connected products and provide a **Start selling this category** route into the customer account flow.
- Retail products are loaded from the subscriber's published Inventory → Selling data.
- A site with a small buying catalogue stays compact; the same layout can expand as categories and products are added.
- The template does not require subscribers to re-enter catalogue products, prices or inventory.

### Four-step subscriber setup
1. Add business name and logo.
2. Choose brand colours.
3. Choose one of the ten templates.
4. Save, preview and publish.

Content, buying categories and retail products remain connected to TradeFlow rather than being duplicated inside the website editor.

### Ten supported templates
Editorial, Classic, Grid, Studio, Horizon, Field, Business, Luxe, Commerce and Impact.

The public renderer now contains the same ten template layouts and responsive rules used by the builder. The previous public-site shell and legacy template styling were removed so an old static header cannot appear underneath the new template.

### Business-name handling
A blank subscriber business name is now displayed as **Your business** rather than the platform name. The old public fallback to **TradeFlow** was removed. TradeFlow remains only as the platform attribution in the footer.

### Preview / deployment
The public website assets were cache-bumped to version 40. This is intentional so browsers do not continue serving the previous public-site CSS/JavaScript after the template rebuild.

### Architecture
- `website-builder.js` remains responsible for editing and saving subscriber website content.
- `public-site.js` is now a clean public renderer for the same ten template IDs.
- `public-site.css` was replaced with a public-only stylesheet matching the ten fresh template designs rather than carrying the previous legacy template family.
- The public page shell is now only a loading container; the renderer owns the header, hero, buying section, selling section and footer.
- Custom-domain public links now retain the active tenant ID after hostname resolution.

### Important future rule
Do not add separate visual layouts to the public renderer. Any future template must be added to the shared ten-template system and tested in both Website Builder and public Preview before publication.


## Guided Customer Selling Journey — 20 September 2026

The public subscriber website now treats **selling to the subscriber** as a guided valuation/request journey rather than a catalogue list.

### Customer journey
1. **What do you have to sell?** — choose the subscriber's buying category.
2. **What type?** — choose the product type/branch derived from the connected buying catalogue.
3. **What make?** — manufacturer options are narrowed from the connected catalogue.
4. **What model?** — model options are narrowed from the previous selections; package/version is shown when available.
5. **What condition is it in?** — sealed, opened-unused, excellent, good, fair, damaged, or not working/spares.
6. **Final questions** — missing package items, legal right to sell, DJI serial number when applicable, and additional notes.
7. **Review** — the customer reviews the complete request before continuing to their customer account.

The completed answers are carried in browser session state into the customer portal so the customer does not have to enter the same information again. The customer portal pre-fills the category, item title and a structured notes summary before submission.

### Navigation behaviour
- The homepage now includes a prominent **What do you have to sell?** prompt.
- What We Buy category menu entries route into the guided selling journey with the selected category preselected.
- Start Selling links from buying categories route into the same journey.
- The old buying catalogue remains available as an information view, but it is no longer the primary selling path.

### Future-proofing
The hierarchy is generated from the subscriber's connected buying catalogue rather than hard-coded DJI/drone choices. New categories, product types, manufacturers, models and packages therefore become available to the customer as the subscriber expands the catalogue.

The TradeFlow `category_fields` system remains the intended extension point for category-specific questions beyond the common selling questions. Those fields can later be surfaced dynamically in this journey without creating a separate page for each category.

### Current scope limitation
Photos are not falsely represented as uploaded by this public wizard. The current journey captures the structured information and hands it into the authenticated customer portal. Photo upload should be added as an authenticated evidence step when the existing media/storage workflow is connected to customer buying requests.


## Subscriber Business + Customer Portal Completion — 20 September 2026

TradeFlow now has the first production-oriented connection between subscriber business identity, subscriber customer management, customer account registration and the public customer website.

### Subscriber Business Settings
The subscriber Settings area now provides customer-facing business details: business name, public email, telephone, address, postcode, country, business description and public-display controls. Website URL and payment settings remain separate.

### Subscriber Customer Backend
Customer Management is now a dedicated tenant-scoped area. Subscribers can search customers and edit first name, last name, email, phone and status. The active tenant remains the security boundary.

### Customer Portal
The existing customer portal has been converted away from the old test-lab tenant selector. Customer registration now receives the tenant from the subscriber website and creates the customer relationship against that tenant. Customer profile editing is available for first name, last name and phone; authenticated email remains authoritative.

### Customer Website
The public website reads the subscriber's public business profile and can show the business description, telephone, email and address. Customer Login, What We Buy and What We Sell remain platform-controlled routes so subscribers cannot accidentally remove the core customer journey.

### Semi-editable design rule
Subscribers control templates, colours, backgrounds, typography, copy, imagery, logo, optional pages and social/review links. TradeFlow retains the customer-critical routes, tenant connection, catalogue connection, retail inventory connection and customer account entry.

### Security
A tenant-scoped tenant_public_profiles table is protected with RLS. Anonymous visitors receive read-only access to active tenant profiles. Subscriber writes require tenant.manage. Customer registration/update RPCs are restricted to authenticated users and use a pinned search path. A partial unique index prevents duplicate Auth-user/customer relationships within a tenant.

### Remaining portal work
Customer address management, richer subscriber customer detail/history, logo/profile media synchronisation and a complete fresh-account browser test remain follow-up items. Existing unrelated Security Advisor findings remain separate hardening work.


## Subscriber Website User Manual — 20 September 2026

A dedicated subscriber website manual is now available at `subscriber-website-manual.html` and is linked from the Subscriber Dashboard and Website Builder top bars.

The manual explains:
- Business Settings and authoritative business identity/logo.
- How to choose templates, edit page text, add images, change colours/backgrounds/typography and manage pages.
- Save Draft, Preview and Publish.
- **What We Buy:** products/categories are supplied automatically from the subscriber's active Buying Catalogue. Subscribers do not recreate catalogue products in Website Builder.
- **What We Sell:** customer-facing retail products are supplied automatically from the subscriber's published Selling listings. Subscribers do not recreate selling products in Website Builder.
- How to add products from the TradeFlow Master Catalogue by Category, Branch, Manufacturer or search.
- How Inventory and Selling connect products to the retail website.
- Which customer-critical platform routes and tenant/security connections should not be rebuilt in the visual editor.
- Basic troubleshooting for missing buying products, missing selling products, logo changes and unpublished website changes.

The Website Builder also shows a short page-specific guidance note when the subscriber selects **What We Buy** or **What We Sell**, explaining the automatic connection and linking directly to the relevant management area and the full manual.


## Live Buying Workflow Dashboard Repair — 21 September 2026

The subscriber Business Dashboard live-workflow panel was repaired without changing the underlying buying architecture or tenant security model.

The workflow summary now uses the existing Active acquisitions counter element correctly and counts active acquisition statuses (accepted, awaiting_item, received, processing). A mismatched DOM ID had previously thrown a JavaScript error after the data queries succeeded, which caused the dashboard to replace the workflow list with the generic Workflow status could not be loaded message.

The Buying page cache-buster was advanced so the corrected subscriber Buying controller is loaded rather than an older cached controller. The current Buying controller renders customer details, customer-supplied information, valuation amount/method/status, offer amount/status and next-action messaging from the existing tenant-scoped data.

Structured customer fields use category_fields.label; category_fields.name is not a valid column. No database schema change was required for this repair.

The live test record was not deleted or reset. Its current database state remains authoritative.

## Accepted Offer → Shipping Label Handoff — 21 September 2026

After a customer accepts an offer, the subscriber Buying workflow no longer treats the request as waiting for the customer. The next internal action is now **Send customer shipping label**.

The Buying request derives its accepted state from the accepted offer and the existing acquisition record, so the UI is not dependent on the older buying request/item status remaining at `offer_ready`.

The accepted stage shows the agreed offer amount, identifies the customer handoff, and provides the shipping-label URL, carrier, service, tracking number and customer instructions fields. Publishing the handoff writes to the existing acquisition shipping fields and moves an `accepted` acquisition to `awaiting_item` through the existing workflow transition function.

The existing Customer Portal already reads these acquisition shipping fields. After publication, the customer can see the label/instructions and can mark the item as posted. No new customer portal was created.

## Buying Dashboard Acquisition Loading Repair — 21 September 2026

A follow-up live test found that the accepted-offer logic had been added to the Buying controller, but the controller was not actually including the existing `acquisitions` REST query in the two data-loading Promise calls. As a result, the acquisition map was empty in the browser and the request fell back to the stale approved-valuation state. The repair restores the existing acquisition query; no new data model or workflow was introduced.

The accepted £100 test sale remains the live test record. After the browser loads the repaired controller, the accepted offer/acquisition should drive the subscriber stage to **Offer accepted — send customer shipping label** and expose the existing shipping handoff fields.


## Acquisition API Access Repair — 21 September 2026

The live Buying dashboard test exposed a database API privilege gap after the acquisition query was correctly restored in the controller. The `authenticated` role could access the existing acquisitions table for write operations but lacked `SELECT`, so the browser received `permission denied for table acquisitions`. The existing tenant-scoped RLS policy already requires `acquisitions.view` and the buying module. `SELECT` and `UPDATE` privileges were restored for `authenticated` so the subscriber can read and publish the existing shipping handoff without changing the RLS boundary or creating new tables.


## Accepted Offer Detail-State Repair — 21 September 2026

The Buying detail workspace contained a second, older offer renderer inside `loadItemFinancials()`. It could display `Approved valuation ... No offer has been sent yet` independently of the request-level lifecycle state. The repair passes the authoritative request workflow state into that renderer so an accepted request cannot display the pre-offer message. The Buying page now also starts its existing 10-second status refresh on initial load. Script cache-busting was advanced from v11 to v12.

## Accepted Offer Visibility and Customer Field Repairs — 21 September 2026

A final live browser test exposed two database-layer issues behind the contradictory Buying screen.

First, the existing offers_subscription_select and acquisitions_subscription_select policies were restrictive policies without a corresponding permissive SELECT policy. The subscriber therefore received zero rows from those REST reads even though the tenant permissions were correct. Live migration repair_offer_and_acquisition_select_policies added permissive tenant-member SELECT policies while retaining the existing restrictive subscription permission and feature checks.

Second, the customer-details RPC had a PostgreSQL CASE expression mixing text and jsonb return types. Live migration repair_subscriber_customer_field_json_types converts text-like field values to jsonb before building the response.

The authenticated-role database tests now return the accepted £100 offer and linked acquisition, and the customer-details RPC returns successfully for the live test item. The expected Buying stage is therefore **Offer accepted — send customer shipping label**, with the existing shipping handoff fields available. The legacy buying_requests.status and buying_items.status values remain offer_ready and must not override the accepted offer/acquisition state.

## Shipping Label Upload and Resend — 21 September 2026

The accepted-offer shipping handoff now supports two label sources:

- **Shipping label URL** — paste the label URL supplied by the carrier.
- **Uploaded shipping label** — upload a PDF, PNG or JPEG directly to TradeFlow.

Uploaded labels are stored in the existing private `tradeflow-media` bucket under the tenant/acquisition path. The customer can access only the label belonging to their own acquisition. The subscriber can open/print the label from the Buying or Acquisition workspace.

The shipping handoff action is now **Send shipping label to customer** initially, then **Save & resend shipping label** when a label already exists. This republishes the current label/instructions to the customer portal without creating a duplicate acquisition or offer.

The Customer Portal shows **Open / print shipping label** and **Download shipping label** when an uploaded label exists. Signed links are generated on demand rather than permanently exposing the private storage object.


## Shipping Service Override — 21 September 2026

The accepted-offer shipping handoff now has an explicit **Shipping method** choice. The subscriber can use the future automated courier route or select **Use my own shipping service** for an individual acquisition.

The subscriber override supports:
- shipping label URL;
- uploaded shipping label (PDF, PNG or JPEG);
- QR code URL;
- uploaded QR code image (PNG or JPEG);
- courier/carrier;
- service;
- tracking number;
- customer shipping instructions.

The manual/override route does not create a separate shipping system. It writes to the existing acquisition shipping handoff and keeps the same accepted → awaiting_item workflow. A handoff can contain a label, a QR code, or both.

The Customer Portal now shows the selected shipping method, courier/service information, label actions and any QR code supplied by the subscriber. QR images remain in the private TradeFlow media bucket and are exposed to the authenticated customer through on-demand signed URLs.

The automated Voila option is currently represented in the UI but deliberately disabled until the secure Voila account/API connection is implemented. This prevents a subscriber from selecting an automated route that cannot yet create a real label.


## Shipping Cost Responsibility — 21 September 2026

TradeFlow does not handle customer shipping payments or shipping expenses. For items a customer is selling to a subscriber, the **subscriber is responsible for arranging and paying for shipping**. TradeFlow does not add shipping to the accepted offer, collect a shipping payment, reimburse the customer, or record customer shipping as a TradeFlow business expense.

The shipping handoff is an information and workflow facility only. It may contain a subscriber-provided label, URL, QR code, courier/service details, tracking information and instructions. The subscriber can use its own shipping arrangement or the future Voila route. The financial responsibility for shipping remains outside TradeFlow's transaction and accounting model.

## Connected Parcel2Go shipping
After an offer is accepted, a subscriber can use a connected Parcel2Go account instead of manually supplying a label. The subscriber's connected shipping service is used to arrange the shipment; the customer does not arrange or pay the shipping through TradeFlow. The £ offer remains separate from shipping. Manual label and QR handoff remains available as an override.


### Shipping handoff and customer confirmation

Shipping settings are business-wide and are shared by Buying/acquisitions and the Retail Shop sales/fulfilment workflow. Configure shipping providers once under Settings → Shipping services.

For an accepted acquisition, the subscriber chooses either a manual label or an integrated shipping service. The customer-facing handoff keeps the provider/service link separate from the actual physical shipping label and QR code. Uploaded label/QR files have separate Download and Print controls. The customer also sees the carrier/service, tracking number and tracking link, instructions, and a clear **Item sent** button.

Publishing the shipping handoff does not mean the customer has sent the item. The acquisition remains **Awaiting item from customer** until the customer clicks **Item sent** after handing the parcel to the courier or dropping it off. Only then does the subscriber see **Item on its way — awaiting receipt** and the integrated tracking state can progress.

The customer does not pay the shipping cost in this workflow. The subscriber arranges and pays the shipping service and supplies the label/QR/instructions needed by the customer.


## 22 September 2026 — Shipping handoff controls and receipt workflow

The shipping handoff is one continuous customer-facing block. It must distinguish:
- **Shipping service / provider website** — an external service link only.
- **Physical shipping label** — the actual uploaded label stored in private TradeFlow media.
- **Physical QR code** — the actual uploaded QR asset stored in private TradeFlow media.
- **Tracking** — tracking number and, where available, a provider tracking URL.

The subscriber Buying/Acquisition workspace provides separate controls to print/download the physical label and QR code, plus a resend/replace action. A provider website link must never be treated as the physical label or QR asset.

Publishing the handoff moves an accepted acquisition into **Awaiting item from customer**. Customer clicking **Item sent** records customer_sent_at and shipping_status=in_transit; the database acquisition workflow remains awaiting_item until the subscriber confirms receipt. The subscriber then sees **Item on its way — awaiting receipt** and a **Confirm item received** action. That action performs the authoritative awaiting_item → received transition, after which the existing received → inspection workflow continues.

If a label is missing from the acquisition record, staff must be able to replace/upload the physical label and resend the handoff. Storage objects are private and should be referenced from the acquisition record rather than exposed publicly.


## 2026-09-22 — Item receipt and inspection handoff repair

The acquisition receipt stage is authoritative. When the subscriber confirms receipt after the customer has sent the item, the acquisition moves to `received`, `received_at` is recorded, shipping status becomes `received`, and the next acquisition action is inspection. The customer portal now explicitly renders `Item received by subscriber — inspection next`; the subscriber Buying dashboard renders `Item received — inspection next` and the existing acquisition inspection workflow remains the next operational step. Receipt handling also synchronises acquisition-item workflow state through the authoritative workflow transition function. Shipping remains subscriber-arranged and subscriber-paid; the £100 accepted offer is not altered by receipt.


## 2026-09-22 — Purchasing inspection workspace after item receipt

When an acquisition reaches **received**, the Subscriber Buying workspace now presents a clear **Next step required — you've received the item, inspect it** action with **START INSPECTION**. Inspection remains in Purchasing/Buying rather than the legacy Acquisition test workspace.

Starting inspection uses the authoritative `subscriber_start_acquisition_inspection` RPC. It creates the linked inventory asset when necessary, synchronises the acquisition and acquisition-item workflow to `inspection`, and opens the full Purchasing inspection workspace.

The inspection compares the physical item against the customer's submitted information and records:
- customer description match;
- condition match against the customer's declaration;
- package/accessories verification;
- serial/model verification;
- physical condition/damage;
- function/technical test;
- inspector condition grade;
- discrepancies/missing items/faults;
- inspection notes;
- inspection photographs.

Completion routes are explicit: **Pass inspection — send to Sales**, **Requires Testing**, **Requires Repair**, or **Not as described — hold for review**. A passed inspection moves the inventory asset to `ready_for_sale`, finalises the acquisition and acquisition item, and leaves the inspection as the authoritative read-only record for Sales. The original accepted offer remains unchanged.


## 2026-09-22 — Correction: receipt → inspection → final offer

The customer-facing portal no longer exposes the internal term "subscriber". Customer wording now uses business/website terminology instead.

The received Purchasing stage now has a direct START INSPECTION action in the main Buying dashboard itself. This was moved into the authoritative dashboard controller so it does not depend on the supplemental inspection script to create the CTA.

The correct acquisition flow after receipt is:
Received → Inspection → Inspection complete / Final offer required → Customer accepts or refuses final offer → payment process → Sales.

The original accepted offer remains distinct from the post-inspection final valuation and final offer. A passed inspection therefore does not immediately put the inventory item into Sales. The inventory asset remains in inspection while the final offer is sent and awaits the customer's response.

The inspection completion RPC was corrected accordingly: acquisition and acquisition-item move to finalised with next_stage=final_offer; the inventory asset remains inspection and is marked as requiring a final offer. Testing and repair outcomes still leave the item in their respective Purchasing/Repairs routes.


## 2026-09-22 — Inspection CTA ownership and customer wording follow-up

The inspection CTA is now handled by the main Buying dashboard as the authoritative workflow controller. The supplemental inspection workspace delegates its `START INSPECTION` click to that controller when available, preventing the CTA from appearing clickable while being owned by a separate polling script. Customer selling-status wording has also been removed from the internal `subscriber` terminology, including receipt and inspection messages. Browser cache versions were incremented for the Buying and customer dashboard scripts.


## 2026-09-22 — Inspection notice and direct Testing navigation

Human manual — direct Testing workspace link from Purchasing inspection. The inspection outcome now uses “Send to Testing”. Selecting it reveals an OPEN TESTING link that opens Inventory directly filtered to Testing and focuses the current asset. The Buying dashboard notice is driven by the acquisition workflow state so an inspected/received item cannot display the obsolete “Item on its way — awaiting receipt” message.

## 2026-09-22 — Purchasing is pre-acquisition until payment

The purchasing journey has been corrected so an item received from a customer is **not yet an acquisition and is not inventory**.

The authoritative sequence is now:

1. Initial offer accepted by customer → purchasing workflow moves to **Awaiting item**.
2. Customer receives shipping instructions and sends the item → **Shipping / Item on its way**.
3. Business confirms physical receipt → **Received**.
4. Business starts the inspection → **Inspection in progress**.
5. Inspection outcome is recorded as **Accept — continue to final offer**, **Send to Testing**, **Requires Repair**, or **Refuse — return to customer**.
6. An accepted inspection moves to **Final offer required**. A separate final offer is sent to the customer.
7. Customer accepts the final offer → **Final offer accepted — payment required**.
8. Staff records the bank payment → only then does TradeFlow create the **Acquisition**, **Acquisition Item**, **Payment Record**, and **Inventory Asset**.
9. The new inventory asset is created ready for sale after the purchase is completed.

The Acquisitions workspace now represents completed purchases rather than the customer's initial acceptance of an offer. Provisional receipt/inspection data is stored against the buying item in the pre-acquisition purchasing workflow.

The current test Canon EOS R7 transaction was repaired accordingly: its provisional acquisition and inventory asset were removed, its shipping data was retained in the pre-acquisition workflow, and the buying item is currently at **Inspection**.

## 2026-09-22 — Inspection shortcut and business workflow board

The Buying detail now retains a direct **OPEN INSPECTION** link while an item is in the inspection stage. It opens the inspection workspace for the currently open buying item; it does not create or imply an acquisition.

The Business Dashboard live workflow board now reads the pre-acquisition purchase stage. Received, inspection, testing, repair, return and final-offer/payment stages are therefore visible as active purchasing work rather than being omitted because no acquisition exists yet.
## 2026-09-22 — Open Inspection link target corrected

The **OPEN INSPECTION** link on an in-progress Buying request now targets the actual `tradeflow-inspection-workspace` section generated by the inspection workspace. It no longer targets the broader item-detail/quotation container.
## 2026-09-22 — Open Inspection asynchronous render fix

The embedded inspection workspace is rendered asynchronously by `buying-inspection.js`. The OPEN INSPECTION control now waits for `#tradeflow-inspection-workspace` to exist before scrolling to it, so the link remains reliable even when the inspection section has not finished loading at click time.
## 2026-09-22 — Dashboard attention count and direct inspection action

The Business Dashboard now includes a dedicated **Needs attention** count for pre-acquisition work such as inspection, testing, repair, final offer and payment. The inspection row has an **OPEN INSPECTION** action that opens the specific Buying request and automatically opens/scrolls to its embedded inspection workspace.

## 2026-09-23 — Purchasing workflow audit corrections

The business dashboard's **Needs attention** count represents active pre-purchase work such as inspection, testing, repair, final offer and payment. Completed purchases are counted separately under Completed purchases.

The Buying request's **OPEN INSPECTION** action opens the embedded Purchasing Inspection workspace after it has rendered. Inspection remains within Buying and does not create an acquisition.

Acquisitions and Inventory are now purchase-completion records. They are created only after the customer has accepted the final offer and the bank payment has been recorded.

## 2026-09-23 — OPEN INSPECTION repair

The OPEN INSPECTION action now explicitly asks the embedded Purchasing Inspection workspace to render before scrolling to it. It no longer relies only on a browser hash jump or on the inspection element already existing.

The inspection workspace itself is also resilient to missing/failed inspection-media lookups. Existing inspection photographs are optional; they must never prevent the inspection checks and outcome controls from appearing.

The current Canon EOS R7 request remains at Inspection in progress. The OPEN INSPECTION action is navigation only and does not change the purchase stage.

## 2026-09-23 — Final offer, customer bank details and payment completion

The post-inspection path is now connected end-to-end around the existing pre-acquisition workflow.

Sequence:
1. Inspection accepted -> purchase_stage=final_offer_required.
2. Staff sends a separate final offer -> purchase_stage=final_offer_sent.
3. Customer accepts the final offer -> purchase_stage=final_offer_accepted.
4. Customer portal immediately asks for the UK bank account details to receive payment. The customer can save or update account holder name, sort code, account number and optional bank name.
5. The subscriber Buying workspace checks whether bank details are on file. Full bank details are exposed only through the finance.view-protected subscriber RPC; the payment operation requires buying.manage and finance.manage.
6. Staff sends the bank payment and records the bank payment reference using CONFIRM PAYMENT SENT & COMPLETE PURCHASE.
7. The authoritative purchase RPC verifies the accepted final offer, customer bank details and payment reference, then creates the paid Payment Record, Acquisition, Acquisition Item and Inventory Asset atomically and moves the buying item to purchased. The inventory asset starts at ready_for_sale.

Customer bank details are stored in a dedicated tenant/customer table with RLS enabled and no direct authenticated/anonymous table grants. Customer and subscriber access is through controlled security-definer RPCs.

The current Canon test remains at final_offer_required until the final offer is sent. No acquisition or inventory record is created merely by passing inspection.


## 2026-09-23 — Final offer, bank details and payment handoff verified

The post-inspection purchase backend already contains the intended next-stage workflow:

- Passed inspection moves the buying item to final_offer_required.
- subscriber_publish_final_offer creates the separate final offer and moves the item to final_offer_sent.
- The customer portal already presents the final offer for acceptance and, after final-offer acceptance, presents the secure bank-details form.
- customer_bank_details stores account holder name, UK sort code, account number and optional bank name; customer access is through customer_get_bank_details/customer_save_bank_details rather than direct browser table access.
- The subscriber Buying inspection workspace already checks subscriber_get_customer_bank_details after final-offer acceptance and masks the account number for display.
- subscriber_complete_purchase refuses to complete the purchase unless the final offer is accepted, bank details exist and a bank payment reference has been entered. It then creates the outbound paid payment record, acquisition, acquisition item and inventory asset with status ready_for_sale, and moves purchase_stage to purchased in the same transaction.

The missing connection found in this audit was the customer notification when a final post-inspection offer is published. The final-offer RPC now records an offer_sent notification event and queues the existing customer notification infrastructure when the customer has an email address. Migration 20260923000001_final_offer_customer_notification.sql was applied to live Supabase and committed to the repository.

For the current Canon test, the item is at final_offer_required with no bank details and no final offer yet. No purchase/payment/inventory record has been created. Staff must choose the final offer amount and publish it; the customer can then accept it and enter bank details; staff can verify the bank details, make the bank transfer, enter the bank payment reference and use CONFIRM PAYMENT SENT & COMPLETE PURCHASE. Only then is the item purchased and the inventory asset created ready_for_sale.


## Customer portal sign-in
The customer portal uses `customer-auth.js` as the single authentication controller. The dashboard page receives the authenticated session through `tradeflow-auth-success` / `tradeflowHandleCustomerAuthSuccess` and then loads the portal data. Do not add a second Sign in/Sign up handler to `customer-dashboard.js`; duplicate handlers can start competing portal initialisation requests. The dashboard script remains responsible for loading authenticated portal data after the handoff.


### Customer portal login implementation
Customer portal scripts must load deterministically: `customer-dashboard.js` first with `defer`, `customer-dashboard-nav.js` second with `defer`, and `customer-auth.js` last with `defer`. On successful authentication, `customer-auth.js` immediately hides the login panel and reveals the portal, then hands the session to `tradeflowHandleCustomerAuthSuccess`. Do not rely on script execution races or duplicate authentication controllers.


## 2026-09-23 — Customer portal empty-account repair

- The customer portal was revealing its static `Welcome back` shell but showing zero requests/orders/returns because `customer-dashboard.js` contained a JavaScript parse error in the bank-details rendering block. The error was caused by single-quoted HTML containing the conditional text `hasBank?'Update bank details':'Save bank details'`, which terminated the JavaScript string before the portal controller could load.
- The broken block was converted to a template literal and the resulting file was syntax-checked successfully. `customer-dashboard.html` now references `customer-dashboard.js?v=18` to force the repaired controller to load.
- Live Supabase verification for customer `valley-discounts@outlook.com`, tenant `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`, confirms the customer profile, request `BR-744BA41BDC`, approved £100 valuation, published final offer `OF-A03E4C24CB`, and customer-facing RPCs all return the expected records when run under the customer's auth identity.
- The test buying item had a published final offer but was still marked `final_offer_required`. This was repaired to `final_offer_sent`, guarded by the existence of the published final offer. No acquisition or inventory record was created.
- Next customer step remains: review the £100 final offer and accept/refuse it. If accepted, the portal should collect bank details; the business then completes the external bank transfer and records the payment reference before acquisition/inventory creation.


## 2026-09-23 — Final payment, bank-detail reveal and purchase completion

- After final-offer acceptance, the Buying workflow now has a payment-completion path in the current repository. It checks the accepted final offer and customer bank details through a finance-gated RPC before enabling payment confirmation.
- Customer bank details are masked by default in the subscriber Buying workspace. Sort code and account number can be hovered to reveal the full values. Full values are only returned by `subscriber_get_buying_item_payment_details`, which requires both `buying.view` and `finance.manage` permissions.
- `CONFIRM PAYMENT SENT & COMPLETE PURCHASE` remains disabled until the payment prerequisites are present and a bank payment reference has been entered. TradeFlow does not perform the external bank transfer; staff make the bank transfer first, then record the reference in TradeFlow.
- `subscriber_complete_purchase` is now wired to the Buying dashboard. A successful confirmation atomically records the outbound seller payment, creates the acquisition and acquisition item, creates the inventory asset with `ready_for_sale`, moves the buying item to `purchased`, and queues the existing `payment_sent` customer notification.
- The current Canon test item remains uncompleted. It is at `final_offer_accepted`, with customer bank details present, and has no acquisition or inventory record yet. No payment was recorded during this repair.


## 2026-09-23 — Payment UI consolidation and CTA repair

- The first payment UI repair created a duplicate payment panel because both the Buying item workspace and the existing inspection workspace rendered payment controls. The duplicate Buying-dashboard payment panel has been removed. The inspection workspace is now the single payment UI for the `final_offer_accepted` stage.
- Bank details now use explicit Reveal/Hide controls rather than relying on a browser `title` tooltip. Sort code and account number are masked by default and can be revealed by an authorised subscriber user when making the bank transfer.
- The payment CTA is intentionally disabled until bank details are present and a bank payment reference has been entered. Typing a reference now immediately enables `CONFIRM PAYMENT SENT & COMPLETE PURCHASE`.
- The CTA calls `subscriber_complete_purchase`; successful completion records the payment, creates the acquisition/acquisition item and ready-for-sale inventory asset, changes the buying item to `purchased`, queues the existing `payment_sent` customer notification, and refreshes the workflow in place.
- Buying dashboard cache versions are now `buying-dashboard.js?v=44` and `buying-inspection.js?v=11`.


## 2026-09-23 — Payment CTA and customer payment-status refresh follow-up

- The payment completion CTA was adjusted so it is enabled whenever the customer bank details are present. It no longer becomes silently unclickable simply because the payment-reference field is blank. Clicking it without a reference now focuses the reference field and displays the required-reference message.
- The CTA still requires a bank payment reference before `subscriber_complete_purchase` can execute. This preserves the rule that staff must make the external bank transfer before recording it as paid.
- The customer portal now refreshes the selling workflow every 10 seconds while visible. After the purchase-completion transaction changes the buying item to `purchased`, the customer dashboard updates without requiring a manual page refresh.
- The customer-facing purchased status now explicitly reads `Payment sent — purchase complete` and explains that the business has sent the payment and the item is now part of business inventory.
- Current cache versions: customer dashboard `v21`; buying inspection `v12`.


## 2026-09-23 — Inventory payment-order guard repair

- The first live attempt to confirm the Canon payment reached the inventory boundary and returned: `Inventory assets require a recorded acquisition payment`.
- Root cause: `subscriber_complete_purchase` created the paid acquisition and acquisition item, but inserted the inventory asset before linking the outbound `payment_records` row to the acquisition. The inventory guard correctly rejected that ordering.
- The completion transaction has been repaired so `payment_records.acquisition_id` is populated immediately after the paid acquisition is created and before the inventory asset is inserted. The inventory boundary can therefore verify the recorded acquisition payment as designed.
- The failed attempt rolled back cleanly. Current Canon state remains `final_offer_accepted` with zero payment records, zero acquisitions and zero inventory assets. No purchase was completed by the failed attempt.


## 2026-09-23 — Customer payment-complete wording

- Customer-facing purchased-stage wording was simplified. The portal now shows `Payment sent` with the message: `The business has sent your payment. Please check your bank account for the payment.`
- Customer messaging no longer tells the seller that the item has become part of the business inventory. Inventory/acquisition progression remains an internal business-side workflow.
- Customer dashboard cache is now `customer-dashboard.js?v=20`.


## 2026-09-23 — Acquisitions dashboard loading and inventory hand-off

- The Acquisitions page was stuck on `Loading acquisitions…` because its legacy tenant helper only recognised the two old test-business tenant IDs. The live Camerashack tenant ID was valid in the URL but was rejected by that helper before the acquisition query ran.
- The tenant helper now accepts the tenant ID supplied by the authenticated subscriber URL, so the live acquisition query can run for the current tenant. Dashboard cache is now `acquisition-dashboard.js?v=16`.
- The current Canon purchase has already created acquisition `ACQ-BA60C739F2A2`, acquisition item `433b206c-0044-44fc-bdbf-9873c9bb6197`, and inventory asset `AST-20260923-F0856A6E` with status `ready_for_sale`.
- The Acquisitions item view now exposes an `Open in Inventory` link for an existing inventory asset. `ready_for_sale` is the pre-sales inventory stage: the item is owned and in inventory but has not yet been listed/sold. The Inventory workflow can then move it to `listed` when ready.


## 2026-09-23 — Acquisitions retired; Inventory becomes the hand-off point

- The separate Acquisitions UI is being retired from the subscriber navigation. The legacy `acquisition-dashboard.html` now redirects to Inventory so old bookmarks do not strand users on the obsolete workflow.
- A completed purchase already creates the acquisition record internally for audit/payment boundaries, but staff no longer need an Acquisitions screen to move the product onward. The customer payment completion transaction creates the inventory asset directly with `ready_for_sale` status.
- Inventory is now the operational hand-off: staff can edit the asset details, add photographs, and use `Send this item to a sales channel` / `Send to sales` to open the Selling workspace for that inventory asset.
- Selling accepts a preselected inventory asset and lets staff choose an active sales channel. The listing flow carries the inventory photographs into the listing. The inventory asset retains its lifecycle independently from the listing.
- The Selling asset lookup now includes `branch_id`, fixing the listing form's branch requirement for inventory-created assets.
- Inventory and Selling navigation no longer expose Acquisitions. The Inventory script cache is `inventory-dashboard-fixed.js?v=11`; Selling is `selling-dashboard-fixed.js?v=8`.


## 2026-09-23 — Replace Acquisitions with inventory-to-sales workflow

- The separate Acquisitions UI is retired from the operational workflow. A completed purchase now creates the paid acquisition record internally and the inventory asset directly at `ready_for_sale`.
- The old Acquisitions page no longer loads a separate workspace; it redirects to Inventory. This removes the obsolete `Loading acquisitions…` screen from the normal business flow.
- Inventory `ready_for_sale` is now the hand-off point to Selling. The inventory dashboard no longer offers a direct `Mark listed` action. It provides `Send to sales`, opening the Selling workspace focused on that inventory asset.
- Selling is the place where staff add/confirm the sales listing information: title, description, asking price, sales channel and postage/dispatch details. Inventory photographs are carried into the listing automatically.
- A live `TradeFlow Website` storefront sales channel has been created for the Camerashack tenant. The existing public website only displays listings after a listing is actually created and moved to `published`; changing an inventory asset to `listed` was never sufficient to create a website listing.
- The Canon test asset was returned from the accidental `listed` status to `ready_for_sale`. It has not been published as a sales listing because no genuine selling price/details have been supplied yet.
- The selling channel model remains extensible for marketplace channels. A marketplace must have its own configured sales channel/integration before TradeFlow can publish to it; the website channel is the current working storefront channel.
- Cache versions: `inventory-dashboard-fixed.js?v=11`, `selling-dashboard-fixed.js?v=9`.


## 2026-09-23 — Single Inventory → Sales workflow and autofill

- Acquisitions is no longer a separate business-operating category. Completed purchases are created as inventory directly; the acquisition records remain internal accounting/audit records.
- The main subscriber dashboard no longer presents Acquisitions as a workflow step. The legacy acquisitions page redirects to Inventory.
- Inventory `ready_for_sale` is the sales-team hand-off point. Selecting an asset or using `Send to sales` opens Selling with the asset focused.
- Selling now loads the complete inventory context for the selected asset: title, description, currency, current value as the initial asking-price suggestion, condition, serial number, quantity, location, category and selling branch. Category/branch are loaded from the actual tenant data rather than the old test-only lookup.
- Sales staff can then adjust the selling information and add postage/dispatch details before creating the listing for the selected sales channel. Inventory photographs are carried into the listing when it is created.
- The workflow is therefore Buying → purchased → Inventory / Ready for sale → Selling → selected sales channel → published listing. Acquisitions remains a back-office record rather than a user-facing stage.
- Selling dashboard cache is now `selling-dashboard-fixed.js?v=10`.


## 2026-09-23 — Sales listing source information and photographs

- The Selling workspace now treats the original Buying record and completed Inspection as source material for preparing a sales listing.
- When an Inventory asset is selected, Selling loads the linked buying item/request and displays the customer's item description, condition, request notes/explanation and structured customer-supplied fields. It also displays the latest completed inspection outcome, condition grade, inspection notes, inspection checks and discrepancies.
- Customer/inspection photographs linked through `buying_item_media` and `media_assets` are displayed in the Selling workspace using time-limited signed URLs. The underlying media bucket remains private; private Storage assets are intended to be accessed through authorised downloads or signed URLs. citeturn0search0turn0search1
- Sales staff can add further sales photographs directly from the Selling workspace. These are stored against the Inventory asset and are then available to be carried into listings.
- Manual Selling category and branch dropdowns have been removed. The listing inherits the category and branch already attached to the purchased Inventory asset, which are retained from the original Buying category/branch. The shared Category → Branch → Properties structure remains independently enabled for Buying/Selling, but the individual purchased item should not be re-categorised manually during listing preparation.
- The Selling workspace therefore uses the original buying classification as the source of truth for the shop listing, while the sales team concentrates on title, description, price, photographs, postage/dispatch and sales-channel publication.
- Selling dashboard cache is now `selling-dashboard-fixed.js?v=11`.


## 2026-09-23 — Dashboard workflow colour coding and Inventory action layout

- The Business Dashboard workflow now shows a live numeric count on each core stage: Buying, Inventory, Selling, Orders, Fulfilment and Returns.
- Workflow colour semantics are fixed: **green = action required**, **yellow = no action/waiting**, **blue = completed/active historical state**. Each stage has a clear CTA button rather than relying on plain text.
- Inventory is explicitly shown as the purchased-stock hand-off. A ready-for-sale inventory count appears in the Business Workflow and the Inventory card is green with **SEND TO SALES** when stock needs sales preparation.
- The Inventory page now keeps **Add product** collapsed by default as a dropdown/expandable block. The status/filter/refresh area is a separate block immediately below it.
- Inventory status rows are colour-coded and use explicit action buttons. A ready_for_sale asset is green and exposes **REVIEW & COMPLETE**. The inline Sales hand-off has been removed; **SEND TO SALES** only appears inside the asset detail after the Inventory completion check passes. completed lifecycle states use blue; waiting/no-action states use yellow.
- Selling retains the inherited original buying category/branch rather than asking sales staff to choose unrelated category and branch values. The selling listing should therefore use the original buying classification automatically; the sales team should not have to reclassify the purchased item merely to create a listing.
- Selling also has source-information and photograph areas for the customer's original submission and inspection record, plus customer/inspection photographs and additional sales photographs. These are now part of the intended listing-preparation workflow and should be visible below the listing form when the current deployed page is refreshed.
- Cache/version checkpoints: Inventory inventory-dashboard-fixed.js?v=13; Selling selling-dashboard-fixed.js?v=15; Public site public-site.css?v=57 and public-site.js?v=56.


## 2026-09-23 — Purchased Inventory → Sales Preparation → Website

A completed purchase hands the item to Inventory with status **Prepared for sale / ready_for_sale**. Inventory is the operational stock hand-off; Acquisitions remains an internal accounting/audit record.

From Inventory, staff must first open the purchased asset and use **REVIEW & COMPLETE**. The Inventory card is now a clear stock record rather than a raw table row. The Sales hand-off is deliberately locked until the required Inventory information has been checked and completed. Selling preloads the inventory title, condition, price suggestion where available, category and branch, and now also retrieves the original customer submission and inspection context from the linked Buying item. Customer name/reference and structured customer fields are shown where available; missing information is displayed as not provided rather than being invented.

Photographs are sourced from both the original Buying-item media links and the Inventory asset media links. This is important because photographs added to the purchased Inventory asset do not necessarily exist in buying_item_media. The Selling workspace also permits additional sales photographs to be uploaded to the Inventory asset.

The primary sales action is **SEND TO SALES / PUBLISH TO WEBSITE**. Completing the listing creates the actual listings record, carries Inventory photographs into listing_media, transitions the listing through draft → ready → published, and then transitions the Inventory asset from ready_for_sale → listed. Publication is therefore based on the actual storefront listing record rather than merely changing an Inventory status.

The current Camerashack test tenant has an active **TradeFlow Website** sales channel and a published site revision. The Canon test currently has one published listing at £125 and is marked listed in Inventory.


## 2026-09-23 — Inventory completion gate before Sales

The purchased item is represented once as an Inventory asset. It is no longer an active Buying item after purchase completion. The Inventory list now presents each purchased asset as a clear card showing the asset reference, product title, status, condition, quantity, purchase price, current value, location and serial number.

The old inline SEND TO SALES action has been removed from the Inventory list. Staff must select **REVIEW & COMPLETE**, check the Inventory record and complete the required stock information first. The detail view shows a completion checklist. SEND TO SALES is only displayed when the required Inventory information is complete. This prevents an unfinished asset from being handed to Sales and reinforces the workflow: Buying → Inventory → Sales, with one Inventory asset rather than a duplicate purchase item.

The current completion gate checks: product title, description, condition, quantity, purchase price, category, branch, location and serial number. Current value is retained as a separate field and is not treated as the retail asking price.


## 2026-09-23 — Compact Inventory → Product Listing workspace

Inventory is now intentionally compact: each active item is a single green action-required line showing only the product title, status and **REVIEW & COMPLETE**. The row opens the focused product workspace. The previous verbose inventory card and inline hand-off were removed so large inventories do not become long scrolling pages.

The focused product workspace places purchase/customer/inspection information and retained photographs first, followed by a simple retail listing template. The listing template pre-fills the product title and uses inspection notes as the listing description when available, otherwise the original customer/item description. Retail condition uses the business taxonomy: **Poor, Good, Very good, Excellent, Opened, Never used, Sealed**. Existing A/B/C/D values were found in the live `condition_grade` data; they were not part of the newly requested retail taxonomy, so legacy grades are not silently converted and the user is prompted to select the new wording. Additional listing photographs can be added before **SEND TO WEBSITE** publishes the listing.


## 2026-09-23 — Selling listings presentation and storefront visibility

The Selling page now presents existing listings in the same compact, structured style as Inventory. Each listing has separated Reference, Title, Status, Price, Channel and Action areas, with a coloured status treatment and spaced action buttons. A **VIEW** action is always available, while workflow actions retain their status-specific labels such as **Reserve**, **Mark sold** and **Delist**.

The focused Product workspace hides the general listings panel so the product preparation workflow remains focused on purchase information, photographs and the retail listing template. The selling dashboard script cache version was also incremented so the updated layout is loaded by the browser.

A live database check on 23 September 2026 also identified why the published Canon listing was not appearing in the public Retail Shop: the listing itself is published on the active TradeFlow Website channel, but its inherited Camera category and Camera branch currently have selling_enabled = false. The storefront publication query excludes listings whose category/branch are not enabled for selling. This is a live category/branch configuration issue rather than a missing listing record.


## 2026-09-23 — Duplicate listing prevention and storefront repair

The Canon test exposed a duplicate-listing path: repeated submission created seven additional draft listings for the same Inventory asset while the original listing was already published. Those seven accidental draft records were removed. An active-per-asset unique index now prevents more than one non-sold/non-delisted listing for the same tenant and Inventory asset. The Selling workspace also checks for an existing active listing before creating one and locks a focused product once its Inventory status is `listed`.

The live `buying_item_media` table was missing the `SELECT` table grant for authenticated users even though a SELECT policy existed. The grant was restored so the Product workspace can load purchase media instead of showing a permission error.

The Canon Camera category and Camera branch were both active but had selling disabled. Both are now enabled for selling. Live verification now returns the published Canon listing from `get_published_store_listings`, and the Inventory asset is marked `listed`.
## 2026-09-23 — Public Retail Shop product images and product-page access

The public Retail Shop now treats a published listing as a public product record rather than sending the visitor directly to the Customer Account. **View product** opens a public TradeFlow product page using the listing reference, and that product page is accessible whether or not the visitor is signed in. The product page contains the product title, category, price, description, quantity/currency information and the available retail photographs. The separate **Buy this item** action can then take the visitor into the customer purchasing journey.

The public search field no longer displays the development placeholder text PLACEHOLDER.

Published listing photographs are read through a dedicated public storefront media function. The underlying tradeflow-media bucket remains private; a storage policy exposes only media attached to genuinely published, selling-enabled storefront listings. This prevents unrelated Inventory, customer or shipping media in the same bucket from becoming public.

The Canon test currently has one published listing, LST-20260923-B5AAABFB, with one linked Inventory photograph. The public storefront database functions return both the published listing and its published media path.

## 2026-09-23 — Inventory listed-state display

Inventory no longer labels every row as **Action required**. ready_for_sale and other active preparation states remain action-required, while listed, sold, returned, written_off and archived display their actual lifecycle status and use the completed blue treatment. Listed items use **VIEW PRODUCT** rather than **REVIEW & COMPLETE**.

## 2026-09-23 — Selling focused workspace lookup repair

The focused Product workspace was still showing the general Existing listings panel and lookup fields remained on Loading because the focused-mode initialization was running before the asset lookup completed. The Selling lookup loader now fetches the requested asset directly when an asset query parameter is present, handles the four lookup requests independently so one optional lookup cannot leave the whole form stuck in Loading, and applies focused-product mode only after lookups finish. The general Existing listings panel is hidden after focused initialization. The listed-item submit lock selector was also corrected so a listed product cannot expose an active publish button.

Selling dashboard cache version: **selling-dashboard-fixed.js?v=17**.

## 2026-09-23 — Final Selling loading and public product image repair

- The Selling Product workspace had a second loading problem caused by waiting indefinitely on the subscriber-auth readiness promise. The Selling loader now uses the already-established subscriber auth object immediately when available and has an eight-second failure timeout instead of remaining on Loading forever.
- Focused Product lookup and initialization therefore completes even when the authentication readiness promise has already been established elsewhere on the page.
- Selling dashboard cache version is now selling-dashboard-fixed.js?v=18.
- Retail product images were still broken because the public browser was attempting to create private Storage signed URLs directly. A public validation-only Edge Function named public-listing-media now validates that the requested listing is published, its category/channel are active and selling-enabled, and its tenant has a published site revision, then creates time-limited signed URLs using the server-side service role.
- The function source is stored in supabase/functions/public-listing-media/index.ts and is deployed to the live Supabase project.
- public-site.js now calls that function for published listing media instead of attempting browser-side private-bucket signing. Public site cache is now public-site.js?v=57 with CSS v57.
- The underlying tradeflow-media bucket remains private; this repair does not make the mixed business/customer media bucket public.


## 2026-09-23 — Selling load error, retail condition and public sales details

- The Selling dashboard had a live JavaScript error because the listing renderer called an undefined `statusLabel()` function. This stopped the normal listing render before the remaining Selling lookups completed, leaving the focused product page showing **Loading listings/assets/channels**. `statusLabel()` is now defined with explicit labels for draft, ready, published, reserved, sold and delisted.
- Selling cache version is now **selling-dashboard-fixed.js?v=19**.
- The retail listing form now requires a retail condition before a new listing can be published. The selected retail condition is stored in `listings.listing_data.condition`.
- The public product page now displays **Condition** and **P&P**, while deliberately omitting **Quantity** and **Currency** from the customer-facing product facts.
- The published-store RPC now exposes `listing_data` so the public site can read the listing's retail condition and shipping information without exposing the underlying listings table directly.
- Public site cache version is now **public-site.js?v=59 / public-site.css?v=59**.
- The existing Canon test listing was created before the new retail-condition requirement and currently has no `listing_data.condition`; therefore its public product page will show **Condition: Not specified** until a retail condition is recorded. No A/B/C/D inspection grade is silently converted into a retail condition.


## 2026-09-23 Selling Listing Editing

Existing sales listings are now editable from the Selling dashboard. Use **EDIT** on an existing listing to load its current title, description, asking price, retail condition, postage option, postage price and dispatch time. **SAVE CHANGES** updates the existing listing in place; it does not create a duplicate and does not change its publication status. **CANCEL EDIT** exits edit mode. Published website product pages read the updated listing data through the published-store RPC, so price, description, condition and P&P changes are reflected on the public product page after refresh.


## 2026-09-23 Customer Portal Session Repair

The customer portal login loop was traced to two separate scripts attempting to restore the same customer session on page load. The dashboard could refresh an expired access token while the authentication script simultaneously validated the old token and removed the session, leaving the login panel visible. Session restoration is now owned by `customer-auth.js`; expired access tokens are refreshed using the stored refresh token before the session is accepted. The dashboard no longer performs a second independent restoration. Cache versions were advanced to customer dashboard v22 and customer auth v6.


## 2026-09-23 — Selling listing edit action correction

The Existing listings block now includes a visible **EDIT** button for active listings, including published products. Selecting EDIT opens that exact listing in the Retail listing form; it does not require searching Inventory first and does not create a new listing. The form button changes to **UPDATE LISTING**. Updating changes the existing listing's title, description, asking price, retail condition, postage option, postage price and dispatch time while preserving its current publication status. Sold and delisted history is not offered for editing.


## 2026-09-23 — Retail listing photograph editing

When an existing listing is opened with **EDIT**, the Selling workspace now loads the photographs attached specifically to that retail listing. Staff can select additional image files and use **ADD / UPDATE LISTING PHOTOGRAPHS** to attach them to the listing. Existing retail listing photographs can be removed from the listing with **REMOVE FROM LISTING**. Removing a photograph unlinks it from the listing but does not delete the underlying media file from TradeFlow. Purchase/customer/inspection photographs remain separate source material.
