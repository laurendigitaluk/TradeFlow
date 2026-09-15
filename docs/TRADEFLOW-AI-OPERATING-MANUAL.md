# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 1.0  
**Date:** 15 September 2026  
**Project:** TradeFlow

## 1. Purpose

This document is the AI continuity companion to `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`. It records current architectural truth, decisions, faults, lessons, limitations and verification state so future AI sessions can resume safely without guessing.

## 2. Mandatory procedure

For significant TradeFlow work:

**Retrieve → inspect current GitHub → inspect current Supabase → identify the first actual failure/boundary → change minimally → test → verify live → document → capture checkpoint.**

Never treat chat history or a remembered summary as sufficient when current code/database state can be inspected.

## 3. Non-negotiable TradeFlow rules

- Never modify GearCashOut production when working on TradeFlow.
- `tenant_id` is the primary tenant security boundary.
- Never infer tenant identity merely from `auth.uid()` when a user can belong to multiple tenants.
- Tenant staff access is through `tenant_memberships` and role permissions.
- Current tenant roles are `owner`, `admin`, `staff`.
- Platform Owner is conceptually above tenant roles, but a separate database/platform-owner implementation must not be claimed until inspected and implemented.
- Subscription capabilities belong to the tenant.
- Customer data must remain tenant-isolated.
- Dynamic fields are data-driven; arbitrary browser JSON must not become valuation authority.
- Accepting an offer must not be treated as possession; acquisition, receipt, inspection, payment and inventory creation are separate lifecycle steps.
- Inventory and listings are separate domains.
- Public storefront access must resolve to a tenant and expose only published records.
- Do not mark a feature complete solely because code was committed.
- Do not expose temporary test-lab onboarding mechanisms as production onboarding.
- Do not store credentials or secrets in documentation or project memory.

## 4. Verification states

Use these states independently:

1. Proposed
2. Implemented
3. Tested
4. Verified Live

A commit is implementation evidence, not live verification.

## 5. Current verified checkpoint — 15 September 2026

- GitHub repository: `laurendigitaluk/TradeFlow`, `main`.
- Supabase project: TradeFlow, ref `twfbmjwwqzxdxvclxbun`.
- Customer Test Lab: 34/34 passed at the recorded checkpoint.
- Customer subscription tests: Buying and Selling accounts recorded as 17/17 passed.
- Staff security lab: 19/19 passed.
- RLS enabled across the recorded public-table checkpoint.
- Customer subscription guard hardening completed through migration 043.
- Master roadmap is `TRADEFLOW-MASTER-ROADMAP.md`.

## 6. Platform-owner / tenant-role audit — 15 September 2026

Current database inspection confirms:

- `tenant_memberships.role_code` is constrained to `owner`, `admin`, `staff`.
- `private.is_tenant_member()` checks active membership.
- `private.is_tenant_admin()` treats active `owner` and `admin` memberships as tenant administrators.
- `private.has_tenant_permission()` resolves active role permissions for a tenant.
- Current role permissions give Owner the full permission catalogue.
- Admin does not have `staff.manage`, `tenant.manage` or `audit.view`.
- Staff does not have `staff.manage`, `tenant.manage`, `website.manage`, `website.publish`, `finance.manage` or `audit.view`.

The audit also found that the original tenant foundation contains an authenticated tenant INSERT policy with `with check (true)`, and test-lab onboarding functions exist. Therefore production tenant creation and the separate platform-owner control plane remain **not yet verified / not yet production-complete**.

Do not repair this by simply adding a `platform_owner` role to tenant memberships. The intended hierarchy is platform owner above tenants, so the correct implementation must be designed and audited as a platform-level control boundary rather than as an ordinary tenant role.

## 7. Diagnostic roadmap requirement

For each major action, record:

**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS → status transition → external integration → visible result → verification.**

If a route has not been inspected, say **Roadmap status: Not yet audited**.

## 8. Current roadmap position

The customer security/subscription boundary is protected and verified. Tenant role permissions are now inspected at database level. The next implementation/audit task is the **TradeFlow platform-owner control boundary and production tenant onboarding**, followed by tenant owner/admin/staff management workflow.

After that continue through the Master Roadmap AMBER domains without disturbing the verified customer subscription layer.

## 9. Mandatory change capture

After meaningful work record:

- what changed;
- why;
- affected GitHub files and Supabase objects;
- architectural decisions;
- faults and lessons;
- test result;
- live verification result;
- current stopping point.

Then update the Human / Developer Handbook, this AI manual, the Master Roadmap and the structured Supabase memory/checkpoint layer where available.
