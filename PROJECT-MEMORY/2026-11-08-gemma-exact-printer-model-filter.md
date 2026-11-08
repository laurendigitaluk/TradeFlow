# Project Memory — Gemma exact printer model and package matching

Date: 8 November 2026 (UTC)
Scope: TradeFlow LIVE Gemma, 3D Printers branch only.

LIVE review found K1 Max and accessory/upgrade product pages being captured under the Creality K1 Standard Printer task because the previous matcher intentionally accepted sibling variants and accessories for later ChatGPT classification. That broad match polluted the exact task identity in the review queue.

A feature branch now makes 3D-printer matching exact: reject sibling model suffixes not included in the task model, reject accessory/spare/replacement/upgrade pages, and keep Standard and Combo/AMS/ACE/CFS/multicolour package tasks separate. Exact K1 Max tasks and correctly matching Combo tasks remain eligible. Other catalogue categories and the short-model identity guard are unchanged.

No queue/source/catalogue data, approvals/imports, tasks, TEST data, credentials, .env files or Research PC runtime were changed. CI is pending. After merge, deploy the agent in place and run a controlled 3D-only acceptance batch before further research.
