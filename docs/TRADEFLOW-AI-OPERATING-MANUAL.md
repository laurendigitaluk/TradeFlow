# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 1.1  
**Date:** 15 September 2026  
**Project:** TradeFlow

## 1. Purpose
This is the AI continuity companion to `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`. It records current architectural truth, decisions, faults, lessons, limitations and verification state so future AI sessions can resume safely without guessing.

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
- Platform Owner is above tenant roles and uses a separate platform-level identity boundary.
- Subscription capabilities belong to the tenant.
- Customer data must remain tenant-isolated.
- Dynamic fields are data-driven; arbitrary browser JSON must not become valuation authority.
- Accepting an offer is not possession; acquisition, receipt, inspection, payment and inventory creation are separate lifecycle steps.
- Inventory and listings are separate domains.
- Public storefront access must resolve to a tenant and expose only published records.
- Do not mark a feature complete solely because code was committed.
- Do not expose temporary test-lab onboarding mechanisms as production onboarding.
- Do not store credentials or secrets in documentation or project memory.

## 4. Verification states
Use independently: Proposed, Implemented, Tested, Verified Live. A commit is implementation evidence, not live verification.

## 5. Current checkpoint — 15 September 2026
- GitHub repository: `laurendigitaluk/TradeFlow`, `main`.
- Supabase project: TradeFlow, ref `twfbmjwwqzxdxvclxbun`.
- Customer Test Lab: 34/34 passed at the recorded checkpoint.
- Customer subscription tests: Buying and Selling accounts recorded as 17/17 passed.
- Staff security lab: 19/19 passed.
- RLS enabled across the recorded public-table checkpoint.
- Customer subscription guard hardening completed through migration 043.
- Platform-owner security foundation implemented through migrations 044 and 045.
- Master roadmap: `TRADEFLOW-MASTER-ROADMAP.md`.

## 6. Platform-owner / tenant-role audit — 15 September 2026
Live Supabase inspection confirms:
- `tenant_memberships.role_code` is constrained to `owner`, `admin`, `staff`.
- `private.is_tenant_member()` checks active membership.
- `private.is_tenant_admin()` recognises active owner/admin memberships.
- `private.has_tenant_permission()` resolves active role permissions.
- Owner has the full current permission catalogue.
- Admin lacks `staff.manage`, `tenant.manage`, `audit.view`.
- Staff lacks `staff.manage`, `tenant.manage`, `website.manage`, `website.publish`, `finance.manage`, `audit.view`.

Migration 044 created `public.platform_memberships`, separate from tenant memberships, with controlled status, unique `user_id`, RLS and no client write policy. `private.is_platform_owner()` checks an explicitly provisioned active platform membership.

Migration 045 created restricted `private.require_platform_owner()` and `private.has_platform_owner_access()` guards. These bind identity to the current authenticated user and do not accept tenant ownership as a substitute.

**Current provisioning state:** `platform_memberships` contains zero rows. Therefore the platform-owner foundation is implemented, but no real platform-owner identity has been provisioned and no platform administration UI is verified.

## 7. Production onboarding finding
The original tenant foundation still has an authenticated tenant INSERT policy with `with check (true)`, and temporary test-lab onboarding functions exist. These are development mechanisms, not the final SaaS onboarding architecture.

Required production sequence:
**Platform Owner / approved onboarding → tenant creation → initial tenant owner provisioning → subscription assignment → tenant owner/admin/staff management.**

Never solve this by adding a `platform_owner` tenant role or by allowing users to self-claim platform ownership.

## 8. Documentation and diagnostic standard
For each major action record:
**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS → status transition → external integration → visible result → verification.**

If a route or connection has not been inspected, record **Roadmap status: Not yet audited**.

## 9. Current roadmap position
Customer security/subscription boundaries are verified. Tenant role permissions are inspected. Platform-owner security foundation is implemented but not provisioned or live-tested. Production tenant onboarding remains to be hardened. The next implementation task is to establish trusted platform-owner provisioning and the authoritative production tenant onboarding path, then verify tenant owner/admin/staff management before moving to the next AMBER business domain.

## 10. Change capture — 15 September 2026
**What changed:** migrations 044 and 045 added the separate platform-owner identity and authorisation foundation; Human/Developer Handbook and Master Roadmap were updated.

**Why:** the original architecture requires Gary/TradeFlow Platform Owner to sit above subscriber tenants. Tenant owner/admin/staff roles must remain tenant-scoped.

**Important finding:** the live platform membership table is empty, so provisioning and UI verification are still outstanding. The authenticated tenant INSERT policy remains unsuitable as the final production onboarding mechanism.

**Current stopping point:** do not alter the verified customer subscription layer. Continue with trusted platform-owner provisioning and production onboarding.
