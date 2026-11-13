# Retrospective UK Used Nearest-Match Review 02

**Date:** 13 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**Branch:** main  
**Environment:** TradeFlow LIVE

## Result
Six further held candidates reviewed. Three new UK Used inspection observations inserted and read back. One existing DJI Matrice 350 RTK observation refreshed in place.

## New observations
- Holy Stone HS110D — £52.24, eBay UK, Thornton Heath. Exact model; condition "Opened – never used", not previously used. Package details beyond Ready-to-Fly title unconfirmed. Evidence: `8c837d32-cc7a-4767-8816-bfb78da0e181`.
- HOVERAir X1 PRO Max — £564.75, eBay UK, London. Exact model, larger bundle with carry case, extra batteries, charging dock, ND filters and 256GB SD card. Full price retained; no base-price adjustment. Evidence: `bc1c3627-53d6-4f91-aa8a-ae2e138a55c7`.
- Potensic ATOM SE Fly More Kit 2 — £129.72, eBay UK, Dartford. Two-battery sold listing compared with three-battery + fast hub catalogue package. Sold 5 July 2026; displayed £134.67 included separately itemised £4.95 Buyer Protection; base item price recorded. Evidence: `7784a82a-df37-4650-b3e9-5707787a867b`.

## Existing observation refreshed
DJI Matrice 350 RTK — same eBay item in Gravesend, Kent, now £7,567 Used and active/current (previously £7,000 historical). Exact model; Standard Package contents still unverified. Evidence: `59860300-2266-499b-a4d7-921892faf379`.

## Held
GEPRC DarkStar20 £188.67: seller UK location not exposed; separate Ivybridge listing is brand new. Holy Stone HS900 £169.92: seller location/package not confirmed. Other HOVERAir results lacked confirmed UK location/model/configuration.

## LIVE coverage
541 total; 173 neither; 146 UK New only; 118 UK Used only; 104 both; 291 missing UK New; 319 missing UK Used.

## Guardrails
UK Used remains inspection-only and does not feed automatic valuation. UK New-only valuation logic unchanged. No catalogue master/package rows, schema, RLS, RPC, Edge Functions, TEST, Stripe, tenant/customer/transaction data or deployments changed.
