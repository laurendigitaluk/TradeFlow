# 9 November 2026 — Post-restart 3D-printer runtime acceptance

## Scope
LIVE Research PC worker and the 3D-printers branch only. No TEST, source registry, schema, migration, catalogue import, or tenant/customer data changes.

## Worker
- Worker ID: `DESKTOP-LVASEUB-126848`
- Worker restart recorded at 20:28:44 UTC.
- Worker claimed and completed the acceptance tasks; returned idle afterward.

## Runtime runs

| Task | Result |
|---|---|
| `owner-live-3d-printers-postrestart-seeded-ender3v3ke-20261109-2030` | Creality direct page request redirected to SparkX i7; exact-model guard rejected it. Both configured Creality collection API requests returned HTTP 404. No capture. |
| `owner-live-3d-printers-postrestart-anycubic-kobra3maxv2-20261109-2032` | Official Anycubic page discovered but exact model matcher rejected the title because it contains “Full-Metal Hotend”. No capture. |
| `owner-live-3d-printers-postrestart-3djake-bambu-a1-20261109-2034` | 3DJake page fetched and full raw capture retained; Gemma timed out; duplicate skipped because identical source already imported as £215.61 UK-new evidence. |
| `owner-live-3d-printers-independent-source-3dprima-bambu-a1-20261109-2040` | 3D Prima page fetched; full raw capture staged; Gemma timed out; 1 review row created. |

## ChatGPT review of 3D Prima capture
- Review row: `8c18a064-c2e3-4bfd-a1a9-5660254acec7`.
- Product: Bambu Lab A1 Standard Printer; SKU 12558; EAN 6975337039150; manufacturer part PF002-A-EU.
- Current offer: £215.00 GBP; previous/reference £239.00; VAT included, delivery excluded.
- Availability: In Stock (50+); classified New / UK-new.
- Existing active shared evidence already records £215.00 from the same URL. Candidate remains `needs_research`; no shared evidence import or duplicate created. This capture adds explicit current stock confirmation.

## Code finding and fix
- Root cause: `matchesTaskModel` rejected a valid Anycubic Kobra 3 Max V2 page because its title's feature wording “Full-Metal Hotend” matched the generic accessory keyword list.
- PR #337: https://github.com/laurendigitaluk/TradeFlow/pull/337
- Fix removes bare `hotend` from accessory rejection; explicit accessory/replacement/spare/upgrade checks remain.
- Regression test covers the real product title and ensures a replacement hotend page is still rejected.
- GitHub Actions run #42697121803 passed 103/103 tests. PR #337 merged into production at 20:56:51 UTC as commit 6c305f145b8fa18c1b827e152d28013387c933d1. Research PC installation remains unverified.

## Remaining fault
- Creality official Ender-3 V3 KE URL redirected from the Research PC to SparkX i7; the exact-model guard correctly rejected the unrelated page.
- Creality collection discovery returned HTTP 404 for Shopify products JSON on both configured collection routes.
- Do not weaken exact-model matching. Verify the final redirect and locale-aware collection API route before changing source configuration or fetch logic.

## Next actions
1. PR #337 is already merged to production; verify the Research PC installation through the approved updater process before another acceptance task.
2. Update the Research PC in place using the existing production updater; preserve private `.env`, credentials, service.json and specialist config.
3. Run a bounded Anycubic Kobra 3 Max V2 acceptance task and confirm direct page capture and separate standard/Combo prices.
4. Investigate and correct Creality's official URL redirect and collection API route; run a bounded Ender-3 V3 KE task.
5. Keep all other categories paused until these checks pass. Then replicate the proven 3D-printer process one category at a time.

## 9 November 2026 — 21:31 UTC LIVE follow-up (3D-printers only)

