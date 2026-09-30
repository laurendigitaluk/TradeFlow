# TradeFlow — Live Launch & Test/Production Runbook

**Version:** 1.0  
**Date:** 30 September 2026  
**Purpose:** Handover from development/final validation into a permanently separated Test/Staging and Live/Production operating model.

---

## 1. Current position

TradeFlow has completed the main development and end-to-end validation cycle and is now moving to live-environment preparation.

The current repository is:

- GitHub: `laurendigitaluk/TradeFlow`
- Current branch: `main`
- Current latest commit: `b0a42de34958febf883ca7db8092ea9ef2a263cc`
- Current Supabase project: `twfbmjwwqzxdxvclxbun`, eu-west-2
- Current Supabase project is the development/test environment and must **not** become the production database.

Test One remains the frozen known-good functional baseline. Later Test Two/Test Five work was performed against the current development environment without overwriting the Test One checkpoint.

Recent work includes:
- subscriber/customer tenant isolation testing;
- same customer email across two tenants;
- bidirectional customer/address/bank-data isolation;
- subscriber session/sign-out isolation;
- standardised subscriber sign-out to `subscriber-login.html`;
- cache-busting of subscriber authentication;
- customer retail purchase and return workflows;
- manual shipping architecture;
- customer order tracking;
- subscriber/customer portal testing.

The latest sign-in page cleanup removed the redundant subscriber signup panel.

Latest relevant commits:
- `b0a42de34958febf883ca7db8092ea9ef2a263cc` — remove subscriber signup panel;
- `a57b23b3d80060dff4f69901d9bad86629d73d9f` — remove duplicate top-right signup link;
- `20e867b713b2223be9b3cbbd0eca9bc3b9c33ea3` — subscriber sign-out wiring;
- `24c0583d8e93fe8bef17109d4c17157e0ae24445` — central subscriber sign-out handling.

---

# 2. The permanent environment rule

From this point forward TradeFlow has two separate environments:

## TEST / STAGING

Purpose:
- development;
- bug fixing;
- new features;
- database migrations;
- browser testing;
- subscriber testing;
- customer testing;
- Stripe test mode;
- deliberate test data.

Nothing here is customer production data.

## LIVE / PRODUCTION

Purpose:
- real TradeFlow platform;
- real subscriber accounts;
- real customer accounts;
- real inventory;
- real orders;
- real payments;
- real domains;
- real email/notifications.

Production must never be used as a development or debugging environment.

### Absolute rule

**No code, database migration, Edge Function, authentication change, RLS change, domain change or configuration change is applied directly to Production simply because it appears to work.**

The sequence is:

**Build → TEST → browser test → security/isolation test → regression test → release checkpoint → promote → PRODUCTION → smoke test**

If something fails in Production:
1. do not experiment directly in Production;
2. record the exact failure;
3. reproduce it in TEST;
4. repair TEST;
5. test the repair;
6. promote the tested version.

---

# 3. Recommended permanent architecture

## GitHub

Keep the existing repository:

`laurendigitaluk/TradeFlow`

Use separate release branches:

### `main`
TEST/STAGING development branch.

All normal development goes here first.

### `production`
LIVE release branch.

This branch must only receive tested releases.

Production should not be edited directly.

Before every production release:

`main` → complete testing → approved release commit → merge/promote to `production`

A production release must have a known commit SHA.

---

# 4. Supabase separation

The current Supabase project:

`twfbmjwwqzxdxvclxbun`

remains TEST/STAGING.

Create a completely separate Supabase project for Production.

Do not copy production credentials into the test application.

Do not use the production Supabase URL or keys while testing new code.

## TEST Supabase

Contains:
- Test Business A/B/C;
- Camerashack/Test Sub 2;
- test customers;
- test orders;
- test returns;
- test inventory;
- Stripe test data;
- development/test subscriptions.

## PRODUCTION Supabase

Contains:
- real subscriber tenants;
- real subscriber users;
- real customers;
- real customer data;
- real inventory;
- real orders;
- real returns;
- real financial records.

Production data must never be used to reproduce a test bug.

---

# 5. Supabase production setup sequence

Create the Production Supabase project first.

Then:

1. Record the new project URL.
2. Record the production publishable key.
3. Configure production authentication settings.
4. Configure production redirect URLs.
5. Deploy the complete migration history.
6. Verify all tables exist.
7. Verify RLS is enabled.
8. Verify grants.
9. Verify SECURITY DEFINER functions.
10. Verify Edge Functions.
11. Configure production secrets.
12. Configure production Storage buckets/policies.
13. Configure production email/auth settings.
14. Configure production Stripe integration.
15. Run the production security checks before allowing real accounts.

The production database must be created from the version-controlled schema/migrations, not by manually copying random test rows.

---

# 6. Production onboarding must be hardened

