# Retrospective UK Used Nearest-Match Review 03

**Date:** 13 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**Branch:** main  
**Environment:** TradeFlow LIVE

## Result
Five further held candidates reviewed. Two additional UK Used observations inserted and read back. Both add depth to existing Potensic ATOM 2 master products that already had UK Used observations, so product coverage counts are unchanged.

## Added observations
- Potensic ATOM 2 Standard Package — £219 GBP, eBay item 358916809528, seller item location Coatbridge, Scotland. Used a couple of times; box, one battery, charging cable and two rotor-blade sets described. Grelly item mirror reports one sold/zero remaining; historical/ended inspection reference. £8.95 postage separate. Evidence: `b8723f76-8dd0-4660-a93e-84cdd93fdc2a`.
- Potensic ATOM 2 PTD 1 Fly More Combo — £238.99 GBP, eBay item 389927611088, seller location Birmingham. Used; more than 10 available and 10 sold at capture. Potensic Care unavailable for used units; full bundle contents to be checked on source listing. Current asking price. Evidence: `f6ec8337-1242-48e2-8d10-44378822d024`.

## Held
- FIMI Mini 3 £260 Gumtree, Stoke-on-Trent: model and extra battery/case/landing pad described, but no stable individual listing URL exposed.
- BetaFPV Cetus Pro sold £88.42 displayed includes £3.42 Buyer Protection (base £85); UK seller location and complete goggles/FPV kit contents unconfirmed.
- Potensic ATOM 2 PTD 1 Standard Kit £270.82 listing was Opened – never used, not Used, and out of stock.
- Holy Stone HS900 £169.92 eBay result did not expose seller item location.

## Coverage
541 total; 173 neither; 146 UK New only; 118 UK Used only; 104 both; missing UK New 291; missing UK Used 319. Two observations add evidence depth, not new product coverage.

## Guardrails
UK Used remains inspection-only; automatic valuation uses UK New only. No catalogue master/package rows, schema, RLS, RPC, Edge Functions, TEST, Stripe, tenant/customer/transaction data or deployment changed.
