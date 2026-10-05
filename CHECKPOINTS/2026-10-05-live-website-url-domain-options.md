# LIVE CHECKPOINT — Website URL / Domain Options — 2026-10-05

## Status
LIVE implementation updated and ready for subscriber testing.

## Website URL page
The LIVE Website URL page now presents three separate choices:
1. Included Lauren Digital website address.
2. Connect a domain the subscriber already owns.
3. Buy a new domain through Porkbun.

## Included address
The subscriber's included address is generated from the current LIVE application origin plus the authenticated tenant ID. The page provides an Open website action.

## Existing domain
The existing custom-domain connection form remains in place. It saves the subscriber's supplied hostname as a pending tenant domain without changing the locked Website Builder.

## New domain purchase
The existing proven Porkbun domain purchase workflow is reused. The LIVE purchase page:
- checks Porkbun availability;
- displays the server-calculated GBP customer price;
- supports .co.uk, .com and .uk;
- rechecks the chosen domain before checkout;
- creates the existing secure Stripe checkout;
- continues into the existing registrant and Porkbun registration workflow.

The LIVE purchase frontend now points to the LIVE Supabase project rather than the historical TEST project.

## Safety boundary
No Website Builder layout, coordinates, templates, editor controls, draft/publish behaviour, or locked point-set values were changed.

No LIVE Supabase schema or payment functions were changed in this task.

## Verification
Production branch changes were committed for:
- domain-settings.html
- domain-settings.js
- domain-purchase.html
- domain-purchase.js

Browser cache-busting was incremented for the two HTML pages.

## Next test
Log into the LIVE subscriber workspace and open Website URL. Test each of the three choices independently. For the purchase route, begin with availability checking only and report any unexpected result before completing a real purchase.