The Master Roadmap currently records Production Onboarding as an open boundary.

The development system contains temporary/test-lab onboarding paths. These must not be exposed as the public production subscriber registration mechanism.

Before real subscriber launch:

- remove or isolate Customer Test Lab onboarding;
- remove development-only tenant insertion paths from production;
- use the approved subscriber signup/business creation flow;
- ensure subscriber membership is created only through the authoritative production path;
- verify tenant ownership;
- verify subscription/capability creation;
- verify RLS;
- verify tenant switching;
- verify session isolation.

The Customer Test Lab is temporary infrastructure and must not become part of the production customer journey.

---

# 7. Production application hosting

The intended production direction is:

**GitHub → Cloudflare Workers → Supabase**

GitHub remains the source of truth.

Cloudflare serves the application.

Supabase provides:
- authentication;
- database;
- RLS;
- storage;
- RPCs;
- Edge Functions.

The Test and Production Cloudflare deployments must use different environment configuration.

---

# 8. Test website

The Test site should have its own hostname.

Recommended structure:

- Test platform: `test.<chosen-domain>`
- Production platform: `<chosen-domain>`

The exact domain names are to be selected when the domains are purchased.

The Test hostname must point to the TEST Cloudflare deployment and TEST Supabase.

The Production hostname must point to the PRODUCTION Cloudflare deployment and PRODUCTION Supabase.

Never point the Test hostname at Production Supabase.

Never point the Production hostname at Test Supabase.

---

# 9. Subscriber website architecture

TradeFlow is a multi-tenant SaaS.

The architecture is:

**TradeFlow Platform → Subscriber Tenant → Subscriber Dashboard → Subscriber Website → Subscriber Customers**

Each subscriber website is tenant-specific.

The public website can use:
- a TradeFlow tenant URL;
- a subscriber custom domain.

Custom-domain resolution must preserve the tenant identity and load only that tenant's published website.

The subscriber's website content is not a separate manually coded website. It is generated from the subscriber's TradeFlow website configuration.

The Website Builder currently supports the unified template system.

Current template family:

- Editorial
- Classic
- Grid
- Studio
- Horizon
- Field
- Business
- Luxe
- Commerce
- Impact

Future templates must be added to the shared builder/public-renderer system and tested in TEST before Production.

---

# 10. Domains — next workstream

Purchase the required TradeFlow domains before Production launch.

At minimum, determine:

1. Main TradeFlow platform domain.
2. Test/staging hostname or domain.
3. Wildcard/subscriber-hosting strategy.
4. Any separate business/marketing domain required.

Do not hard-code a registrar into the application yet.

The existing domain-purchasing database foundation supports:
- domain catalogues;
- tenant domain orders;
- provider metadata;
- registration/expiry information;
- auto-renewal fields.

The current Website URL feature is primarily an existing-domain connection mechanism. Full automated registrar purchasing remains a separate provider-specific implementation.

## DNS plan

Production platform:
- root/apex domain → Cloudflare;
- `www` → Production application if required;
- wildcard `*.<domain>` → subscriber tenant routing if used.

Test platform:
- separate test hostname/domain → Test Cloudflare deployment.

Do not mix the DNS records between environments.

---

# 11. Main TradeFlow subscriber page

The next public-facing task is to put the main TradeFlow subscriber/SaaS page online.

This is different from a subscriber's individual business website.

There are two levels:

### TradeFlow platform
The public SaaS site where a new business learns about TradeFlow and creates a subscriber account.

### Subscriber website
The individual business website created inside TradeFlow after the subscriber account exists.

The Production platform page must therefore provide the public entry points for:
- TradeFlow information;
- subscriber signup;
- subscriber sign-in;
- customer access where appropriate;
- legal/privacy pages;
- the subscriber onboarding route.

The current test environment must be used to validate every link before the Production page is published.

---

# 12. Production subscriber test

Once the Production environment exists, perform a controlled real subscriber test.

Use a new real test business account.

Do not use Camerashack/Test Sub 2 as the Production test account.

Test:

1. Open the Production TradeFlow homepage.
2. Create subscriber account.
3. Confirm email.
4. Sign in.
5. Confirm correct tenant is created.
6. Confirm correct subscription/capabilities.
7. Open Business Dashboard.
8. Open Buying.
9. Open Inventory.
10. Open Selling.
11. Open Customers.
12. Open Orders.
13. Open Fulfilment.
14. Open Returns.
15. Open Sales Channels.
16. Open Settings.
17. Open Shipping Settings.
18. Open Website Builder.
19. Save website configuration.
20. Preview website.
21. Publish website.
22. Open public subscriber URL.
23. Confirm only that subscriber's data appears.
24. Sign out.
25. Confirm the session is destroyed.
26. Confirm protected pages cannot be reopened from browser history without authentication.

---

# 13. Production customer test

