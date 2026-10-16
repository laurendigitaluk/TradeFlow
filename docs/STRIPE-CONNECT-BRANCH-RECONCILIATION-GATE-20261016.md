# Stripe Connect Branch Reconciliation Gate — 16 October 2026

Repository: `laurendigitaluk/TradeFlow`
Base: `production`
Feature: `feature/live-stripe-connect-onboarding-20261015`
Latest reviewed feature commit before this note: `07ef1087edb1d4b65226ecefa48b89db12956e99`

## Current comparison

GitHub's compare endpoint reports the feature branch as **diverged**, with **2 commits on production not yet incorporated**. On the latest check before this documentation update, the feature branch was 126 commits ahead and 2 behind; that ahead count changes as checkpoint documentation commits are added. The merge base remains `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`, and the production head observed was `419dc34b42bb60b175b65e9beacb430a195c7a00`.

Treat the exact ahead count as a timestamped snapshot, not a stable invariant. The critical point is that the histories remain divergent. Do not merge/rebase blindly.

## Required before integration

1. Identify both commits on `production` that are not in the feature branch and inspect their changed files and behavior.
2. Inspect the 44 feature commits as a set, especially settings, checkout, onboarding, webhook, migrations, and manual changes.
3. Determine whether production changes overlap any modified files or change assumptions in the checkout/payment flows.
4. Reconcile the histories on a separate integration branch or via a reviewed merge/rebase plan. Do not force-update either `production` or the current feature branch.
5. Run static checks, migration validation, and tests on the resulting candidate commit; preserve the original feature branch as a checkpoint until the candidate is verified.

## CI evidence

The earlier GitHub Actions lookup for checkout commit `aa000aeb34e904e2f13c43919f4da76ae218bd37` returned no workflow runs. This does not prove no workflow exists or that the code fails; it means there is no CI result available from that lookup. Check the current head and workflow configuration before release.

## Safety

No merge, rebase, deployment, LIVE migration, connected-account creation, or live charge is authorised by this note. Preserve the existing DJI Osmo Action 6 Adventure Combo transaction (sale £125, acquisition cost £70, seller payment marked paid by bank transfer).


## Additional validation findings — 16 October 2026

### Existing duplicate migration version

The production branch contains two distinct migration files with the same version prefix, `20261002131500`:

- `supabase/migrations/20261002131500_domain_registrant_details.sql`
- `supabase/migrations/20261002131500_domain_registrant_details_status.sql`

Both files are also present on the feature branch. This is a migration-order/replay hazard for fresh database setup and branch migration validation, because migration tooling commonly expects each migration version to be unique. The duplicate has not been proven to be the cause of the earlier Supabase branch failure. Do not rename or rewrite these historical migrations casually: LIVE's migration history is not a direct filename-for-filename mirror. Resolve this only with a reviewed migration-history plan and test it against a disposable database.

### CI and source validation

The repository search returned no matching GitHub workflow files, and the latest refund-worker commit returned no combined status checks or workflow runs. Deno checks, SQL migration execution, PostgreSQL concurrency tests, and Stripe test-mode tests remain unrun. Treat source inspection as review only, not validation evidence.

### Checkout routing observation

The current feature-branch checkout function creates the retail Checkout Session using the stored connected account in the Stripe `Stripe-Account` request header. This is a connected-account direct-charge context, rather than a platform-account Checkout Session. The draft PR #151 description says retail checkout still charges through the platform account; that wording appears stale relative to the current feature source and must be reconciled before review/merge. The function currently does not set an application fee in the inspected Session parameters, so do not assume TradeFlow commission collection is implemented by this path.

These findings are read-only source observations. No LIVE database, deployment, connected account, or Stripe payment was changed.
