# Bambu Lab UK printer collection route correction — 8 November 2026

## LIVE finding
Task: `owner-3d-printers-exact-identity-acceptance-20261108-0032`.

The Bambu A1 Standard new lane returned 3 search results but discovered no product pages. The Bambu A1 Combo new lane returned zero search results. The Bambu official source recorded HTTP 404 on its second route.

## Root cause
Production playbook used `https://bambu-lab-uk.myshopify.com/collections/3d-printers`. The official storefront's own “All 3D Printers” navigation resolves to the singular route:
`https://bambu-lab-uk.myshopify.com/collections/3d-printer`.

The official collection page is reachable and links to the individual A1 product page. The previous route was a path typo, not proof that the official Bambu host was unavailable.

## Change
- Replace the plural collection path with the verified singular path in the 3D-printer Bambu site playbook.
- Add a regression test that asserts the singular collection URL, rejects the obsolete plural URL, and keeps the collection page discovery-only.
- Preserve the existing manufacturer-specific search route and all product/package identity checks.

## Scope and safeguards
Only category `3d-printers-equipment`, branch `3d-printers`. No LIVE source registry, queue, catalogue, approvals/imports, task queue, TEST data, secrets, private .env or Research PC runtime changed. No duplicate task queued.

## Verification and release
- GitHub Actions Gemma Research Tests run [42442363517](https://github.com/laurendigitaluk/TradeFlow/actions/runs/42442363517) completed successfully at 03:21 UTC on 8 November 2026: **46 tests passed, 0 failed**. This includes the new singular Bambu collection-route assertion, source-playbook/agent tests, syntax checks and Owner Dashboard JavaScript syntax.
- The passing workflow ran against code/test commit `5d43daecaeb76d498557b11bd7b2af8b26d8fbe8`. Subsequent documentation-only updates do not change the tested source or test files. This is CI verification only; the Research PC has not been updated and no LIVE route acceptance has been run.

Merge only after review and green CI. After explicit approval, update the existing Research PC in place, preserve `TRADEFLOW_GEMMA_ENV_FILE`, and run one controlled Bambu A1 new-lane route acceptance test. Do not approve/import automatically.
