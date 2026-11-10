# TradeFlow AI Manager

Standalone Windows desktop companion for weekly TradeFlow catalogue research.

This is a new application. It does not restore the retired Gemma worker platform and does not change TradeFlow LIVE.

## Current status

Architecture discovery and initial project setup only. The application is not yet packaged or ready to install.

See:
- [Developer Diagnostic Roadmap](../../docs/TRADEFLOW-AI-MANAGER-DIAGNOSTIC-ROADMAP.md)
- [Build-start checkpoint](../../CHECKPOINTS/2026-11-10-tradeflow-ai-manager-build-start.md)

## Intended behaviour

- Lightweight Windows desktop dashboard.
- Secure local storage for provider and MCP credentials.
- Free-only multi-provider routing with no paid fallback.
- Persistent, resumable research queue.
- Weekly scan and new-product scan when the PC is running.
- Existing TradeFlow Research MCP integration.
- Research reports submitted for review; no direct product/evidence writes.

## Important prerequisites

The existing LIVE MCP has five deployed tools, but does not expose paginated full-catalogue enumeration or the approved source registry. Those capabilities must be added and tested on TEST before catalogue-wide scanning can be enabled. The deployed LIVE MCP source also differs from the GitHub production source and must be reconciled first.

## Build target

Windows x64, designed to run on the owner's Dell Inspiron 3671 (Intel i5-9400, 8GB RAM, GTX 1650). Keep the app lightweight; cloud providers do the inference.
