# Checkpoint — 3 October 2026 — Documentation and Owner Access

## Purpose

TradeFlow documentation is now treated as part of the maintained production record rather than as historical notes.

## Owner Dashboard

The LIVE Platform Owner Dashboard now has direct links to:
- System Handbook
- Human User Manual
- Subscriber Manual
- Backend User Manual
- AI Operating Manual

The dashboard JavaScript cache-buster was advanced to v9.

## Subscriber documentation

The existing subscriber documentation entry point remains subscriber-website-manual.html. It has been updated with the current LIVE documentation position.

The Subscriber Dashboard now has a separate Customer Documentation link.

## Customer documentation

A new subscriber-customer-documentation.html foundation page has been added. It is deliberately separate from internal owner/backend/AI documentation. The subscriber will maintain customer-facing business guidance for account use, selling, buying, shipping, returns and the Customer Assistant.

## Maintained manuals updated

The following production documents were updated:
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- docs/TRADEFLOW-HUMAN-USER-MANUAL.md
- docs/TRADEFLOW-BACKEND-USER-MANUAL.md
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- subscriber-website-manual.html

## Backend audit rule

The Backend Manual now explicitly requires periodic comparison against the LIVE Supabase project and production GitHub branch, including tables/relationships, RLS and security-definer RPCs, constraints/indexes, Edge Functions, storage, environment boundaries, Worker routes, AI configuration and retired integrations.

## Continuity rule

After every material LIVE change:
1. Update the relevant manual(s).
2. Record a dated checkpoint where the change is material.
3. Distinguish implementation from LIVE browser/backend verification.
4. Do not allow historical TEST wording to override a newer dated LIVE continuity statement.

## Current launch context

Cloudflare Production is configured to use the production branch. LIVE Owner Dashboard authentication has been browser-verified and old TEST/Camerashack data is no longer being served by the corrected production deployment. The next product stage remains the real LIVE subscriber/customer chatbot and launch workflow.

Manual shipping remains authoritative. Parcel2Go API and ResellerClub are retired and must not be reintroduced without an explicit architecture decision.
