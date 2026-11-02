# Project Memory — 2 November 2026 — Selling Listing Editor Repair

- Root cause: Selling editor PATCHed `public.listings` directly. Authenticated direct UPDATE is revoked in both TEST and LIVE; RLS policies do not grant table privileges. Preserve this security boundary.
- New RPC `public.subscriber_update_listing_details(p_tenant_id,p_listing_id,p_title,p_description,p_asking_price,p_currency,p_listing_data)`: SECURITY DEFINER; requires auth.uid(), `selling.manage`, `module.selling`; rejects sold/delisted records; edits listing content/pricing only; does not alter status or ownership. Authenticated EXECUTE true; anon EXECUTE false.
- Migration `20261102130000_subscriber_update_listing_details.sql` applied independently to TEST `nnsshnfkjcflucjrftzi` and LIVE `gxsrajtqzdjvmceqcpgv`.
- Front end now uses RPC, normalises Manufacturer/Model/Package to avoid duplicate title when package equals model, leaves new public listing description blank rather than copying structured internal fields, and bumps Selling script cache to v92.
- Existing LIVE Adventure Outpost GoPro listing `LST-20261102-BA831BAE` was not modified. Its £0.00 asking price remains until user explicitly enters a retail price; never auto-copy £123 purchase price.
- Current branch: `fix/selling-listing-edit-security-20261102-v2`, based on latest production after concurrent catalogue commits. Manuals, diagnostic roadmap and checkpoint updated on branch.
- Outstanding: Cloudflare production/TEST deployment confirmation and browser save/reload test. Database grants alone are not E2E verification.
