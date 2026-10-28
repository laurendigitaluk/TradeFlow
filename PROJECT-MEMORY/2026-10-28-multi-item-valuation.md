# Project Memory — Multi-Item Valuation (2026-10-28)

TradeFlow now has a visually reviewed multi-item valuation workflow committed on both `cloudflare-test` (TEST) and `production` (LIVE). See `CHECKPOINTS/2026-10-28-multi-item-valuation.md` for scope, files, behavior, safeguards and outstanding tests.

Key decisions:
- One buying request can contain multiple products, but each product remains a separate item record and lifecycle.
- Subscriber dashboard groups items by request and provides stacked item valuation panels plus one “Submit total valuations” button.
- Customer sees a combined quote with item-level values/totals and may accept/refuse individual items, or accept all for cash, accept all for trade-in, or refuse the entire quote.
- Final offers after inspection remain item-specific.
- Whole-request customer decisions use `customer_respond_to_combined_offer`; mixed individual decisions use existing per-offer RPCs.

Important limitation: subscriber-side combined submission calls the manual valuation RPC sequentially for each item, not atomically. If a later call fails, earlier item offers may already exist. This must be hardened or documented as partial-failure behavior before declaring the workflow complete.

Verified so far: UI reviewed in user-provided screenshots; four dashboard JavaScript files passed syntax checks at the time of the latest changes; combined response RPC installed on TEST and LIVE with execute permissions checked. Not yet end-to-end verified: mixed decisions and all downstream shipping/receipt/inspection/final-offer/payment/inventory transitions. Do not claim full acceptance or launch certification.
