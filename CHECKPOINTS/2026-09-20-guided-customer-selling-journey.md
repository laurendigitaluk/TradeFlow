# TradeFlow Guided Customer Selling Journey Checkpoint — 20 September 2026

## Branch
`customer-selling-journey`

Base: `main` after the website template unification merge.

## Purpose
Replace the public buying-list experience with a clear customer journey that asks **What do you have to sell?** and narrows the item through the subscriber's actual buying catalogue before handing the completed request into the customer account.

## Implemented
- Added a dedicated public `page=sell` journey.
- Homepage now has a prominent What do you have to sell? prompt.
- What We Buy category navigation now routes into the guided journey.
- Category selection is populated from the connected public buying catalogue.
- Product type/branch is derived from catalogue data.
- Manufacturer is filtered by category/type.
- Model is filtered by category/type/manufacturer.
- Package/version appears when the selected model has package data.
- Condition step mirrors the existing GearCashOut-style valuation questions.
- Added missing-items, legal-right-to-sell and additional-notes questions.
- DJI serial number is requested when the selected manufacturer is DJI.
- Review step summarises the request before account handoff.
- Request data is stored temporarily in sessionStorage and carried into the customer portal.
- Customer portal pre-fills category, item title and structured notes from the journey.
- Public CSS includes responsive mobile layout for the wizard.
- Public and customer-dashboard cache versions were bumped.

## Data architecture
No new product/category tables were created. The hierarchy is driven from the existing public buying catalogue RPC, which returns category, branch/product type, manufacturer, model and package data.

The existing `category_fields` system remains the future extension point for additional category-specific questions. The current common selling questions are captured without pretending that photo upload is already connected.

## Acceptance criteria
1. Customer lands on a subscriber website and immediately sees a clear route to **What do you have to sell?**.
2. Category selection is dynamic.
3. Selecting Drone narrows the next choices to the drone types available to that subscriber.
4. Manufacturer, model and package choices narrow progressively.
5. Condition and final questions are captured.
6. Customer reviews the request before handoff.
7. After authentication, the customer does not have to retype the collected information.
8. The request remains tied to the subscriber tenant.
9. Adding catalogue products/categories changes the available choices without rebuilding the website template.
10. Mobile layout remains usable.

## Not yet implemented
- Authenticated photo upload directly inside the guided wizard.
- Full dynamic `category_fields` rendering in the public wizard.
- Automatic valuation calculation during the customer journey.
- Multiple-item basket in the new guided public flow.

These should be added through the existing TradeFlow buying-request/media/valuation architecture rather than by creating a parallel data model.