- Production is `6c305f145b8fa18c1b827e152d28013387c933d1`. PR #337 merged at 20:56:51 UTC; merge commit is the current production HEAD. GitHub Actions run #42697121803 passed 103/103 tests. The earlier statement that PR #337 was open/unmerged is superseded.
- LIVE exact category/branch task query: 27 registered task rows, all completed; 69 product subtasks. Latest grouped task `owner-3d-printers-equipment-1794259145802` completed at 21:21:16 UTC under worker `DESKTOP-LVASEUB-129576`; no active task remains.
- Latest five-subtask batch totals: 18 search results, 3 exact product pages discovered, 2 successful HTTP page fetches, 1 post-fetch model/package rejection, 1 page accepted for capture, 1 raw capture retained and staged, 1 Gemma batch failure, 70 approved-source route attempts (16 found, 49 empty, 5 failed), zero collection errors and zero HTTP page-fetch errors. The legacy inspected_product_pages counter reported 1 because it counts only pages accepted after validation. Sum of the five per-product runtimes was 115.3 seconds; this is not wall-clock batch duration.
- Anycubic Kobra 3 Max V2 / Standard: 9 search results; 1 page discovered; the page fetch succeeded in 856 ms, then the exact-model guard rejected it. Existing summary metrics reported 0 inspected pages because that field counts only pages accepted after validation. The official page title is the exact model plus the feature wording “Full-Metal Hotend”; current production after PR #337 accepts that title. The runtime result is therefore consistent with the Research PC still using the pre-#337 matcher. The worker event does not record an installed source commit SHA, so this is a strong inference, not a verified local version hash.
- Anycubic Kobra 4 / Standard: 9 search results; 2 pages discovered; 1 page fetched and retained. Gemma's one 3D-printer batch timed out at 45.4 seconds; the full 12,909-character page was staged as `needs_research`. Queue price and `evidence_type` remain null because the page contains multiple package/price options; ChatGPT must allocate the correct option before any later owner review.
- The other three Combo subtasks returned zero search results. Each probed 14 approved-source routes: 13 empty and one eBay UK HTTP 403. Across the batch there were five eBay 403 errors.
- LIVE review queue: 67 rows (28 imported, 37 rejected, 2 `needs_research`). The two open rows are Bambu Lab A1 / 3D Prima (`uk_new`, £215 GBP, New, in stock 50+) and Anycubic Kobra 4 / Standard (raw capture only; no price/type classification). Active shared evidence remains 239 UK-new and 21 UK-used; 17 UK-new rows are inactive. No shared-market-evidence rows were created after 20:00 UTC.
- Worker status is idle with no current task. Category heartbeat: 21:21:16 UTC; generic worker heartbeat: 21:17:16 UTC. The generic idle heartbeat remains stale because production only refreshes it during active processing; PR #331 remains open and unmerged.
- PR #338 adds explicit 3D-printer page-flow telemetry to distinguish fetch attempts, successful HTTP fetches, pre-fetch model/package skips, post-fetch model/package rejections and pages eligible for capture. It does not change search, source selection, model matching, extraction, queue or evidence behaviour. Regression test reproduces the observed 1 discovered / 1 successfully fetched / 1 post-fetch rejection / 0 eligible case. PR #338 is open; CI result must be checked before review.
- The approved production updater validates both existing LIVE and TEST project URLs, backs up installed source, runs syntax/tests before and after installation, and does not edit the private `.env` or specialist `config.json`. Do not run it, restart the Research PC or queue an acceptance task without explicit owner approval.
- No task was queued, no worker was restarted, no source row or migration was changed, no evidence was approved/imported, and no TEST/LIVE data was copied. No secrets or private configuration were accessed.

## 9 November 2026 — 21:43 UTC ChatGPT review enrichment (LIVE queue only)

- Reviewed LIVE queue row `5c951409-c951-4f35-be87-884eba7968cc` for Anycubic Kobra 4 / Standard Printer against the direct official Anycubic UK product page.
- The official page identifies the Standard Kobra 4 option at **£159.00 GBP**, states GB VAT is included and says the Kobra 4 ships in 24 hours. The separate Kobra 4 Combo (4 colors) option is **£259.00** and was explicitly excluded from the Standard Printer price.
- The queue row was enriched with `evidence_type=uk_new`, `observed_price=159.00`, `price_currency=GBP`, `item_condition=New` and package-specific availability/research notes. The original 12,909-character source capture remains intact.
- The row remains `needs_research`. `reviewed_by`, `reviewed_at`, `approved_at` and `imported_at` remain null. No owner approval, catalogue import or `shared_market_evidence` write occurred.
- The other open row, Bambu Lab A1 / 3D Prima, remains `uk_new` at £215.00 GBP and `needs_research`; it is a refreshed stock observation against an existing same-URL £215 active evidence record.
- The review queue remains 67 rows: 28 imported, 37 rejected, 2 pending. No used-market capture was added in this batch.
