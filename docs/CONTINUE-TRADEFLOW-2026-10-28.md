# TradeFlow continuation note — 28 October 2026

## Purpose
Use this note to continue the existing TradeFlow work in a fresh ChatGPT chat. The user is frustrated by repeated context loss and inaccurate “completed” claims. Continue from the current code/database state, make concrete progress, and report only what was actually changed and verified.

## Project and safety boundaries
- GitHub repository: `laurendigitaluk/TradeFlow`
- Production branch: `production`
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- TEST Supabase project: `nnsshnfkjcflucjrftzi`
- Until real customer onboarding, keep shared catalogue/code changes aligned between TEST and LIVE after verification.
- Never blindly copy tenant, customer, website, published content, custom-domain, ownership, or billing data between environments.
- Do not change LIVE Stripe.
- User wants direct execution, concise updates, and evidence of verification. Do not claim a fix is live until deployment and behaviour have been checked.

## Current workstreams

### 1. Automatic cash and trade-in pricing
PR #186, “Add separate automatic trade-in pricing controls,” was submitted and a merge was attempted in the prior chat. Verify its actual merged state and resulting production commit before proceeding:
https://github.com/laurendigitaluk/TradeFlow/pull/186

The subscriber Buying & Pricing editor change adds separate trade-in percentages alongside cash percentages for each condition. The pricing RPC already has separate trade-in percentage fields in `tenant_buying_condition_rules`:
- `sealed_trade_in_percentage`
- `opened_never_used_trade_in_percentage`
- `excellent_trade_in_percentage`
- `good_trade_in_percentage`
- `poor_trade_in_percentage`

Required verification and completion:
1. Confirm the UI changes are present in production source and the Cloudflare production deployment.
2. Confirm catalogue reads return the saved percentages, and that values persist after refresh.
3. Trace the full automatic valuation calculation. Cash and trade-in must be calculated separately from UK-new GBP research using their own condition percentages.
4. If UK-new evidence is missing, do not invent a price; retain the manual valuation/offer route. UK-used evidence is reference only.
5. Verify customer-facing offer creation supports a choice between cash (bank transfer) and trade-in credit where each is available.
6. Trade-in credit must use the existing Tridon customer account workflow. Do not post credit until the customer has accepted the trade-in offer and the existing inspection/post-inspection safeguards permit it.
7. Verify accepted offer, inspection, inventory, and sales retain the same product identity, condition, offer type, and price without category crossover.

Important: do not call automatic trade-in “finished” until the end-to-end path has been tested.

### 2. Buying Catalogue filters and selection
The earlier Pokémon-specific filter changes and set/expansion RPCs were merged in previous work. Pokémon must retain its special Category → Set/Expansion → Search path. Do not break it while correcting ordinary categories.

Ordinary categories should retain:
Category → Branch → Manufacturer → Model → Package/Variant → Search.

Outstanding issues to verify:
- My Buying Catalogue must show only products configured for that subscriber’s buying catalogue. Its category choices should not expose categories with no configured buying products.
- Master Catalogue is a browse-and-add view of the shared catalogue. It should not behave like My Buying Catalogue.
- Verify “Select all matching” respects current filters and the visible count.
- Restore/verify bulk automatic pricing actions.
- Verify adding selected Pokémon cards really creates the buying-product configurations and they appear in My Buying Catalogue after refresh.
- Do not automatically configure all 23,780 Pokémon catalogue products or invent pricing percentages.

### 3. Pokémon-specific conditions and product lifecycle
The user wants card-specific condition choices, separate from the normal electronics/drone condition set. The selected condition must flow consistently through:
customer valuation → automatic/manual offer → inspection/final offer → inventory → sales.
Do not change condition rules for other product categories.

## Relevant prior findings
- LIVE master Pokémon Trading Cards category ID: `20a49587-2601-4b1a-b736-bd4a8271dfc6`.
- LIVE had approximately 23,780 active, customer-visible Pokémon-category products, including Pokémon, Trainer and Energy branches.
- The 30th Classic Collection set filter was verified to return 30 cards at the master-catalogue query level, but prior screenshots showed bulk selection incorrectly counting all 23,780 products until a fix was attempted.
- Previous Buying Catalogue investigation found a large discrepancy between master catalogue selections and configured buying products. One earlier check reported 23,993 catalogue selections but only 213 active configured buying products. Recheck current counts rather than relying on old numbers.
- The user also reported that clicking “Add selected to Buying Catalogue” faded the button but did not add the selected 30 Pokémon cards. A code fix was attempted in PR #185; verify current production state and actual add workflow.
- Customer credit function previously required an accepted trade-in offer and the `final_offer_required` post-inspection stage before posting credit. Re-verify function definitions before relying on this.
- Cloudflare dashboard showed production deployments, but earlier checks did not conclusively prove every code change was served by the LIVE site.

## Suggested next actions
1. Inspect PR #186 status and latest production source for `buying-catalogue.js` and its HTML cache-busting version.
2. Verify the actual deployed production UI.
3. Read the relevant LIVE and TEST SQL function definitions for pricing configuration, valuation calculation, offer creation, acceptance, Tridon credit, and inventory transition.
4. Run read-only checks first; make the smallest safe code/schema changes needed.
5. Test each environment separately, then align shared catalogue/code changes where appropriate.
6. Keep a short factual list of commits, deployments and tests completed; explicitly state what remains unverified.

## Prompt to start the next chat
Continue TradeFlow from this note in the repository `laurendigitaluk/TradeFlow`. First verify PR #186’s real merge/deployment state, then continue the three workstreams: (1) automatic cash and trade-in pricing end-to-end, including Tridon safeguards; (2) correct separation of My Buying Catalogue vs Master Catalogue, Pokémon filtered bulk selection/addition, and bulk automatic pricing; (3) Pokémon-specific conditions persisting through valuation, inspection, inventory and sales. Keep regular category filters unchanged. Use GitHub and Supabase tools to make concrete fixes, test LIVE and TEST separately, and do not claim anything is fixed or deployed without evidence. Keep shared code/catalogue aligned but never copy tenant/customer/site/domain/ownership/billing data between environments; do not change LIVE Stripe.
