# TradeFlow LIVE camera research batches 05–06

Date: 5 November 2026
Branch: production
Supabase: LIVE gxsrajtqzdjvmceqcpgv

## Batch 05
Added official Blackmagic Design UK observations to existing LIVE products:
- URSA Cine 12K LF — £11,779 GBP.
- URSA Cine 12K LF + EVF — £12,779 GBP.
Source: https://www.blackmagicdesign.com/uk/products/blackmagicursacine. Availability unknown. Inserts succeeded; the previous turn did not complete independent read-back for these two rows.

## Batch 06
Three products were confirmed active and had zero qualifying evidence before insertion:
- URSA Cine Immersive 100G — product cfbd190a-4b3e-4511-b964-532e4e57ef62; £21,275 GBP.
- URSA Cine Immersive 100G Body — product de437a2f-99d4-495f-817c-3f05d16be5ff; £15,859 GBP.
- URSA Cine Immersive Body — product a1cf989e-df43-460f-aadc-295cc9ea9637; £15,245 GBP.
Source for all: https://www.blackmagicdesign.com/uk/products/blackmagicursacineimmersive (official Blackmagic Design UK). Availability unknown; manufacturer list prices are not stock confirmation.

## Verification and scope
All three batch 06 evidence rows were independently read back and confirmed active, GBP, and source-linked. Exact source keys were used with conflict target (source_name, source_record_key). Existing master products were not modified. LIVE only; TEST untouched. No valuation, schema, RLS, app, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. Used-market evidence remains reference-only.

## Open issue
Do not publish camera coverage totals until the 722-product baseline versus 720-row main_category=Cameras roll-up is reconciled.

Earlier batch 03 evidence is recorded in the camera research history; the manuals have now been brought up to date with that batch as well as batches 05 and 06.