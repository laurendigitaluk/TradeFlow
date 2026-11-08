# Gemma concatenated Combo URL package matching — 8 November 2026

## Finding
Controlled LIVE task: `owner-3d-printers-exact-identity-acceptance-20261108-0032`.

The official Creality UK page `https://store.creality.com/uk/products/essential-combok1-max-hyper-pla-2` was staged under the Creality K1 Max Standard Printer task. Captured title: `K1 Max + PLA*2(White+Red)`; visible page price: £599.00. This is a printer bundle and must not be treated as standalone Standard evidence.

## Root cause
The matcher normalised URL punctuation but did not split concatenated bundle markers such as `combok1`. The package detector consequently missed the Combo marker in the URL even though the title and model tokens were present.

## Change
- Restore a token boundary after concatenated `combo`, `ams`, `ace`, and `cfs` URL markers before identity/package checks.
- Add a regression assertion for the exact Creality URL/title; it must be rejected for the K1 Max Standard task.
- Preserve existing sibling-model, accessory, short-ID, source-scope and category-isolation rules.
- Update both manuals and the Gemma research diagnostic roadmap.

## Scope and safeguards
3D-printer matching only. No LIVE queue rows, catalogue products/evidence, approvals/imports, source registry, task dispatch, TEST data, secrets, .env files or Research PC runtime changed by this code/documentation branch. The existing Research PC updater already installs `agent.mjs` and `source-playbooks.test.mjs`.

## Verification
GitHub workflow CI and the local Research PC updater test run are required before merge/deployment. Then rerun a small exact K1/K1 Max Standard-vs-Combo test and inspect page captures and package text. Do not approve/import automatically.
