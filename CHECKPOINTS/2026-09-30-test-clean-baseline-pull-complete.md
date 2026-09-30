# Checkpoint — 2026-09-30 TEST clean baseline pull completed

## Scope
TEST Supabase project only: `twfbmjwwqzxdxvclxbun`  
LIVE/production was not touched.

## Completed
The TEST project's migration-history table was cleared previously without changing the application schema or business data. A clean baseline pull was then completed from the live TEST schema using the local Supabase CLI with pg-delta enabled.

CLI result:
- Generated local baseline: `supabase/migrations/20260930215656_remote_schema.sql`
- Remote migration history was updated to exactly one entry: `20260930215656 / remote_schema`
- `supabase db pull` completed successfully.

Current TEST schema verification:
- 93 public tables
- 178 public functions
- 78 non-internal public triggers
- 92 public tables with RLS enabled

## Repository state inspected
GitHub `main` currently contains 139 migration files:
- 27 legacy/non-timestamped migration filenames
- 112 timestamped migration filenames

The existing migration set contains the recent automatic valuation, buying workflow, return workflow, security hardening and payment-ledger changes that correspond to objects verified in TEST.

## Direct TEST verification
Verified that TEST contains the key recent workflow functions, including:
- `customer_submit_buying_request`
- `calculate_buying_item_valuation`
- `subscriber_get_business_workflow`
- `subscriber_get_business_workflow_counts`
- `subscriber_complete_buying_item_inspection`
- `subscriber_publish_buying_item_return_shipping`
- `customer_get_selling_status`
- `customer_refuse_offer`
- payment/ledger status guard functions

Verified current constraints include:
- `buying_items_purchase_stage_check` with the current offer/refusal/return/payment stages
- `trading_values_method_check` allowing `manual`, `rule`, `market`, `ai`
- `notification_templates_event_code_check` including the current valuation/refusal events

Verified the automatic valuation condition rules currently use UK New reference types for all 128 rows.

Verified the recent security hardening state:
- customer/subscriber security-definer functions are present;
- public execution grants are limited to the explicitly public catalogue/site functions;
- payment and ledger status guard functions use `search_path=pg_catalog` and are attached to their corresponding tables.

## Important — not yet done
The generated `20260930215656_remote_schema.sql` exists on the local PC but has not yet been committed to GitHub. No `db push`, remote reset, or further migration repair has been performed.

Before any migration files are removed, renamed, archived, or replaced, the generated baseline must be preserved and compared against the repository migration history.

## Next controlled step
Inspect/preserve the generated baseline and reconcile GitHub migration history around it. Do not deploy or reset TEST or LIVE during this reconciliation.
