# TradeFlow LIVE checkpoint — 13 November 2026

## Free Business Tools page

Implemented on GitHub `production` (LIVE) branch:
- `free-tools.html` — subscriber-only page.
- `free-tools.css` — responsive tool UI.
- `free-tools.js` — browser-local calculators, template generation, canvas drawing, PNG export and print handling.
- `subscriber-dashboard.html` — adds Tools → Free Business Tools navigation entry.

### Available tools
1. Profit and margin calculator (cost, sale price, fee %, postage, other costs, profit, margin, markup, break-even).
2. VAT calculator (inclusive/exclusive, standard/reduced/zero/custom rate; not tax advice).
3. Product listing builder (rule-based editable template from subscriber-supplied facts; not AI).
4. Manual logo and banner designer (canvas text/colour/layout composition, PNG download; not AI generation).
5. Basic printable invoice/receipt template.
6. SKU/stock label maker with browser print.

### Access, data and cost controls
- Existing subscriber auth and active tenant context only: `subscriber-auth.js` and `subscriber-tenant-context.js`.
- No customer/Test Lab session, Supabase REST/RPC, database write, Storage, AI API, image service, external paid API, Stripe or billing integration.
- Inputs and outputs remain in the browser; subscriber downloads/prints any output they want to keep.
- AI Image Studio is visibly marked planned/not available until local hardware is upgraded and costs are controlled.
- TEST remains untouched; LIVE Stripe remains untouched.

### Verification
- Browser JavaScript syntax parsed successfully before commit.
- GitHub production branch content read back.
- Production browser verification remains open: auth/session, tenant identity, each calculation, PNG download, invoice/SKU print, mobile layout and sign-out.
- The production deployment workflow previously did not trigger for subscriber static-asset changes. Its path filter is being extended to include these page/auth assets so the change deploys through the established Cloudflare Worker workflow.
