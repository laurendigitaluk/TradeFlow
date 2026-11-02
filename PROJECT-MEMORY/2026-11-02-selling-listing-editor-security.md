# Project Memory — 2 November 2026 — Selling Listing Editor Repair

TradeFlow Selling editor failure and repair record.

- Root cause: `selling-dashboard-fixed.js` PATCHed `public.listings` directly. Authenticated table UPDATE is revoked in both TEST and LIVE; RLS policy does not itself grant SQL table privilege. This is intentional security posture and must not be weakened.
- New narrow RPC: `public.subscriber_update_listing_details(p_tenant_id,p_listing_id,p_title,p_description,p_asking_price,p_currency,p_listing_data)`. Requires auth.uid(), `selling.manage`, `module.selling`; refuses sold/delisted rows; updates content/pricing only, never workflow status or ownership. Authenticated EXECUTE true; anon EXECUTE false.
- Migration `20261102130000_subscriber_update_listing_details.sql` applied to TEST `nnsshnfkjcflucjrftzi` and LIVE `gxsrajtqzdjvmceqcpgv` independently.
- Frontend now calls the RPC; title normalizer reads structured Manufacturer/Model/Package and avoids repeating Package when identical to Model. New listing description starts blank instead of copying structured private submission fields. HTML cache key v92.
- Existing LIVE Adventure Outpost GoPro listing `LST-20261102-BA831BAE` was not mutated. Asking price remains £0.00 until user chooses a retail price; £123 purchase price must never be substituted automatically.
- GitHub branch `fix/selling-listing-edit-security-20261102`; checkpoint `CHECKPOINTS/2026-11-02-selling-listing-editor-security-repair.md`.
- Manuals and subscriber dashboard diagnostic roadmap updated on branch.
- Outstanding: merge/deploy front-end via Cloudflare, then browser save/reload check of title and user-entered asking price in Selling and public shop. Database privilege checks alone are not browser E2E verification.
