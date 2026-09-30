# TradeFlow checkpoint — 2026-09-30 — Post-baseline TEST health audit

## Purpose
Record the first verification pass after the TEST migration-history reconciliation.

## Environment
- GitHub repository: `laurendigitaluk/TradeFlow`
- Branch: `main` = TEST/STAGING
- Supabase TEST: `twfbmjwwqzxdxvclxbun`
- No LIVE/production database or branch was changed.

## Migration state
- Local and remote migration history both contain exactly `20260930215656`.
- The full-schema baseline is present in `supabase/migrations/`.
- The previous 139 migration files remain preserved under `docs/migration-archive/2026-09-30/`.
- No further migration repair, remote reset or push was performed.

## TEST backend health
- Supabase project status: ACTIVE_HEALTHY.
- PostgreSQL 17.
- Public schema: 93 tables.
- Public functions: 178.
- RLS remains enabled across the public application tables.
- Current Edge Functions are active.
- Security/performance advisors still report known non-blocking findings documented in the release-candidate checkpoint.

## Workflow verification from current TEST data
- Camerashack C50 automatic-pricing product linkage is present on current fresh-test records.
- Approved automatic C50 valuation evidence is present at £1,529.40 for Excellent, based on the UK New pricing rule.
- The current return-test C50 item `BI-9B99D90D5F` remains at purchase stage `return_pending`, but its return shipping record is now `return_shipped` with carrier/service Evri and a tracking number. This means the return-shipping test reached the shipped state; the purchase stage intentionally remains the return workflow state.
- The legacy refused C50 item `BI-FC9C2C8F26` remains correctly classified as `offer_refused` and is outside active Buying work.

## Remaining boundary found
Email delivery is not yet verified end-to-end:
- notification queue still contains 1 `order_shipping_ready` event and 4 `order_dispatched` events with `sent_at` null.
- platform email sending is enabled but sender verification is still `pending`.
- The notification processor source and deployed Edge Function version 5 match and require verified sender configuration before sending.

This is a notification-delivery boundary, not a blocker to the underlying portal/database workflow transitions.

## Next controlled test
Do not change the database baseline or production.

Run one fresh browser journey in TEST:
Customer valuation → Subscriber Buying → automatic valuation/offer → customer acceptance → manual shipping handoff → customer dispatch → subscriber receipt → inspection → payment/final-offer decision → purchased → Inventory → Selling.

Record each stage separately as:
- GitHub implemented
- TEST database verified
- browser verified

After that journey, repair only the first actual browser failure found.
