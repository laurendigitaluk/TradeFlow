# TradeFlow TEST Clean-Baseline Migration History Repair — 30 September 2026

## Scope
TEST only: Supabase project `twfbmjwwqzxdxvclxbun` in eu-west-2.

## Repair completed
Remote migration-history records were removed for:
- `20260930181936`
- `20260930182507`

This is equivalent to `supabase migration repair --status reverted` for those two timestamps: migration history was corrected only; their SQL was not executed or rolled back by the repair.

## Verification before repair
The live TEST definitions of:
- `public.subscriber_get_business_workflow(uuid)`
- `public.customer_refuse_offer(uuid, uuid, text)`

match the replacement version-controlled migrations:
- `20260930200000_exclude_completed_return_from_workflow_list`
- `20260930201500_customer_initial_offer_refusal_closes_buying_item`

The TEST migration history still contains the later security hardening entries:
- `20260930192821`
- `20260930192850`

## Current state
The TEST project remains ACTIVE_HEALTHY. No customer, bank, payment, order or transaction data was copied or removed. LIVE was not changed.

## Next exact step
Use the dedicated local workspace `TradeFlow-Clean-Baseline-20260930`:
1. Verify `supabase/migrations` is empty.
2. Confirm the project is linked to TEST `twfbmjwwqzxdxvclxbun`.
3. Run `supabase db pull`.
4. Inspect the generated baseline migration.
5. Do not replace the existing version-controlled migration history or promote anything to `production` until the generated baseline has been inspected and tested.

## Safety
- TEST = `main`.
- LIVE = `production` code branch and separate Supabase project.
- Test One remains frozen.
- Manual shipping remains authoritative.
- Parcel2Go API/checkout/payment-link shipping remains retired.