Create a separate real customer test account against the Production subscriber.

Test:

1. Open the subscriber public website.
2. Use What We Buy.
3. Use What We Sell / selling journey.
4. Create customer account.
5. Confirm customer is linked to the correct subscriber tenant.
6. Sign out.
7. Sign back in.
8. Confirm customer data remains.
9. Check My Details.
10. Check addresses.
11. Check bank/payment details where applicable.
12. Submit a buying request.
13. Confirm the subscriber sees it.
14. Confirm no other subscriber can see it.
15. Test valuation/offer workflow.
16. Test customer acceptance/refusal.
17. Test shipping handoff.
18. Test tracking display.
19. Test inspection.
20. Test payment.
21. Test acquisition/inventory hand-off.
22. Test retail sale where applicable.
23. Test customer return.
24. Test subscriber return decision.
25. Confirm all resulting records remain tenant-scoped.

---

# 14. Tenant isolation test in Production

This is mandatory.

Create:

- Production Subscriber A
- Production Subscriber B
- Customer A belonging to Subscriber A
- Customer B belonging to Subscriber B

Use deliberately similar test data where useful.

Verify:

### Subscriber A cannot see:
- Subscriber B customers;
- Subscriber B addresses;
- Subscriber B bank details;
- Subscriber B buying requests;
- Subscriber B valuations;
- Subscriber B offers;
- Subscriber B inventory;
- Subscriber B listings;
- Subscriber B orders;
- Subscriber B returns;
- Subscriber B website data.

### Subscriber B cannot see Subscriber A's equivalent data.

### Customer A cannot see Customer B's data.

### Customer A cannot use a Subscriber B URL to access Subscriber B data.

This is not just a browser test. The database/RLS boundary must also be checked.

---

# 15. Retail payment Production test

TEST currently uses Stripe Sandbox/Test Mode.

Production must use a separate Production Stripe configuration.

Do not copy Test payment IDs or webhook secrets into Production.

Production sequence:

**Customer Shop → Order → Stripe Checkout → Payment → Stripe webhook → TradeFlow payment record → Order paid → Fulfilment**

Run one controlled real payment only after:
- Production Stripe account/configuration is complete;
- webhook signature verification is configured;
- success/cancel URLs use the Production domain;
- payment record linking has been tested in TEST.

---

# 16. Shipping architecture

The current shipping decision is:

**Manual shipping architecture.**

Do not reintroduce the old Parcel2Go API checkout architecture.

Subscriber:

**Settings → Shipping Settings**

Subscriber selects the shipping services they want displayed.

Customer:
- receives shipping instructions;
- adds tracking information where required;
- receives/uses the shipping label;
- pays their own shipping costs.

TradeFlow does not collect the customer's shipping payment as part of the current shipping architecture.

Shipping label requirements remain:
- 6×4 portrait;
- suitable for ZDesigner GK420;
- printable top-left on A4.

---

# 17. Production return architecture

Two return types remain:

### Customer retail return
A customer purchased an item and wants to return it.

### Acquisition return
The subscriber did not purchase/retain the customer's item and needs to return it to the customer.

These must remain separate workflows.

Do not collapse them into a single generic return state.

---

# 18. Inventory and selling architecture

The physical `inventory_assets` record remains the master stock record.

Lifecycle:

**Buying/Acquisition → Inventory → Selling → Customer Order → Sold**

A physical asset must not be duplicated simply because it is listed on multiple sales channels.

Sales Channels currently include:
- Website;
- eBay;
- Amazon;
- Other.

Real eBay/Amazon marketplace API connections are not currently the core launch dependency.

The authoritative sale workflow must eventually control delisting of other active listings.

---

# 19. What is already established

The following major areas have already been developed and tested during the project:

- multi-tenant architecture;
- tenant-scoped RLS;
- subscriber authentication;
- customer authentication;
- subscriber/customer separation;
- customer tenant registration;
- same-email customer testing across tenants;
- customer/address/bank-data isolation;
- subscriber session isolation;
- Buying;
- valuations;
- offers;
- acquisition;
- fulfilment;
- manual shipping;
- Inventory;
- Selling;
- Sales Channels;
- retail orders;
- Stripe test checkout;
- customer returns;
- subscriber return decisions;
- customer order tracking;
- subscriber Website Builder;
- ten-template public website system;
- tenant website publishing;
- custom-domain architecture foundation.

---

# 20. Known areas that must be explicitly checked before Production

The Master Roadmap still records some areas as AMBER/BLUE rather than fully production-certified.

Before real launch, specifically re-check:

1. Production subscriber onboarding.
2. Production authentication redirects.
3. Production RLS and grants.
4. Storage policies and media access.
5. Notification/email delivery.
6. Payment Production configuration.
7. Production webhook configuration.
8. Website publishing/custom-domain routing.
9. Browser regression across subscriber and customer journeys.
10. Production tenant isolation.
11. Backup/recovery arrangements.
12. Any development/test-lab code that must not be exposed publicly.

