# Developer Diagnostic Roadmap — Free Business Tools (LIVE)

Last checked: 13 November 2026
Environment: TradeFlow LIVE production only
Production branch: `production`
Current page: `https://tradeflow.laurendigital.co.uk/free-tools.html`

## Purpose and boundary

Provide subscribers with free, low-operating-cost browser tools. All six available tools execute in the subscriber's browser. Do not connect paid AI APIs, image-generation services, background AI jobs, or persistent storage without a separate cost and security decision. The AI Image Studio is a planned placeholder and must remain unavailable until local hardware and cost controls are approved.

## User action and entry points

- Subscriber signs in to the TradeFlow business dashboard.
- Dashboard navigation: `subscriber-dashboard.html` → Tools → Free Business Tools.
- Page entry: `free-tools.html`.
- Tool tabs: Profit & margin, VAT, Product listing builder, Logo & banner designer, Invoice / receipt, SKU label maker.
- AI Image Studio appears as planned/unavailable only.

## Front-end files and responsibilities

- `free-tools.html`: page shell, six tool forms/panels, privacy notice, AI placeholder, and script/style references.
- `free-tools.css`: responsive layout, tool components, focus states, and print-only invoice/SKU styles.
- `free-tools.js`: all calculator, text-template, canvas drawing, PNG export, invoice rendering/printing and SKU generation logic.
- `subscriber-dashboard.html`: subscriber navigation link.
- `subscriber-auth.js`: subscriber authentication, session refresh, membership lookup and sign-out.
- `subscriber-tenant-context.js`: waits for the authenticated tenant and publishes active tenant identity in document attributes.
- `subscriber-dashboard.css`: shared dashboard shell and navigation styles.

## Authentication and tenant boundary

1. Page loads `subscriber-auth.js`.
2. It loads `subscriber-tenant-context.js`, which awaits `window.tradeflowSubscriberAuthReady`.
3. `free-tools.js` waits for both `window.tradeflowSubscriberAuthReady` and `window.tradeflowSubscriberTenantReady`.
4. The page displays the active tenant's business name and authenticated user's email.
5. Failed authentication replaces the tool content with a sign-in prompt.
6. Sign-out is handled by the existing subscriber auth layer.

Do not add a separate login flow, read Customer/Test Lab sessions, accept a query-string tenant override, or use a tenant identifier supplied by page input.

## Data flow and external dependencies

- Profit, VAT, listing draft, logo/banner canvas, invoice/receipt and SKU calculations/rendering are local JavaScript operations.
- Listing copy uses the browser Clipboard API.
- Logo/banner PNG export uses the browser canvas `toDataURL` and a local download link.
- Invoice and SKU output use the browser print dialog.
- The tool page makes no Supabase REST/RPC/Storage calls and does not persist entered form data.
- No AI provider, external image service, paid API, or research-PC/Ollama call is used.
- The Cloudflare Worker serves the static page through its `ASSETS` binding. `wrangler.jsonc` sets the LIVE environment and the LIVE Supabase runtime configuration for production; the tool page itself does not call Supabase.

## Deployment path

- Repository: `laurendigitaluk/TradeFlow`.
- Branch: `production`.
- Workflow: `.github/workflows/deploy-tradeflow-production.yml`.
- Path filters must include `free-tools.html`, `free-tools.css`, `free-tools.js`, subscriber auth/tenant files and Worker assets.
- Deploy command: Cloudflare Wrangler using `wrangler.jsonc`.
- Initial deployment run #43502223975 succeeded.
- Follow-up fix deployment run #43515108158 succeeded on commit `f4dcd8f67f9b54e03f9dd55a2f2cb482d6ae0834`.

## Known logic and failure points

- Profit calculator: clamp fee input to 0–100%; when fee is 100%, break-even is impossible and must not display a finite sale price.
- VAT calculator: verify inclusive/exclusive calculations and custom rates; this tool does not determine VAT registration or legal treatment.
- Listing builder: output is a draft only; subscriber must verify factual condition and contents.
- Logo/banner designer: square logo 1200 × 1200; social graphic 1080 × 1080; banner 1600 × 600. Confirm canvas preview dimensions and PNG file dimensions agree.
- Invoice/receipt: verify quantity, unit price, VAT and total; this is a basic template, not an accounting system.
- SKU label maker: verify generated and user-supplied references and print layout.
- Print CSS: confirm only the intended invoice or SKU label is visible in print preview.
- Mobile: tool tabs must remain usable horizontally and forms must collapse to one column.
- Authentication: if either readiness promise rejects or membership is missing, show a clear sign-in error without exposing another tenant's information.

## Verification checklist still required in a live browser

- [ ] Open the LIVE page while signed out; verify the sign-in gate.
- [ ] Sign in with an authorised subscriber and confirm the correct business identity.
- [ ] Verify tenant switching for a multi-tenant account and confirm the page follows the active tenant.
- [ ] Test profit, margin, markup and break-even, including a 100% fee.
- [ ] Test VAT inclusive, exclusive, reduced, zero and custom rates.
- [ ] Build, edit and copy a product listing draft.
- [ ] Generate logo, banner and social graphics; verify PNG dimensions and downloaded content.
- [ ] Generate an invoice/receipt and inspect print/save-as-PDF output.
- [ ] Generate and print an SKU label.
- [ ] Check mobile layout and tab navigation.
- [ ] Sign out and verify the page is protected on reload.
- [ ] Confirm no tool input is written to Supabase and no AI/external image request is made.

## Current status and guardrails

Deployment is confirmed successful. Browser-level verification remains open because the available verification environment could not resolve/reach the production host. Do not claim end-to-end verification until the checklist is completed in a real browser session.

No database schema, RLS, RPC, Edge Function, Storage bucket, tenant/customer data, TEST environment, Stripe or billing settings were changed for this feature. Keep AI features disabled and do not introduce operating costs.
