# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 1.0  
**Date:** 15 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose

This is the human-readable technical and operational handbook for TradeFlow. It documents verified architecture and progressively records exact workflow connections as each area is audited.

The handbook is not a substitute for source code or Supabase migrations. Where documentation and deployed behaviour differ, inspect current GitHub and Supabase state and correct the documentation.

## 2. Authority

The authoritative operational model is:

**Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour.**

A Git commit alone is not proof that a feature works live.

## 3. Architecture baseline

TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

The intended hierarchy is:

**TradeFlow platform → subscriber tenant → tenant owner/admin/staff → tenant customers**

Subscriber businesses are tenants. Tenant staff are authorised through tenant memberships and roles. Customers belong to a tenant and must not cross tenant boundaries. Subscription capabilities belong to the tenant.

The current database role catalogue contains exactly the tenant roles `owner`, `admin` and `staff`. A separate platform-owner implementation has **not** been found in the current inspected database/code and must not be assumed to exist.

## 4. Current verified security state

- Customer tenant/isolation test: 34/34 passed at the recorded checkpoint.
- Customer subscription tests: Buying and Selling customer accounts recorded as 17/17 passed.
- Staff security test: 19/19 passed at the recorded checkpoint.
- RLS is enabled across the recorded public-table checkpoint.
- Customer subscription read/action guard hardening is implemented through migration 043.

## 5. Tenant-role boundary — audited 15 September 2026

### Database model inspected

`public.tenant_memberships` contains:

- `tenant_id`
- `user_id`
- `role_code`
- `status`

`role_code` is constrained to `owner`, `admin` or `staff`.

`public.roles` and `public.role_permissions` provide the permission model. `private.has_tenant_permission()` resolves a permission from the authenticated user's active tenant membership and role.

`private.is_tenant_member()` checks active membership. `private.is_tenant_admin()` currently treats `owner` and `admin` as tenant administrators.

### Verified role capability catalogue

Owner currently has the complete system permission set, including staff management, tenant management, finance, website management/publishing, buying, valuation, offers, acquisition, inventory, selling, orders, fulfilment, returns, messaging, notifications, categories, customers and audit.

Admin has the operational management permissions but does not have `staff.manage`, `tenant.manage` or `audit.view` in the current role-permission mapping.

Staff has operational permissions appropriate to day-to-day work and does not have `staff.manage`, `tenant.manage`, `website.manage`, `website.publish`, `finance.manage` or `audit.view` in the current mapping. Staff does have `tenant.view` and relevant operational view/manage permissions.

This mapping is database evidence, not a claim that every UI route has yet been traced.

### Important security finding

The current foundation migration permits an authenticated user to insert a tenant (`tenants_insert_authenticated` uses `with check (true)`). The project also contains temporary test-lab onboarding mechanisms. This is **not yet accepted as production onboarding architecture**.

The platform-owner/admin boundary and production tenant-creation flow therefore remain an audit/implementation item. Do not expose unrestricted production tenant creation merely because the test lab can create tenants.

## 6. Developer Diagnostic Roadmap standard

For every major TradeFlow feature, document this exact chain once inspected:

**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS → status transition → external integration → visible result → verification state.**

For each feature record:

- visible entry point;
- exact HTML/page;
- JavaScript/controller/module;
- handler/function;
- Supabase query/RPC/Edge Function;
- tables and important fields/statuses;
- database functions, triggers, constraints and RLS;
- external services where applicable;
- failure modes;
- recovery path;
- verification state: Proposed / Implemented / Tested / Verified Live.

Do not invent paths. If a connection has not been inspected, mark it **Not yet audited**.

## 7. Documentation change rule

A material change is not closed until the relevant documentation and verification state are updated. Where applicable update:

1. this Human / Developer System Handbook;
2. `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`;
3. the TradeFlow structured Supabase project-memory/checkpoint layer;
4. `TRADEFLOW-MASTER-ROADMAP.md`.

## 8. Audit sequence

1. Platform owner / platform administration boundary.
2. Tenant owner/admin/staff management workflow.
3. Dynamic categories and fields.
4. Complete Buying workflow.
5. Trading Value and valuation workflow.
6. Offers and customer response.
7. Acquisition, receipt, inspection, payment and inventory creation.
8. Inventory and Selling/listings.
9. Retail orders, fulfilment and returns.
10. Finance/payment records.
11. Notifications/email.
12. Public storefront and published read model.
13. Media/storage.
14. Final system-wide RLS, grants, RPC and integration audit.

## 9. Current stopping point

The customer subscription boundary is verified. The first platform/tenant-role audit has now confirmed the tenant role model and permission mapping, while also identifying that the separate TradeFlow platform-owner layer and production tenant onboarding are not yet verified.

Next work must address that boundary before moving deeper into the AMBER business workflows.
