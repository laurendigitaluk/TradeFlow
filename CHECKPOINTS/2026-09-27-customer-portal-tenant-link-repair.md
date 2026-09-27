# CHECKPOINT — 2026-09-27 Customer Portal Tenant-Link Repair

## Problem
The customer authentication/session repair was in place, but the public customer-facing website was still generating the Customer Portal link without the business tenant identifier.

The public site customer link previously stored the active tenant in the legacy localStorage key tradeflow_customer_tenant_id, then generated a bare customer-dashboard.html URL. The repaired customer portal no longer reads that localStorage fallback, so the portal correctly displayed: "This Customer Portal link is missing its business identifier."

## Repair
Updated public-site.js so:
- Customer Portal links include the current activeTenantId when the public site has tenant context.
- Customer portal session detection uses the tenant-specific tab-local session key tradeflow_customer_session:<tenant_id>.
- The public site no longer writes the legacy shared customer tenant key.
- Subscriber dashboard URL behavior remains unchanged.
- public-site.html cache version was bumped from public-site.js?v=81 to public-site.js?v=82.

## Intended flow
A customer visiting a tenant's public website and selecting Customer Login / Customer Account is taken to the tenant-scoped Customer Portal URL. The portal can therefore authenticate the customer against the correct business without relying on shared localStorage state.

## Related prior repair
This follows CHECKPOINTS/2026-09-27-customer-login-session-repair.md, which changed the customer portal authentication layer to require the tenant query parameter and use tenant-specific sessionStorage.

## Verification
GitHub commits:
- e0be282d1394d5bf06d5e5ff8571e9694d04f0b9 — customer portal URL/session-context repair
- 689e614b2837784c1050e52d1471fd872e8637c7 — public-site cache-bust update

## Next test
1. Allow GitHub Pages to publish the latest commits.
2. Open the business public website, not a manually typed bare customer-dashboard.html URL.
3. Click Customer Login / Customer Account.
4. Confirm the resulting URL contains customer-dashboard.html?tenant_id=21fca2c5-5da2-4ff6-9f8e-318f9b6277f9.
5. Sign in with the existing customer credentials.
6. Test a second customer in another Chrome tab to confirm sessions remain isolated.
