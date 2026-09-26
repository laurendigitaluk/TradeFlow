# Subscriber dashboard account-control fix — 26 September 2026

## Issue
The subscriber dashboard displayed an Account button in the header, but no click handler was attached to `#account-details`. The existing account-details modal was therefore unreachable from the header. The Settings section also contained a “View account details” button without a handler.

## Repair
- Wired the header Account button to open the existing account-details modal.
- Wired the Settings “View account details” button to the same modal.
- Added close-button, backdrop-click and Escape-key handling.
- Reused the existing authenticated account values already populated by the dashboard: business, email, role and tenant.

## Scope
No buying, inventory, selling, orders, fulfilment, customer portal, authentication or database workflow logic was changed.
