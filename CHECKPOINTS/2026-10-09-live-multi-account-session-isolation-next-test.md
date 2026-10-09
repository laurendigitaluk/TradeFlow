# New Chat Continuation Prompt — LIVE Multi-Account Session Isolation Test
Date: 9 October 2026
Project: TradeFlow — LIVE production acceptance testing

## Where we are now

We are working on the LIVE TradeFlow production environment, not TEST.

The LIVE platform URL is https://tradeflow.laurendigital.co.uk/

The current browser screenshot shows all three relevant surfaces open in the same Google Chrome browser:
1. **Platform Owner Dashboard** — opened in a separate Chrome window/tab and signed in.
2. **Subscriber/business dashboard** — Adventure Outpost is signed in at `subscriber-dashboard.html`. The displayed owner account is `valley-discounts@outlook.com`.
3. **Subscriber's public website** — https://www.scenesource.co.uk/ — now renders the Action Outfit/Adventure Outpost website with navigation, customer-facing pages and the Customer Login button.

The SceneSource custom domain is already recorded in LIVE Supabase as active and primary, and the LIVE published-site index contains its publication. Do not repeat or undo the domain setup. Do not change DNS, SSL, Cloudflare for SaaS, Worker routes, API tokens, domain activation or published content as part of this account/session test.

The public-site routing work included:
- Worker-first routing for subscriber-owned URLs.
- Cloudflare Static Assets `html_handling: "none"` and `run_worker_first: true`.
- Trailing-slash handling in `public-site.js`.
- A cache-busted script reference `public-site.js?v=26`.
- A correction to the malformed JavaScript regular-expression literal that had left the public website on “Loading website…”.
The source fix has been committed to the production branch. The latest screenshot now shows the subscriber website rendering, but still verify relevant customer-facing routes during the next test rather than assuming every route is passed.

## Immediate next task: verify account records before creating anything

First inspect LIVE Supabase and the relevant customer/subscriber account screens to determine whether a customer account has already been registered for Adventure Outpost/SceneSource.

- Search existing LIVE authentication/profile/customer records using safe, read-only queries.
- Establish which records are actual registered customer accounts versus subscriber owner accounts, business customers, test records or abandoned registrations.
- Do not print or expose passwords, access tokens, refresh tokens, secret keys or full authentication credentials.
- Do not delete existing records.
- Do not create a duplicate subscriber, duplicate subscription, or new Stripe checkout. The Adventure Outpost subscriber session already exists in the current browser.
- Report what exists and what does not exist before taking any create-account action.

If there is no suitable registered **website customer** account, create one through the normal public Customer Login/registration flow on https://www.scenesource.co.uk/ using a clearly identifiable test email address that the user controls. Do not create a second subscriber account unless the read-only audit proves the existing Adventure Outpost subscriber account is absent or unusable and the user explicitly approves creating another.

## Test objective: all roles can coexist in one browser

Prove that these distinct contexts work at the same time in the same Chrome browser:
- Platform Owner account / owner dashboard.
- Adventure Outpost subscriber/business owner account / subscriber dashboard.
- A customer account for the SceneSource public website.

This is a session-isolation and role-separation test, not just a check that three pages can be opened.

### Test sequence
1. Record the current browser tabs/windows and which account is signed in to each.
2. Confirm the existing owner dashboard remains authenticated.
3. Confirm the Adventure Outpost subscriber dashboard remains authenticated and still shows the correct tenant.
4. Check LIVE for an existing SceneSource website customer before registering one.
5. If none exists, register a customer via the public site's Customer Login flow and sign that customer in.
6. Return to the owner dashboard and verify it is still the platform owner, not the customer or subscriber.
7. Return to the subscriber dashboard and verify it is still Adventure Outpost.
8. Return to the public website/customer area and verify the customer session is still signed in.
9. Navigate or refresh each surface and verify that logging in/out of one role does not silently replace or corrupt another role's session.
10. Test the Customer Login/customer account flow separately from the subscriber/business login. Do not add a business-owner login link to the public website; the established design is that subscribers sign in to TradeFlow, while Customer Login is for their own website customers.
11. Capture evidence for pass/fail at each stage. If sessions conflict, identify the exact cookie/storage/auth mechanism and reproduce the problem before changing code.

## Safety and working rules

- Work step by step. Inspect before changing anything.
- LIVE is the acceptance environment; do not substitute TEST data for LIVE evidence.
- Do not weaken authentication, tenant isolation, RLS, or role checks to make the test pass.
- Do not change working login details or reset credentials unnecessarily.
- No destructive cleanup or bulk test-data deletion.
- Do not change domain/DNS/SSL/Cloudflare settings for an account-session issue.
- If an action requires creating a new account or altering live billing, stop and obtain explicit approval where needed.
- Use the repository's existing account/customer tables and registration flow; do not guess table names or schema. Inspect migrations/functions and existing manuals first.
- If a test fails, stop at the first reproducible failure, collect console/network/backend evidence, identify the root cause, and make the smallest justified repair.
- After the test, update the checkpoint, project memory, AI/manual documentation and roadmap with observed results. Do not mark any test passed without evidence.

## Required outcome

Produce a clear pass/fail matrix for:
- Owner login remains valid.
- Subscriber login remains valid.
- Public website customer registration/login works.
- All three sessions coexist in one Chrome browser.
- Refresh/navigation preserves the correct role in each context.
- Logging out of one context does not unexpectedly sign out or impersonate another.
- Public website clean routes still work.

Do not declare acceptance until these results have been observed and documented.
