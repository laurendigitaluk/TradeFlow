# Checkpoint — 2026-09-27 — Buying Item Workspace Detail Rendering

## Finding
The Buying dashboard item cards opened the item workspace container, but the workspace stopped after showing the item title. The rest of the transaction/detail page did not render.

## Root cause
In `buying-dashboard.js`, `renderDetail()` used `displayStage` in the detail subtitle before the `const displayStage=...` declaration. Because `displayStage` is a block-scoped constant, this throws a JavaScript ReferenceError before the remainder of the detail workspace can be rendered.

This is a front-end rendering error. The transaction data and the opening click handler were already working.

## Repair
Moved the `displayStage` calculation before its first use.

No database workflow, shipping state, authentication, payment logic, or Test Two data was changed.

Buying dashboard cache bumped from v45 to v46.

Commits:
- `f5b86b969650ed370b832c0e07fbf928c6f55a43` — fix detail workspace rendering
- `8a2be1fb467dabe6573e68f40d3c00ac2ea78a53` — cache v46

## Expected result
After GitHub Pages publishes v46 and the Buying dashboard is hard-refreshed, clicking either active transaction should open the complete item workspace rather than stopping at the title.

The workspace should continue to render customer details, supplied item details, research evidence, actions, photographs and the current workflow-specific section.

Do not reset Test Two or alter the shipping architecture.
