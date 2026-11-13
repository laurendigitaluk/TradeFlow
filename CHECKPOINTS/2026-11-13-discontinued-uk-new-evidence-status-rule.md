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
