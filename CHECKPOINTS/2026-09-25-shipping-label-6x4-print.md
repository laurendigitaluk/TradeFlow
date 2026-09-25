# Checkpoint — 2026-09-25 Customer Shipping Label Print Size

## Scope
Test Two unified buying workflow. Customer Portal shipping label popup.

## Change
The shipping label popup now treats the label as a physical **6 × 4 inch** label instead of scaling it to the browser window.

### Print options
- **Print 6×4** — sets the print page to 6 × 4 inches for a thermal/direct label printer.
- **Print on A4** — keeps the label itself at 6 × 4 inches but prints it on an A4 page.
- The label preview is constrained to 6 × 4 inches so it is no longer rendered at an oversized screen-dependent scale.
- The existing secure signed-file retrieval and popup behaviour are unchanged.
- The same print treatment is used for the shipping label and QR-code popup.

## Code
- `customer-dashboard.js` updated in commit `776a883d16fa286f9aa0ce62fe4dddfe29714c58`.
- `customer-dashboard.html` cache version raised from v105 to v106 in commit `2648cecc10f6ae19b340f007f5eed01ebae42e3a`.

## Required live verification
1. Refresh the Customer Portal so `customer-dashboard.js?v=106` is loaded.
2. Click **Open shipping label**.
3. Confirm the popup shows the complete label at 6 × 4 proportion without oversized scaling.
4. Test **Print 6×4**.
5. Test **Print on A4** and confirm the label remains 6 × 4 inches on the A4 page.
6. Confirm the Customer Portal remains open underneath.
