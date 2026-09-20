# TradeFlow Subscriber + Customer Portal Completion Checkpoint — 20 September 2026

## Scope completed

This checkpoint records the first production-oriented completion pass for the subscriber business details, subscriber customer backend, customer account flow, and customer-facing website connection.

### Architecture retained

- One shared TradeFlow application.
- tenants remains the business boundary.
- Subscriber membership/auth remains the source of the active tenant.
- Existing customer portal remains the single customer portal; no second customer portal was created.
- Existing tenant-scoped catalogue, buying, selling, orders, fulfilment and returns architecture remains in place.
- Website Builder remains the subscriber-controlled design layer.

## Subscriber business details

Added a tenant-scoped tenant_public_profiles table for customer-facing business information.

Subscriber-editable fields now include:

- Business name
- Customer-facing email
- Telephone
- Address
- Town/city
- County
- Postcode
- Country code
- Customer-facing business description
- Whether email, telephone and address are shown publicly

Business name is still sourced from tenants.name; the public profile keeps a synchronised copy for safe public presentation.

Subscriber Settings now contains the business profile editor alongside existing payment settings and domain/website links.

## Subscriber customer backend

Added:

- customers.html
- customers.js

The subscriber can now view and search only customers belonging to the active tenant and edit customer first name, last name, email, phone and status.

The subscriber dashboard now links directly to Customer Management instead of showing a placeholder customer section.

## Production customer account flow

The old test-lab customer registration/tenant selection is no longer used by the main customer portal.

Added:

- customer_register_for_tenant(...)
- customer_update_profile(...)

Customer registration is tied to the tenant_id supplied by the subscriber's customer-facing website. The customer cannot select an arbitrary test business.

Customer profile editing now allows the customer to maintain first name, last name and phone while email remains tied to the authenticated account.

A partial unique index now prevents the same Auth user from being registered twice against the same tenant.

## Customer-facing website

The existing public website now loads the subscriber's public business profile and can display:

- Business description
- Telephone
- Email
- Address

The public navigation continues to force the core TradeFlow customer functions:

- What We Buy
- What We Sell
- Customer Login

The footer also retains those customer-critical links regardless of the subscriber's optional navigation choices.

## Semi-editable website model

The subscriber retains control over:

- Template
- Colours
- Background mode/pattern
- Typography
- Hero and page text
- Images
- Logo
- Optional pages
- Social/review links
- Layout and tile choices

TradeFlow retains control over customer-critical structure:

- Customer account entry
- What We Buy route
- What We Sell route
- Subscriber/tenant data connection
- Customer-to-tenant security
- Buying catalogue connection
- Published retail inventory connection
- Checkout and customer workflow routes

The Website Builder now treats the business name as controlled by Business Settings rather than ordinary website copy.

## Database/security work

Added RLS to tenant_public_profiles.

- Public visitors can read only the profile of an active tenant.
- Subscribers can write their own tenant profile only with tenant.manage.
- Anonymous users cannot insert or update public profiles.
- Customer registration/update functions are executable by authenticated users only.
- Security-definer functions use a pinned empty search path.

## Verification completed

- Public profile rows created for all existing tenants.
- Active tenant profile is readable as anon.
- Anonymous insert/update privileges on tenant_public_profiles are disabled.
- Customer registration/update RPCs are not executable by anon.
- Authenticated execution privileges for the customer RPCs are present.
- Subscriber owner RLS update against the active tenant profile was verified.
- Existing duplicate customer (tenant_id, auth_user_id) pairs were checked before adding the unique index; no duplicates were found.

## Known follow-up work

Not included in this pass:

1. Customer address create/edit/delete UI.
2. Subscriber customer detail page with full order/acquisition/return history.
3. Tenant-specific logo/profile media synchronisation between Business Settings and Website Builder.
4. Full end-to-end browser test using a fresh subscriber account and fresh customer account.
5. Existing Supabase Security Advisor findings unrelated to this feature remain open and should be hardened separately rather than mixed into this feature.

## Branch

subscriber-customer-portal-completion

The branch contains the application changes and the corresponding Supabase migration file:

supabase/migrations/20260920203230_subscriber_customer_portal_profile.sql

## Important

No existing background/template simplification was reverted. The Website Builder's current ten-template and simplified background system remains the active design architecture.


## Follow-up pass — Customer addresses + subscriber customer history

Completed after the initial portal foundation:

- Customer portal now supports address create/edit/delete.
- Customer can mark an address as default.
- Address mutations are performed through authenticated, tenant/customer-scoped RPCs.
- Anonymous execution of those mutation RPCs is disabled.
- Subscriber Customer Management now includes a customer History view.
- History shows tenant-scoped orders, buying requests, acquisitions and returns.
- Live Supabase migration: customer_address_management.
- GitHub PR #41 was merged to main.

### Next
- Synchronise logo/business identity cleanly between Business Settings and Website Builder.
- Run a fresh-account browser end-to-end test across subscriber website, customer registration, customer portal and core buying/selling flows.


## Follow-up pass — Business identity logo synchronisation

Completed after PR #41. Business Settings is now the authoritative source for the subscriber business logo. Settings can upload or remove a PNG/JPEG/WebP logo using the existing `tradeflow-site-media` storage bucket and records the asset in `media_assets`. The Website Builder reads the authoritative `tenant_public_profiles.logo_url`, no longer exposes competing logo editing controls, and preserves the business logo through website resets. The public website prefers the authoritative tenant profile logo so the customer-facing identity stays consistent even before a website draft is republished. PR #42 merged to main with merge commit `3753cb6b05a46e66f132acbbe10f26142f32b72c`.

Supabase verification confirmed the existing public `tradeflow-site-media` bucket and the `tenant_public_profiles.logo_url` column, plus authenticated tenant-scoped update policy coverage. No new database migration was required.
