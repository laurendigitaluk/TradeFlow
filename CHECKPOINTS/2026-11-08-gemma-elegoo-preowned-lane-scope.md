# Gemma ELEGOO UK pre-owned lane scope correction

Date: 8 November 2026 (UTC)
Scope: TradeFlow LIVE Gemma — category `3d-printers-equipment`, branch `3d-printers`.
Base: production `db65d8aab83cc1a890fd2626cdf3651dcc3f6e54`.
Branch: `fix/gemma-elegoo-preowned-lane-scope-20261108`.

## Diagnosis
The LIVE ELEGOO UK manufacturer source is assigned to the 3D-printer category but has `research_scope='new_uk'`. Production lane filtering therefore excludes ELEGOO from every `uk_used` task before its already-configured pre-owned collection route can run.

The website playbook already has correct separate routes:
- New: `https://uk.elegoo.com/collections/fdm-printers`
- Used: `https://uk.elegoo.com/collections/pre-owned-3d-printer`

The used collection was checked on 8 November 2026: 27 products, UK/GBP context and displayed prices from £39 to £370. Some cards are sold out; the collection is discovery only and does not itself establish current used evidence.

## Change
- Add migration `20261108093000_enable_elegoo_uk_3d_printer_used_lane.sql` to update only the existing enabled ELEGOO UK manufacturer row for category `3d-printers-equipment` from `new_uk` to `all`.
- Preserve the existing manufacturer identity filter and category scope.
- Keep lane-specific routes: FDM for new; pre-owned for used.
- Add a regression test for both lanes, exact routes, other-manufacturer rejection and other-category rejection.
- Update the Developer System Handbook, AI Operating Manual and Gemma diagnostic roadmap.

## Verification and safety
- LIVE schema permits `research_scope='all'`; `domain` is unique.
- TEST currently has no ELEGOO UK source row, so the update-only migration is a no-op there. No source row is copied between environments.
- CI verification is pending. This branch is not merged/deployed; migration not applied.
- No task queued, no LIVE source row or queue row changed, no catalogue approval/import, no TEST/LIVE crossover, no secret/.env or Research PC change.
