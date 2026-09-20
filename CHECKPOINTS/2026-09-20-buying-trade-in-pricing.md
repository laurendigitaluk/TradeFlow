# TradeFlow Checkpoint — 20 September 2026 — Buying + Trade-In Pricing

## Purpose
Extend the existing TradeFlow valuation architecture so automatic condition pricing can produce both:
- the amount TradeFlow is willing to pay for the item (buying/cash price)
- the separate value offered when that item is used as a trade-in against an in-stock retail purchase.

## Important architectural finding
The original TradeFlow valuation foundation already contains `trading_values.trade_in_price`. The valuation table also retains `cash_price`, and the retail order layer already has `trade_in_credit_total`. The work here therefore extends the existing valuation path rather than introducing a parallel trade-in system.

## Implemented

### Condition pricing
`tenant_buying_condition_rules` now supports, for each condition:
- Sealed
- Opened / Never Used
- Excellent
- Good
- Poor

Each condition can now have:
- buying percentage
- buying fixed override
- trade-in percentage
- trade-in fixed override
- research basis (UK New or UK Used)

Trade-in percentages and overrides are optional so existing buying rules continue to calculate without requiring trade-in configuration.

### Automatic valuation
`calculate_buying_item_valuation()` now returns:
- `amount` — buying/cash value
- `trade_in_amount` — trade-in value when configured
- `percentage`
- `trade_in_percentage`
- research reference/source information

Condition-specific manual overrides can return both buying and trade-in values.

### Buying & Pricing UI
The subscriber Buying & Pricing page now shows, per condition:
- research basis
- Buy %
- calculated Buy value
- Buy override
- Trade %
- calculated Trade value
- Trade override

### Buying Dashboard
The automatic valuation action now places both calculated values into the valuation form, and the current valuation display shows both buy and trade-in values.

## Deliberate scope boundary
No trade-in percentages have been invented or populated automatically. The subscriber must decide the trade-in policy for each condition. This avoids silently changing commercial pricing.

Bulk buying-price presets remain buying-price focused. Trade-in configuration is currently product-specific in the detailed automatic pricing editor.

## Database migrations applied
- `20260920104235_add_trade_in_pricing_to_valuation`
- `20260920104250_remove_legacy_trade_in_pricing_function_overload`
- `20260920104323_expose_trade_in_pricing_in_buying_catalogue`

## Verification
- Live Supabase migration application: PASS
- Legacy pricing RPC overload removed: PASS
- New pricing RPC exists with trade-in parameters: PASS
- Ten trade-in condition columns exist: PASS
- `buying-catalogue.js` syntax: PASS
- `buying-dashboard.js` syntax: PASS

## Next verification
1. Browser test a real subscriber product.
2. Enter Buy % and Trade % for all five conditions.
3. Save the automatic rule.
4. Submit a buying item with each condition and run Calculate automatic price.
5. Confirm both values populate the valuation.
6. Create/approve the valuation and confirm `cash_price` and `trade_in_price` are both stored.
7. Trace the existing trade-in purchase bridge so the approved `trade_in_price` is used as the trade-in credit against an in-stock retail item.

## Restore point
The previous 20 September 2026 guided customer selling journey checkpoint remains the restore point before this pricing extension. This branch is separate until browser verification is complete.
