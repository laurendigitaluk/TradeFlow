# Gemma runtime readiness review — 8 November 2026

## Scope
Read-only review of the LIVE 3D-printer capture task, current production agent code, PR branches, task telemetry and linked queue/evidence records. No worker restarted and no full research run started.

## Verified capture result
- Task: owner-3d-printers-capture-only-smoke-20261108-2020.
- Task ID: f9a5fa58-9782-4f25-bcf8-b555818eee4f.
- Product: Anycubic Kobra S1 Max.
- Exact UK manufacturer page captured: https://uk.anycubic3d.com/products/kobra-s1-max.
- One exact product page discovered and one page captured.
- Visible GBP options: £549 standard, £749 4-colour, £935 8-colour, £1,307 16-colour.
- Existing queue row enriched; linked active evidence is mapped to the 16-colour combo at £1,307.
- No product record created.

## Correct metric interpretation
The production 3D-printer path is capture-first. Zero Gemma calls is expected because local Ollama inference is intentionally skipped and ChatGPT reviews raw page captures. The `eligible_urls` counter counts direct eligible search results only; collection-discovered product pages are counted under `discovered_product_pages` and `captured_pages`. Do not treat zero `eligible_urls` or zero Gemma calls alone as proof of failure.

## Historical metadata anomaly
Queue row 2dd24f89-7165-4b1a-9f75-7a96cf40430c has package_key=standard and package_name=16-Color Combo. Its linked active evidence row is correctly mapped to master product package combo-16-color at £1,307. Other imported combo queue rows show similar queue-key/name inconsistencies, while linked active evidence maps to combo products. No rows were changed; preserve provenance and audit this separately before any repair.

## Release/install gate
- Production branch uses capture-first mode for 3D printers.
- PR #300 branch contains a different extraction path; installed Research PC branch/commit is not fingerprinted in Supabase.
- PR #300: draft/open, 54 tests passed.
- PR #312: open/ready for review, 73 tests passed.
- Prior local Ollama structured-output smoke success does not prove full installed-code acceptance.
- Gemma task worker idle; last recorded heartbeat 2026-11-08 20:28 UTC.
- Do not restart or run full research until installed commit is verified and a controlled exact-model source→page→capture→ChatGPT handoff test passes.

## Safety
- No product/evidence rows deleted.
- No TEST data changed.
- No full run started.
- Supabase project activity record owner-gemma-runtime-review-20261108 inserted and verified.
