# Checkpoint — Owner Dashboard dropdown sections — 7 November 2026

## Branch and base
- Branch: `feature/owner-dashboard-dropdown-sections-20261107`
- Base: current LIVE release branch `production` at commit `e8f2bece911cd79864376a48a5a9559ee988671b`.

## Implemented
- Wrapped eight major Platform Owner dashboard sections in a consistent native collapsible tile design:
  - Product details — name, headline and tagline
  - Subscriber businesses
  - Domain connection requests
  - TradeFlow plan and pricing
  - Public Website Pages
  - Gemma Control Centre
  - Complimentary subscriber accounts
  - Platform email settings
- Kept overview statistics visible.
- Added matching summary labels/descriptions, plus/minus affordance, responsive spacing and visible keyboard focus.
- Sidebar hash links expand the corresponding accordion, including direct hash navigation on page load.
- Preserved all existing section IDs, control IDs, forms, buttons, event handlers and RPC workflows.
- Added a note clarifying that How It Works is source-managed static HTML and that its legacy database draft does not control the published guide.
- Updated both manuals, the public-pages roadmap and the Owner Dashboard diagnostic roadmap.

## Preserved current behaviour
- Gemma LIVE category/branch selection, new/used evidence filters, product selection, batch sizes, task queue, candidate review and category-specific research-source controls remain intact.
- No Platform Configuration or AI-provider panel/handlers are reintroduced.
- The `platform_ai_settings` compatibility table remains in place. Both environments were observed with provider `none`, allowed providers `["none"]`, and subscriber-supplied AI disabled. No database setting was changed.
- How It Works remains the ten-section text-only accordion page in `how-it-works.html` / `how-it-works.css`. No page content or published data was changed.

## Verification
- Static transformation check: eight intended sections wrapped; HTML section tags balanced; CSS and JS cache versions incremented.
- Code inspection: existing Gemma RPC calls and owner handlers remain present; AI provider settings handlers are absent from current production JS.
- Supabase read-only inspection: TEST and LIVE each contain the two public-page rows; LIVE has 11 agent-status rows and 526 activity rows; no project-memory/checkpoint table exists in the LIVE public schema.
- Not yet verified: authenticated browser rendering, sidebar anchor interaction, all dashboard forms/buttons after collapsing, mobile layout, How It Works browser rendering, or Cloudflare Worker deployment.

## Safety
No Supabase schema/data, RLS, Edge Functions, tenant/customer/order/payment/Stripe data, domain ownership, research evidence, Research PC configuration/secrets or Cloudflare deployment changed.

## Next
1. Run authenticated LIVE owner-dashboard browser acceptance on desktop and mobile.
2. Confirm all eight panels expand/collapse and all existing actions still work.
3. Confirm How It Works static accordion page and public navigation in browser.
4. Merge/release only after acceptance; then independently verify the LIVE Worker serves the new HTML/CSS/JS.
5. Decide separately whether How It Works should become editable through the dashboard; that requires a new accordion content schema/editor/renderer rather than the retained legacy JSON record.
