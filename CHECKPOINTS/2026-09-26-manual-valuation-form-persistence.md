# Manual valuation form persistence fix — 26 September 2026

## Issue
Clicking Submit valuation briefly displayed the manual valuation inputs, then immediately returned to the original item view.

## Root cause
The `value` action rendered the manual valuation UI, but the shared action handler then called `load()` and `renderDetail()`, replacing the newly rendered form with the original workflow stage.

## Repair
For manual valuation results, the action now stops after rendering the valuation form. The form remains available for entering the cash/trade-in valuation and approving it. Automatic and manual-override catalogue valuations continue through the existing offer creation and refresh path.

## Scope
No database records or valuation logic were changed. Only the client-side refresh behaviour was corrected.

## Commit
`1da9bef6601ccb1598b0ea101b6383b99d51d5bd`
