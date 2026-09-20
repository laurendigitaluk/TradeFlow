# TradeFlow Template Placeholder Audit — 20 September 2026

## Audit

Checked the ten homepage templates in both the Website Builder renderer and public-site renderer for fixed demonstration/placeholder copy.

The audit covered Connected Catalogue wording, Sell to us / Browse the shop / Shop products / Start selling, What we buy / What we sell hero CTAs, BUYING / SELLING / BUSINESS INFORMATION / PRIVATE SERVICE labels, fixed business facts, the fixed commerce catalogue panel, and product-card fallback labels.

## Changes

- All ten template default kicker values are now blank.
- All ten template default CTA values are now blank.
- Existing known template-demo values are sanitized when the builder loads saved template copy, without removing unrelated custom copy.
- The public renderer applies the same protection to known demo values.
- Business template fixed BUYING / SELLING facts removed.
- Commerce template fixed CONNECTED CATALOGUE panel removed.
- Unused homepage READY TO SELL prompt function removed from the public renderer.
- Product-card fallback labels were removed where they were only placeholders for missing data.
- Assets bumped to v47.

## Legitimate remaining text

The audit still finds strings such as What do you have to sell? in the code because that wording is part of the actual guided selling journey, not a template placeholder. Category selling-page CTAs such as Start selling this category are functional page actions.

## Validation

- website-builder.js syntax PASS.
- public-site.js syntax PASS.
- No rendered template defaults remain for the ten template kicker/CTA fields.
- No CONNECTED CATALOGUE panel remains.
- No fixed business facts remain in the Business hero.
- No Supabase schema/data changes.
