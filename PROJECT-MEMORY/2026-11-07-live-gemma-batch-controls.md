# Project Memory — LIVE Gemma batch research controls
Date: 7 November 2026

The owner dashboard now has the implementation for category-driven multi-product research batches. The old single product input is replaced by LIVE catalogue category/branch selectors, evidence coverage filters, research type, specialist agent choice and 10/20/50/100/all-selected batch sizing. It submits one LIVE queue item containing a tasks array; the existing worker processes those subtasks sequentially.

The LIVE category/product RPCs are owner-authenticated and use LIVE master catalogue/evidence tables only. Their execution grants were checked (anon denied, authenticated granted) and the functions check active platform membership. The 3D Printers & Equipment LIVE category currently has 201 active products, with 1 missing new evidence, 190 missing used evidence, 0 missing both and 191 missing either (point-in-time).

Pokémon Trading Cards remains an active master category but is deliberately excluded from Gemma batch selection until its research sources/agent are explicitly linked. Do not queue Pokémon research.

The Platform AI provider settings panel was removed from the owner dashboard UI; subscriber-provided AI remains disabled. The public How It Works page is the existing text-only accordion page. The owner editor now suppresses its legacy screenshots and visual_layout image-box fields, and the Examples visual editor no longer overwrites the How It Works editor loader.

All changes were committed directly to production. No feature branch was used. No TEST catalogue/customer/tenant/order/Stripe data was changed. Database RPCs and basic query output were verified, but authenticated browser acceptance, Cloudflare deployment verification and an end-to-end Research PC batch remain outstanding.
