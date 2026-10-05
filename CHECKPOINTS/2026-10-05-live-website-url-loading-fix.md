# LIVE CHECKPOINT — Website URL Included Address Loading Fix — 2026-10-05

The LIVE Website URL page was showing the included website address as "Preparing..." because the page waited for an unnecessary tenant-slug REST lookup before rendering the address.

Fix:
- Removed the unnecessary tenant-slug lookup from the LIVE Website URL page.
- The included address now renders directly from the authenticated subscriber tenant context and current LIVE application origin.
- Increased the domain-settings script cache version from v2 to v3.

No changes were made to the Porkbun purchase workflow, custom-domain connection workflow, or locked Website Builder.
