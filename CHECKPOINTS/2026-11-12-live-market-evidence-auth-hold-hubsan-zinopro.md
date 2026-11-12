# LIVE Market Evidence Continuation — Hubsan Zino Pro / authorization hold

**Date:** 12 November 2026  
**Environment:** TradeFlow LIVE only  
**Repository:** `laurendigitaluk/TradeFlow`, production branch  
**Supabase project:** `gxsrajtqzdjvmceqcpgv`  
**Status:** Source verified; database import blocked by authorization gate

## Pre-change checks

- Read the current production Batch 08, Batch 10, Batch 11, Batch 12 and Batch 13 checkpoints.
- Read current LIVE master catalogue schema and confirmed manufacturer relationship through `catalogue_master_manufacturers`.
- Checked existing evidence against the exact FIMI X8 Mini V2, Freefly Flux H1, Hubsan H109, Hubsan HT55 and Hubsan Zino Pro master products.
- The exact Hubsan Zino Pro Standard Package master exists: `a43c3673-d3a0-496b-a2f6-f78dfa349ffb`. Its current active Elite Models UK observation is £389.99, new, supplier stock. No duplicate was found for the Align-Trex source.
- Existing Hubsan Zino Pro+ is a separate model; do not merge it.

## Verified candidate — do not import until authorized

| Field | Value |
|---|---|
| Master product | Hubsan Zino Pro — Standard Package |
| Master UUID | `a43c3673-d3a0-496b-a2f6-f78dfa349ffb` |
| Source | Align-Trex UK |
| Source URL | https://www.align-trex.co.uk/hubsan-zino-pro-folding-drone-h117p.html |
| Exact model | H117P |
| Price | £356.80 GBP |
| Condition | New |
| Availability | Out of Stock / Notify Me |
| Classification | Historical UK New evidence; not an in-stock offer |
| Source evidence | Direct retailer page identifies H117P, £356.80, RRP £419.99, and explicitly Out of Stock / Notify Me. The page says Bundle Available: No. |

This is an exact standard-package observation and is distinct from the Elite Models £419.99 H117M-HIGH bundle, which includes an extra battery and storage bag. Do not attach the £419.99 bundle price to the Standard Package master. The existing Elite Models £389.99 standard offer is a separate active supplier-stock observation.

Suggested idempotent key when authorized: `batch08-followup-hubsan-zinopro-align-trex-35680-20261112`.

## Other research leads checked

- **FIMI X8 Mini V2:** the exact master exists, but current UK-labelled Dronesset result is sold out; variant and included bag do not clearly match the catalogue's “Camera Drone with Bag” package. Ubuy's £297 result is imported from the USA and excludes shipping/VAT/customs. Neither is imported.
- **Freefly Flux H1:** Freefly Store displays USD $32,995; CVP UK says contact for pricing. No qualifying UK GBP price found. Do not convert USD.
- **Hubsan H109:** CheapDrone category shows £187.93 for Hubsan X4 Brushless H109, but its linked product page could not be opened and details/availability could not be confirmed. Keep RED VERIFY; do not import.
- **Hubsan H109S:** distinct X4 Pro H109S model, not the catalogue H109 X4 Brushless. CheapDrone listing is out of stock and its price text is inconsistent. Do not map it to H109.
- **Hubsan HT55:** no exact complete-drone UK GBP offer found in this search round.

## Authorization gate and action taken

LIVE SQL returned `auth.uid() = NULL` and database role `postgres`. The current scheduled evidence checkpoint explicitly requires a non-null authenticated user and a successful platform-owner check before staging or importing. Therefore **no Supabase write was attempted**. Do not bypass the gate by running a privileged migration. The verified Align-Trex candidate is held for the next authenticated owner-authorized session.

No dashboard notification was inserted because the same authorization gate blocks database writes. The two manuals were updated on production with this hold and candidate details.

## Counts and safeguards

Cumulative Batches 04–13 remain **236 GBP observations: 232 active (127 UK New, 105 UK Used), four inactive**. These counts were checked before this hold; no evidence rows were changed in this pass.

- UK Used evidence remains reference-only and excluded from automatic valuation.
- No foreign currency was converted.
- No master products, schema, tenant/customer data, TEST data, Stripe settings or valuation logic were changed.
- Next action: re-run the auth/owner gate in an authenticated owner context; if it passes, insert the Align-Trex H117P £356.80 historical UK New observation using the established idempotent LIVE route, read it back, then update counts, both manuals, the batch checkpoint and dashboard message.
