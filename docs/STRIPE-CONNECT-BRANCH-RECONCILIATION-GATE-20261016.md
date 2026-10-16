# Stripe Connect Branch Reconciliation Gate — 16 October 2026

Repository: `laurendigitaluk/TradeFlow`
Base: `production`
Feature: `feature/live-stripe-connect-onboarding-20261015`
Latest reviewed feature commit before this note: `07ef1087edb1d4b65226ecefa48b89db12956e99`

## Current comparison

GitHub's compare endpoint currently reports the feature branch as **44 commits ahead and 2 commits behind** `production`, with a divergent history. The merge base is `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`; the current production comparison commit is `419dc34b42bb60b175b65e9beacb430a195c7a00`.

This is a material change from earlier notes that described 42 commits ahead. Treat the current compare result as the latest snapshot and re-run it immediately before any merge/rebase decision.

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
