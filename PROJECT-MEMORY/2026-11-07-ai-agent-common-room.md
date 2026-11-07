# Project memory — AI Agent Common Room — 7 November 2026

The user wants a shared workspace for Gemma specialist agents and ChatGPT supervisory workflows to communicate, learn from one another, inspect work and receive owner instructions. The owner must be able to view the same persistent message history.

Branch: `feature/ai-agent-common-room-20261107`.

Implemented: LIVE message-table migration; owner-authenticated list/post RPCs; service-role-only agent list/post RPCs; owner dashboard room with thread/category/message filters and compose; Gemma worker room read/post integration; manuals/roadmap/checkpoint updates.

LIVE migration applied to `gxsrajtqzdjvmceqcpgv`. Verified table exists, RLS on, no direct anon/authenticated table policies, owner RPC authenticated access, agent RPC service-role-only. No messages were seeded.

Worker change preserves `TRADEFLOW_GEMMA_ENV_FILE` and loads its separate `.env`. Do not overwrite that PC environment file or expose its service-role credentials.

Not yet deployed: branch is not merged; dashboard not yet verified in Cloudflare LIVE; Research PC not yet updated/restarted. Full instruction-read → handover-post → owner-visible round-trip remains pending. No claims that the Common Room is live/operational until this test succeeds.

Messages are not tasks, evidence approval, catalogue imports or valuation inputs. Owner instructions are separate from the Gemma queue. Candidate evidence remains subject to owner/ChatGPT review.

Documentation updated in branch: System Handbook, Human User Manual, Backend User Manual, AI Operating Manual, Subscriber Website Manual, Backend Operations Manual and Gemma Research Pipeline Diagnostic Roadmap. How It Works stays source-managed in `how-it-works.html` / `how-it-works.css`; Examples remains CMS-editable.

 
## Follow-up implementation — 7 November 2026
The Gemma worker now passes up to ten bounded Common Room instruction/handover/learning notes into the Ollama extraction prompt. The prompt treats them as untrusted operational guidance and preserves all hard-coded product identity, approved source, evidence validation and review constraints. This closes the previous gap where the worker read and logged notes without supplying them to Gemma.

The Owner Dashboard has nine consistent native collapsible sections, including the Common Room and Gemma Control Centre; overview metrics remain visible and sidebar anchors expand the matching section. Owner Dashboard diagnostic roadmap added at docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-OWNER-DASHBOARD.md.

The Subscriber Website Manual now reflects the central TradeFlow AI model: subscribers do not add their own AI provider. The System, Human, Backend User, AI Operating and Backend Operations manuals have current-position sections at the top. How It Works remains source-managed; Examples remains CMS-editable.

Still pending: PR #267 merge/release, Cloudflare LIVE deployment/browser acceptance, Research PC code update/restart and an end-to-end Common Room message round-trip. Preserve the local .env and TRADEFLOW_GEMMA_ENV_FILE path.
