# TradeFlow Test Two Preflight Restore Point — 24 September 2026

## Purpose

This checkpoint freezes the TradeFlow state immediately before the next end-to-end test-server validation.

GitHub repository: `laurendigitaluk/TradeFlow`
Restore branch: `checkpoint-test-two-preflight-20260924`
Checkpoint audit base: `dbbb0abbe6f3ed1df827196eeb84b231afce701e`

Retail CTA follow-up commits are included on this restore branch.
Supabase project: `twfbmjwwqzxdxvclxbun`

## Known-good Test One boundary

The established Test One path remains:

New subscriber/business → new subscriber customer → customer request/selling journey → buying/valuation → offer → inspection → payment/bank-detail handoff → purchase completion → Inventory → Selling → Sales Channels → published retail website listing.

The physical Inventory asset remains the single stock master. Sales listings reference that asset and must not create duplicate physical stock.

The remaining identified subscriber-facing feature is the subscriber's own website **Subscribe / receive payments** journey. This is separate from the customer purchase/payment workflow already exercised in Test One.

## 24 September preflight audit

### Website Builder / public website

- The dedicated Website Banner is a compact horizontal branding area in the **What We Sell** title area.
- It replaces the normal shop logo/title image slot when a banner is configured.
- It is **not** a full-width strip beneath site navigation.
- Homepage hero imagery remains separate from the dedicated branding banner.
- Website Builder preview and public What We Sell rendering use the same placement.
- The obsolete full-width banner renderer and its obsolete CSS were removed.
- Public-site and Builder cache versions were refreshed after the cleanup.
- The current public renderer no longer contains the obsolete `renderBrandBanner` function.
- The current Builder no longer contains the obsolete `renderBrandBannerPreview` function.
- A static function-reference audit found no unreferenced function declarations in the audited public-site, Builder, Selling, Inventory or Sales Channels controllers after cleanup.

### Workflow / application code

The current architecture remains:

Buying → purchased → Inventory / Ready for sale → Selling → selected sales channel → published listing.

Acquisitions remains an internal accounting/audit record and is not a separate user-facing operational stage.

The Inventory → Selling rule remains that the existing physical asset is the source record. Inventory completion gates the Sales hand-off, and Selling prepares the retail listing from that asset.

Sales Channels remains a channel-management foundation. TradeFlow Website is the active storefront; eBay, Amazon and Other are configurable channels but are not represented as externally connected marketplace APIs.

### Database state

The live Supabase project is `twfbmjwwqzxdxvclxbun`.

The Camerashack test tenant remains the active test tenant. The test Canon asset remains the single physical stock record used for the completed Test One purchase-to-retail path.

The latest site revision state contains both the subscriber logo and the dedicated banner in draft and published revisions.

The homepage retail CTA has also been standardised to **Visit our retail shop**. Existing `What We Sell` CTA text is migrated to that wording at render time so it does not remain as a generic label. The CTA continues to link to the TradeFlow retail shop.

No database schema/data mutation was performed as part of this preflight audit.

### Security/advisor findings

The Supabase security advisor still reports existing findings, including a SECURITY DEFINER view (`published_site_preview`), mutable search paths on two functions, multiple SECURITY DEFINER functions executable by anon/authenticated roles, and leaked-password protection disabled.

These were not silently changed during this checkpoint audit because they are broader existing database/security architecture items rather than a demonstrated Test Two regression. The earlier known RLS/payment-provider advisory boundary remains unchanged.

Performance advisories also include unused indexes, multiple permissive policies and duplicate indexes. These are recorded as separate hardening work rather than mixed into the Test Two application-flow checkpoint.

## Verification language

This checkpoint is **GitHub/code audited and database state checked**.

It is **not** claimed to be browser-verified after the final preflight cleanup. Browser verification begins with the test-server run.

## Test Two rule

Start Test Two as a new validation run from the normal/default project state.

Do not redesign or overwrite working Test One behaviour because of a later failure. Identify the first failing boundary, compare it with this checkpoint, and repair only the required layer.

If a Test Two failure is found, preserve this branch as the comparison restore point.
