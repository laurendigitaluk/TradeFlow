# TradeFlow Human User Manual

## Restore checkpoint — 18 September 2026

This document records the known-good stopping point for continuing TradeFlow development.

### Website Builder
The subscriber Website Builder is a visual, page-first editor with the current expanded template set:

1. Business
2. Premium Marketplace
3. Buy & Sell
4. Services
5. Editorial
6. Minimal
7. Retail
8. Professional
9. Bold
10. Classic
11. Local Business

The Premium Marketplace homepage is designed for a two-sided business and presents:
- professional hero
- buying and selling introduction
- visual What We Buy tiles
- visual What We Sell tiles
- trust information
- connected retail shop below the homepage

Homepage tile choices are 6, 8 or 10. Tiles can have their own title, description and image.

### Branding
Subscriber-controlled website colours are available for:
- Brand/accent
- Text
- Page background
- Header/navigation
- Buying section
- Selling section
- Footer

Quick palettes are available for Professional, Warm, Dark and Clean.

### Social, sharing and reviews
Subscribers can add:
- Facebook
- Instagram
- LinkedIn
- YouTube
- TikTok
- X

Website share buttons can be enabled or disabled.

Up to four review-site links can be added, such as Google Reviews, Trustpilot, Reviews.io or Feefo. TradeFlow displays subscriber-supplied external links; it does not verify third-party review profiles.

### Website workflow
Website content is saved as the existing site JSON within site_revisions. Images use the tenant-scoped tradeflow-site-media Storage bucket. Products remain connected to Inventory → Selling rather than being manually entered into the Website Builder.

The subscriber flow remains:
Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns.

### Subscriber onboarding repair
New subscriber onboarding now creates a 30-day trial window. The repair is migration 065, repair_subscriber_trial_entitlement_window.

The affected test subscriber's live database capability checks were verified for:
- tenant membership
- website.editor
- website.publish

No RLS or tenant security boundary was weakened.

### Restore point
GitHub restore branch:
checkpoint-tradeflow-20260918-premium-builder

Restore branch base:
7f03b3964add0857ebc0ec3bcce2bf0d7113c80c

Live Supabase migration state includes:
repair_subscriber_trial_entitlement_window

### Status
The code and database checkpoint are saved. Browser verification of the newest branding/social/review controls remains the next testing task when development resumes.

Do not modify GearCashOut while working on this TradeFlow checkpoint.


## Website domains and future domain purchasing — 19 September 2026

TradeFlow can already store a custom website address against your business. The current **Website URL** area is for connecting a domain you already own.

A future TradeFlow domain service is now supported by the database design. The intended customer journey is:

1. Open **Website / Domain** in the business dashboard.
2. Search for a domain name.
3. See current availability and price.
4. Choose the domain and registration period.
5. Pay through TradeFlow.
6. TradeFlow registers the domain through its domain provider.
7. TradeFlow connects the domain to the customer's website and enables the required SSL/hosting routing.
8. The domain appears in the business account with its registration and renewal information.

The database now records the information needed for purchased domains, including registration status, provider reference, purchase amount, expiry date and auto-renewal state.

**Important:** the domain-purchase button/search/checkout and automatic DNS/hosting connection are not yet live. The current Website URL page only records a domain as pending for later connection.

Domain availability and prices will be checked with the selected registrar at the time of purchase; the prices stored in TradeFlow's TLD catalogue are configuration/pricing data, not a promise of current availability.


