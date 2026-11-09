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
- GitHub Actions run #42697121803 passed 103/103 tests. PR is open, mergeable, unmerged and not deployed.

## Remaining fault
- Creality official Ender-3 V3 KE URL redirected from the Research PC to SparkX i7; the exact-model guard correctly rejected the unrelated page.
- Creality collection discovery returned HTTP 404 for Shopify products JSON on both configured collection routes.
- Do not weaken exact-model matching. Verify the final redirect and locale-aware collection API route before changing source configuration or fetch logic.

## Next actions
1. Merge PR #337 only through the approved production review process.
2. Update the Research PC in place using the existing production updater; preserve private `.env`, credentials, service.json and specialist config.
3. Run a bounded Anycubic Kobra 3 Max V2 acceptance task and confirm direct page capture and separate standard/Combo prices.
4. Investigate and correct Creality's official URL redirect and collection API route; run a bounded Ender-3 V3 KE task.
5. Keep all other categories paused until these checks pass. Then replicate the proven 3D-printer process one category at a time.
