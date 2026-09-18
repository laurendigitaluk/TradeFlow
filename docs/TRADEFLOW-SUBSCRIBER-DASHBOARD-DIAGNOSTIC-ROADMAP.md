# TradeFlow Subscriber Dashboard — Developer Diagnostic Roadmap

**Status:** Living roadmap  
**Date:** 18 September 2026  
**Purpose:** Map the subscriber business application shell without duplicating or replacing the existing backend workflows.

## 1. Product boundary

TradeFlow has four distinct layers:

1. TradeFlow SaaS marketing website.
2. Platform Owner administration.
3. Subscriber private business dashboard.
4. Subscriber customer-facing website.

This roadmap covers layer 3 only.

The subscriber dashboard is an application shell over the existing tenant-scoped backend. It must not become a second business-logic layer.

## 2. Current entry point

User action:
- Subscriber signs in and enters the business workspace.

Front-end entry:
- subscriber-dashboard.html
- subscriber-dashboard.css
- subscriber-auth.js
- subscriber-tenant-context.js

Authentication/data flow:
Subscriber Auth
→ Supabase Auth session
→ subscriber_get_my_memberships()
→ selected tenant membership
→ tenant_id / role
→ subscriber tenant context
→ existing workspace controller
→ tenant-scoped RPC/table/RLS
→ visible business result.

## 3. Existing operational destinations

The shell currently links to these real existing pages:

- buying-dashboard.html
- acquisition-dashboard.html
- inventory-dashboard.html
- selling-dashboard.html
- orders-dashboard.html
- fulfilment-dashboard.html
- returns-dashboard.html
- finance-dashboard.html
- categories.html
- website-builder.html

Do not invent replacement pages until the existing page/controller has been inspected.

## 4. Security boundary

Tenant boundary:
- public.tenants
- public.tenant_memberships
- authenticated subscriber session
- private.has_tenant_feature()
- private.require_tenant_feature()
- private.has_tenant_permission()
- private.has_tenant_role()
- tenant-scoped RLS policies

Tenant roles:
- owner
- admin
- staff

Platform Owner is separate and must never be introduced as a tenant role.

## 5. Subscription boundary

Authoritative objects:
- public.plans
- public.plan_features
- public.tenant_subscriptions
- private.has_tenant_feature()
- private.require_tenant_feature()

Current active plans:
- Basic
- Enhanced
- Catalogue

Catalogue is intentionally held back from operational subscriber rollout until Gemma can maintain/update the TradeFlow product catalogue. Do not remove the active Catalogue plan and do not seed catalogue data merely to make the UI appear complete.

## 6. Website Builder boundary

Existing entry:
- website-builder.html
- website-builder.js

Existing persistence:
- tenant_site_state
- site_revisions
- tenant_domains
- published_site_index
- publish_site_revision()
- get_published_site_preview()
- get_published_sites()

Do not replace the revision/publishing architecture while improving the shell.

## 7. Dashboard build sequence

Stage 1:
- common subscriber shell
- authentication loading order
- tenant identity
- navigation groups
- responsive layout
- dashboard entry page

Stage 2:
- real dashboard work queue
- authenticated live summary data
- needs-attention actions
- website status

Stage 3:
- apply common shell consistently to existing operational pages
- preserve each page's existing controller and backend calls

Stage 4:
- Website workspace
- genuine template layouts
- branding/content controls
- preview/publish/domain areas

Stage 5:
- feature-aware navigation
- staff, messaging, analytics, audit, integrations and market intelligence where entitled

## 8. Failure points to investigate first

1. Subscriber authentication promise does not load.
2. Tenant membership cannot be resolved.
3. URL tenant_id differs from authenticated tenant.
4. Workspace controller starts before subscriber tenant context.
5. Controller uses legacy customer/test-lab session state.
6. Feature gate rejects the tenant correctly.
7. Permission/RLS rejects an operation correctly.
8. Front-end navigation points to a nonexistent or placeholder destination.
9. Existing controller is broken independently of the shell.
10. Website Builder revision/publishing state becomes inconsistent.

Never weaken RLS or subscription enforcement to hide one of these failures.

## 9. Change-control rule

For every shell change:

Current GitHub main
→ relevant existing file
→ live Supabase object
→ smallest UI change
→ static/runtime test
→ representative authenticated browser test
→ verify no existing workflow regression
→ update System Handbook
→ update AI Operating Manual
→ update this roadmap/checkpoint.

Verification states remain:
**Proposed → Implemented → Tested → Verified Live.**

## 10. Current checkpoint

Stage 1 shell is implemented on branch subscriber-shell-stage1.

Changed:
- subscriber-dashboard.html
- subscriber-dashboard.css
- System Handbook
- AI Operating Manual

No Supabase schema, RLS policy, RPC, Edge Function or existing operational controller was changed.

Live browser verification remains open before merging this staging branch to main.
