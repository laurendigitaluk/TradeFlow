# Checkpoint — Shared Top Section Control Parity

Date: 4 October 2026
Branch: production

The Shared top section editor now matches the Top of page editable canvas for border formatting.

Selected Shared top section text, photo, banner and logo elements expose:
- Border: None / Solid / Dashed / Dotted / Double
- Border width: 1–4px
- Border colour
- Round corners: Square / 2px / 4px / 8px / 12px / 20px / Fully round

The values use the existing editable-element properties and persist through Save Draft / reload / Publish.

Commits:
- JS: 77f9da74822ad4af8930087a074add3d1cae85f9
- CSS: 18d0e9c11a778808f7f42c2588f82858b0e4804a
- HTML asset bump: 5a2f7c372b77d20b548297985dce65172bc461e1
- Handbook: 51ac2d9ff6b7da3ae53d5af70daa28dfdcc3e08b
- AI Operating Manual: 1d3d71b89bab3867f5205e8f89fb85cbd9c59c65

Browser verification required: select a Shared top section text/photo/banner/logo element and confirm the four border controls appear and update the element immediately.
