# Numbered and CTA Placeholder Cleanup — 20 September 2026

## User requirement

Template designs must not contain numbered hero CTAs such as 01 / WHAT WE BUY or 02 / WHAT WE SELL. Fixed orange demonstration CTAs such as Sell to us, View product and View shop must not appear as template defaults.

## Changes

- Hero CTA sanitisation now removes numbered CTA values matching a numeric slash prefix.
- Hero rendering re-sanitises saved template copy at render time, protecting against old saved values and cache/state drift.
- Fixed CTA demo values are treated as blank template values.
- Empty public hero CTA links are not rendered.
- The Website Builder hero CTA fields remain contenteditable so subscribers can enter their own wording.
- Removed the builder's View product fallback from connected retail product previews.
- Existing functional selling journey step numbers remain because they identify the seven-step customer process; they are not template placeholder content.
- Assets bumped to v48.

## Validation

- website-builder.js syntax PASS.
- public-site.js syntax PASS.
- No Supabase schema/data changes.
