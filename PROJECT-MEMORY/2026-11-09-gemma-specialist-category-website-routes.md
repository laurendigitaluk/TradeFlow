# Gemma specialist category workers and website routes — 9 November 2026

## Decision
The Windows Research Control Centre exposes one independently switchable Gemma specialist per TradeFlow product category: 3D Printers & Equipment, Gaming Consoles & Accessories, Drones, Metal Detectors, Mobile Phones, Laptops & Computers, and Cameras & Lenses.

The seven specialists share one persistent queue supervisor and one Ollama execution lane. Do not run seven competing Node workers. The desktop config defaults to all seven specialist switches enabled, with per-agent disable/enable controls and individual desktop shortcuts.

## Website research
LIVE source registry audit: 119 UK source records, 116 enabled. Existing source records are retained; no duplicate source rows are inserted. Category coverage counts overlap where sources are shared.

A full re-read of the category-specific source-playbook blocks confirmed the additional registered UK domains already had specialist site definitions. The earlier route-count script used an incorrect block boundary and falsely reported those entries as missing. No source registry rows or website definitions were added or changed in this follow-up.

A regression test now protects the existing specialist definitions for the additional drone, mobile-phone and camera websites, plus Amazon UK and eBay UK marketplace search patterns for metal detectors. Discovery pages are not evidence; Gemma must follow exact product/listing links and capture the individual page for ChatGPT review. No autonomous approval/import is introduced.

## Deployment gates and safety
Code and documentation changes are on feature/gemma-desktop-control-centre-20261109, PR #325. The latest source-route/test commit is 74705aebb170487b8d3015cd654d466430be2727; documentation updates follow it. Re-check the PR's CI against the final head before merge.

The service-role-only platform_ai_agent_claim_task_for_agents(text,text[],integer) migration is part of PR #325 and has not been applied to LIVE. It must be reviewed and applied to LIVE before desktop installation/queue processing. If missing, the desktop worker stops with requires_migration and never falls back to the unscoped claim RPC.

No LIVE or TEST database migration, source registry, task queue, catalogue, evidence, approval or import data has been modified by this follow-up. No Research PC files, private .env, existing worker process or Windows service have been changed. Do not install or start the desktop supervisor until PR review/merge and LIVE migration deployment are complete.
