# TradeFlow checkpoint — customer-owned domain connection

Date: 6 October 2026

## Decision

TradeFlow will no longer offer the previous automatic customer domain purchase/registrar-registration workflow.

The approved model is:

Customer buys and owns the domain
→ customer enters the domain in TradeFlow
→ TradeFlow creates a domain-connection request
→ Platform Owner receives an owner-dashboard action notification
→ Platform Owner prepares the approved TradeFlow/Cloudflare custom-domain connection
→ customer receives exact DNS instructions
→ customer applies the DNS records at their registrar
→ TradeFlow verifies DNS and SSL/HTTPS
→ domain becomes active and routes to the correct subscriber website.

## Subscriber responsibilities

The subscriber:

- buys the domain from a registrar of their choice;
- keeps the domain in their own registrar account;
- pays the registrar directly;
- keeps the domain renewed;
- keeps registrar contact/registrant information accurate;
- enters the domain under Website → Website URL in TradeFlow;
- applies only the DNS records supplied by TradeFlow;
- never provides their registrar password to TradeFlow.

## Platform Owner responsibilities

The Platform Owner:

- receives a DOMAIN CONNECTION REQUIRED action;
- verifies the subscriber and requested hostname;
- checks for duplicate/conflicting domain records;
- prepares the custom-domain connection using the approved hosting architecture;
- supplies exact DNS instructions;
- verifies DNS;
- verifies SSL/HTTPS;
- confirms the hostname routes to the correct tenant website;
- activates the domain;
- closes the outstanding owner action.

## Important boundary

TradeFlow must not invent DNS targets, request registrar credentials, or mark a domain active without DNS/SSL and tenant-routing verification.

## Current implementation position

The subscriber Website Manual and Human User Manual have been updated on the TEST/main branch with the new customer-owned domain instructions.

The subscriber Website URL page has been updated on TEST/main to remove the customer-facing automatic-purchase path and explain the new process.

The internal Backend/Owner Manual now documents the Platform Owner procedure.

The next implementation step is the actual Platform Owner dashboard notification/action workflow and the corresponding domain connection verification controls.

This checkpoint does not promote anything to LIVE.
