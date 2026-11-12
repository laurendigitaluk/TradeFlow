# TradeFlow LIVE — scheduled market-evidence project memory, batch 06

**Date:** 2026-11-12  
**Branch:** production  
**Scope:** LIVE catalogue evidence research only. No TEST or Stripe work.

## Current state

Batch 06 completed research on 20 new active LIVE catalogue master products. Full product IDs, source URLs, observed prices/currencies, condition, availability, package contents, uncertainty notes and RED VERIFY flags are in:

- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-06.md`

## Selection controls

Before selecting products, the run read scheduled-market-evidence checkpoints 02–05 and the corresponding available project-memory files. The batch-03 checkpoint existed but its project-memory file was not found. Related camera-catalogue evidence checkpoints 01–07 and available camera project memories 05–07 were also inspected to reduce overlap.

The selection used no SQL OFFSET. It excluded 122 unique UUIDs from scheduled checkpoints 02–05, all product IDs from the manual AI research prompt table (one completed prompt covering 20 IDs and one outstanding ready prompt covering 20 IDs), 10 outstanding `needs_research` queue candidates, and identified overlapping camera-checkpoint products. Twenty products were selected dynamically from active master products with no active shared market evidence.

Immediately before research, every selected product had:
- 0 active `shared_market_evidence`
- 0 outstanding LIVE research-queue candidates
- 0 outstanding manual AI research prompts

The same status recheck after research returned zero for all 20.

## Authentication and queue staging

The LIVE auth check returned:
- `current_user = postgres`
- `auth.uid() = null`
- `auth.role() = null`
- `platform_cloud_ai_owner_check() = false`

No queue write was attempted. No direct table write, impersonated claim, RLS bypass or schema change was used. Queue staging remains blocked until the supported authenticated platform-owner RPC can be called with a real owner context.

## Research quality findings to preserve

- Keep sold-out, backorder, expired and unverified source links. Do not discard them.
- Leave GBP price blank when the source is in USD/EUR/other currency or when a GBP-looking amount cannot be established as a reliable UK price. Record the source's displayed currency/amount in notes; never convert.
- Separate rental prices from sale prices.
- Distinguish exact package/variant from nearby package. Keep the link and prefix the uncertainty with RED VERIFY.
- Google Shopping click-through matters: the Casio EX-ZR20 Shopping card linked to an eBay page whose title said EX-ZR20, but the opened item specifics identified the model as EX-ZR400. Do not attach that £80.05 lead to EX-ZR20.
- Casio EX-ZR2000 official page confirms a discontinued past model; EX-Z2000 marketplace listings are not exact matches.
- Autel EVO Lite 6K Enterprise Plus: official page defaults to Basic Bundle; third-party Plus listing shows USD price but conflicting UK/US fulfilment text.
- DJI Mini 3 package requires DJI RC. Keep RC-N1 and standard Fly More bundles separate.
- FIMI X6 and X8 Pro are marked older/discontinued in the current master product notes. Keep manufacturer page references even where a current price cannot be found.

## Next run

Read Batch 06 checkpoint and this project-memory file first. Exclude all 20 product UUIDs in Batch 06, all IDs in previous scheduled checkpoints, all outstanding queue candidates and outstanding manual AI prompts. Recheck status immediately before research. Select the next 20 dynamically without SQL OFFSET. Continue the same open-page research and evidence-retention rules. Stage only through the authenticated platform-owner RPC if owner auth is valid; otherwise create the next checkpoint and project-memory files and do not write directly to the queue.

Do not modify master products, schema, valuation logic, TEST or Stripe.
