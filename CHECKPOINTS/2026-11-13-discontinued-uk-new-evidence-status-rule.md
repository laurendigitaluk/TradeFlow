# Discontinued Product — UK New Evidence Status Rule

**Date:** 13 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**Branch:** main  
**Environment reviewed:** TradeFlow LIVE

## Owner decision
When a manufacturer confirms a product is no longer manufactured, mark its UK New evidence availability/status explicitly as **Discontinued**.

## Operating details
- Preserve a verifiable UK GBP listed price as historical/discontinued new-price evidence when useful.
- Use existing evidence `availability` and `notes` fields to record Discontinued, source/date checked, remaining-stock confirmation and whether price is historical/clearance only.
- An old retailer page displaying a price does not prove current purchasable new stock.
- Do not infer discontinued merely from out-of-stock/unavailable status; use those statuses unless manufacturer discontinuation is confirmed.
- Do not remove/deactivate the catalogue product solely because it is discontinued; catalogue lifecycle is a separate decision.
- UK Used remains customer inspection/click-through only. UK New remains the only automatic valuation reference, with availability/status represented accurately.

No schema or valuation-code change is authorised. No production code or catalogue rows changed in recording this rule.


### End-user warning rationale

The purpose of the **Discontinued** label is to warn the customer that the recorded new price may no longer represent a realistic current replacement cost. A discontinued model may have been superseded by a newer model with different features, specifications and market pricing. Therefore, a customer comparing a buyback offer against the old discontinued new price should not assume the comparison is like-for-like or that the old price is still achievable.

Where a replacement model is known, show it as contextual information separately; do not silently substitute its price for the discontinued model's price. The customer-facing wording should explain that the reference is historical and may be misleading for current replacement-value comparisons. This is an information/warning requirement, not a request to change automatic valuation logic.