A feature being functional in TEST does not automatically make its Production configuration correct.

---

# 21. Release procedure

Every future change follows this exact process.

## Step 1 — Build in TEST

Developer/AI changes:

`main`

TEST Supabase.

No Production access.

## Step 2 — Test

Run:
- browser test;
- database verification;
- tenant isolation;
- permissions;
- regression;
- relevant workflow test.

## Step 3 — Create release checkpoint

Record:
- commit SHA;
- database migration numbers;
- Edge Function versions;
- known test result;
- affected features;
- rollback point.

## Step 4 — Promote

Only the approved commit is promoted:

`main` → `production`

Production deployment is tied to that exact release.

## Step 5 — Production smoke test

Immediately check:
- homepage;
- subscriber login;
- customer login;
- one protected subscriber page;
- one public subscriber website;
- one customer journey;
- database connectivity;
- payment boundary if applicable.

## Step 6 — Close release

Record:
- Production release SHA;
- date/time;
- test evidence;
- any known limitations.

---

# 22. Emergency Production rule

If Production breaks:

**DO NOT start editing Production until the failure is understood.**

First capture:
- URL;
- account/tenant;
- exact action;
- exact error;
- browser console error;
- network request;
- Supabase error;
- affected database record/reference.

Then reproduce in TEST.

Fix TEST.

Test TEST.

Only then promote the fix.

---

# 23. Database migration rule

Every schema change must be a version-controlled Supabase migration.

Never make an undocumented Production-only database change.

Required process:

**Migration written → TEST applied → TEST verified → release checkpoint → Production applied → Production verified**

Keep migration order intact.

---

# 24. Edge Function rule

Every Edge Function change must be:

1. committed to GitHub;
2. deployed to TEST;
3. tested against TEST;
4. verified for authentication/JWT behaviour;
5. verified for tenant boundaries;
6. promoted to Production;
7. Production-smoke-tested.

Never patch a Production function manually and leave GitHub behind.

---

# 25. Environment configuration rule

TEST and Production must have separate:

- Supabase URL;
- Supabase publishable key;
- Stripe configuration;
- Stripe webhook secret;
- Cloudflare environment configuration;
- email/provider credentials;
- storage configuration where environment-specific;
- domain configuration.

Public publishable/browser keys are not treated as server secrets, but environment-specific credentials and server secrets must never be mixed.

Never hard-code a Production secret into TEST code.

---

# 26. Final launch sequence

The next project phase should be performed in this order:

### Phase A — Environment separation
1. Freeze current TEST state.
2. Create Production GitHub branch.
3. Create Production Supabase project.
4. Deploy migrations/schema.
5. Configure Production Auth/RLS/functions/storage.
6. Remove/isolate test-lab onboarding from Production.

### Phase B — Domains
7. Purchase TradeFlow domain(s).
8. Configure Cloudflare.
9. Configure Test hostname.
10. Configure Production hostname.
11. Configure SSL.
12. Configure subscriber wildcard routing where required.

### Phase C — Public platform
13. Put the main TradeFlow subscriber page online.
14. Verify signup.
15. Verify sign-in.
16. Verify legal/privacy links.
17. Verify subscriber onboarding.

### Phase D — Production subscriber test
18. Create new Production subscriber.
19. Configure business.
20. Configure buying.
21. Configure inventory.
22. Configure selling.
23. Configure shipping.
24. Configure website.
25. Publish subscriber website.
26. Verify public subscriber URL.

### Phase E — Production customer test
27. Create new Production customer.
28. Test customer account.
29. Test selling request.
30. Test buying workflow.
31. Test shipping.
32. Test inspection.
33. Test payment.
34. Test acquisition/inventory.
35. Test retail sale.
36. Test return.

### Phase F — Security
37. Test Subscriber A vs Subscriber B.
38. Test Customer A vs Customer B.
39. Test direct URL access.
40. Test sign-out/session destruction.
41. Test RLS/database boundaries.

### Phase G — Release
42. Freeze the tested release.
43. Record commit SHA.
44. Record Supabase migration state.
45. Promote to Production.
46. Run Production smoke test.
47. Open the system for real subscriber onboarding.

---

# 27. The operating principle from launch onward

TradeFlow should operate like this:

**TEST is where we build.**

**PRODUCTION is where customers operate.**

**GitHub is the source-controlled code history.**

**Supabase TEST is the development database.**

**Supabase PRODUCTION is the real database.**

**Cloudflare TEST serves the test application.**

**Cloudflare PRODUCTION serves the live application.**

**A release is promoted only after it has passed the TEST checklist.**

This becomes the permanent TradeFlow development and release model.
