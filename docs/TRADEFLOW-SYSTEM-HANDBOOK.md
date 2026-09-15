# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 1.1  
**Date:** 15 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose
This is the human-readable technical and operational handbook for TradeFlow. It documents verified architecture and progressively records exact workflow connections as each area is audited.

## 2. Authority
**Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour.**
A Git commit alone is not proof that a feature works live.

## 3. Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow platform → subscriber tenant → tenant owner/admin/staff → tenant customers**

The tenant role catalogue is `owner`, `admin`, `staff`. Platform ownership is a separate platform-level boundary and must not be represented by giving a tenant membership elevated powers.

## 4. Verified security checkpoint
- Customer tenant/isolation test: 34/34 passed at the recorded checkpoint.
- Customer subscription tests: Buying and Selling accounts recorded as 17/17 passed.
- Staff security test: 19/19 passed.
- RLS enabled across the recorded public-table checkpoint.
- Customer subscription guard hardening through migration 043.

## 5. Tenant-role boundary — audited 15 September 2026
`public.tenant_memberships` contains `tenant_id`, `user_id`, `role_code`, and `status`; `role_code` is constrained to `owner`, `admin`, or `staff`.

`public.roles` and `public.role_permissions` provide the permission model. `private.has_tenant_permission()` resolves active tenant-role permissions. `private.is_tenant_member()` checks active membership and `private.is_tenant_admin()` treats active owners/admins as tenant administrators.

Owner currently has the full permission catalogue. Admin does not have `staff.manage`, `tenant.manage`, or `audit.view`. Staff does not have `staff.manage`, `tenant.manage`, `website.manage`, `website.publish`, `finance.manage`, or `audit.view`.

This is database evidence; every UI route still requires workflow tracing.

## 6. Platform-owner boundary — foundation implemented 15 September 2026
Migration 044 adds `public.platform_memberships`, deliberately separate from `tenant_memberships`, with controlled status and a unique authenticated `user_id`. RLS is enabled and only self-read is exposed; there is no client insert/update/delete path.

Migration 044 adds `private.is_platform_owner()`. Migration 045 adds restricted `private.require_platform_owner()` and `private.has_platform_owner_access()` guards. The guards bind identity to the current `auth.uid()` and do not accept tenant ownership as a substitute.

**Provisioning status:** the live table currently contains zero platform memberships. The security foundation therefore exists, but no real platform-owner account has yet been provisioned and no platform administration UI is verified.

Provisioning must use a trusted administrative path. There must be no public or tenant-level self-claim mechanism.

## 7. Production tenant onboarding finding
The original foundation still contains an authenticated tenant INSERT policy using `with check (true)`, and temporary test-lab onboarding mechanisms exist. These are not accepted as production onboarding architecture.

The intended production sequence is:
**Platform Owner / approved onboarding → tenant creation → initial tenant owner provisioning → subscription assignment → tenant owner/admin/staff management.**

The unrestricted authenticated tenant-insert route must be removed or replaced with an authoritative production onboarding service before public SaaS launch.

## 8. Diagnostic standard
For every major feature document:
**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS → status transition → external integration → visible result → verification state.**

Record exact pages, controllers, handlers, RPCs/queries, tables, statuses, functions, triggers, constraints, RLS, external services, failure modes and recovery. If not inspected, mark **Not yet audited**.

## 9. Documentation change rule
A material change is not closed until the relevant Human/Developer Handbook, AI Operating Manual, structured Supabase project-memory/checkpoint layer where available, and Master Roadmap are updated.

## 10. Audit sequence
1. Complete platform-owner provisioning and platform administration boundary.
2. Replace/harden production tenant onboarding and complete tenant owner/admin/staff management.
3. Dynamic categories and fields.
4. Complete Buying workflow.
5. Trading Value and valuation.
6. Offers and customer response.
7. Acquisition, receipt, inspection, payment and inventory creation.
8. Inventory and Selling/listings.
9. Retail orders, fulfilment and returns.
10. Finance/payment records.
11. Notifications/email.
12. Public storefront and published read model.
13. Media/storage.
14. Final system-wide RLS, grants, RPC and integration audit.

## 11. Current stopping point
Customer subscription security is verified and tenant role permissions are inspected. Platform-owner security foundation is implemented through migrations 044/045 but is not yet provisioned or live-tested. Production tenant onboarding remains to be hardened.
