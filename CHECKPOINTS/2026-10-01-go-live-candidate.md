# CHECKPOINT — 2026-10-01 — TradeFlow Go-Live Candidate

## Release status
The repeated TEST browser validation has established the main commercial journey as working:

Customer → Buying → Offer → Shipping → Inspection → Payment → Inventory → Selling → Website.

The latest Selling repair was also verified in the browser:
- Selling listing updates now correctly update the linked inventory asset.
- Duplicate inventory serial numbers are permitted and produce an explicit warning/confirmation rather than a database uniqueness failure.

## Source control
- Repository: laurendigitaluk/TradeFlow
- TEST/STAGING branch: main
- Current main release-candidate commit: 189397cb351340e4a69503cff447301864e69c81
- LIVE/release branch: production
- production currently points to e5835e00a5f9d8ebd2e4285450325982bc39da23
- main is 36 commits ahead of production and 0 behind.

The current main commit includes the final Selling cache refresh v70.

## TEST database
- Supabase TEST project: twfbmjwwqzxdxvclxbun
- Region: eu-west-2
- Migration history:
  - 20260930215656_remote_schema
  - 20260930232732_allow_duplicate_inventory_serial_numbers_with_warning
- The TEST schema/data remains intact.
- No production database has been changed.

## Production environment finding
As of this checkpoint, the available Supabase projects show only the TradeFlow TEST project and the separate Action Buyer UK project. No separate TradeFlow Production Supabase project is currently available through the connected Supabase account.

The TradeFlow Live organisation/project setup therefore remains the next infrastructure step. The TEST Supabase project must not be promoted or repurposed as Production.

## Release rule
Do not alter TEST functional behaviour merely to repeat already-completed end-to-end testing. The next work is environment preparation and controlled promotion.

Before any Production deployment:
1. Keep this checkpoint as the release candidate.
2. Promote only this tested main commit to production.
3. Create/configure the separate Production Supabase project.
4. Apply the version-controlled schema/migrations to Production.
5. Configure Production Auth, Storage, Edge Functions, secrets, email and payment settings.
6. Configure Production hosting/domain environment.
7. Run the minimum Production smoke test against the new environment.

## Safety
- Do not use TEST data as Production data.
- Do not reset the TEST database.
- Do not reset or repurpose TEST as Production.
- Do not make undocumented Production-only schema changes.
- Do not promote later experimental commits until a new release checkpoint exists.
