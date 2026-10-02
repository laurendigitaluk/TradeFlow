# TradeFlow — Chatbot → Real Domain → Launch Continuity Checkpoint
Date: 2026-10-02

## Purpose

This checkpoint preserves the agreed continuation point after the TradeFlow chatbot work is completed.

## Chatbot workstream

The chatbot is a pre-launch requirement.

Agreed staged architecture:

1. Subscriber read-only assistant.
2. Customer read-only assistant.
3. Controlled messaging/enquiries.
4. Controlled actions only after earlier phases are proven.

The first phase uses the finalized TradeFlow manuals and approved documentation as its primary knowledge source and may use permitted authenticated tenant context. It must not have unrestricted SQL/database access and must never cross tenant boundaries.

Examples already agreed for the first phase include:
- adding a logo
- creating a listing
- changing shipping services
- buying a domain
- understanding “Shipping Required”
- understanding what happens after receiving an item
- publishing the website

## Documentation search result

Previous TradeFlow planning documentation was located and reviewed. The earlier agreed sequence was explicitly:

GoDaddy API foundation
→ domain ownership/registrant architecture
→ DNS/custom-domain automation
→ domain payment
→ safe domain testing
→ Subscriber User Manual
→ Subscriber read-only chatbot
→ chatbot testing
→ Customer read-only chatbot
→ later controlled actions.

The current registrar path has since moved to Porkbun for the tested domain-registration workflow, and the current shipping architecture is manual; those later verified decisions take precedence over historical planning text.

## Current domain TEST state

Porkbun sandbox registration:

- Domain: camerashack.co.uk
- Provider order: 9913828
- Status: registered
- Expiry: 2027-10-02
- TEST Supabase project: twfbmjwwqzxdxvclxbun

TEST published site mapping exists for camerashack.co.uk in published_site_index.

## Cloudflare TEST state

- Worker: tradeflow-test
- Branch: cloudflare-test
- Worker URL: https://tradeflow-test.leannelaurenlowe.workers.dev
- TEST Supabase is served by the TEST Worker; the LIVE Supabase URL/key are rewritten away in served JavaScript.
- No custom domain is currently attached to the TEST Worker.

Cloudflare rejected camerashack.co.uk as a connectable registered zone because the Porkbun registration is sandbox-only. This is an expected sandbox boundary, not a TradeFlow registration failure.

Do not force the sandbox domain through Cloudflare and do not change Porkbun DNS for it.

## Permanent domain strategy

Lauren Digital is the company identity.

TradeFlow is the SaaS/product name used for subscriber websites.

The permanent Lauren Digital company domain should be chosen deliberately and purchased as the real business domain.

One inexpensive genuine test domain may also be purchased if required to prove the public DNS/Cloudflare path without using a production domain.

## Next sequence after chatbot completion

1. Audit current GitHub, TEST Supabase, Cloudflare TEST, checkpoints and manuals.
2. Choose the permanent Lauren Digital domain.
3. Purchase the genuine Lauren Digital domain.
4. If needed, purchase one inexpensive genuine test domain.
5. Configure the genuine test domain in Cloudflare.
6. Verify real DNS → Cloudflare → tradeflow-test → TEST Supabase → published subscriber website.
7. Verify tenant routing and environment separation.
8. Configure the permanent Lauren Digital production domain separately.
9. Promote only an approved tested release to Production.
10. Complete final launch testing.

## Environment rule

Never mix TEST and LIVE.

Never use a real production customer domain as an unverified experiment.

Never claim a domain is verified until DNS, Cloudflare routing, published-site resolution and environment selection have been browser/database verified.

## Documentation updated

The following continuity records have been updated on the TEST branch:

- TRADEFLOW-MASTER-ROADMAP.md
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- docs/TRADEFLOW-BACKEND-USER-MANUAL.md
- docs/TRADEFLOW-HUMAN-USER-MANUAL.md
- subscriber-website-manual.html
- this checkpoint

## Verification status

Implemented in GitHub: documentation/continuity updates.

Live/browser verification of the real custom-domain path: NOT YET VERIFIED.

The chatbot itself remains the immediate workstream before returning to domain setup.


## 2026-10-02 — Final chatbot boundary work completed in TEST

The project has deliberately stopped treating the Porkbun sandbox `camerashack.co.uk` registration as a useful public-routing test.

### Customer Assistant Phase 2
- Added `customer-assistant.html` and `customer-assistant.js`.
- Added clean TEST Worker route `/assistant`.
- Added Assistant navigation to the customer portal.
- Updated `tradeflow-assistant` Edge Function to accept `audience=customer`.
- Customer identity is verified using `public.customers.auth_user_id` plus the tenant supplied by the customer website hostname.
- Customer context is limited to that customer's buying requests/items, offers, acquisitions, retail orders and returns.
- Product Research is explicitly unavailable to customers.
- Customer assistant is read-only.
- No bank details, unrestricted database access or cross-tenant information is included.
- TEST Edge Function is now version 8, ACTIVE, JWT verification enabled.
- AI provider remains `none`; no external AI request is made.

### Documentation boundary
- Backend User Manual is explicitly owner/platform-operator only.
- Platform Owner Dashboard already contains the Backend User Manual link.
- Subscriber dashboard does not link to the Backend User Manual.
- Subscriber Website Manual now explains the subscriber/customer assistant boundary without exposing backend implementation details.

### Next launch path
1. Perform the remaining TEST customer-assistant browser check.
2. Stop spending time on the sandbox public-domain routing.
3. Purchase/configure the genuine production domain.
4. Create the LIVE subscriber.
5. Configure the LIVE subscriber website/domain.
6. Create LIVE customer account(s).
7. Perform final real-world acceptance in LIVE.
8. Any defects found in LIVE are fixed in TEST and promoted; do not patch LIVE directly.
